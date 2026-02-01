import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'all_tracks_screen.dart';
import '../../../Quest/ui/screens/quest_welcome_screen.dart';
import '../../../auth/logic/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  // Données initiales pour les filières
  final List<Map<String, dynamic>> _allTracks = [
    {
      "title": "Informatique & IA",
      "subtitle": "Le secteur qui recrute massivement en 2024",
      "imageUrl": "https://images.unsplash.com/photo-1518770660439-4636190af475?w=500&q=80",
      "tag": "TOP 1",
      "tagColor": Colors.blue,
    },
    {
      "title": "Sciences de l'Env",
      "subtitle": "Innover pour un avenir durable",
      "imageUrl": "https://images.unsplash.com/photo-1473341304170-971dccb5ac1e?w=500&q=80",
      "tag": "DURABLE",
      "tagColor": Colors.green,
    },
    {
      "title": "Médecine & Santé",
      "subtitle": "Prendre soin des autres, une vocation d'avenir",
      "imageUrl": "https://images.unsplash.com/photo-1584982681876-bd444391ac3c?w=500&q=80",
      "tag": "ESSENTIEL",
      "tagColor": Colors.red,
    },
    {
      "title": "Droit & Science Po",
      "subtitle": "Comprendre les règles du monde",
      "imageUrl": "https://images.unsplash.com/photo-1589216532372-1c2a367900d9?w=500&q=80",
      "tag": "PRESTIGE",
      "tagColor": Colors.indigo,
    },
    {
      "title": "Architecture & Design",
      "subtitle": "Bâtir les espaces de demain",
      "imageUrl": "https://images.unsplash.com/photo-1503387762-592dee58c460?w=500&q=80",
      "tag": "CRÉATIF",
      "tagColor": Colors.orange,
    },
    {
      "title": "Aéronautique",
      "subtitle": "S'envoler vers de nouveaux horizons",
      "imageUrl": "https://images.unsplash.com/photo-1517976487492-5750f3195933?w=500&q=80",
      "tag": "TECHNIQUE",
      "tagColor": Colors.lightBlue,
    },
  ];

  // Données initiales pour les métiers
  final List<Map<String, dynamic>> _allCareers = [
    {
      "title": "Data Scientist",
      "subtitle": "Analyser les données pour prédire le futur.",
      "icon": Icons.trending_up,
      "iconBg": const Color(0xFFE3F2FD),
      "tags": ["Bac +5", "45k€+ / an"],
    },
    {
      "title": "UX Designer",
      "subtitle": "Concevoir des expériences numériques fluides.",
      "icon": Icons.lightbulb_outline,
      "iconBg": const Color(0xFFFFF3E0),
      "tags": ["Bac +3/5", "38k€+ / an"],
    },
    {
      "title": "Gestionnaire de Projets",
      "subtitle": "Coordonner les équipes vers la réussite.",
      "icon": Icons.assignment,
      "iconBg": const Color(0xFFF1F8E9),
      "tags": ["Bac +5", "42k€+ / an"],
    },
  ];

  // Listes filtrées
  List<Map<String, dynamic>> _filteredTracks = [];
  List<Map<String, dynamic>> _filteredCareers = [];

  final AuthService _authService = AuthService();
  
  @override
  void initState() {
    super.initState();
    _filteredTracks = List.from(_allTracks);
    _filteredCareers = List.from(_allCareers);
    _searchController.addListener(_onSearchChanged);
    _loadCustomCareers();
  }

  Future<void> _loadCustomCareers() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userData = await _authService.getUserData(user.uid);
        if (userData != null && userData['custom_careers'] != null) {
          final List<dynamic> customList = userData['custom_careers'];
          
          setState(() {
            for (var career in customList) {
              _allCareers.insert(0, {
                "title": career["title"],
                "subtitle": career["subtitle"],
                "icon": IconData(career["icon"], fontFamily: 'MaterialIcons'),
                "iconBg": Color(career["iconBg"]).withOpacity(0.1),
                "tags": List<String>.from(career["tags"]),
              });
            }
            _onSearchChanged();
          });
        }
      } catch (e) {
        debugPrint("Erreur chargement métiers: $e");
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTracks = _allTracks.where((t) {
        return t['title'].toLowerCase().contains(query) || 
               t['subtitle'].toLowerCase().contains(query);
      }).toList();
      
      _filteredCareers = _allCareers.where((c) {
        return c['title'].toLowerCase().contains(query) || 
               c['subtitle'].toLowerCase().contains(query);
      }).toList();
    });
  }

  void _showAddDialog() {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 25,
          left: 20,
          right: 20,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Ajouter une nouvelle piste",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Titre (ex: Architecte)",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: subtitleController,
              decoration: InputDecoration(
                labelText: "Description courte",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  if (titleController.text.isNotEmpty) {
                    final newCareer = {
                      "title": titleController.text,
                      "subtitle": subtitleController.text.isNotEmpty 
                          ? subtitleController.text 
                          : "Nouveau métier ajouté",
                      "icon": Icons.stars.codePoint, // Sauvegarder codePoint pour Firestore
                      "iconBg": Colors.amber.value, // Sauvegarder la valeur de couleur
                      "tags": ["Nouveau"],
                    };

                    setState(() {
                      _allCareers.insert(0, {
                        "title": titleController.text,
                        "subtitle": newCareer["subtitle"],
                        "icon": Icons.stars,
                        "iconBg": Colors.amber.shade50,
                        "tags": ["Nouveau"],
                      });
                      _onSearchChanged();
                    });

                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      await _authService.addCustomCareer(user.uid, newCareer);
                    }

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Élément ajouté avec succès !")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.questBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Ajouter à l'exploration", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        title: const Text(
          "Explorer MentOr",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: false,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(Icons.school, color: AppColors.questBlue, size: 28),
        ),
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundColor: Colors.grey.shade100,
              child: const Icon(Icons.notifications, color: Colors.black, size: 20),
            ),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Colors.grey.shade400),
                  hintText: "Rechercher une filière, un métier...",
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  border: InputBorder.none,
                  suffixIcon: _searchController.text.isNotEmpty 
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                ),
              ),
            ),
            
            const SizedBox(height: 25),

            // Personalize Recommendations Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                children: [
                   Container(
                     padding: const EdgeInsets.all(12),
                     decoration: const BoxDecoration(
                       color: AppColors.questBlue,
                       shape: BoxShape.circle,
                     ),
                     child: const Icon(Icons.upload_file, color: Colors.white),
                   ),
                   const SizedBox(width: 15),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         const Text(
                           "Personnaliser mes recommandations",
                           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black),
                         ),
                         const SizedBox(height: 4),
                         Text(
                           "Ajoutez votre CV ou bulletin pour une orientation sur mesure.",
                           style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                         ),
                         const SizedBox(height: 15),
                         SizedBox(
                           width: double.infinity,
                           height: 45,
                           child: ElevatedButton.icon(
                             onPressed: () {},
                             icon: const Icon(Icons.add_circle_outline, size: 18),
                             label: const Text("Déposer un document", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                             style: ElevatedButton.styleFrom(
                               backgroundColor: AppColors.questBlue,
                               foregroundColor: Colors.white,
                               elevation: 0,
                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                             ),
                           ),
                         )
                       ],
                     ),
                   )
                ],
              ),
            ),

            const SizedBox(height: 35),

            // Trending Tracks
            _sectionHeader("Filières en vogue", "Voir tout", onAction: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllTracksScreen(tracks: _allTracks),
                ),
              );
            }),
            const SizedBox(height: 15),
            SizedBox(
              height: 220,
              child: _filteredTracks.isEmpty 
                ? const Center(child: Text("Aucun résultat pour cette filière"))
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filteredTracks.length,
                    itemBuilder: (context, index) {
                      final track = _filteredTracks[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: _buildTrackCard(
                          track['title'], 
                          track['subtitle'], 
                          track['imageUrl'],
                          track['tag'],
                          track['tagColor'],
                        ),
                      );
                    },
                  ),
            ),

            const SizedBox(height: 35),

            // Future Careers
            _sectionHeader("Métiers d’avenir", "Filtrer"),
            const SizedBox(height: 15),
            if (_filteredCareers.isEmpty) 
               const Padding(
                 padding: EdgeInsets.symmetric(vertical: 20),
                 child: Center(child: Text("Aucun métier trouvé")),
               )
            else
               ..._filteredCareers.map((career) => Padding(
                 padding: const EdgeInsets.only(bottom: 10),
                 child: _buildCareerItem(
                   career['title'], 
                   career['subtitle'], 
                   career['icon'], 
                   career['iconBg'],
                   career['tags'],
                 ),
               )).toList(),

            const SizedBox(height: 35),

            // Partner Schools
            _sectionHeader("Établissements partenaires", "Carte"),
            const SizedBox(height: 15),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                   _buildSchoolCircle("Polytechnique", "Palaiseau", "https://logowik.com/content/uploads/images/ecole-polytechnique6092.jpg"),
                   const SizedBox(width: 25),
                   _buildSchoolCircle("Goblins Paris", "Paris", "https://pbs.twimg.com/profile_images/1541785514659176449/7O7y_Y5C_400x400.jpg"),
                   const SizedBox(width: 25),
                   _buildSchoolCircle("HEC Business", "Jouy-en-Josas", "https://www.hec.edu/sites/default/files/styles/logo_header_mobile/public/2021-03/logo-hec-paris-noir.png?itok=8Z7o0qQo"),
                ],
              ),
            ),
            
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: AppColors.questBlue,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _sectionHeader(String title, String action, {VoidCallback? onAction}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title, 
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)
        ),
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            action, 
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.questBlue)
          ),
        ),
      ],
    );
  }

  Widget _buildTrackCard(String title, String subtitle, String imageUrl, String tag, Color tagColor) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Stack(
              children: [
                Image.network(
                  imageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 120,
                      width: double.infinity,
                      color: Colors.grey.shade100,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 120,
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_not_supported_outlined, color: Colors.grey.shade400),
                        const SizedBox(height: 4),
                        Text(
                          "Image non disponible",
                          style: TextStyle(fontSize: 8, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: tagColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tag, 
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle, 
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCareerItem(String title, String subtitle, IconData icon, Color iconBg, List<String> tags) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.black.withOpacity(0.7)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black)
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle, 
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: tags.map((t) => Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(t, style: TextStyle(color: Colors.grey.shade600, fontSize: 9, fontWeight: FontWeight.bold)),
                  )).toList(),
                )
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade300),
        ],
      ),
    );
  }

  Widget _buildSchoolCircle(String name, String city, String logoUrl) {
    return Column(
      children: [
        Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Image.network(
              logoUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.school, size: 20, color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name, 
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black)
        ),
        Text(
          city, 
          style: TextStyle(fontSize: 9, color: Colors.grey.shade500)
        ),
      ],
    );
  }
}
