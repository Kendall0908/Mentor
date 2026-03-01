import 'package:flutter/material.dart';
import 'package:mentor/core/constants/app_colors.dart';
import 'package:mentor/features/home/ui/screens/home_screen.dart';
import 'package:mentor/features/flieres/data/program_data.dart';
import 'package:mentor/features/flieres/ui/screens/program_detail_screen_dynamic.dart';
import 'package:mentor/features/Quest/data/ai_recommendation_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mentor/features/auth/logic/auth_service.dart';


class QuestResultsScreen extends StatelessWidget {
  final List<ProgramRecommendation> recommendations;
  
  const QuestResultsScreen({super.key, required this.recommendations});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recommandations MentOr"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Vos filières idéales",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "${recommendations.length} recommandations basées sur votre profil",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 25),

            // Afficher toutes les recommandations
            if (recommendations.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.search_off, size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 20),
                      Text(
                        "Aucune recommandation disponible",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...recommendations.map((rec) {
                final program = rec.programData;
                return _buildRecommendationCard(
                  context: context,
                  title: program.name,
                  category: program.category,
                  percentage: rec.matchPercentage,
                  jobs: program.skills.take(3).toList(),
                  icon: _getIconForCategory(program.category),
                  color: _getColorForCategory(program.category).withOpacity(0.2),
                  iconColor: _getColorForCategory(program.category),
                  imageUrl: program.imageUrl,
                  programData: program,
                  matchReason: rec.matchReason,
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard({
    required BuildContext context,
    required String title,
    required String category,
    required int percentage,
    required List<String> jobs,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required String imageUrl,
    required programData,
    String matchReason = '',
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ProgramDetailScreenDynamic(programData: programData),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: iconColor, size: 28),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          category,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.questBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: AppColors.accent,
                    child: Text(
                      "$percentage%",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
            ),
            

            
            // Actions Row (Save + Match Reason)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: matchReason.isNotEmpty 
                      ? Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.questBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.lightbulb_outline, size: 16, color: AppColors.questBlue),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  matchReason,
                                  style: const TextStyle(fontSize: 12, color: AppColors.questBlue, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                  ),
                  const SizedBox(width: 10),
                  // Save Button with favorite state
                  Builder(
                    builder: (context) {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) {
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Connectez-vous pour sauvegarder')),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: const Icon(Icons.bookmark_border, color: Colors.grey),
                            ),
                          ),
                        );
                      }
                      return StreamBuilder<List<String>>(
                        stream: AuthService().getFavorites(user.uid),
                        builder: (context, snapshot) {
                          final favorites = snapshot.data ?? [];
                          final isFavorite = favorites.contains(programData.id);
                          
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () async {
                                if (!isFavorite) {
                                  // Adding — check limit
                                  final success = await AuthService().toggleFavorite(user.uid, programData.id);
                                  if (success) {
                                    final metadata = {
                                      'id': programData.id,
                                      'name': programData.name,
                                      'category': programData.category,
                                      'imageUrl': programData.imageUrl,
                                      'skills': programData.skills,
                                    };
                                    await AuthService().saveFavoriteMetadata(user.uid, metadata);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('🔖 Filière sauvegardée dans vos favoris !'), backgroundColor: Colors.green),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('⚠️ Vous ne pouvez pas dépasser 2 filières en favoris.'),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  }
                                } else {
                                  // Removing — always allowed
                                  await AuthService().toggleFavorite(user.uid, programData.id);
                                  await AuthService().deleteFavoriteMetadata(user.uid, programData.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Filière retirée des favoris'), backgroundColor: Colors.orange),
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isFavorite ? AppColors.questBlue.withOpacity(0.1) : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isFavorite ? AppColors.questBlue : Colors.grey.shade300,
                                  ),
                                ),
                                child: Icon(
                                  isFavorite ? Icons.bookmark : Icons.bookmark_border,
                                  color: isFavorite ? AppColors.questBlue : Colors.grey,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(Icons.image_not_supported, color: Colors.grey.shade400),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: jobs
                          .map(
                            (job) => Text(
                              "• $job",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: const Text(
                "Découvrir le cursus complet →",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Helper functions pour les icônes et couleurs par catégorie
  IconData _getIconForCategory(String category) {
    if (category.contains('TECHNOLOGIE')) return Icons.terminal;
    if (category.contains('DESIGN')) return Icons.palette;
    if (category.contains('BUSINESS') || category.contains('FINANCE')) return Icons.business_center;
    if (category.contains('SANTÉ')) return Icons.medical_services;
    if (category.contains('JURIDIQUE')) return Icons.gavel;
    if (category.contains('MÉDIAS')) return Icons.newspaper;
    if (category.contains('BEAUTÉ')) return Icons.spa;
    if (category.contains('ÉDUCATION')) return Icons.school;
    return Icons.work;
  }

  Color _getColorForCategory(String category) {
    if (category.contains('TECHNOLOGIE')) return Colors.blue;
    if (category.contains('DESIGN')) return Colors.purple;
    if (category.contains('BUSINESS') || category.contains('FINANCE')) return Colors.orange;
    if (category.contains('SANTÉ')) return Colors.red;
    if (category.contains('JURIDIQUE')) return Colors.brown;
    if (category.contains('MÉDIAS')) return Colors.teal;
    if (category.contains('BEAUTÉ')) return Colors.pink;
    if (category.contains('ÉDUCATION')) return Colors.green;
    return Colors.grey;
  }
}
