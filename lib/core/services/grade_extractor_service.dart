import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service d'extraction de notes utilisant Google Gemini.
/// Ce service combine l'OCR et l'analyse sémantique en une seule étape de façon stricte.
class GradeExtractorService {
  final String _apiKey;
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  GradeExtractorService() : _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  /// Extrait les notes d'un bulletin (image ou PDF) en retournant un JSON.
  Future<Map<String, double>> extractGrades(PlatformFile file, String className) async {
    if (_apiKey.isEmpty || _apiKey == 'VOTRE_CLE_ICI') {
      throw Exception('Clé API Gemini non configurée. Veuillez l\'ajouter dans le fichier .env');
    }

    if (file.bytes == null) {
      throw Exception('Les données du fichier sont vides.');
    }

    final String mimeType = _getMimeType(file.extension ?? '');
    final String base64Content = base64Encode(file.bytes!);

    final prompt = '''Tu es un expert en analyse de bulletins scolaires camerounais.
Analyse ce document (classe: $className) et extrais les moyennes de l'élève par matière.

INSTRUCTIONS CRITIQUES DE NORMALISATION :
1. Les notes doivent être TOUJOURS sur 20.
2. Si une note est sur un total différent (ex: 76/80, 15/40, 9/10), tu DOIS la convertir sur 20.
   - Exemple : 76/80 équivaut à (76 ÷ 80) × 20 = 19.0/20.
   - Exemple : 15/40 équivaut à (15 ÷ 40) × 20 = 7.5/20.
3. Identifie les matières et leurs moyennes après conversion.

INSTRUCTIONS GÉNÉRALES :
4. Utilise les noms de matières standard (Mathématiques, Français, Anglais, Physique, Chimie, SVT, Histoire-Géographie, Philosophie, Informatique, EPS).
5. Si une matière n'est pas dans la liste mais est présente, ajoute-la.
6. Ignore les coefficients et les appréciations.
7. Si une moyenne n'est pas claire ou est absente, ne l'inclus pas.
''';

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt},
                {
                  "inlineData": {
                    "mimeType": mimeType,
                    "data": base64Content
                  }
                }
              ]
            }
          ],
          "generationConfig": {
            "temperature": 0.1, // Température basse pour plus de précision
            "responseMimeType": "application/json",
            // Le Schema force l'IA à renvoyer une liste stricte, impossible d'avoir des erreurs de syntaxe
            "responseSchema": {
              "type": "ARRAY",
              "items": {
                "type": "OBJECT",
                "properties": {
                  "matiere": {
                    "type": "STRING",
                    "description": "Le nom de la matière"
                  },
                  "moyenne": {
                    "type": "NUMBER",
                    "description": "La note moyenne de l'élève sur 20"
                  }
                },
                "required": ["matiere", "moyenne"]
              }
            }
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String textResponse = data['candidates'][0]['content']['parts'][0]['text'];
        
        // Décodage direct : grâce au responseSchema, textResponse sera TOUJOURS un tableau JSON valide
        final List<dynamic> decodedList = jsonDecode(textResponse);
        
        // Reconstruction de votre Map<String, double> d'origine pour ne pas casser le reste de votre application
        final Map<String, double> grades = {};
        for (var item in decodedList) {
          if (item['matiere'] != null && item['moyenne'] != null) {
            final key = item['matiere'].toString().trim();
            final value = item['moyenne'];
            if (value is num) {
              grades[key] = value.toDouble();
            }
          }
        }
        
        debugPrint('Gemini: ${grades.length} matières extraites pour $className');
        return grades;
      } else {
        final error = jsonDecode(response.body);
        throw Exception('Erreur Gemini (${response.statusCode}): ${error['error']?['message'] ?? 'Inconnue'}');
      }
    } catch (e) {
      debugPrint('GradeExtractorService.extractGrades: $e');
      rethrow;
    }
  }

  String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf': return 'application/pdf';
      case 'jpg':
      case 'jpeg': return 'image/jpeg';
      case 'png': return 'image/png';
      case 'webp': return 'image/webp';
      case 'heic': return 'image/heic';
      case 'heif': return 'image/heif';
      default: 
        throw FormatException('Format de fichier non supporté : .$extension. Veuillez utiliser PDF, JPG, PNG, WEBP ou HEIC.');
    }
  }
}