class ProgramData {
  final String id;
  final String name;
  final String imageUrl;
  final bool isTrending;
  final String duration;
  final String durationType;
  final String demand;
  final String salaryMin;
  final String salaryMax;
  final int matchPercentage;
  final String matchDescription;
  final List<String> skills;
  final List<SchoolData> schools;

  ProgramData({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.isTrending = false,
    required this.duration,
    required this.durationType,
    required this.demand,
    required this.salaryMin,
    required this.salaryMax,
    required this.matchPercentage,
    required this.matchDescription,
    required this.skills,
    required this.schools,
  });
}

class SchoolData {
  final String id;
  final String name;
  final String city;
  final double distance;
  final String imageUrl;
  final String websiteUrl;

  SchoolData({
    required this.id,
    required this.name,
    required this.city,
    required this.distance,
    required this.imageUrl,
    required this.websiteUrl,
  });

  String get locationText => '$city • ${distance.toStringAsFixed(1)} km';
}

/// 🔥 INGÉNIERIE LOGICIELLE
final ProgramData softwareEngineeringProgram = ProgramData(
  id: '1',
  name: 'Ingénierie Logicielle',
  imageUrl:
      'https://images.unsplash.com/photo-1581090700227-1e37b190418e',
  isTrending: true,
  duration: '5 ans',
  durationType: 'Licence + Master',
  demand: 'Très forte',
  salaryMin: '25 000',
  salaryMax: '60 000',
  matchPercentage: 95,
  matchDescription:
      'Ce parcours correspond parfaitement à votre profil logique, analytique et créatif.',
  skills: [
    'Programmation',
    'Algorithmique',
    'Bases de données',
    'Cloud',
    'Intelligence Artificielle',
  ],
  schools: [
    SchoolData(
      id: '1',
      name: 'INPHB',
      city: 'Yamoussoukro',
      distance: 2.3,
      imageUrl:
          '/lib/features/flieres/ui/assets/images/inphb_logo.png',
      websiteUrl: 'https://www.inphb.ci',
    ),
    SchoolData(
      id: '2',
      name: 'ESATIC',
      city: 'Abidjan',
      distance: 6.8,
      imageUrl:
          '/lib/features/flieres/ui/assets/images/esatic_logo.png',
      websiteUrl: 'https://www.esatic.ci',
    ),
  ],
);
