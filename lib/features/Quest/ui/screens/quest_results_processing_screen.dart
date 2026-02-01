import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'quest_results_screen.dart';

class QuestResultsProcessingScreen extends StatefulWidget {
  const QuestResultsProcessingScreen({super.key});

  @override
  State<QuestResultsProcessingScreen> createState() => _QuestResultsProcessingScreenState();
}

class _QuestResultsProcessingScreenState extends State<QuestResultsProcessingScreen> with SingleTickerProviderStateMixin {
  double _progressValue = 0.0;
  late Timer _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  int _messageIndex = 0;
  final List<String> _loadingMessages = [
    "Analyse de votre profil...",
    "Comparaison avec les filières...",
    "Recherche des meilleures écoles...",
    "Calcul des taux de réussite...",
    "Finalisation de vos résultats..."
  ];

  @override
  void initState() {
    super.initState();
    
    // Pulse Animation for the circle
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Dynamic Messages
    Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _messageIndex = (_messageIndex + 1) % _loadingMessages.length;
      });
    });

    // Simulate Progress
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _progressValue += 0.008; // Slower for more realism
        if (_progressValue >= 1.0) {
          _progressValue = 1.0;
          timer.cancel();
          // Navigate to Home after completion
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const QuestResultsScreen()),
              );
            }
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          "Calcul des résultats",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        leading: Container(),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(height: 20),
                      
                      // Animated Pulsing Circle
                      Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              ScaleTransition(
                                scale: _pulseAnimation,
                                child: Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.questBlue.withOpacity(0.1),
                                  ),
                                ),
                              ),
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [AppColors.questBlue, Color(0xFF5E9EFF)],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.questBlue.withOpacity(0.4),
                                      blurRadius: 25,
                                      offset: const Offset(0, 10),
                                    )
                                  ],
                                ),
                                child: const Icon(Icons.school_rounded, color: Colors.white, size: 60),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          
                          // Dynamic Text
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            child: Text(
                              _loadingMessages[_messageIndex],
                              key: ValueKey<String>(_loadingMessages[_messageIndex]),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                           Text(
                            "Comparaison avec 500+ filières d'études\npour trouver votre voie idéale.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Progress Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Progression",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                                ),
                                Text(
                                  "${(_progressValue * 100).toInt()}%",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.questBlue,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: _progressValue,
                                backgroundColor: Colors.grey.shade100,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.questBlue),
                                minHeight: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Footer
                      Column(
                        children: [
                          Text(
                            "MENTOR ORIENTATION INTELLIGENTE",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildDot(0),
                              const SizedBox(width: 6),
                              _buildDot(1),
                              const SizedBox(width: 6),
                              _buildDot(2),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: (_progressValue * 3).floor() >= index ? AppColors.questBlue : Colors.blue.shade100,
      ),
    );
  }
}
