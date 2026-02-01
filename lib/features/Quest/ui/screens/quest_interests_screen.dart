import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../auth/logic/auth_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/ui/widgets/custom_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'quest_skills_screen.dart';

class QuestInterestsScreen extends StatefulWidget {
  const QuestInterestsScreen({super.key});

  @override
  State<QuestInterestsScreen> createState() => _QuestInterestsScreenState();
}

class _QuestInterestsScreenState extends State<QuestInterestsScreen> {
  // Placeholder images with specific passions
  final List<Map<String, dynamic>> _interests = [
    {'name': 'Mode', 'image': 'https://images.unsplash.com/photo-1537832816519-689ad163238b?ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=80', 'selected': true}, // Fashion runway
    {'name': 'Esthétique', 'image': 'https://images.unsplash.com/photo-1522337660859-02fbefca4702?ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=80', 'selected': false}, // Makeup aesthetic
    {'name': 'Beauté', 'image': 'https://images.unsplash.com/photo-1616394584738-fc6e612e71b9?ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=80', 'selected': false}, // Skincare products
    {'name': 'Coiffure', 'image': 'https://images.unsplash.com/photo-1560869713-7d0a29430803?ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=80', 'selected': false}, // Salon info
    {'name': 'Couture', 'image': 'https://images.unsplash.com/photo-1512413914633-b5043f4041ea?ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=80', 'selected': false}, // Sewing machine
    {'name': 'Sport', 'image': 'https://images.unsplash.com/photo-1517649763962-0c623066013b?ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=80', 'selected': false}, // Gym
    {'name': 'Gaming', 'image': 'https://images.unsplash.com/photo-1542751371-adc38448a05e?ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=80', 'selected': false}, // Controller
    {'name': 'Musique', 'image': 'https://images.unsplash.com/photo-1511379938547-c1f69419868d?ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=80', 'selected': false}, // Piano
    {'name': 'Cuisine', 'image': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=80', 'selected': false}, // Food
    {'name': 'Voyage', 'image': 'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=80', 'selected': false}, // Switzerland
    {'name': 'Tech', 'image': 'https://images.unsplash.com/photo-1518770660439-4636190af475?ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=80', 'selected': false}, // Chip
    {'name': 'Art', 'image': 'https://images.unsplash.com/photo-1513364776144-60967b0f800f?ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=80', 'selected': false}, // Painting
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Slightly off-white for depth
      appBar: AppBar(
        title: const Text(
          "Vos Passions",
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
        actions: [
          TextButton(
            onPressed: () {
              // Skip logic
            },
            child: const Text("Passer", style: TextStyle(color: AppColors.questBlue, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: Column(
        children: [
          // Progress Bar with modern styling
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                     Text("Étape 1 sur 3", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                     Text("33%", style: TextStyle(color: AppColors.questBlue, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: 0.33,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.questBlue),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Qu’est-ce qui vous passionne ?",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Sélectionnez les passions qui vous inspirent le plus.",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                  ),
                  const SizedBox(height: 25),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.85, 
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _interests.length,
                    itemBuilder: (context, index) {
                      final item = _interests[index];
                      return _buildInterestCard(item, index);
                    },
                  ),
                  
                  // Bottom spacer
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: AppColors.questBlue.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ]
          ),
          child: CustomButton(
            text: "Suivant", 
            onPressed: () async {
              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid != null) {
                await AuthService().updateUserData(uid, {
                  'orientation_passions': _interests
                      .where((e) => e['selected'] == true)
                      .map((e) => e['name'])
                      .toList(),
                });
              }
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QuestSkillsScreen()),
                );
              }
            },
            type: ButtonType.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildInterestCard(Map<String, dynamic> item, int index) {
    final isSelected = item['selected'] as bool;
    return GestureDetector(
      onTap: () {
        setState(() {
          _interests[index]['selected'] = !isSelected;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.questBlue : Colors.transparent,
            width: isSelected ? 3 : 0, 
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.questBlue.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ] : [
             BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Image with Cache and Error Handling
            ClipRRect(
              borderRadius: BorderRadius.circular(17), // 20 - 3 border
              child: CachedNetworkImage(
                imageUrl: item['image'],
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade200,
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade300,
                  child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                ),
              ),
            ),

            // Dark Gradient Overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(17),
                color: Colors.black.withValues(alpha: isSelected ? 0.6 : 0.3), // Darker when selected
              ),
            ),
            
            // Checkmark
            AnimatedOpacity(
              opacity: isSelected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                alignment: Alignment.topRight,
                padding: const EdgeInsets.all(8),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.questBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                ),
              ),
            ),

            // Text
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Text(
                  item['name'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ]
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
