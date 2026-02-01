import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Téléverse un fichier brut (Uint8List) utile pour le Web
  Future<String> uploadFileBytes(String path, Uint8List bytes, String fileName) async {
    try {
      final ref = _storage.ref().child(path).child(fileName);
      final uploadTask = ref.putData(bytes);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint("Erreur StorageService.uploadFileBytes: $e");
      rethrow;
    }
  }

  /// Téléverse un fichier depuis un chemin (Path) utile pour Mobile/Desktop
  Future<String> uploadFile(String path, File file) async {
    try {
      final fileName = file.path.split('/').last;
      final ref = _storage.ref().child(path).child(fileName);
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint("Erreur StorageService.uploadFile: $e");
      rethrow;
    }
  }
}
