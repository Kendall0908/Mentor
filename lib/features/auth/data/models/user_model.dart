import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String grade;
  final String school;
  final String avatarUrl;
  final String bio;
  final String location;
  final List<String> documents;
  final List<Map<String, dynamic>> documentsDetailed;
  final Map<String, dynamic>? orientationResults;
  final double progress;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.grade = '',
    this.school = '',
    this.avatarUrl = '',
    this.bio = '',
    this.location = '',
    this.documents = const [],
    this.documentsDetailed = const [],
    this.orientationResults,
    this.progress = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'grade': grade,
      'school': school,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'location': location,
      'documents': documents,
      'documents_detailed': documentsDetailed,
      'orientationResults': orientationResults,
      'progress': progress,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      grade: map['grade'] ?? '',
      school: map['school'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      bio: map['bio'] ?? '',
      location: map['location'] ?? '',
      documents: List<String>.from(map['documents'] ?? []),
      documentsDetailed: List<Map<String, dynamic>>.from(map['documents_detailed'] ?? []),
      orientationResults: map['orientationResults'],
      progress: (map['progress'] ?? 0.0).toDouble(),
    );
  }
}
