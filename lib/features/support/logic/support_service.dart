import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/academic_need.dart';

class SupportService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _needsCollection = _firestore.collection('academic_needs');

  // Create
  static Future<void> addNeed(AcademicNeed need) async {
    try {
      await _needsCollection.add(need.toMap());
    } catch (e) {
      throw Exception("Erreur lors de l'ajout du besoin: $e");
    }
  }

  // Read (Stream)
  static Stream<List<AcademicNeed>> getNeedsStream() {
    return _needsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AcademicNeed.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}
