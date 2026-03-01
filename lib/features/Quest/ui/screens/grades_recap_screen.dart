import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/logic/auth_service.dart';
import '../../../auth/ui/widgets/custom_button.dart';
import 'quest_welcome_screen.dart';

class GradesRecapScreen extends StatefulWidget {
  final List<String> classes;
  final Map<String, Map<String, double>>? extractedGrades;

  const GradesRecapScreen({
    super.key,
    required this.classes,
    this.extractedGrades,
  });

  @override
  State<GradesRecapScreen> createState() => _GradesRecapScreenState();
}

class _GradesRecapScreenState extends State<GradesRecapScreen> {
  final AuthService _authService = AuthService();

  // Matières principales du système camerounais
  static const List<String> _defaultSubjects = [
    'Mathématiques',
    'Français',
    'Anglais',
    'Physique',
    'Chimie',
    'SVT',
    'Histoire-Géographie',
    'Philosophie',
    'Informatique',
    'EPS',
  ];

  // Map: className -> subjectName -> average (as double)
  final Map<String, Map<String, TextEditingController>> _controllers = {};
  final Map<String, double?> _generalAverages = {};

  // Track expanded classes
  final Set<String> _expandedClasses = {};

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    for (var className in widget.classes) {
      _controllers[className] = {};
      
      final extractedForClass = widget.extractedGrades?[className];
      if (extractedForClass != null && extractedForClass.isNotEmpty) {
        // Si on a des données extraites, on n'affiche QUE celles-là
        for (var subject in extractedForClass.keys) {
          _controllers[className]![subject] = TextEditingController();
        }
      } else {
        // Si aucune extraction, on garde les matières par défaut comme base
        for (var subject in _defaultSubjects) {
          _controllers[className]![subject] = TextEditingController();
        }
      }
    }
    // Expand the most recent class by default
    if (widget.classes.isNotEmpty) {
      _expandedClasses.add(widget.classes.last);
    }
    // Pré-remplir avec les notes extraites par l'IA
    if (widget.extractedGrades != null) {
      _prefillFromExtractedGrades();
    }
  }

  /// Pré-remplit les champs avec les notes extraites par l'IA
  void _prefillFromExtractedGrades() {
    for (var className in widget.classes) {
      final grades = widget.extractedGrades?[className];
      if (grades == null) continue;
      for (var entry in grades.entries) {
        final subject = entry.key;
        final value = entry.value;

        // On s'assure que le controller existe (devrait déjà être le cas via initState)
        if (_controllers[className]?.containsKey(subject) == false) {
          _controllers[className]![subject] = TextEditingController();
        }

        _controllers[className]![subject]!.text = value.toStringAsFixed(1);
      }
    }
  }

  /// Permet d'ajouter une matière manuellement (cas où l'IA rate une matière)
  void _addNewSubject(String className) {
    final TextEditingController subjectNameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ajouter une matière"),
        content: TextField(
          controller: subjectNameController,
          decoration: const InputDecoration(
            hintText: "Nom de la matière (ex: Latin)",
            labelText: "Matière",
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              final name = subjectNameController.text.trim();
              if (name.isNotEmpty) {
                setState(() {
                  _controllers[className]![name] = TextEditingController();
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Ajouter"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (var classControllers in _controllers.values) {
      for (var controller in classControllers.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  /// Calcule la moyenne générale pour une classe donnée
  double? _calculateGeneralAverage(String className) {
    final controllers = _controllers[className];
    if (controllers == null) return null;

    double total = 0;
    int count = 0;
    for (var controller in controllers.values) {
      final text = controller.text.trim();
      if (text.isNotEmpty) {
        final value = double.tryParse(text.replaceAll(',', '.'));
        if (value != null && value >= 0 && value <= 20) {
          total += value;
          count++;
        }
      }
    }
    if (count == 0) return null;
    return total / count;
  }

  Future<void> _saveAndContinue() async {
    setState(() => _isSaving = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception("Utilisateur non connecté");

      // Build grades data
      final Map<String, dynamic> gradesData = {};

      for (var className in widget.classes) {
        final Map<String, dynamic> classGrades = {};
        final controllers = _controllers[className]!;

        for (var entry in controllers.entries) {
          final text = entry.value.text.trim();
          if (text.isNotEmpty) {
            final value = double.tryParse(text.replaceAll(',', '.'));
            if (value != null) {
              classGrades[entry.key] = value;
            }
          }
        }

        final generalAvg = _calculateGeneralAverage(className);
        if (generalAvg != null) {
          classGrades['moyenne_generale'] = double.parse(generalAvg.toStringAsFixed(2));
        }

        gradesData[className] = classGrades;
      }

      await _authService.updateUserData(uid, {
        'grades': gradesData,
      });

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const QuestWelcomeScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          children: [
            Text(
              "MentOr",
              style: TextStyle(
                color: AppColors.questBlue,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              "MOYENNES SCOLAIRES",
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.withOpacity(0.12),
                          Colors.orange.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.orange.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.bar_chart_rounded,
                            color: Colors.orange,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Récap de vos moyennes",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Entrez vos moyennes par matière pour chaque classe (sur 20).",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Class accordions (most recent first)
                  for (var className in widget.classes.reversed)
                    _buildClassGradesAccordion(className),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Bottom bar
          Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                CustomButton(
                  text: _isSaving ? "Enregistrement..." : "Continuer",
                  onPressed: _isSaving ? null : _saveAndContinue,
                  type: ButtonType.primary,
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _isSaving
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const QuestWelcomeScreen(),
                            ),
                          );
                        },
                  child: Text(
                    "Passer cette étape",
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
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

  Widget _buildClassGradesAccordion(String className) {
    final bool isExpanded = _expandedClasses.contains(className);
    final controllers = _controllers[className] ?? {};
    final int filledCount = controllers.values
        .where((c) => c.text.trim().isNotEmpty)
        .length;
    final generalAvg = _calculateGeneralAverage(className);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isExpanded
              ? AppColors.questBlue.withOpacity(0.3)
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: isExpanded
                ? AppColors.questBlue.withOpacity(0.08)
                : Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedClasses.remove(className);
                } else {
                  _expandedClasses.add(className);
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.questBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.school_rounded,
                        color: AppColors.questBlue,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              className,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            if (generalAvg != null) ...[
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: generalAvg >= 10
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "Moy: ${generalAvg.toStringAsFixed(1)}/20",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: generalAvg >= 10
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "$filledCount/${controllers.length} matières renseignées",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: isExpanded ? 0.5 : 0,
                    child: Icon(
                      Icons.expand_more_rounded,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expanded: subject inputs
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  for (var subject in controllers.keys)
                    _buildSubjectRow(className, subject),
                  const SizedBox(height: 8),
                  // Bouton pour ajouter manuellement une matière manquante
                  TextButton.icon(
                    onPressed: () => _addNewSubject(className),
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    label: const Text("Ajouter une autre matière"),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.questBlue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectRow(String className, String subject) {
    final controller = _controllers[className]![subject]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Subject icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.questBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(
                _getSubjectIcon(subject),
                color: AppColors.questBlue,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Subject name
          Expanded(
            child: Text(
              subject,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.black,
              ),
            ),
          ),

          // Grade input
          SizedBox(
            width: 75,
            height: 42,
            child: TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: _isValid(controller.text)
                    ? AppColors.questBlue
                    : Colors.red,
              ),
              decoration: InputDecoration(
                hintText: "0-20",
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: _isValid(controller.text)
                        ? Colors.grey.shade300
                        : Colors.red.withOpacity(0.5),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: _isValid(controller.text)
                        ? Colors.grey.shade300
                        : Colors.red.withOpacity(0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: _isValid(controller.text)
                        ? AppColors.questBlue
                        : Colors.red,
                    width: 1.5,
                  ),
                ),
              ),
              onChanged: (_) {
                setState(() {}); // Refresh averages et validation visuelle
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _isValid(String text) {
    if (text.isEmpty) return true;
    final val = double.tryParse(text.replaceAll(',', '.'));
    return val != null && val >= 0 && val <= 20;
  }

  IconData _getSubjectIcon(String subject) {
    switch (subject) {
      case 'Mathématiques':
        return Icons.calculate_rounded;
      case 'Français':
        return Icons.menu_book_rounded;
      case 'Anglais':
        return Icons.language_rounded;
      case 'Physique':
        return Icons.science_rounded;
      case 'Chimie':
        return Icons.biotech_rounded;
      case 'SVT':
        return Icons.eco_rounded;
      case 'Histoire-Géographie':
        return Icons.public_rounded;
      case 'Philosophie':
        return Icons.psychology_rounded;
      case 'Informatique':
        return Icons.computer_rounded;
      case 'EPS':
        return Icons.fitness_center_rounded;
      default:
        return Icons.book_rounded;
    }
  }
}
