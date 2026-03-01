import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/ecole_model.dart';
import 'package:flutter/foundation.dart';

class EcolesDataService {
  static final EcolesDataService _instance = EcolesDataService._internal();
  factory EcolesDataService() => _instance;
  EcolesDataService._internal();

  List<EcoleModel> _allEcoles = [];
  bool _isLoaded = false;
  
  // URL Cloudinary du fichier JSON
  static const String _dataUrl = "https://res.cloudinary.com/dmil2rzl9/raw/upload/ecoles_data_v1.json";
  static const String _fileName = "ecoles_data.json";

  /// Charge les données des écoles (Cache -> Cloud)
  Future<void> loadEcoles() async {
    if (_isLoaded) return;

    try {
      if (kIsWeb) {
        // Le web ne supporte pas File() et path_provider de la même manière
        debugPrint("🌐 Exécution sur le Web : téléchargement direct sans cache fichier...");
        final response = await http.get(Uri.parse(_dataUrl));
        if (response.statusCode == 200) {
          final List<dynamic> jsonList = json.decode(response.body);
          _allEcoles = jsonList.map((json) => EcoleModel.fromJson(json)).toList();
          _isLoaded = true;
          debugPrint("✅ Données téléchargées pour le web !");
        } else {
          debugPrint("❌ Erreur téléchargement web: ${response.statusCode}");
        }
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$_fileName');

        // 1. Essayer de charger depuis le cache local (Mobile/Desktop)
        if (await file.exists()) {
          debugPrint("📂 Chargement depuis le cache local...");
          final jsonString = await file.readAsString();
          final List<dynamic> jsonList = json.decode(jsonString);
          _allEcoles = jsonList.map((json) => EcoleModel.fromJson(json)).toList();
          _isLoaded = true;
          
          // En arrière-plan, vérifier si une mise à jour est dispo
          _downloadAndCache(file); 
        } else {
          // 2. Si pas de cache, télécharger
          debugPrint("☁️ Aucun cache trouvé, téléchargement depuis Cloudinary...");
          await _downloadAndCache(file);
          
          if (await file.exists()) {
             final jsonString = await file.readAsString();
             final List<dynamic> jsonList = json.decode(jsonString);
             _allEcoles = jsonList.map((json) => EcoleModel.fromJson(json)).toList();
             _isLoaded = true;
          }
        }
      }
    } catch (e) {
      debugPrint("❌ Erreur lors du chargement des écoles : $e");
      _allEcoles = [];
    }
  }

  /// Télécharge le fichier et le met en cache (Mobile/Desktop unique)
  Future<void> _downloadAndCache(File file) async {
    try {
      final response = await http.get(Uri.parse(_dataUrl));
      if (response.statusCode == 200) {
        await file.writeAsString(response.body);
        debugPrint("✅ Données téléchargées et mises en cache !");
      } else {
        debugPrint("❌ Erreur téléchargement: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Erreur réseau: $e");
    }
  }

  /// Récupère toutes les écoles chargées
  List<EcoleModel> getAllEcoles() {
    return List.from(_allEcoles);
  }

  /// Recherche des écoles par filière (ex: "BTS : IDA")
  /// [query] peut être un code (IDA) ou un nom partiel
  List<EcoleModel> getEcolesByFiliere(String query) {
    if (query.isEmpty) return [];
    
    final normalizedQuery = query.toLowerCase();
    
    return _allEcoles.where((ecole) {
      return ecole.filieres.any((filiere) => 
        filiere.toLowerCase().contains(normalizedQuery)
      );
    }).toList();
  }

  /// Recherche des écoles par ville
  List<EcoleModel> getEcolesByVille(String ville) {
    if (ville.isEmpty) return _allEcoles;
    
    return _allEcoles.where((ecole) => 
      ecole.ville.toLowerCase() == ville.toLowerCase()
    ).toList();
  }

  /// Recherche globale (nom, ville, filières)
  List<EcoleModel> searchEcoles(String keyword) {
    if (keyword.isEmpty) return _allEcoles;
    
    final normalizedKeyword = keyword.toLowerCase();
    
    return _allEcoles.where((ecole) {
      return ecole.etablissement.toLowerCase().contains(normalizedKeyword) ||
             ecole.ville.toLowerCase().contains(normalizedKeyword) ||
             ecole.commune.toLowerCase().contains(normalizedKeyword) ||
             ecole.filieres.any((f) => f.toLowerCase().contains(normalizedKeyword));
    }).toList();
  }

  /// Récupère la liste unique des villes disponibles
  List<String> getAvailableVilles() {
    final villes = _allEcoles.map((e) => e.ville).toSet().toList();
    villes.sort();
    return villes;
  }
}
