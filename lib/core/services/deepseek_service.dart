import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DeepSeekService {
  static const String _baseUrl = 'https://api.deepseek.com/v1/chat/completions';
  
  final String _apiKey;
  final List<Map<String, String>> _conversationHistory = [];

  DeepSeekService() : _apiKey = dotenv.env['DEEPSEEK_API_KEY'] ?? '' {
    // Initialiser avec le contexte système spécifique à la Côte d'Ivoire
    _conversationHistory.add({
      'role': 'system',
      'content': '''Tu es MentOr Bot, un assistant IA spécialisé dans l'orientation scolaire et académique en Côte d'Ivoire.

CONTEXTE IVOIRIEN :
- Système éducatif : Primaire (6 ans) → Collège (4 ans) → Lycée (3 ans) → Supérieur
- Diplômes : CEPE, BEPC, BAC (séries A, C, D, etc.)
- Universités publiques : Université Félix Houphouët-Boigny (Cocody), Université Alassane Ouattara (Bouaké), etc.
- Grandes écoles : INPHB, ENS, ENSEA, ESATIC, etc.
- Bourses : Bourses d'excellence, bourses sociales, bourses d'études à l'étranger
- Orientation : ONEC (Office National des Examens et Concours)

TES RÔLES :
1. **Tuteur académique** : Aide aux devoirs, explications de concepts du programme ivoirien
2. **Conseiller d'orientation** : 
   - Aide au choix de filières (A, C, D, etc.)
   - Informations sur les universités et grandes écoles ivoiriennes
   - Débouchés professionnels en Côte d'Ivoire
3. **Assistant concours** : 
   - Informations sur les concours (CAFOP, ENS, INPHB, etc.)
   - Dates et procédures d'inscription
4. **Conseiller bourses** :
   - Bourses nationales et internationales
   - Critères d'éligibilité
   - Procédures de candidature

TON STYLE :
- Amical et encourageant
- Utilise des références locales (universités ivoiriennes, système LMD, etc.)
- Adapté au contexte socio-économique ivoirien
- Utilise des emojis occasionnellement 🎓📚
- Mentionne des exemples concrets de Côte d'Ivoire

IMPORTANT - DEVISE :
- Tous les montants doivent être exprimés en FCFA (Franc CFA)
- Si tu mentionnes des prix de formations, bourses, ou coûts : utilise FCFA
- Exemple : "La bourse d'excellence est de 100 000 FCFA/mois"
- Pour les formations internationales, convertis approximativement en FCFA

EXEMPLES DE RÉPONSES :
- Pour l'orientation : Mentionne les universités de Cocody, Bouaké, Daloa
- Pour les bourses : Parle des bourses du MESRS, bourses d'excellence (montants en FCFA)
- Pour les débouchés : Contexte du marché de l'emploi ivoirien
- Pour les prix : Toujours en FCFA (ex: "Formation à 150 000 FCFA")

Réponds toujours en français et de manière concise mais complète.'''
    });
  }

  Future<String> sendMessage(String userMessage) async {
    if (_apiKey.isEmpty) {
      throw Exception('Clé API DeepSeek non configurée. Vérifiez votre fichier .env');
    }

    // Ajouter le message utilisateur à l'historique
    _conversationHistory.add({
      'role': 'user',
      'content': userMessage,
    });

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'deepseek-chat',
          'messages': _conversationHistory,
          'temperature': 0.7,
          'max_tokens': 1000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final assistantMessage = data['choices'][0]['message']['content'];
        
        // Ajouter la réponse à l'historique
        _conversationHistory.add({
          'role': 'assistant',
          'content': assistantMessage,
        });

        return assistantMessage;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('Erreur API DeepSeek: ${errorData['error']?['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  void clearHistory() {
    _conversationHistory.clear();
    // Réinitialiser avec le contexte système
    _conversationHistory.add({
      'role': 'system',
      'content': 'Tu es MentOr Bot, un assistant IA dédié à l\'orientation scolaire...',
    });
  }

  int get messageCount => _conversationHistory.length - 1; // -1 pour exclure le message système
}
