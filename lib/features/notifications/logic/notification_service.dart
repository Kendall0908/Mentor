import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference
  CollectionReference _userNotifications(String uid) {
    return _firestore.collection('users').doc(uid).collection('notifications');
  }

  // Stream of notifications
  Stream<List<AppNotification>> getNotificationsStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    return _userNotifications(uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AppNotification.fromFirestore(doc))
          .toList();
    });
  }

  // Mark as read
  Future<void> markAsRead(String notificationId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _userNotifications(uid).doc(notificationId).update({'isRead': true});
  }

  // Check and generate notifications based on favorites
  Future<void> checkAndGenerateNotifications() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    // 1. Get User Favorites
    final favoritesSnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('choices')
        .get();

    if (favoritesSnapshot.docs.isEmpty) return;

    final favoritePrograms = favoritesSnapshot.docs
        .map((doc) => doc['programName'] as String)
        .toSet();

    // 2. Get Existing Notifications to avoid duplicates
    final existingNotifsSnapshot = await _userNotifications(uid).get();
    final existingTitles = existingNotifsSnapshot.docs
        .map((doc) => doc['title'] as String)
        .toSet();

    // 3. Mock Opportunities Database
    final List<Map<String, dynamic>> mockOpportunities = [
      {
        'keyword': 'Informatique',
        'title': 'Hackathon Tech 2024',
        'message': 'Participez au plus grand hackathon étudiant de la région !',
        'type': NotificationType.event,
      },
      {
        'keyword': 'Informatique',
        'title': 'Stage développeur Web',
        'message': 'Une startup locale cherche des stagiaires React/Node.js.',
        'type': NotificationType.opportunity,
      },
      {
        'keyword': 'Droit',
        'title': 'Conférence Juridique',
        'message': 'Rencontre avec des avocats du barreau de Paris.',
        'type': NotificationType.event,
      },
      {
        'keyword': 'Commerce',
        'title': 'Concours Business School',
        'message': 'Inscriptions ouvertes pour le concours passerelle.',
        'type': NotificationType.contest,
      },
       {
        'keyword': 'Art',
        'title': 'Exposition Jeunes Talents',
        'message': 'Envoyez vos oeuvres pour la galerie de fin d\'année.',
        'type': NotificationType.opportunity,
      },
      {
        'keyword': 'Médecine',
        'title': 'Portes Ouvertes CHU',
        'message': 'Découvrez les métiers de l\'hôpital ce samedi.',
        'type': NotificationType.event,
      },
    ];

    // 4. Match and Create
    for (final program in favoritePrograms) {
      for (final opportunity in mockOpportunities) {
        // Simple keyword matching
        if (program.contains(opportunity['keyword'])) {
          if (!existingTitles.contains(opportunity['title'])) {
            await _userNotifications(uid).add({
              'title': opportunity['title'],
              'message': opportunity['message'],
              'type': opportunity['type'].toString().split('.').last,
              'date': FieldValue.serverTimestamp(),
              'isRead': false,
              'relatedProgramName': program,
            });
          }
        }
      }
    }
  }
  // Simulate a new notification for testing
  Future<void> simulateNotification() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _userNotifications(uid).add({
      'title': 'Nouveau Message !',
      'message': 'Ceci est une notification de test simulée.',
      'type': 'info',
      'date': FieldValue.serverTimestamp(),
      'isRead': false,
      'relatedProgramName': 'Test',
    });
  }
}
