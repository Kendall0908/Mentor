import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../auth/logic/auth_service.dart';
import '../../../../core/constants/app_colors.dart';
import 'quest_results_processing_screen.dart';

class QuestEnvironmentScreen extends StatefulWidget {
  const QuestEnvironmentScreen({super.key});

  @override
  State<QuestEnvironmentScreen> createState() => _QuestEnvironmentScreenState();
}

class _QuestEnvironmentScreenState extends State<QuestEnvironmentScreen> {
  // Environment Options
  final List<Map<String, dynamic>> _environments = [
    {
      'title': 'Bureau',
      'description': 'Calme, organisé et numérique',
      'icon': Icons.desk,
      'color': Colors.blue.shade100,
      'iconColor': Colors.blue
    },
    {
      'title': 'Terrain',
      'description': 'Mobile, extérieur et actif',
      'icon': Icons.terrain,
      'color': Colors.green.shade100,
      'iconColor': Colors.green
    },
    {
      'title': 'Studio Créatif',
      'description': 'Artistique, flexible et innovant',
      'icon': Icons.palette,
      'color': Colors.purple.shade100,
      'iconColor': Colors.purple
    },
    {
      'title': 'Cadre Structuré',
      'description': 'Processus clairs et hiérarchie',
      'icon': Icons.apartment,
      'color': Colors.grey.shade200,
      'iconColor': Colors.grey
    },
    {
      'title': 'Travail en Équipe',
      'description': 'Collaboration et échanges',
      'icon': Icons.groups,
      'color': Colors.orange.shade100,
      'iconColor': Colors.orange
    },
    {
      'title': 'Télétravail',
      'description': 'Flexible, autonome et à distance',
      'icon': Icons.home_work,
      'color': Colors.teal.shade100,
      'iconColor': Colors.teal
    },
    {
      'title': 'Laboratoire',
      'description': 'Recherche, expérimentation et précision',
      'icon': Icons.science,
      'color': Colors.cyan.shade100,
      'iconColor': Colors.cyan
    },
    {
      'title': 'Hôpital/Clinique',
      'description': 'Médical, urgent et humain',
      'icon': Icons.local_hospital,
      'color': Colors.red.shade100,
      'iconColor': Colors.red
    },
    {
      'title': 'Salle de Classe',
      'description': 'Enseignement et transmission',
      'icon': Icons.school,
      'color': Colors.amber.shade100,
      'iconColor': Colors.amber
    },
    {
      'title': 'Atelier/Usine',
      'description': 'Pratique, technique et production',
      'icon': Icons.build,
      'color': Colors.brown.shade100,
      'iconColor': Colors.brown
    },
    {
      'title': 'Commerce/Retail',
      'description': 'Contact client et vente',
      'icon': Icons.storefront,
      'color': Colors.pink.shade100,
      'iconColor': Colors.pink
    },
    {
      'title': 'Startup/Innovation',
      'description': 'Dynamique, risque et croissance',
      'icon': Icons.rocket_launch,
      'color': Colors.deepOrange.shade100,
      'iconColor': Colors.deepOrange
    },
  ];



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          "Questionnaire MentOr",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
           // Progress Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Étape 3 : Environnement", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("75%", style: TextStyle(color: AppColors.questBlue, fontWeight: FontWeight.bold, fontSize: 14)), 
                  ],
                ),
                const SizedBox(height: 15),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: 0.75, 
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.questBlue),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ReorderableListView(
              padding: const EdgeInsets.all(24),
              header: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Classez vos environnements idéaux",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Maintenez et glissez pour ordonner vos préférences (1 = le plus important).",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
              children: [
                for (int index = 0; index < _environments.length; index++)
                  Container(
                    key: ValueKey(_environments[index]['title']),
                    margin: const EdgeInsets.only(bottom: 15),
                    child: _buildEnvironmentCard(index),
                  ),
              ],
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final item = _environments.removeAt(oldIndex);
                  _environments.insert(newIndex, item);
                });
              },
            ),
          ),
          
          // Bottom Navigation Buttons
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                 BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5))
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.questBlue, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.arrow_back_ios, size: 16, color: AppColors.questBlue),
                        SizedBox(width: 8),
                        Text("Précédent", style: TextStyle(color: AppColors.questBlue, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final uid = FirebaseAuth.instance.currentUser?.uid;
                      if (uid != null) {
                        try {
                          await AuthService().updateUserData(uid, {
                            'orientation_environment_ranking': _environments.map((e) => e['title']).toList(),
                            // Also save the top choice as the main environment for compatibility
                            'orientation_environment': _environments.first['title'],
                          });
                        } catch (e) {
                          debugPrint("Erreur sauvegarde: $e");
                        }
                      }

                      if (mounted) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const QuestResultsProcessingScreen()));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.questBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text("Suivant", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnvironmentCard(int index) {
    final item = _environments[index];
    // Color varies by rank to give visual feedback
    final isTopChoice = index == 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTopChoice ? AppColors.questBlue : Colors.grey.shade200,
          width: isTopChoice ? 2 : 1,
        ),
        boxShadow: [
           BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: item['color'],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(item['icon'], color: item['iconColor'], size: 24),
        ),
        title: Text(
          item['title'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isTopChoice ? AppColors.questBlue : Colors.black,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            item['description'],
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ),
        trailing: const Icon(Icons.drag_handle_rounded, color: Colors.grey),
      ),
    );
  }
}
