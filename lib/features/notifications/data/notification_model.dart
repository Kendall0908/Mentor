import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  opportunity,
  event,
  contest,
  info
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime date;
  final bool isRead;
  final String? relatedProgramName;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.date,
    this.isRead = false,
    this.relatedProgramName,
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${data['type']}',
        orElse: () => NotificationType.info,
      ),
      date: (data['date'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
      relatedProgramName: data['relatedProgramName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'type': type.toString().split('.').last, // Stocker comme string simple
      'date': Timestamp.fromDate(date),
      'isRead': isRead,
      'relatedProgramName': relatedProgramName,
    };
  }
}
