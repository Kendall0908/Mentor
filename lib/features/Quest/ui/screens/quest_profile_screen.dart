import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../auth/logic/auth_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/ui/widgets/custom_button.dart';
import 'quest_interests_screen.dart';

class QuestProfileScreen extends StatefulWidget {
  const QuestProfileScreen({super.key});

  @override
  State<QuestProfileScreen> createState() => _QuestProfileScreenState();
}

class _QuestProfileScreenState extends State<QuestProfileScreen> {
  String _selectedLevel = 'Université'; // Default
  String? _selectedSector;

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

  // Dynamic list of interests for the profile screen
  // Dynamic list of interests for the profile screen
  final List<Map<String, dynamic>> _profileInterests = [
    {'label': 'Mode', 'selected': false},
    {'label': 'Esthétique', 'selected': false},
    {'label': 'Beauté', 'selected': false},
    {'label': 'Coiffure', 'selected': false},
    {'label': 'Couture', 'selected': false},
    {'label': 'Sport', 'selected': false},
    {'label': 'Gaming', 'selected': false},
    {'label': 'Musique', 'selected': false},
    {'label': 'Cuisine', 'selected': false},
    {'label': 'Voyage', 'selected': false},
    {'label': 'Tech', 'selected': false},
    {'label': 'Art', 'selected': false},
    {'label': 'Science', 'selected': false},
    {'label': 'Business', 'selected': false},
    {'label': 'Nature', 'selected': false},
    {'label': 'Photographie', 'selected': false},
    {'label': 'Écriture', 'selected': false},
    {'label': 'Cinéma', 'selected': false},
    {'label': 'Architecture', 'selected': false},
    {'label': 'Médecine', 'selected': false},
    {'label': 'Droit', 'selected': false},
    {'label': 'Psychologie', 'selected': false},
    {'label': 'Ingénierie', 'selected': false},
    {'label': 'Éducation', 'selected': false},
  ];

  void _addNewInterest(String interest) async {
    if (interest.isNotEmpty) {
      setState(() {
        _profileInterests.add({'label': interest, 'selected': true});
      });
      
      // Sauvegarder dans Firestore - tous les intérêts sélectionnés
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          final selectedInterests = _profileInterests
              .where((e) => e['selected'] == true)
              .map((e) => e['label'])
              .toList();
          
          await AuthService().updateUserData(user.uid, {
            'interests': selectedInterests,
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Intérêt "$interest" ajouté et sauvegardé !'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur lors de la sauvegarde: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  void _showAddInterestDialog() {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Ajouter un intérêt", style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Ex: Intelligence Artificielle",
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.questBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              _addNewInterest(controller.text);
              Navigator.pop(context);
            },
            child: const Text("Ajouter", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadUserInterests();
  }

  /// Charge les intérêts de l'utilisateur depuis Firestore
  Future<void> _loadUserInterests() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userData = await AuthService().getUserData(user.uid);
        if (userData != null) {
          // Charger les intérêts sauvegardés
          // Charger les intérêts sauvegardés ou initiaux
          List<dynamic>? interestsToLoad = userData['interests'] as List?;
          if (interestsToLoad == null || interestsToLoad.isEmpty) {
            interestsToLoad = userData['orientation_initial_interests'] as List?;
          }

          if (interestsToLoad != null && interestsToLoad.isNotEmpty) {
            setState(() {
              // 1. Réinitialiser tout à non sélectionné d'abord
              for (var interest in _profileInterests) {
                interest['selected'] = false;
              }

              // 2. Parcourir les intérêts sauvegardés
              for (var savedItem in interestsToLoad!) {
                final String savedLabel = savedItem.toString();
                
                // Chercher si cet intérêt existe déjà dans la liste
                final index = _profileInterests.indexWhere(
                  (element) => element['label'].toString().toLowerCase() == savedLabel.toLowerCase()
                );

                if (index != -1) {
                  // Si oui, le marquer comme sélectionné
                  _profileInterests[index]['selected'] = true;
                } else {
                  // Si non (intérêt custom), l'ajouter à la liste
                  _profileInterests.add({
                    'label': savedLabel,
                    'selected': true,
                  });
                }
              }
            });
          }
          
          // Charger le niveau et la filière
          final level = userData['orientation_level'] as String?;
          final sector = userData['orientation_sector'] as String?;
          
          if (level != null) {
            setState(() {
              _selectedLevel = level;
            });
          }
          
          if (sector != null) {
            setState(() {
              _selectedSector = sector;
            });
          }
        }
      } catch (e) {
        debugPrint('Erreur lors du chargement des intérêts: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int selectedCount = _profileInterests.where((e) => e['selected']).length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          children: const [
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
              "PROFIL UNIVERSITÉ",
               style: TextStyle(
                 color: AppColors.textGrey, 
                 fontSize: 11, 
                 letterSpacing: 1.5,
                 fontWeight: FontWeight.w500
               ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              "Configuration du Profil",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.black,
                letterSpacing: -1.0, 
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Affinez vos préférences universitaires pour des recommandations sur-mesure.",
              style: TextStyle(
                color: Colors.grey.shade600, 
                fontSize: 15,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 35),
            
            // Level Selection
            _buildSectionHeader(Icons.school_rounded, "NIVEAU ACTUEL"),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: _buildLevelCard("Lycée", Icons.menu_book_rounded, _selectedLevel == "Lycée")),
                const SizedBox(width: 15),
                Expanded(child: _buildLevelCard("Université", Icons.account_balance_rounded, _selectedLevel == "Université")),
              ],
            ),

            const SizedBox(height: 35),

            // Sector Input (Dropdown)
            _buildSectionHeader(Icons.auto_stories_rounded, "VOTRE FILIÈRE"),
             const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.questBlue.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ]
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedSector,
                  hint: Row(
                    children: [
                      Icon(Icons.category_outlined, color: AppColors.questBlue.withOpacity(0.7), size: 20),
                      const SizedBox(width: 12),
                      const Text(
                        "Sélectionner votre filière",
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal, fontSize: 14),
                      ),
                    ],
                  ),
                  isExpanded: true,
                  icon: const Icon(Icons.expand_more_rounded, color: AppColors.questBlue),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    fontFamily: 'Poppins'
                  ),
                  borderRadius: BorderRadius.circular(16),
                  items: _sectors.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedSector = newValue;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 35),

            // Interests Tags Preview
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader(Icons.favorite_rounded, "VOS INTÉRÊTS"),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.questBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "$selectedCount SÉLECTIONNÉS",
                    style: const TextStyle(color: AppColors.questBlue, fontSize: 10, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ..._profileInterests.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, dynamic> interest = entry.value;
                  return GestureDetector(
                    onTap: () async {
                      setState(() {
                         _profileInterests[index]['selected'] = !_profileInterests[index]['selected'];
                      });
                      
                      // Sauvegarder dans Firestore
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        try {
                          await AuthService().updateUserData(user.uid, {
                            'interests': _profileInterests
                                .where((e) => e['selected'])
                                .map((e) => e['label'])
                                .toList(),
                          });
                        } catch (e) {
                          debugPrint('Erreur sauvegarde intérêts: $e');
                        }
                      }
                    },
                    child: _buildInterestTag(interest['label'], interest['selected']),
                  );
                }),
                
                GestureDetector(
                  onTap: _showAddInterestDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.questBlue, width: 1.5),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                         BoxShadow(
                           color: AppColors.questBlue.withOpacity(0.15),
                           blurRadius: 10,
                           offset: const Offset(0, 5),
                         )
                      ]
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.add_rounded, size: 18, color: AppColors.questBlue),
                        SizedBox(width: 4),
                        Text("Ajouter", style: TextStyle(color: AppColors.questBlue, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 50),

            CustomButton(
              text: "Continuer",
              onPressed: () async {
                final uid = FirebaseAuth.instance.currentUser?.uid;
                if (uid != null) {
                  await AuthService().updateUserData(uid, {
                    'orientation_level': _selectedLevel,
                    'orientation_sector': _selectedSector,
                    'orientation_initial_interests': _profileInterests
                        .where((e) => e['selected'] == true)
                        .map((e) => e['label'])
                        .toList(),
                  });
                }
                if (mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const QuestInterestsScreen()),
                  );
                }
              },
              type: ButtonType.primary,
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                "PROFIL MODIFIABLE À TOUT MOMENT",
                style: TextStyle(
                  fontSize: 10, 
                  color: Colors.black.withOpacity(0.4), 
                  fontWeight: FontWeight.bold, 
                  letterSpacing: 1.5
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColors.questBlue, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 13,
            color: Colors.grey.shade800,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildLevelCard(String title, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLevel = title;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: 120,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.questBlue : Colors.white, // Blue background when selected looks more premium
          border: Border.all(
            color: isSelected ? AppColors.questBlue : Colors.grey.shade200,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: AppColors.questBlue.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10))
                ]
              : [
                   BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
              ],
        ),
        child: Stack(
          children: [
            if (isSelected)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2), 
                    shape: BoxShape.circle
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
              ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon, 
                      color: isSelected ? AppColors.questBlue : Colors.grey.shade400,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestTag(String label, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.questBlue : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: isSelected ? [
           BoxShadow(
             color: AppColors.questBlue.withOpacity(0.3),
             blurRadius: 12,
             offset: const Offset(0, 6),
           )
        ] : [
           BoxShadow(
             color: Colors.black.withOpacity(0.05),
             blurRadius: 5,
             offset: const Offset(0, 2),
           )
        ],
        border: isSelected ? null : Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelected) ...[
            const Icon(Icons.check, color: Colors.white, size: 14),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade700,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
