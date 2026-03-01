import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/program_data.dart';
import '../../../../core/services/deepseek_service.dart';

class RoadmapScreen extends StatefulWidget {
  final ProgramData program;

  const RoadmapScreen({super.key, required this.program});

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  List<dynamic>? _roadmapPhases;
  String? _error;
  late AnimationController _mainController;
  late AnimationController _pulseController;
  final Set<int> _expandedPhases = {};

  // Phase colors for mind-map branches
  static const List<Color> _phaseColors = [
    Color(0xFF4A90D9), // Blue
    Color(0xFFE8A838), // Amber/Gold
    Color(0xFF4CAF50), // Green
    Color(0xFFE57373), // Red/Coral
    Color(0xFF7E57C2), // Purple
  ];

  static const List<IconData> _phaseIcons = [
    Icons.school_outlined,
    Icons.build_outlined,
    Icons.hub_outlined,
    Icons.rocket_launch_outlined,
    Icons.star_outline,
  ];

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _loadOrGenerateRoadmap();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadOrGenerateRoadmap() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _error = "Utilisateur non connecté.";
        _isLoading = false;
      });
      return;
    }

    try {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorite_details')
          .doc(widget.program.id);

      final doc = await docRef.get();

      if (doc.exists && doc.data() != null && doc.data()!['roadmap'] != null) {
        final roadmapString = doc.data()!['roadmap'];
        try {
          final decoded = jsonDecode(roadmapString);
          if (mounted) {
            setState(() {
              _roadmapPhases = decoded is List ? decoded : [decoded];
              _isLoading = false;
            });
            _mainController.forward();
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _error =
                  "Ancien format détecté. Veuillez retirer puis remettre en favori pour obtenir le nouveau design.";
              _isLoading = false;
            });
          }
        }
      } else {
        final generatedRoadmap = await DeepSeekService().generateRoadmap(
          programName: widget.program.name,
          skills: widget.program.skills,
          category: widget.program.category,
        );

        await docRef.set({
          'roadmap': generatedRoadmap,
        }, SetOptions(merge: true));

        if (mounted) {
          try {
            final decoded = jsonDecode(generatedRoadmap);
            setState(() {
              _roadmapPhases = decoded is List ? decoded : [decoded];
              _isLoading = false;
            });
            _mainController.forward();
          } catch (e) {
            setState(() {
              _error = "L'IA a généré un format invalide. Veuillez réessayer.";
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Impossible de charger la roadmap. Veuillez réessayer.";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Custom SliverAppBar with gradient
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, Color(0xFF00D2FF)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(56, 0, 20, 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ROADMAP',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.program.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Body content
          SliverToBoxAdapter(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pulsing brain icon
              _PulsingIcon(animation: _pulseController),
              const SizedBox(height: 24),
              const Text(
                "L'IA construit votre parcours...",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3436),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Analyse des compétences et du marché",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child:
                      Icon(Icons.error_outline, color: Colors.red.shade300, size: 36),
                ),
                const SizedBox(height: 20),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _error = null;
                    });
                    _loadOrGenerateRoadmap();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text("Réessayer"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        children: [
          // Central Mind Map Node
          _buildCentralNode(),
          const SizedBox(height: 8),

          // Branch connectors + Phase nodes
          if (_roadmapPhases != null)
            ...List.generate(_roadmapPhases!.length, (index) {
              final phase = _roadmapPhases![index];
              final delay = index * 0.15;

              final slideAnim = Tween<Offset>(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _mainController,
                curve: Interval(delay, (delay + 0.35).clamp(0.0, 1.0),
                    curve: Curves.easeOutBack),
              ));

              final fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: _mainController,
                  curve: Interval(delay, (delay + 0.25).clamp(0.0, 1.0),
                      curve: Curves.easeIn),
                ),
              );

              return FadeTransition(
                opacity: fadeAnim,
                child: SlideTransition(
                  position: slideAnim,
                  child: _buildMindMapBranch(index, phase),
                ),
              );
            }),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ─── Central Hub Node ───
  Widget _buildCentralNode() {
    final scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
      ),
    );

    return ScaleTransition(
      scale: scaleAnim,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE8A838), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE8A838).withOpacity(0.15),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, color: Color(0xFFE8A838), size: 22),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                widget.program.name,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Mind Map Branch (connector + expand card) ───
  Widget _buildMindMapBranch(int index, dynamic phaseData) {
    final color = _phaseColors[index % _phaseColors.length];
    final icon = _phaseIcons[index % _phaseIcons.length];
    final title = phaseData['phase'] ?? 'Phase ${index + 1}';
    final description = phaseData['description'] ?? '';
    final List<dynamic> steps = phaseData['steps'] ?? [];
    final bool isExpanded = _expandedPhases.contains(index);

    // Alternate alignment: left / right for mind-map feel
    final bool isLeft = index.isEven;

    return Column(
      children: [
        // Vertical connector line from center
        Container(
          width: 2.5,
          height: 28,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withOpacity(0.2),
                color.withOpacity(0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // Phase Node Card
        GestureDetector(
          onTap: () {
            setState(() {
              if (isExpanded) {
                _expandedPhases.remove(index);
              } else {
                _expandedPhases.add(index);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            margin: EdgeInsets.only(
              left: isLeft ? 0 : 32,
              right: isLeft ? 32 : 0,
            ),
            padding: const EdgeInsets.all(0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isExpanded ? color : color.withOpacity(0.3),
                width: isExpanded ? 2 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(isExpanded ? 0.15 : 0.06),
                  blurRadius: isExpanded ? 16 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.06),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Numbered circle icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color, color.withOpacity(0.7)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(icon, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: color.withOpacity(0.9),
                              ),
                            ),
                            if (description.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                                maxLines: isExpanded ? 3 : 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Expand/collapse chevron
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: color,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),

                // Expandable Steps
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: _buildStepsList(steps, color),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 350),
                  sizeCurve: Curves.easeInOut,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Steps List inside expanded card ───
  Widget _buildStepsList(List<dynamic> steps, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: List.generate(steps.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step indicator dot with mini-connector
                Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: color.withOpacity(0.4)),
                      ),
                      child: Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    if (i < steps.length - 1)
                      Container(
                        width: 1.5,
                        height: 16,
                        color: color.withOpacity(0.2),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withOpacity(0.08)),
                    ),
                    child: Text(
                      steps[i].toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2D3436),
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ─── Pulsing Icon Widget (uses AnimatedWidget for compatibility) ───
class _PulsingIcon extends AnimatedWidget {
  const _PulsingIcon({required Animation<double> animation})
      : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    return Transform.scale(
      scale: 1.0 + (animation.value * 0.15),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3A7BD5), Color(0xFF00D2FF)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3A7BD5).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(Icons.psychology, color: Colors.white, size: 40),
      ),
    );
  }
}
