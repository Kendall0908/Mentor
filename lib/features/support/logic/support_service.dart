import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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

  // Delete
  static Future<void> deleteNeed(String needId) async {
    try {
      await _needsCollection.doc(needId).delete();
    } catch (e) {
      throw Exception("Erreur lors de la suppression: $e");
    }
  }

  // Send payment notification to the author
  static Future<void> sendPaymentNotification({
    required String authorUserId,
    required String payerName,
    required String needTitle,
    required String amount,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(authorUserId)
          .collection('notifications')
          .add({
        'type': 'payment',
        'title': 'Paiement reçu !',
        'message': '$payerName a payé $amount pour "$needTitle".',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Don't throw — notification failure shouldn't block payment flow
      debugPrint("Erreur notification: $e");
    }
  }
}
