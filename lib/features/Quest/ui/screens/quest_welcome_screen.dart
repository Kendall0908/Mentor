import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../core/constants/app_colors.dart';
import '../../../auth/ui/widgets/custom_button.dart';
import 'quest_profile_screen.dart';
import 'package:file_picker/file_picker.dart' show FilePicker, FilePickerResult, FileType, PlatformFile;
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../auth/logic/auth_service.dart';
import '../../../../core/services/cloudinary_service.dart';
class QuestWelcomeScreen extends StatefulWidget {
  const QuestWelcomeScreen({super.key});

  @override
  State<QuestWelcomeScreen> createState() => _QuestWelcomeScreenState();
}

class _QuestWelcomeScreenState extends State<QuestWelcomeScreen> {
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final AuthService _authService = AuthService();
  final List<PlatformFile> _pickedFiles = [];
  bool _isUploading = false;
  
  final int _maxFileSize = 5 * 1024 * 1024; // 5 MB
  final List<String> _allowedExtensions = ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'];

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _allowedExtensions,
        allowMultiple: true,
        withData: true,
      );

      if (result != null) {
        setState(() => _isUploading = true);
        
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid == null) throw Exception("Utilisateur non connecté");

        for (var file in result.files) {
          try {
            // Validation de la taille
            if (file.size > _maxFileSize) {
              throw Exception("Le fichier ${file.name} dépasse la limite de 5Mo");
            }

            debugPrint("Uploading to Cloudinary: ${file.name}");
            final response = await _cloudinaryService.uploadFile(file);

            if (response != null && response.containsKey('secure_url')) {
              final String url = response['secure_url'];
              final String displayName = response['display_name'] ?? file.name;
              final int fileSize = response['bytes'] ?? file.size;
              
              // Enregistrement des métadonnées détaillées
              await _authService.addDocumentMetadata(uid, {
                'fileName': displayName,
                'fileType': file.extension ?? 'unknown',
                'fileSize': fileSize,
                'cloudinaryUrl': url,
                'publicId': response['public_id'],
                'userId': uid,
              });

              if (mounted) {
                setState(() {
                  _pickedFiles.add(file);
                });
              }
            }
          } catch (fileError) {
            debugPrint("Erreur fichier ${file.name}: $fileError");
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Échec pour ${file.name} : $fileError")),
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Global error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de la sélection : $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _removeFile(int index) {
    setState(() {
      _pickedFiles.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Orientation MentOr",
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Hero Image avec Gradient
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.questBlue.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                  image: const DecorationImage(
                    image: NetworkImage(
                        'https://images.unsplash.com/photo-1523240795612-9a054b0db644?w=800&q=80'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.4),
                      ],
                    ),
                  ),
                  alignment: Alignment.bottomLeft,
                  padding: const EdgeInsets.all(20),
                  child: const Text(
                    "Explorez\nvotre avenir",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              
              const Text(
                "Prêt à découvrir ton futur ?",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                "Ce questionnaire est conçu pour t'aider à identifier tes intérêts académiques et tes forces professionnelles.",
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textGrey,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Info Cards
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: _buildCompactInfoCard(Icons.timer, "3-5 min")),
                  const SizedBox(width: 15),
                  Expanded(child: _buildCompactInfoCard(Icons.quiz, "15 Questions")),
                  const SizedBox(width: 15),
                  Expanded(child: _buildCompactInfoCard(Icons.auto_awesome, "IA Analyse")),
                ],
              ),
              const SizedBox(height: 30),

              // Upload Section - CORRIGÉ ICI
              GestureDetector(
                onTap: _isUploading ? null : _pickFiles,
                child: DottedBorder(
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(20),
                  strokeWidth: 2,
                  color: AppColors.questBlue.withOpacity(0.5),
                  dashPattern: const [8, 4],
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColors.questBlue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: _isUploading 
                      ? const Center(child: CircularProgressIndicator(color: AppColors.questBlue))
                      : _pickedFiles.isEmpty
                        ? Column(
                            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.questBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cloud_upload_rounded, 
                  color: AppColors.questBlue, size: 28),
              ),
              const SizedBox(height: 15),
              const Text(
                "Ajoute ton bulletin ou CV",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Format PDF, PNG, JPG supporté (Optionnel)",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black.withOpacity(0.5),
                  fontSize: 11,
                ),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${_pickedFiles.length} fichier(s) prêt(s)",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.questBlue,
                      fontSize: 13,
                    ),
                  ),
                  const Icon(Icons.check_circle, 
                    size: 18, color: AppColors.questBlue),
                ],
              ),
              const SizedBox(height: 10),
                ..._pickedFiles.asMap().entries.map((entry) {
                  int index = entry.key;
                  PlatformFile file = entry.value;
                  IconData fileIcon = Icons.description;
                  Color iconColor = AppColors.questBlue;

                  if (['png', 'jpg', 'jpeg'].contains(file.extension?.toLowerCase())) {
                    fileIcon = Icons.image;
                    iconColor = Colors.orange;
                  } else if (file.extension?.toLowerCase() == 'pdf') {
                    fileIcon = Icons.picture_as_pdf;
                    iconColor = Colors.redAccent;
                  } else if (['doc', 'docx'].contains(file.extension?.toLowerCase())) {
                    fileIcon = Icons.article;
                    iconColor = Colors.blue;
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: AppColors.questBlue.withOpacity(0.2)),
                    ),
                    child: ListTile(
                      dense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      leading: Icon(fileIcon, color: iconColor, size: 20),
                      title: Text(
                        file.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.close,
                            color: Colors.grey, size: 18),
                        onPressed: () => _removeFile(index),
                      ),
                    ),
                  );
                }),
                            ],
                          ),
                  ),
                ),
              ),


              const SizedBox(height: 40),

              CustomButton(
                text: "Commencer l'aventure",
                onPressed: _isUploading ? null : () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const QuestProfileScreen()),
                  );
                },
                type: ButtonType.primary, 
              ),
              const SizedBox(height: 20),
              Text(
                "PROPULSÉ PAR MENTOR IA",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactInfoCard(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.questBlue, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textBlack,
            ),
          ),
        ],
      ),
    );
  }
}