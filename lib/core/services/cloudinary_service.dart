import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';

class CloudinaryService {
  // Configuration Cloudinary - À personnaliser par l'utilisateur
  static const String _cloudName = "dmil2rzl9"; // Remplacer par votre Cloud Name
  static const String _uploadPreset = "mentor"; // Remplacer par votre Unsigned Upload Preset
  //757143457645561:clé API
  //YZReHPcoiaZ2bZINxxvnegNEKO8:clé secrète
  //nom dossier
  static const String _baseUrl = "https://api.cloudinary.com/v1_1/$_cloudName";

  /// Téléverse un fichier vers Cloudinary
  Future<Map<String, dynamic>?> uploadFile(PlatformFile file) async {
    try {
      final url = Uri.parse("$_baseUrl/raw/upload"); // "raw" pour PDF/DOC, "image" pour PNG/JPG
      
      var request = http.MultipartRequest("POST", url);
      
      // Configuration de l'upload unsigned
      request.fields['upload_preset'] = _uploadPreset;
      
      // Ajout du fichier
      if (kIsWeb) {
        if (file.bytes == null) throw Exception("Fichier vide (Web)");
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          file.bytes!,
          filename: file.name,
        ));
      } else {
        if (file.path == null) throw Exception("Chemin du fichier manquant");
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          file.path!,
        ));
      }

      // Envoi de la requête
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error']?['message'] ?? "Erreur inconnue";
        debugPrint("Erreur Cloudinary: $errorMessage");
        throw Exception("$errorMessage (${response.statusCode})");
      }
    } catch (e) {
      debugPrint("CloudinaryService.uploadFile: $e");
      rethrow;
    }
  }
}
