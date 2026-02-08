import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:mentor/features/explore/ui/screens/explore_screen.dart';
import 'package:mentor/features/chat/ui/screens/chat_screen.dart';
import 'package:mentor/features/profile/ui/screens/profile_screen.dart';
import 'package:mentor/features/Quest/ui/screens/quest_welcome_screen.dart';
import 'package:mentor/features/Quest/ui/screens/quest_results_screen.dart';
import 'package:mentor/features/Quest/data/ai_recommendation_service.dart';
import 'package:mentor/features/flieres/ui/screens/program_detail_screen_dynamic.dart';
import 'package:mentor/features/flieres/data/program_data.dart';
import 'package:mentor/features/support/ui/screens/support_feed_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mentor/features/auth/logic/auth_service.dart';
import 'package:mentor/features/auth/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mentor/features/profile/ui/screens/notifications_screen.dart';
import 'package:mentor/features/notifications/logic/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _HomeContent(),
    const ExploreScreen(),
    const SupportFeedScreen(), // New Tab
    const ChatScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.questBlue,
        unselectedItemColor: Colors.grey.shade400,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 10),
        elevation: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Accueil"),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Explorer"),
          BottomNavigationBarItem(icon: Icon(Icons.handshake), label: "Entraide"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: "Conseiller"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final authService = AuthService();

    if (currentUser == null) {
      return const Center(child: Text("Utilisateur non connecté"));
    }

    return FutureBuilder<Map<String, dynamic>?>(
      future: authService.getUserData(currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final userData = snapshot.data;
        final userModel = userData != null ? UserModel.fromMap(userData) : null;
        final userName = userModel?.name ?? "Utilisateur";
        final userProgress = userModel?.progress ?? 0.1;

        return Scaffold(
          backgroundColor: const Color(0xFFFAFAFA),
          appBar: AppBar(
            backgroundColor: const Color(0xFFFAFAFA),
            elevation: 0,
            automaticallyImplyLeading: false, // Disable back button on home screen
            title: const Text(
              "Accueil",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            centerTitle: true,
            // Header profile removed as requested (redundant with the one below)
            actions: [

              StreamBuilder<List<dynamic>>( // Using dynamic to avoid import error until fixed
                stream: FirebaseAuth.instance.currentUser != null 
                    ? FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection('notifications')
                        .where('isRead', isEqualTo: false)
                        .snapshots()
                        .map((s) => s.docs)
                    : Stream.value([]),
                builder: (context, snapshot) {
                  final unreadCount = snapshot.data?.length ?? 0;
                  return IconButton(
                    icon: Stack(
                      children: [
                        const Icon(Icons.notifications, color: Colors.black),
                        if (unreadCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 12,
                                minHeight: 12,
                              ),
                              child: Text(
                                '$unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                      ],
                    ),
                    onPressed: () {
                       Navigator.push(
                         context,
                         MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                       );
                    },
                  );
                }
              )
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.pink.shade50,
                      backgroundImage: userModel?.avatarUrl != null && userModel!.avatarUrl.isNotEmpty
                          ? CachedNetworkImageProvider(userModel.avatarUrl)
                          : null,
                      child: userModel?.avatarUrl == null || userModel!.avatarUrl.isEmpty
                          ? const Icon(Icons.face_3, color: Colors.pink, size: 40)
                          : null,
                     ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Bonjour, $userName !",
                            style: const TextStyle(
                              fontSize: 18, // Reduced slightly to help with very long names
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Prêt à explorer ton futur ?\n${userModel?.grade ?? 'Élève'}",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
    
                // Profile Progress Card - Dynamic
                Builder(
                  builder: (context) {
                    // Calculer le pourcentage de complétion du profil
                    double calculatedProgress = _calculateProfileCompletion(userData);
                    String progressMessage = _getProgressMessage(calculatedProgress);
                    
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  calculatedProgress >= 1.0 
                                    ? "Ton profil est complet !" 
                                    : "Ton profil est presque prêt",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  if (calculatedProgress >= 1.0)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 16,
                                    ),
                                  if (calculatedProgress >= 1.0)
                                    const SizedBox(width: 4),
                                  Text(
                                    "${(calculatedProgress * 100).toInt()}%",
                                    style: TextStyle(
                                      color: calculatedProgress >= 1.0 
                                        ? Colors.green 
                                        : AppColors.questBlue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: calculatedProgress,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                calculatedProgress >= 1.0 
                                  ? Colors.green 
                                  : AppColors.questBlue,
                              ),
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            progressMessage,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    
                const SizedBox(height: 30),
    
                // Simulation Card (Hero)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: Image.network(
                          "https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=800&q=80", 
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 180,
                            width: double.infinity,
                            color: Colors.blue.shade50,
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.map_outlined, size: 50, color: AppColors.questBlue),
                                SizedBox(height: 10),
                                Text("Illustration non disponible", style: TextStyle(color: AppColors.questBlue, fontSize: 12)),
                              ],
                            ),
                          ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 180,
                              color: Colors.blue.shade50,
                              child: const Center(child: CircularProgressIndicator()),
                            );
                          },
                        ),
                      ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Lancer une simulation d’orientation",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Découvre les métiers et études qui te correspondent en 5 minutes seulement.",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(20)
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.access_time_filled, size: 14, color: AppColors.questBlue),
                                  SizedBox(width: 4),
                                  Text("5 min", style: TextStyle(color: AppColors.questBlue, fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            const Spacer(),
                            SizedBox(
                              width: 130,
                              height: 40,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const QuestWelcomeScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.questBlue,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                                child: const Text("C’est parti !", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Recommendations Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Dernière recommandation",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                TextButton(
                  onPressed: () async {
                    // Récupérer toutes les recommandations et naviguer
                    final userData = await authService.getUserData(currentUser.uid);
                    final orientationResults = userData?['orientationResults'] as Map<String, dynamic>?;
                    final recommendationsData = orientationResults?['recommendations'] as List?;
                    
                    if (recommendationsData != null && recommendationsData.isNotEmpty) {
                      // Convertir les données en objets ProgramRecommendation
                      final recommendations = recommendationsData.map((rec) {
                        final recMap = rec as Map<String, dynamic>;
                        return ProgramRecommendation(
                          programData: allPrograms.firstWhere(
                            (p) => p.id == recMap['programId'],
                            orElse: () => allPrograms.first,
                          ),
                          matchPercentage: recMap['matchPercentage'] as int? ?? 0,
                          matchReason: recMap['matchReason'] as String? ?? '',
                        );
                      }).toList();
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuestResultsScreen(recommendations: recommendations),
                        ),
                      );
                    } else {
                      // Pas de recommandations, naviguer vers le questionnaire
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const QuestWelcomeScreen(),
                        ),
                      );
                    }
                  }, 
                  child: const Text("Voir tout", style: TextStyle(color: AppColors.questBlue, fontWeight: FontWeight.bold))
                )
              ],
            ),

            // Recommendation Card - Dynamic from Firestore
            FutureBuilder<Map<String, dynamic>?>(
              future: authService.getUserData(currentUser.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: 120,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                final userData = snapshot.data;
                final orientationResults = userData?['orientationResults'] as Map<String, dynamic>?;
                final recommendations = orientationResults?['recommendations'] as List?;

                // Si pas de recommandations, afficher un message
                if (recommendations == null || recommendations.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
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
                        Icon(Icons.lightbulb_outline, size: 50, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          "Aucune recommandation pour le moment",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Complète le questionnaire d'orientation pour obtenir des recommandations personnalisées !",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const QuestWelcomeScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.questBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Commencer le test",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Récupérer la première recommandation (la meilleure)
                final topRecommendation = recommendations.first as Map<String, dynamic>;
                final programName = topRecommendation['programName'] as String? ?? 'Programme';
                final matchPercentage = topRecommendation['matchPercentage'] as int? ?? 0;
                final matchReason = topRecommendation['matchReason'] as String? ?? 'Recommandation basée sur votre profil';

                // Déterminer l'icône et la couleur selon le nom du programme
                IconData programIcon = Icons.school;
                Color programColor = const Color(0xFF4DB6AC);

                if (programName.contains('Ingénierie') || programName.contains('Logicielle')) {
                  programIcon = Icons.terminal;
                  programColor = Colors.blue;
                } else if (programName.contains('Design') || programName.contains('UX')) {
                  programIcon = Icons.palette;
                  programColor = Colors.purple;
                } else if (programName.contains('Marketing') || programName.contains('Commerce')) {
                  programIcon = Icons.business_center;
                  programColor = Colors.orange;
                } else if (programName.contains('Médecine') || programName.contains('Santé')) {
                  programIcon = Icons.medical_services;
                  programColor = Colors.red;
                } else if (programName.contains('Droit')) {
                  programIcon = Icons.gavel;
                  programColor = Colors.brown;
                } else if (programName.contains('Journalisme')) {
                  programIcon = Icons.newspaper;
                  programColor = Colors.teal;
                } else if (programName.contains('Esthétique') || programName.contains('Beauté')) {
                  programIcon = Icons.spa;
                  programColor = Colors.pink;
                } else if (programName.contains('Éducation') || programName.contains('Enseignement')) {
                  programIcon = Icons.school;
                  programColor = Colors.green;
                } else if (programName.contains('Architecture')) {
                  programIcon = Icons.architecture;
                  programColor = Colors.deepPurple;
                }

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
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
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: programColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(programIcon, color: Colors.white, size: 30),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        programName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.questBlue,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "$matchPercentage%",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  matchReason,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.lightbulb_outline, size: 12, color: programColor),
                                const SizedBox(width: 4),
                                const Text(
                                  "Recommandé pour vous",
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              // Naviguer vers les détails du programme
                              final programId = topRecommendation['programId'] as String?;
                              if (programId != null) {
                                final program = allPrograms.firstWhere(
                                  (p) => p.id == programId,
                                  orElse: () => allPrograms.first,
                                );
                                
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProgramDetailScreenDynamic(programData: program),
                                  ),
                                );
                              }
                            },
                            child: const Text(
                              "Voir détails →",
                              style: TextStyle(
                                color: AppColors.questBlue,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            // Stats Grid
            Row(
              children: [
                Expanded(child: _buildStatCard(Icons.work_outline, "12", "MÉTIERS EXPLORÉS")),
                const SizedBox(width: 15),
                Expanded(child: _buildStatCard(Icons.school_outlined, "4", "ÉCOLES FAVORITES")),
              ],
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  },
);
}

  Widget _buildStatCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.questBlue, size: 28),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 24),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Calcule le pourcentage de complétion du profil basé sur les données utilisateur
  static double _calculateProfileCompletion(Map<String, dynamic>? userData) {
    if (userData == null) return 0.0;

    double totalWeight = 0.0;
    double completedWeight = 0.0;

    // 1. Informations de base (30%)
    const double basicInfoWeight = 0.30;
    double basicInfoCompletion = 0.0;
    int basicFieldsCompleted = 0;
    int totalBasicFields = 4;

    if (userData['name'] != null && (userData['name'] as String).isNotEmpty) {
      basicFieldsCompleted++;
    }
    if (userData['email'] != null && (userData['email'] as String).isNotEmpty) {
      basicFieldsCompleted++;
    }
    if (userData['grade'] != null && (userData['grade'] as String).isNotEmpty) {
      basicFieldsCompleted++;
    }
    if (userData['avatarUrl'] != null && (userData['avatarUrl'] as String).isNotEmpty) {
      basicFieldsCompleted++;
    }

    basicInfoCompletion = basicFieldsCompleted / totalBasicFields;
    totalWeight += basicInfoWeight;
    completedWeight += basicInfoCompletion * basicInfoWeight;

    // 2. Questionnaire d'orientation (50%)
    const double questionnaireWeight = 0.50;
    double questionnaireCompletion = 0.0;
    int questionnaireStepsCompleted = 0;
    int totalQuestionnaireSteps = 3;

    // Étape 1: Passions
    final passions = userData['orientation_passions'] as List?;
    if (passions != null && passions.isNotEmpty) {
      questionnaireStepsCompleted++;
    }

    // Étape 2: Compétences
    final skills = userData['orientation_skills'] as Map?;
    if (skills != null && skills.isNotEmpty) {
      questionnaireStepsCompleted++;
    }

    // Étape 3: Environnement
    final environment = userData['orientation_environment_ranking'] as List?;
    if (environment != null && environment.isNotEmpty) {
      questionnaireStepsCompleted++;
    }

    questionnaireCompletion = questionnaireStepsCompleted / totalQuestionnaireSteps;
    totalWeight += questionnaireWeight;
    completedWeight += questionnaireCompletion * questionnaireWeight;

    // 3. Résultats d'orientation (20%)
    const double resultsWeight = 0.20;
    double resultsCompletion = 0.0;

    final orientationResults = userData['orientationResults'] as Map?;
    final recommendations = orientationResults?['recommendations'] as List?;
    if (recommendations != null && recommendations.isNotEmpty) {
      resultsCompletion = 1.0;
    }

    totalWeight += resultsWeight;
    completedWeight += resultsCompletion * resultsWeight;

    // Retourner le pourcentage total
    return totalWeight > 0 ? completedWeight / totalWeight : 0.0;
  }

  /// Génère un message contextuel basé sur le pourcentage de complétion
  static String _getProgressMessage(double progress) {
    if (progress >= 1.0) {
      return "Bravo ! Ton profil est complet. Explore tes recommandations personnalisées !";
    } else if (progress >= 0.7) {
      return "Plus que quelques étapes pour des conseils ultra-personnalisés !";
    } else if (progress >= 0.4) {
      return "Continue ! Complète le questionnaire pour obtenir tes recommandations.";
    } else if (progress >= 0.2) {
      return "Commence par compléter tes informations de base et le questionnaire.";
    } else {
      return "Bienvenue ! Commence par compléter ton profil pour des recommandations personnalisées.";
    }
  }
}
