import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/logic/auth_service.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/ui/screens/welcome_screen.dart';
import 'edit_profile_screen.dart';
import 'notifications_screen.dart';
import 'privacy_screen.dart';
import 'support_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("Utilisateur non connecté")),
      );
    }

    return FutureBuilder<Map<String, dynamic>?>(
      future: _authService.getUserData(currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userData = snapshot.data;
        final userModel = userData != null ? UserModel.fromMap(userData) : null;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.settings, color: Colors.black),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Paramètres bientôt disponibles !")),
                );
              },
            ),
            title: const Text(
              "Mon Profil",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.black),
                onPressed: () async {
                  await _authService.logout();
                  if (mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Header Profile
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.blue.shade50,
                        backgroundImage: NetworkImage(userModel?.avatarUrl ?? "https://img.freepik.com/free-psd/3d-illustration-human-avatar-profile_23-2150671142.jpg"),
                        onBackgroundImageError: (e, s) => debugPrint("Profile image error: $e"),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.questBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, color: Colors.white, size: 20),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  userModel?.name ?? "Utilisateur",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  userModel?.grade ?? "Étudiant",
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      userModel?.school ?? "Non spécifié",
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (userModel != null) {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfileScreen(user: userModel),
                            ),
                          );
                          if (result == true) {
                            setState(() {}); // Refresh data
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE3F2FD),
                        foregroundColor: AppColors.questBlue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Modifier le profil", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Container(height: 8, color: Colors.grey.shade50),
                
                // Progression
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Ma progression", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text("Niveau 1", style: TextStyle(color: AppColors.questBlue, fontSize: 11, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Profil d’orientation", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          Text("${((userModel?.progress ?? 0.1) * 100).toInt()}%", style: const TextStyle(color: AppColors.questBlue, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: userModel?.progress ?? 0.1,
                          minHeight: 8,
                          backgroundColor: const Color(0xFFEEEEEE),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.questBlue),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Continue ton exploration pour booster ton profil !",
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                
                Container(height: 8, color: Colors.grey.shade50),

                // Mes documents (Keeping static for now as requested by user logic)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Mes documents", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (userModel != null && userModel.documentsDetailed.isNotEmpty)
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: userModel.documentsDetailed.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final doc = userModel.documentsDetailed[index];
                            final fileName = doc['fileName'] ?? 'Fichier sans nom';
                            final fileType = doc['fileType']?.toString().toLowerCase() ?? '';
                            final docUrl = doc['cloudinaryUrl'] ?? '';

                            // Déterminer l'icône selon le type
                            IconData iconData = Icons.description;
                            Color iconColor = AppColors.questBlue;
                            
                            if (fileType == 'pdf') {
                              iconData = Icons.picture_as_pdf;
                              iconColor = Colors.red.shade400;
                            } else if (['png', 'jpg', 'jpeg'].contains(fileType)) {
                              iconData = Icons.image;
                              iconColor = Colors.orange.shade400;
                            }

                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                              decoration: BoxDecoration(
                                color: iconColor.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: iconColor.withOpacity(0.1)),
                              ),
                              child: Row(
                                children: [
                                  Icon(iconData, color: iconColor, size: 24),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          fileName,
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (doc['fileSize'] != null)
                                          Text(
                                            "${(doc['fileSize'] / 1024).toStringAsFixed(1)} Ko",
                                            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                                          ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.download_rounded, size: 22, color: iconColor),
                                    onPressed: () async {
                                      if (docUrl.isNotEmpty) {
                                        final uri = Uri.parse(docUrl);
                                        if (await canLaunchUrl(uri)) {
                                          await launchUrl(uri);
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      else
                        const Center(
                          child: Text(
                            "Aucun document ajouté",
                            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                          ),
                        ),
                    ],
                  ),
                ),

                Container(height: 8, color: Colors.grey.shade50),

                // Préférences
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Préférences", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      _buildPreferenceItem(context, Icons.notifications_none_outlined, "Notifications"),
                      _buildPreferenceItem(context, Icons.lock_outline, "Confidentialité"),
                      _buildPreferenceItem(context, Icons.help_outline, "Aide & Support"),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPreferenceItem(BuildContext context, IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: () {
          Widget screen;
          switch (title) {
            case "Notifications":
              screen = const NotificationsScreen();
              break;
            case "Confidentialité":
              screen = const PrivacyScreen();
              break;
            case "Aide & Support":
              screen = const SupportScreen();
              break;
            default:
              screen = Scaffold(appBar: AppBar(title: Text(title)), body: const Center(child: Text("Bientôt disponible")));
          }
          Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: Colors.grey.shade600, size: 22),
            ),
            const SizedBox(width: 15),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }
}
