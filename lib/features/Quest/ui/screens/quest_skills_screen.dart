import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../auth/logic/auth_service.dart';
import '../../../../core/constants/app_colors.dart';
import 'quest_environment_screen.dart';

class QuestSkillsScreen extends StatefulWidget {
  const QuestSkillsScreen({super.key});

  @override
  State<QuestSkillsScreen> createState() => _QuestSkillsScreenState();
}

class _QuestSkillsScreenState extends State<QuestSkillsScreen> {
  // Skill data model
  // Skill data model - Scale 0 to 10
  final List<Map<String, dynamic>> _skills = [
    {'name': 'Mathématiques', 'icon': Icons.calculate, 'value': 5.0, 'color': Colors.blue.shade100, 'iconColor': Colors.blue},
    {'name': 'Langues', 'icon': Icons.language, 'value': 7.0, 'color': Colors.orange.shade100, 'iconColor': Colors.orange},
    {'name': 'Sciences', 'icon': Icons.science, 'value': 4.0, 'color': Colors.green.shade100, 'iconColor': Colors.green},
    {'name': 'Littérature', 'icon': Icons.menu_book, 'value': 6.0, 'color': Colors.purple.shade100, 'iconColor': Colors.purple},
    {'name': 'Histoire-Géo', 'icon': Icons.public, 'value': 4.0, 'color': Colors.brown.shade100, 'iconColor': Colors.brown},
    {'name': 'Arts Plastiques', 'icon': Icons.palette, 'value': 3.0, 'color': Colors.pink.shade100, 'iconColor': Colors.pink},
    {'name': 'Musique', 'icon': Icons.music_note, 'value': 3.0, 'color': Colors.indigo.shade100, 'iconColor': Colors.indigo},
    {'name': 'Sport (EPS)', 'icon': Icons.sports_soccer, 'value': 6.0, 'color': Colors.red.shade100, 'iconColor': Colors.red},
    {'name': 'Informatique', 'icon': Icons.computer, 'value': 5.0, 'color': Colors.cyan.shade100, 'iconColor': Colors.cyan},
    {'name': 'Économie', 'icon': Icons.trending_up, 'value': 4.0, 'color': Colors.amber.shade100, 'iconColor': Colors.amber},
    {'name': 'Philosophie', 'icon': Icons.psychology, 'value': 4.0, 'color': Colors.deepPurple.shade100, 'iconColor': Colors.deepPurple},
    {'name': 'Biologie', 'icon': Icons.biotech, 'value': 4.0, 'color': Colors.lightGreen.shade100, 'iconColor': Colors.lightGreen},
    {'name': 'Chimie', 'icon': Icons.science_outlined, 'value': 4.0, 'color': Colors.teal.shade100, 'iconColor': Colors.teal},
    {'name': 'Physique', 'icon': Icons.bolt, 'value': 4.0, 'color': Colors.blueGrey.shade100, 'iconColor': Colors.blueGrey},
    {'name': 'Communication', 'icon': Icons.campaign, 'value': 5.0, 'color': Colors.deepOrange.shade100, 'iconColor': Colors.deepOrange},
  ];

  String _getLevelLabel(double value) {
    if (value <= 1) return "Débutant";
    if (value <= 3) return "Élémentaire";
    if (value <= 5) return "Intermédiaire";
    if (value <= 7) return "Avancé";
    if (value <= 9) return "Très Avancé";
    return "Expert";
  }

  Color _getLevelColor(double value) {
    if (value <= 1) return Colors.grey;
    if (value <= 3) return Colors.blueAccent.withOpacity(0.6);
    if (value <= 5) return AppColors.questBlue;
    if (value <= 7) return Colors.indigo;
    if (value <= 9) return Colors.deepPurple;
    return Colors.green; // Expert
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          "Questionnaire MentOr", // Matching screenshot
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
                    Text("Compétences et Matières", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("Étape 2 sur 3", style: TextStyle(color: AppColors.questBlue, fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 15),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: 0.66, // Step 2/3
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.questBlue),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Évaluez votre niveau",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Indiquez votre aisance dans chaque matière pour nous aider à définir votre profil d'orientation.",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 15, height: 1.5),
                  ),
                  const SizedBox(height: 30),

                  // Skills List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _skills.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      return _buildSkillCard(index);
                    },
                  ),
                   const SizedBox(height: 40),
                ],
              ),
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
                        final skillsMap = {
                          for (var s in _skills) s['name']: s['value']
                        };
                        await AuthService().updateUserData(uid, {
                          'orientation_skills': skillsMap,
                        });
                      }
                      if (mounted) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const QuestEnvironmentScreen()));
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

  Widget _buildSkillCard(int index) {
    final skill = _skills[index];
    double value = skill['value'];
    String label = _getLevelLabel(value);
    Color  labelColor = _getLevelColor(value);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: skill['color'], 
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(skill['icon'], color: skill['iconColor'], size: 24),
              ),
              const SizedBox(width: 15),
              Text(
                skill['name'],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 25),
          
          // Slider and Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("DÉBUTANT", style: TextStyle(color: Colors.grey.shade400, fontSize: 10, fontWeight: FontWeight.bold)),
              Text("EXPERT", style: TextStyle(color: Colors.grey.shade400, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 5),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.questBlue,
              inactiveTrackColor: Colors.grey.shade200,
              trackHeight: 6.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0, elevation: 4),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24.0),
              thumbColor: Colors.white,
              overlayColor: AppColors.questBlue.withOpacity(0.2),
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 10,
              divisions: 10,
              onChanged: (newValue) {
                setState(() {
                  _skills[index]['value'] = newValue;
                });
              },
            ),
          ),
           Align(
             alignment: Alignment.centerRight,
             child: Text(
               label,
               style: TextStyle(
                 color: labelColor,
                 fontWeight: FontWeight.w700,
                 fontSize: 14,
               ),
             ),
           ),
        ],
      ),
    );
  }
}
