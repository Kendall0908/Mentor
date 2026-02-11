import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  // 🔐 INSCRIPTION + ENREGISTREMENT FIRESTORE
  Future<User?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    // 1️⃣ Création du compte Auth
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;

    if (user != null) {
      // 2️⃣ Enregistrement Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'email': email,
        'grade': 'Étudiant', // Default value
        'school': 'Non spécifié', // Default value
        'avatarUrl': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&h=200&fit=crop&q=80', // Default stable avatar (Portrait)
        'bio': '',
        'location': '',
        'progress': 0.1, // Initial progress
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return user;
  }

  // 🔑 CONNEXION
  Future<User?> login(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  // 📄 RÉCUPÉRER LES DONNÉES UTILISATEUR
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }

  // 📝 METTRE À JOUR LES DONNÉES UTILISATEUR
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  Future<void> addDocument(String uid, String documentUrl) async {
    await _firestore.collection('users').doc(uid).update({
      'documents': FieldValue.arrayUnion([documentUrl])
    });
  }

  Future<void> addDocumentMetadata(String uid, Map<String, dynamic> metadata) async {
    await _firestore.collection('users').doc(uid).update({
      'documents_detailed': FieldValue.arrayUnion([
        {
          ...metadata,
          'uploadDate': DateTime.now().toIso8601String(),
        }
      ]),
      // On garde aussi l'ancien champ pour la compatibilité si besoin
      'documents': FieldValue.arrayUnion([metadata['cloudinaryUrl']])
    });
  }

  Future<void> saveOrientationResults(String uid, Map<String, dynamic> results) async {
    await _firestore.collection('users').doc(uid).update({
      'orientationResults': results
    });
  }

  Future<void> addCustomCareer(String uid, Map<String, dynamic> career) async {
    await _firestore.collection('users').doc(uid).update({
      'custom_careers': FieldValue.arrayUnion([career])
    });
  }

  // 💾 SAUVEGARDER UN CHOIX D'ORIENTATION
  Future<void> saveUserChoice(String uid, Map<String, dynamic> choiceData) async {
    await _firestore.collection('users').doc(uid).collection('choices').add({
      ...choiceData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ❤️ GESTION DES FAVORIS
  Future<void> toggleFavorite(String uid, String programId) async {
    final docRef = _firestore.collection('users').doc(uid);
    final doc = await docRef.get();
    
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      final favorites = List<String>.from(data['favorites'] ?? []);
      
      if (favorites.contains(programId)) {
        favorites.remove(programId);
      } else {
        favorites.add(programId);
      }
      
      await docRef.update({'favorites': favorites});
    } else {
       // Create doc if not exists (should not happen for logged user but good for safety)
       await docRef.set({'favorites': [programId]}, SetOptions(merge: true));
    }
  }

  Stream<List<String>> getFavorites(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return List<String>.from(snapshot.data()!['favorites'] ?? []);
      }
      return [];
    });
  }

  // 🔄 STREAM DE L'UTILISATEUR ACTUEL
  Stream<User?> get userStream => _auth.authStateChanges();

  // 🚪 DÉCONNEXION
  Future<void> logout() async {
    await _auth.signOut();
  }
}
