import 'package:flutter/material.dart';
import 'package:mentor/features/Quest/data/ai_recommendation_service.dart';

/// Écran de démonstration pour tester le système de recommandation
/// Utilisation : Naviguer vers cet écran depuis n'importe où dans l'app
class AIRecommendationDemoScreen extends StatefulWidget {
  const AIRecommendationDemoScreen({super.key});

  @override
  State<AIRecommendationDemoScreen> createState() => _AIRecommendationDemoScreenState();
}

class _AIRecommendationDemoScreenState extends State<AIRecommendationDemoScreen> {
  List<ProgramRecommendation> _recommendations = [];
  bool _isLoading = false;
  String _selectedProfile = 'tech';

  // Profils de test prédéfinis
  final Map<String, Map<String, dynamic>> _testProfiles = {
    'tech': {
      'name': '👨‍💻 Profil Tech',
      'passions': ['Tech', 'Gaming', 'Musique'],
      'skills': {'Mathématiques': 2.0, 'Sciences': 2.0},
      'environment': ['Bureau', 'Cadre Structuré'],
    },
    'creative': {
      'name': '🎨 Profil Créatif',
      'passions': ['Art', 'Mode', 'Esthétique'],
      'skills': {'Langues': 1.0, 'Littérature': 1.0},
      'environment': ['Studio Créatif', 'Travail en Équipe'],
    },
    'business': {
      'name': '💼 Profil Business',
      'passions': ['Voyage', 'Mode', 'Cuisine'],
      'skills': {'Langues': 2.0, 'Mathématiques': 1.0, 'Histoire-Géo': 1.0},
      'environment': ['Bureau', 'Travail en Équipe', 'Terrain'],
    },
    'beauty': {
      'name': '💅 Profil Beauté',
      'passions': ['Beauté', 'Esthétique', 'Mode', 'Coiffure'],
      'skills': {'Sciences': 1.0},
      'environment': ['Studio Créatif', 'Travail en Équipe'],
    },
    'health': {
      'name': '🏥 Profil Santé',
      'passions': ['Sport', 'Beauté', 'Voyage'],
      'skills': {'Sciences': 3.0, 'Mathématiques': 2.0},
      'environment': ['Cadre Structuré', 'Travail en Équipe'],
    },
  };

  @override
  void initState() {
    super.initState();
    _generateRecommendations();
  }

  Future<void> _generateRecommendations() async {
    setState(() => _isLoading = true);

    final profile = _testProfiles[_selectedProfile]!;
    final service = AIRecommendationService();

    try {
      final recommendations = await service.generateRecommendations(
        passions: List<String>.from(profile['passions']),
        skills: Map<String, double>.from(profile['skills']),
        environmentRanking: List<String>.from(profile['environment']),
      );

      setState(() {
        _recommendations = recommendations;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erreur: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Démo IA - Recommandations'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Sélecteur de profil
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sélectionnez un profil de test :',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _testProfiles.entries.map((entry) {
                    final isSelected = _selectedProfile == entry.key;
                    return ChoiceChip(
                      label: Text(entry.value['name']),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedProfile = entry.key);
                          _generateRecommendations();
                        }
                      },
                      selectedColor: Colors.blue,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                _buildProfileDetails(),
              ],
            ),
          ),

          // Résultats
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _recommendations.isEmpty
                    ? const Center(child: Text('Aucune recommandation'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _recommendations.length,
                        itemBuilder: (context, index) {
                          final rec = _recommendations[index];
                          return _buildRecommendationCard(rec, index + 1);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetails() {
    final profile = _testProfiles[_selectedProfile]!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Passions', (profile['passions'] as List).join(', ')),
          const SizedBox(height: 8),
          _buildDetailRow(
            'Compétences',
            (profile['skills'] as Map).entries
                .map((e) => '${e.key}: ${_getLevelLabel(e.value)}')
                .join(', '),
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            'Environnement',
            (profile['environment'] as List).first,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  String _getLevelLabel(double value) {
    if (value <= 0) return 'Débutant';
    if (value <= 1) return 'Moyen';
    if (value <= 2) return 'Avancé';
    return 'Expert';
  }

  Widget _buildRecommendationCard(ProgramRecommendation rec, int rank) {
    final program = rec.programData;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(
                    '#$rank',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        program.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        program.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getColorForPercentage(rec.matchPercentage),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${rec.matchPercentage}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, size: 18, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rec.matchReason,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: program.skills.take(5).map((skill) {
                return Chip(
                  label: Text(skill, style: const TextStyle(fontSize: 11)),
                  backgroundColor: Colors.grey.shade200,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForPercentage(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }
}
