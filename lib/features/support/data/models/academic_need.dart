import 'package:cloud_firestore/cloud_firestore.dart';

class AcademicNeed {
  final String id;
  final String title;
  final String description;
  final String category; // 'Book', 'Certification', 'Tutorat', etc.
  final String userName;
  final String userAvatar;
  final DateTime createdAt;
  final bool isResolved;
  // Nouveau : Détails spécifiques
  final String? subject; // Pour Cours/Tutorat
  final String? level;   // Pour Cours (L1, L2, etc.)
  final String? price;   // Pour Livres
  final String? link;    // Pour Certifications

  AcademicNeed({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.userName,
    required this.userAvatar,
    required this.createdAt,
    this.isResolved = false,
    this.subject,
    this.level,
    this.price,
    this.link,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'userName': userName,
      'userAvatar': userAvatar,
      'createdAt': Timestamp.fromDate(createdAt),
      'isResolved': isResolved,
      'subject': subject,
      'level': level,
      'price': price,
      'link': link,
    };
  }

  factory AcademicNeed.fromMap(Map<String, dynamic> map, String docId) {
    return AcademicNeed(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      userName: map['userName'] ?? 'Anonyme',
      userAvatar: map['userAvatar'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isResolved: map['isResolved'] ?? false,
      subject: map['subject'],
      level: map['level'],
      price: map['price'],
      link: map['link'],
    );
  }
}
