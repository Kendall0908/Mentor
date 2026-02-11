import 'package:flutter/material.dart';
import 'package:mentor/features/flieres/data/program_data.dart';
import '../../../../core/models/ecole_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mentor/features/home/ui/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mentor/features/auth/logic/auth_service.dart';

class ProgramDetailScreenDynamic extends StatelessWidget {
  final ProgramData programData;

  const ProgramDetailScreenDynamic({super.key, required this.programData});

  Future<void> _openWebsite(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(programData.name),
        centerTitle: true,
        actions: [
           if (user != null)
            StreamBuilder<List<String>>(
              stream: AuthService().getFavorites(user.uid),
              builder: (context, snapshot) {
                final favorites = snapshot.data ?? [];
                final isFavorite = favorites.contains(programData.id);

                return IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.white,
                  ),
                  onPressed: () {
                    AuthService().toggleFavorite(user.uid, programData.id);
                  },
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Retour à l\'accueil',
            onPressed: () {
              // Navigate to home screen and remove all previous routes
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// HERO IMAGE
            Stack(
              children: [
                Image.network(
                  programData.imageUrl,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 220,
                      width: double.infinity,
                      color: Colors.blue.shade100,
                      child: const Icon(Icons.broken_image, size: 50, color: Colors.blue),
                    );
                  },
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'TENDANCE',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            ),

            const SizedBox(height: 20),

            /// MATCH CARD
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "🎯 Compatibilité ${programData.matchPercentage}%",
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                  const SizedBox(height: 8),
                  Text(programData.matchDescription),
                ],
              ),
            ),

            /// INFOS
            _card(
              child: Column(
                children: [
                  _infoRow("Durée", programData.duration),
                  _infoRow("Diplôme", programData.durationType),
                  _infoRow("Demande", programData.demand),
                  _infoRow(
                    "Salaire",
                    "${programData.salaryMin} – ${programData.salaryMax} €",
                  ),
                ],
              ),
            ),

            /// SKILLS
            _sectionTitle("Compétences clés"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: programData.skills
                    .map(
                      (s) => Chip(
                        label: Text(s),
                        backgroundColor: Colors.blue.shade50,
                      ),
                    )
                    .toList(),
              ),
            ),
            
            /// MEDIA SECTION (New)
            if (programData.videoLinks.isNotEmpty || programData.audioLinks.isNotEmpty) ...[
               _sectionTitle("Multimédia"),
               if (programData.videoLinks.isNotEmpty) ...[
                 Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                   child: const Text("Vidéos", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                 ),
                 ...programData.videoLinks.map((video) => _mediaValidCard(
                   title: video['title'] ?? '',
                   icon: Icons.play_circle_fill,
                   color: Colors.red,
                   onTap: () => _openWebsite(video['url'] ?? ''),
                 )),
               ],
               if (programData.audioLinks.isNotEmpty) ...[
                 Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                   child: const Text("Audios", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                 ),
                 ...programData.audioLinks.map((audio) => _mediaValidCard(
                   title: audio['title'] ?? '',
                   icon: Icons.headset,
                   color: Colors.orange,
                   onTap: () => _openWebsite(audio['url'] ?? ''),
                 )),
               ],
            ],

            /// SCHOOLS
            if (programData.availableSchools.isNotEmpty) ...[
              _sectionTitle("Écoles disponibles (${programData.availableSchools.length})"),
              ...programData.availableSchools.take(10).map(
                (school) => _realSchoolCard(school),
              ),
              if (programData.availableSchools.length > 10)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      "+ ${programData.availableSchools.length - 10} autres écoles",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                ),
            ] else ...[
              _sectionTitle("Écoles recommandées"),
              ...programData.schools.map(
                (school) => _schoolCard(school),
              ),
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }


  Widget _realSchoolCard(EcoleModel school) {
    return RealSchoolCard(school: school, programName: programData.name);
  }

  Widget _schoolCard(SchoolData school) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            )
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                school.imageUrl,
                width: 48,
                height: 48,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 48,
                    height: 48,
                    color: Colors.grey.shade100,
                    child: const Icon(Icons.school, color: Colors.grey),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 48,
                    height: 48,
                    color: Colors.grey.shade100,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    school.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    school.locationText,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 36,
              child: ElevatedButton(
                onPressed: () => _openWebsite(school.websiteUrl),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Site", style: TextStyle(fontSize: 12)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 30, 16, 10),
      child: Text(title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  Widget _card({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _mediaValidCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
      ),
    );
  }
}

class RealSchoolCard extends StatefulWidget {
  final EcoleModel school;
  final String programName;

  const RealSchoolCard({super.key, required this.school, required this.programName});

  @override
  State<RealSchoolCard> createState() => _RealSchoolCardState();
}

class _RealSchoolCardState extends State<RealSchoolCard> {
  bool _isExpanded = false;
  bool _isLoading = false;

  Future<void> _validateChoice() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez vous connecter pour valider ce choix.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService().saveUserChoice(user.uid, {
        'programName': widget.programName,
        'schoolName': widget.school.etablissement,
        'schoolCity': widget.school.ville,
        'schoolId': widget.school.numero,
        'validatedAt': DateTime.now().toIso8601String(),
        'status': 'validated',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Choix validé : ${widget.programName} à ${widget.school.etablissement}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.school, color: Colors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.school.etablissement,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "${widget.school.commune}, ${widget.school.ville}",
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Scolarité",
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                    ),
                    Text(
                      widget.school.fraisInscription,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Capacité",
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.school.capaciteAccueil,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            // Expandable Section
            if (_isExpanded) ...[
              const SizedBox(height: 16),
              const Text("Filières disponibles :", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: widget.school.filieres.map((f) => Chip(
                  label: Text(f, style: const TextStyle(fontSize: 10)),
                  backgroundColor: Colors.grey.shade50,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                )).toList(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : () {
                    // Confirmation dialog
                    showDialog(
                      context: context, 
                      builder: (ctx) => AlertDialog(
                        title: const Text("Valider ce choix ?"),
                        content: Text("Vous allez choisir la filière ${widget.programName} à ${widget.school.etablissement}."),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _validateChoice();
                            }, 
                            child: const Text("Confirmer"),
                          )
                        ],
                      )
                    );
                  },
                  icon: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check_circle_outline),
                  label: Text(_isLoading ? "Validation..." : "Valider ce choix"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],

            // Expand Toggle Button
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: () => setState(() => _isExpanded = !_isExpanded),
                icon: Icon(_isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 16),
                label: Text(_isExpanded ? "Moins de détails" : "Voir détails & Valider", style: const TextStyle(fontSize: 12)),
style: TextButton.styleFrom(foregroundColor: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
