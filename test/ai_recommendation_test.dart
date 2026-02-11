import 'package:flutter_test/flutter_test.dart';
import 'package:mentor/features/Quest/data/ai_recommendation_service.dart';
import 'package:mentor/features/flieres/data/program_data.dart';

void main() {
  group('AI Recommendation Service Tests', () {
    final service = AIRecommendationService();

    test('Calculate passion score - perfect match', () {
      final userPassions = ['Tech', 'Gaming'];
      final programPassions = ['Tech', 'Gaming', 'Musique'];
      
      // Le score devrait être élevé car 2/2 passions correspondent
      final score = service._calculatePassionScore(userPassions, programPassions);
      expect(score, equals(1.0));
    });

    test('Calculate skill score - exact match', () {
      final userSkills = {
        'Mathématiques': 2.0,
        'Sciences': 2.0,
      };
      final programSkills = {
        'Mathématiques': 2.0,
        'Sciences': 2.0,
      };
      
      final score = service._calculateSkillScore(userSkills, programSkills);
      expect(score, equals(1.0));
    });

    test('Calculate environment score - top preference', () {
      final userRanking = ['Bureau', 'Cadre Structuré', 'Terrain'];
      final programEnvs = ['Bureau'];
      
      // Le score devrait être élevé car Bureau est en première position
      final score = service._calculateEnvironmentScore(userRanking, programEnvs);
      expect(score, greaterThan(0.8));
    });

    test('Generate recommendations - Tech profile', () async {
      final passions = ['Tech', 'Gaming'];
      final skills = {
        'Mathématiques': 2.0,
        'Sciences': 2.0,
      };
      final environmentRanking = ['Bureau', 'Cadre Structuré'];

      final recommendations = await service.generateRecommendations(
        passions: passions,
        skills: skills,
        environmentRanking: environmentRanking,
      );

      // Devrait retourner au moins 1 recommandation
      expect(recommendations.isNotEmpty, true);
      
      // La première recommandation devrait probablement être Ingénierie Logicielle
      expect(recommendations.first.programData.name, contains('Ingénierie'));
      
      // Le score devrait être élevé
      expect(recommendations.first.matchPercentage, greaterThan(70));
    });

    test('Generate recommendations - Beauty profile', () async {
      final passions = ['Beauté', 'Esthétique', 'Mode'];
      final skills = {
        'Sciences': 1.0,
        'Langues': 1.0,
      };
      final environmentRanking = ['Studio Créatif', 'Travail en Équipe'];

      final recommendations = await service.generateRecommendations(
        passions: passions,
        skills: skills,
        environmentRanking: environmentRanking,
      );

      expect(recommendations.isNotEmpty, true);
      
      // Devrait recommander Esthétique & Cosmétologie ou Design
      final topProgram = recommendations.first.programData.name;
      expect(
        topProgram.contains('Esthétique') || topProgram.contains('Design'),
        true,
      );
    });

    test('Generate recommendations - Business profile', () async {
      final passions = ['Voyage', 'Mode', 'Cuisine'];
      final skills = {
        'Langues': 2.0,
        'Mathématiques': 1.0,
        'Histoire-Géo': 1.0,
      };
      final environmentRanking = ['Bureau', 'Travail en Équipe', 'Terrain'];

      final recommendations = await service.generateRecommendations(
        passions: passions,
        skills: skills,
        environmentRanking: environmentRanking,
      );

      expect(recommendations.isNotEmpty, true);
      
      // Devrait recommander Commerce International ou Marketing
      final topProgram = recommendations.first.programData.name;
      expect(
        topProgram.contains('Commerce') || topProgram.contains('Marketing'),
        true,
      );
    });

    test('All programs have required metadata', () {
      for (final program in allPrograms) {
        expect(program.relatedPassions.isNotEmpty, true, 
          reason: '${program.name} should have related passions');
        expect(program.requiredSkills.isNotEmpty, true,
          reason: '${program.name} should have required skills');
        expect(program.workEnvironments.isNotEmpty, true,
          reason: '${program.name} should have work environments');
        expect(program.category.isNotEmpty, true,
          reason: '${program.name} should have a category');
      }
    });

    test('Recommendations are sorted by score', () async {
      final passions = ['Tech'];
      final skills = {'Mathématiques': 2.0};
      final environmentRanking = ['Bureau'];

      final recommendations = await service.generateRecommendations(
        passions: passions,
        skills: skills,
        environmentRanking: environmentRanking,
      );

      // Vérifier que les recommandations sont triées par score décroissant
      for (int i = 0; i < recommendations.length - 1; i++) {
        expect(
          recommendations[i].matchPercentage,
          greaterThanOrEqualTo(recommendations[i + 1].matchPercentage),
        );
      }
    });

    test('Match reason is generated', () async {
      final passions = ['Tech', 'Gaming'];
      final skills = {'Mathématiques': 3.0};
      final environmentRanking = ['Bureau'];

      final recommendations = await service.generateRecommendations(
        passions: passions,
        skills: skills,
        environmentRanking: environmentRanking,
      );

      // Chaque recommandation devrait avoir une raison
      for (final rec in recommendations) {
        expect(rec.matchReason.isNotEmpty, true);
      }
    });
  });
}
