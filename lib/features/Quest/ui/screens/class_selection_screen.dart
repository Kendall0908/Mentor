import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../auth/logic/auth_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/ui/widgets/custom_button.dart';
import 'bulletin_upload_screen.dart';

class ClassSelectionScreen extends StatefulWidget {
  const ClassSelectionScreen({super.key});

  @override
  State<ClassSelectionScreen> createState() => _ClassSelectionScreenState();
}

class _ClassSelectionScreenState extends State<ClassSelectionScreen> {
  String? _selectedClass;
  String? _selectedSector;
  String _expandedSection = 'secondary'; // 'secondary' ou 'university'

  // Classes du système secondaire
  static const List<Map<String, dynamic>> _secondaryClasses = [
    {'label': '6ème', 'level': 'Collège', 'icon': Icons.menu_book_rounded},
    {'label': '5ème', 'level': 'Collège', 'icon': Icons.menu_book_rounded},
    {'label': '4ème', 'level': 'Collège', 'icon': Icons.menu_book_rounded},
    {'label': '3ème', 'level': 'Collège', 'icon': Icons.menu_book_rounded},
    {'label': '2nde', 'level': 'Lycée', 'icon': Icons.school_rounded},
    {'label': '1ère', 'level': 'Lycée', 'icon': Icons.school_rounded},
    {'label': 'Tle', 'level': 'Lycée', 'icon': Icons.school_rounded},
  ];

  // Niveaux universitaires
  static const List<Map<String, dynamic>> _universityLevels = [
    {'label': 'Licence 1', 'level': 'Université', 'icon': Icons.account_balance_rounded},
    {'label': 'Licence 2', 'level': 'Université', 'icon': Icons.account_balance_rounded},
    {'label': 'Licence 3', 'level': 'Université', 'icon': Icons.account_balance_rounded},
    {'label': 'Master 1', 'level': 'Université', 'icon': Icons.workspace_premium_rounded},
    {'label': 'Master 2', 'level': 'Université', 'icon': Icons.workspace_premium_rounded},
    {'label': 'Doctorat', 'level': 'Université', 'icon': Icons.history_edu_rounded},
  ];

  final List<String> _sectors = [
    'Informatique & Numérique',
    'Sciences (Maths, Physique, chimie)',
    'Lettres & Langues',
    'Économie & Gestion',
    'Droit & Sciences Politiques',
    'Santé & Médecine',
    'Arts & Design',
    'Sciences de l\'Ingénieur',
    'Sciences Humaines & Sociales',
    'Commerce & Marketing',
    'Autre'
  ];

  /// Retourne les 3 dernières classes
  List<String> _getClassesUpTo(String currentClass) {
    // Chercher dans le secondaire
    final secIdx = _secondaryClasses.indexWhere((c) => c['label'] == currentClass);
    if (secIdx != -1) {
      final start = (secIdx - 2).clamp(0, _secondaryClasses.length);
      return _secondaryClasses.sublist(start, secIdx + 1).map((c) => c['label'] as String).toList();
    }

    // Chercher dans l'université
    final univIdx = _universityLevels.indexWhere((c) => c['label'] == currentClass);
    if (univIdx != -1) {
      final start = (univIdx - 2).clamp(0, _universityLevels.length);
      return _universityLevels.sublist(start, univIdx + 1).map((c) => c['label'] as String).toList();
    }

    return [currentClass]; // Fallback
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Orientation MentOr"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.questBlue,
                    AppColors.questBlue.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.questBlue.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.school, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Dans quelle classe\nêtes-vous ?",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Sélectionnez votre classe actuelle pour personnaliser votre expérience.",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.85),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Secondary Section
            _buildExpandableSection(
              title: "COLLÈGE & LYCÉE",
              icon: Icons.school_rounded,
              isExpanded: _expandedSection == 'secondary',
              onToggle: () => setState(() => _expandedSection = 'secondary'),
              children: [
                for (var c in _secondaryClasses) _buildClassTile(c),
              ],
            ),

            const SizedBox(height: 16),

            // University Section
            _buildExpandableSection(
              title: "UNIVERSITÉ",
              icon: Icons.account_balance_rounded,
              isExpanded: _expandedSection == 'university',
              onToggle: () => setState(() => _expandedSection = 'university'),
              children: [
                for (var c in _universityLevels) _buildClassTile(c),
                if (_selectedClass != null && _universityLevels.any((l) => l['label'] == _selectedClass)) ...[
                  const SizedBox(height: 16),
                  _buildSectorDropdown(),
                ]
              ],
            ),

            const SizedBox(height: 40),

            // Continue button
            CustomButton(
              text: "Continuer",
              onPressed: _isContinueDisabled()
                  ? null
                  : () async {
                      final uid = FirebaseAuth.instance.currentUser?.uid;
                      if (uid != null) {
                        await AuthService().updateUserData(uid, {
                          'currentClass': _selectedClass,
                          'orientation_sector': _selectedSector, // Ajout du secteur
                        });
                      }
                      if (mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BulletinUploadScreen(
                              currentClass: _selectedClass!,
                              classesUpTo: _getClassesUpTo(_selectedClass!),
                            ),
                          ),
                        );
                      }
                    },
              type: ButtonType.primary,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  bool _isContinueDisabled() {
    if (_selectedClass == null) return true;
    // Si c'est un niveau universitaire, la filière est obligatoire
    if (_universityLevels.any((l) => l['label'] == _selectedClass) && _selectedSector == null) {
      return true;
    }
    return false;
  }

  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required List<Widget> children,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isExpanded ? AppColors.questBlue.withOpacity(0.05) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isExpanded ? AppColors.questBlue : Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: isExpanded ? AppColors.questBlue : Colors.grey, size: 20),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isExpanded ? AppColors.questBlue : Colors.grey.shade700,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                Icon(
                  isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  color: isExpanded ? AppColors.questBlue : Colors.grey,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(height: 12),
          ...children,
        ],
      ],
    );
  }

  Widget _buildSectorDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            "VOTRE FILIÈRE",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              color: Colors.grey.shade600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedSector,
              hint: const Text("Sélectionner votre filière", style: TextStyle(fontSize: 14)),
              isExpanded: true,
              items: [
                for (var s in _sectors)
                  DropdownMenuItem(
                    value: s,
                    child: Text(s, style: const TextStyle(fontSize: 14)),
                  ),
              ],
              onChanged: (val) => setState(() => _selectedSector = val),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClassTile(Map<String, dynamic> classData) {
    final String label = classData['label'];
    final bool isSelected = _selectedClass == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedClass = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.questBlue : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.questBlue : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.questBlue.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                classData['icon'],
                color: isSelected ? Colors.white : AppColors.questBlue,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    classData['level'],
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? Colors.white.withOpacity(0.8)
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.white : Colors.transparent,
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: AppColors.questBlue, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
