import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/services/ecoles_data_service.dart';
import '../../../../core/models/ecole_model.dart';
import '../../flieres/data/program_data.dart';

class AIRecommendationService {
  static final AIRecommendationService _instance = AIRecommendationService._internal();
  factory AIRecommendationService() => _instance;
  AIRecommendationService._internal();

  final String _apiKey = dotenv.env['DEEPSEEK_API_KEY'] ?? '';
  final String _baseUrl = 'https://api.deepseek.com/v1/chat/completions';
  final EcolesDataService _ecolesService = EcolesDataService();

  /// Analyse le profil utilisateur et génère des recommandations
  Future<List<ProgramRecommendation>> generateRecommendations({
    required List<String> passions,
    required Map<String, double> skills,
    required List<String> environmentRanking,
  }) async {
    // Charger les données des écoles si nécessaire
    await _ecolesService.loadEcoles();
    
    try {
      // 1. Calculer les scores locaux pour chaque filière
      final localScores = _calculateLocalScores(passions, skills, environmentRanking);

      // 2. Obtenir l'analyse IA pour affiner les recommandations
      final aiAnalysis = await _getAIAnalysis(passions, skills, environmentRanking);

      // 3. Combiner les scores locaux avec l'analyse IA
      final recommendations = _combineScoresWithAI(localScores, aiAnalysis);

      // 4. Trier par score décroissant
      recommendations.sort((a, b) => b.matchPercentage.compareTo(a.matchPercentage));

      final finalRecommendations = recommendations.take(5).toList(); // Top 5 recommandations
      
      // 5. Enrichir avec les vraies écoles
      _enrichWithRealSchools(finalRecommendations);
      
      return finalRecommendations;
    } catch (e) {
      debugPrint('Erreur génération recommandations: $e');
      // Fallback: retourner uniquement les scores locaux
      return _calculateLocalScores(passions, skills, environmentRanking)
          .take(5)
          .toList();
    }
  }

  /// Calcule les scores de compatibilité localement
  List<ProgramRecommendation> _calculateLocalScores(
    List<String> passions,
    Map<String, double> skills,
    List<String> environmentRanking,
  ) {
    final recommendations = <ProgramRecommendation>[];

    for (final program in allPrograms) {
      double score = 0.0;

      // Score basé sur les passions (40%)
      final passionScore = _calculatePassionScore(passions, program.relatedPassions);
      score += passionScore * 0.4;

      // Score basé sur les compétences (35%)
      final skillScore = _calculateSkillScore(skills, program.requiredSkills);
      score += skillScore * 0.35;

      // Score basé sur l'environnement (25%)
      final envScore = _calculateEnvironmentScore(environmentRanking, program.workEnvironments);
      score += envScore * 0.25;

      final percentage = (score * 100).round().clamp(0, 100);

      recommendations.add(ProgramRecommendation(
        programData: program,
        matchPercentage: percentage,
        matchReason: _generateMatchReason(passionScore, skillScore, envScore),
      ));
    }

    recommendations.sort((a, b) => b.matchPercentage.compareTo(a.matchPercentage));
    return recommendations;
  }

  /// Calcule le score de compatibilité des passions
  double _calculatePassionScore(List<String> userPassions, List<String> programPassions) {
    if (userPassions.isEmpty || programPassions.isEmpty) return 0.0;

    int matches = 0;
    for (final passion in userPassions) {
      if (programPassions.any((p) => p.toLowerCase().contains(passion.toLowerCase()) || 
                                      passion.toLowerCase().contains(p.toLowerCase()))) {
        matches++;
      }
    }

    return matches / userPassions.length;
  }

  /// Calcule le score de compatibilité des compétences
  double _calculateSkillScore(Map<String, double> userSkills, Map<String, double> programSkills) {
    if (userSkills.isEmpty || programSkills.isEmpty) return 0.5;

    double totalScore = 0.0;
    int count = 0;

    programSkills.forEach((skill, requiredLevel) {
      if (userSkills.containsKey(skill)) {
        final userLevel = userSkills[skill]!;
        // Plus le niveau utilisateur est proche du niveau requis, meilleur le score
        final diff = (userLevel - requiredLevel).abs();
        final skillScore = 1.0 - (diff / 3.0); // Normaliser sur 3 (max diff)
        totalScore += skillScore.clamp(0.0, 1.0);
        count++;
      }
    });

    return count > 0 ? totalScore / count : 0.5;
  }

  /// Calcule le score de compatibilité de l'environnement
  double _calculateEnvironmentScore(List<String> userRanking, List<String> programEnvs) {
    if (userRanking.isEmpty || programEnvs.isEmpty) return 0.5;

    double score = 0.0;
    
    for (int i = 0; i < userRanking.length; i++) {
      final userEnv = userRanking[i];
      if (programEnvs.any((env) => env.toLowerCase().contains(userEnv.toLowerCase()) ||
                                    userEnv.toLowerCase().contains(env.toLowerCase()))) {
        // Plus l'environnement est haut dans le classement, plus le score est élevé
        score += (userRanking.length - i) / userRanking.length;
      }
    }

    return (score / programEnvs.length).clamp(0.0, 1.0);
  }

  /// Génère une raison de compatibilité
  String _generateMatchReason(double passionScore, double skillScore, double envScore) {
    final scores = [
      ('vos passions', passionScore),
      ('vos compétences', skillScore),
      ('votre environnement idéal', envScore),
    ];
    
    scores.sort((a, b) => b.$2.compareTo(a.$2));
    
    if (scores[0].$2 > 0.7) {
      return 'Excellente correspondance avec ${scores[0].$1}';
    } else if (scores[0].$2 > 0.5) {
      return 'Bonne correspondance avec ${scores[0].$1}';
    } else {
      return 'Correspondance modérée avec votre profil';
    }
  }

  /// Obtient l'analyse IA via DeepSeek
  Future<Map<String, dynamic>> _getAIAnalysis(
    List<String> passions,
    Map<String, double> skills,
    List<String> environmentRanking,
  ) async {
    if (_apiKey.isEmpty) {
      debugPrint('API Key manquante');
      return {};
    }

    try {
      final prompt = _buildPrompt(passions, skills, environmentRanking);

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'deepseek-chat',
          'messages': [
            {
              'role': 'system',
              'content': 'Tu es un conseiller d\'orientation expert qui analyse les profils d\'étudiants pour recommander des filières adaptées.'
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'temperature': 0.7,
          'max_tokens': 1000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return _parseAIResponse(content);
      } else {
        debugPrint('Erreur API: ${response.statusCode} - ${response.body}');
        return {};
      }
    } catch (e) {
      debugPrint('Erreur appel IA: $e');
      return {};
    }
  }

  /// Construit le prompt pour l'IA
  String _buildPrompt(
    List<String> passions,
    Map<String, double> skills,
    List<String> environmentRanking,
  ) {
    final skillsText = skills.entries.map((e) {
      final val = e.value.toInt();
      String level = 'Débutant';
      if (val >= 10) level = 'Expert';
      else if (val >= 8) level = 'Très Avancé';
      else if (val >= 6) level = 'Avancé';
      else if (val >= 4) level = 'Intermédiaire';
      else if (val >= 2) level = 'Élémentaire';
      
      return '${e.key}: $level ($val/10)';
    }).join(', ');

    return '''
Analyse ce profil d'étudiant et suggère les 5 meilleures filières :

PASSIONS: ${passions.join(', ')}
COMPÉTENCES: $skillsText
ENVIRONNEMENT PRÉFÉRÉ: ${environmentRanking.first}

Réponds au format JSON strict suivant (sans texte supplémentaire) :
{
  "recommendations": [
    {
      "program": "Nom de la filière",
      "score_boost": 5,
      "reason": "Raison courte"
    }
  ]
}

Filières disponibles: Ingénierie Logicielle, Design UX/UI, Marketing Digital, Commerce International, Architecture, Médecine, Droit, Journalisme, Comptabilité, Enseignement
''';
  }

  /// Parse la réponse de l'IA
  Map<String, dynamic> _parseAIResponse(String content) {
    try {
      // Extraire le JSON de la réponse
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
      if (jsonMatch != null) {
        return jsonDecode(jsonMatch.group(0)!);
      }
      return {};
    } catch (e) {
      debugPrint('Erreur parsing IA: $e');
      return {};
    }
  }

  /// Combine les scores locaux avec l'analyse IA
  List<ProgramRecommendation> _combineScoresWithAI(
    List<ProgramRecommendation> localScores,
    Map<String, dynamic> aiAnalysis,
  ) {
    if (aiAnalysis.isEmpty || !aiAnalysis.containsKey('recommendations')) {
      return localScores;
    }

    final aiRecs = aiAnalysis['recommendations'] as List;
    
    for (final rec in localScores) {
      // Chercher si l'IA a boosté cette filière
      final aiBoost = aiRecs.firstWhere(
        (ai) => rec.programData.name.toLowerCase().contains(
          (ai['program'] as String).toLowerCase()
        ),
        orElse: () => null,
      );

      if (aiBoost != null) {
        final boost = (aiBoost['score_boost'] as num).toInt();
        rec.matchPercentage = (rec.matchPercentage + boost).clamp(0, 100);
        rec.matchReason = aiBoost['reason'] ?? rec.matchReason;
      }
    }

    return localScores;
  }


  /// Enrichit les recommandations avec les vraies écoles
  void _enrichWithRealSchools(List<ProgramRecommendation> recommendations) {
    for (final rec in recommendations) {
      final filiereKey = _mapProgramToFiliereKey(rec.programData.name);
      if (filiereKey.isNotEmpty) {
        final schools = _ecolesService.getEcolesByFiliere(filiereKey);
        // On modifie la liste availableSchools de l'objet ProgramData existant
        // Attention : ProgramData est immuable normalement, mais availableSchools est une liste
        // Idéalement on devrait cloner l'objet, mais pour l'instant on va tricher un peu
        // en utilisant addAll si la liste est modifiable, ou en remplaçant la référence si on pouvait.
        
        // Comme availableSchools est final et const [], on ne peut pas le modifier direct.
        // On doit créer une copie de ProgramData avec les nouvelles écoles
        // Mais ProgramRecommendation pointe vers ProgramData.
        
        // Pour simplifier cette étape sans refaire toute l'architecture :
        // On va modifier ProgramData pour que availableSchools ne soit pas const par défaut ou soit mutable
        // OU on crée une nouvelle instance de ProgramData ici.
        
        // Option choisie : Remplacer l'instance ProgramData dans la recommandation
        final enrichedProgram = ProgramData(
          id: rec.programData.id,
          name: rec.programData.name,
          imageUrl: rec.programData.imageUrl,
          isTrending: rec.programData.isTrending,
          duration: rec.programData.duration,
          durationType: rec.programData.durationType,
          demand: rec.programData.demand,
          salaryMin: rec.programData.salaryMin,
          salaryMax: rec.programData.salaryMax,
          matchPercentage: rec.programData.matchPercentage,
          matchDescription: rec.programData.matchDescription,
          skills: rec.programData.skills,
          schools: rec.programData.schools, // On garde les écoles fictives pour l'UI actuel
          availableSchools: schools, // On ajoute les vraies écoles
          relatedPassions: rec.programData.relatedPassions,
          requiredSkills: rec.programData.requiredSkills,
          workEnvironments: rec.programData.workEnvironments,
          category: rec.programData.category,
        );
        
        // On remplace le programData dans la recommandation
        // Note: ProgramRecommendation.programData est final... ah.
        // Je dois modifier ProgramRecommendation pour que programData ne soit pas final ? Non, c'est sale.
        // Je vais plutôt créer une nouvelle recommandation.
        // Mais je ne peux pas remplacer l'élément dans la boucle facilement.
        
        // Solution plus propre : Modifier ProgramRecommendation pour accepter une liste d'écoles additionnelle
        // Ou... on a ajouté availableSchools dans ProgramData mais il est final.
        // Bon, on va utiliser une astuce :
        // On va tricher sur le champ availableSchools de ProgramData pour qu'il ne soit pas final (ou utiliser une méthode setter si possible)
        // Mais en Dart 'final' est strict.
        
        // On va recréer l'objet ProgramRecommendation avec le nouveau ProgramData
        // Mais on ne peut pas modifier la liste 'recommendations' pendant qu'on l'itère ? Si, avec un for indexé.
      }
    }
    
    // Deuxième passe pour remplacer les objets
    for (int i = 0; i < recommendations.length; i++) {
      final rec = recommendations[i];
      final filiereKey = _mapProgramToFiliereKey(rec.programData.name);
      
      if (filiereKey.isNotEmpty) {
        final schools = _ecolesService.getEcolesByFiliere(filiereKey);
        
        if (schools.isNotEmpty) {
          final enrichedProgram = ProgramData(
            id: rec.programData.id,
            name: rec.programData.name,
            imageUrl: rec.programData.imageUrl,
            isTrending: rec.programData.isTrending,
            duration: rec.programData.duration,
            durationType: rec.programData.durationType,
            demand: rec.programData.demand,
            salaryMin: rec.programData.salaryMin,
            salaryMax: rec.programData.salaryMax,
            matchPercentage: rec.programData.matchPercentage,
            matchDescription: rec.programData.matchDescription,
            skills: rec.programData.skills,
            schools: rec.programData.schools,
            availableSchools: schools, // Injecter les écoles ici
            relatedPassions: rec.programData.relatedPassions,
            requiredSkills: rec.programData.requiredSkills,
            workEnvironments: rec.programData.workEnvironments,
            category: rec.programData.category,
          );
          
          // Remplacer l'instance dans la liste (nécessite que ProgramRecommendation soit mutable ou qu'on remplace l'entrée)
          // ProgramRecommendation a programData final.
          // On doit créer une nouvelle instance de ProgramRecommendation.
          recommendations[i] = ProgramRecommendation(
            programData: enrichedProgram, 
            matchPercentage: rec.matchPercentage,
            matchReason: rec.matchReason
          );
        }
      }
    }
  }

  /// Mappe le nom du programme générique vers un code/mot-clé de filière BTS
  String _mapProgramToFiliereKey(String programName) {
    final lowerName = programName.toLowerCase();
    
    if (lowerName.contains('logiciel') || lowerName.contains('informatique') || lowerName.contains('web')) {
      return 'IDA'; // Informatique Développeur d'Application
    } else if (lowerName.contains('comptabil') || lowerName.contains('finance') || lowerName.contains('gestion')) {
      return 'FCGE'; // Finances Comptabilité
    } else if (lowerName.contains('commerce') || lowerName.contains('marketing') || lowerName.contains('vente')) {
      return 'GEC'; // Gestion Commerciale
    } else if (lowerName.contains('communication') || lowerName.contains('digital')) {
      return 'COM'; // Communication
    } else if (lowerName.contains('ressources humaines') || lowerName.contains('rh')) {
      return 'GRH'; // Gestion des Ressources Humaines
    } else if (lowerName.contains('transport') || lowerName.contains('logistique')) {
      return 'L'; // Logistique
    } else if (lowerName.contains('électron') || lowerName.contains('réseau')) {
      return 'RIT'; // Réseaux Informatiques et Télécoms
    } else if (lowerName.contains('agriculture') || lowerName.contains('agronomie')) {
      return 'ATV'; // Agriculture
    }
    
    // Fallback : recherche par mot clé
    return programName.split(' ').first; 
  }
}

/// Modèle de recommandation
class ProgramRecommendation {
  final ProgramData programData;
  int matchPercentage;
  String matchReason;

  ProgramRecommendation({
    required this.programData,
    required this.matchPercentage,
    required this.matchReason,
  });
}
