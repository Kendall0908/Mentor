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
  static const int maxFavorites = 2;

  /// Returns true if operation succeeded, false if limit was reached (when adding).
  Future<bool> toggleFavorite(String uid, String programId) async {
    final docRef = _firestore.collection('users').doc(uid);
    final doc = await docRef.get();
    
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      final favorites = List<String>.from(data['favorites'] ?? []);
      
      if (favorites.contains(programId)) {
        // Removing — always allowed
        favorites.remove(programId);
        await docRef.update({'favorites': favorites});
        return true;
      } else {
        // Adding — check limit
        if (favorites.length >= maxFavorites) {
          return false; // Limit reached
        }
        favorites.add(programId);
        await docRef.update({'favorites': favorites});
        return true;
      }
    } else {
       await docRef.set({'favorites': [programId]}, SetOptions(merge: true));
       return true;
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

  // 📝 MÉTADONNÉES DES FAVORIS (POUR ROADMAP IA)
  Future<void> saveFavoriteMetadata(String uid, Map<String, dynamic> programMetadata) async {
    final programId = programMetadata['id'];
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('favorite_details')
        .doc(programId)
        .set({
      ...programMetadata,
      'addedAt': FieldValue.serverTimestamp(),
      // 'roadmap' sera ajouté plus tard par l'IA lors du premier affichage
    }, SetOptions(merge: true));
  }

  Future<void> deleteFavoriteMetadata(String uid, String programId) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('favorite_details')
        .doc(programId)
        .delete();
  }

  Stream<List<Map<String, dynamic>>> getFavoriteDetails(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('favorite_details')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // 🤖 SUGGESTIONS IA EN CACHE
  Future<void> saveAICareersSuggestions(String uid, List<Map<String, dynamic>> careers, List<String> sourceFavorites) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('ai_suggestions')
        .doc('careers')
        .set({
      'careers': careers,
      'sourceFavorites': sourceFavorites,
      'generatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>?> getAICareersSuggestions(String uid) async {
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('ai_suggestions')
        .doc('careers')
        .get();
    
    return doc.data();
  }

  // 🔄 STREAM DE L'UTILISATEUR ACTUEL
  Stream<User?> get userStream => _auth.authStateChanges();

  // 🚪 DÉCONNEXION
  Future<void> logout() async {
    await _auth.signOut();
  }
}
