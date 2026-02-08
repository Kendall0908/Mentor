import '../../../../core/models/ecole_model.dart';

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
  final List<EcoleModel> availableSchools; // Vraies écoles depuis le JSON
  
  // Nouveaux champs pour le matching IA
  final List<String> relatedPassions;
  final Map<String, double> requiredSkills;
  final List<String> workEnvironments;
  final String category;

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
    this.availableSchools = const [],
    this.relatedPassions = const [],
    this.requiredSkills = const {},
    this.workEnvironments = const [],
    this.category = '',
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
  category: 'TECHNOLOGIE & INNOVATION',
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
  relatedPassions: ['Tech', 'Gaming', 'Musique'],
  requiredSkills: {
    'Mathématiques': 2.0,
    'Sciences': 2.0,
  },
  workEnvironments: ['Bureau', 'Cadre Structuré'],
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

/// 🎨 DESIGN UX/UI
final ProgramData uxDesignProgram = ProgramData(
  id: '2',
  name: 'Design UX/UI',
  category: 'DESIGN & CRÉATIVITÉ',
  imageUrl: 'https://images.unsplash.com/photo-1561070791-2526d30994b5',
  isTrending: true,
  duration: '3 ans',
  durationType: 'Licence',
  demand: 'Forte',
  salaryMin: '20 000',
  salaryMax: '45 000',
  matchPercentage: 85,
  matchDescription: 'Parfait pour les esprits créatifs et empathiques',
  skills: ['Design Thinking', 'Prototypage', 'Recherche Utilisateur', 'Figma', 'Adobe XD'],
  relatedPassions: ['Art', 'Tech', 'Mode', 'Esthétique'],
  requiredSkills: {
    'Langues': 1.0,
    'Littérature': 1.0,
  },
  workEnvironments: ['Studio Créatif', 'Travail en Équipe'],
  schools: [
    SchoolData(
      id: '3',
      name: 'École de Design',
      city: 'Abidjan',
      distance: 5.2,
      imageUrl: '/lib/features/flieres/ui/assets/images/esatic_logo.png',
      websiteUrl: 'https://example.com',
    ),
  ],
);

/// 📱 MARKETING DIGITAL
final ProgramData digitalMarketingProgram = ProgramData(
  id: '3',
  name: 'Marketing Digital',
  category: 'BUSINESS & COMMUNICATION',
  imageUrl: 'https://images.unsplash.com/photo-1460925895917-afdab827c52f',
  duration: '3 ans',
  durationType: 'Licence',
  demand: 'Très forte',
  salaryMin: '18 000',
  salaryMax: '40 000',
  matchPercentage: 80,
  matchDescription: 'Idéal pour les communicants créatifs',
  skills: ['SEO/SEM', 'Réseaux Sociaux', 'Analytics', 'Content Marketing', 'Publicité'],
  relatedPassions: ['Tech', 'Mode', 'Voyage', 'Musique'],
  requiredSkills: {
    'Langues': 2.0,
    'Mathématiques': 1.0,
  },
  workEnvironments: ['Bureau', 'Travail en Équipe', 'Studio Créatif'],
  schools: [
    SchoolData(
      id: '4',
      name: 'ESCAE',
      city: 'Abidjan',
      distance: 4.5,
      imageUrl: '/lib/features/flieres/ui/assets/images/esatic_logo.png',
      websiteUrl: 'https://example.com',
    ),
  ],
);

/// 🏗️ ARCHITECTURE
final ProgramData architectureProgram = ProgramData(
  id: '4',
  name: 'Architecture',
  category: 'DESIGN & CONSTRUCTION',
  imageUrl: 'https://images.unsplash.com/photo-1503387762-592deb58ef4e',
  duration: '5 ans',
  durationType: 'Master',
  demand: 'Moyenne',
  salaryMin: '22 000',
  salaryMax: '50 000',
  matchPercentage: 75,
  matchDescription: 'Pour les créatifs avec un sens technique',
  skills: ['Dessin Technique', 'CAO/DAO', 'Urbanisme', 'Matériaux', 'Gestion de Projet'],
  relatedPassions: ['Art', 'Voyage', 'Esthétique'],
  requiredSkills: {
    'Mathématiques': 2.0,
    'Sciences': 1.0,
  },
  workEnvironments: ['Studio Créatif', 'Terrain', 'Bureau'],
  schools: [
    SchoolData(
      id: '5',
      name: 'ESBA',
      city: 'Abidjan',
      distance: 7.1,
      imageUrl: '/lib/features/flieres/ui/assets/images/esatic_logo.png',
      websiteUrl: 'https://example.com',
    ),
  ],
);

/// 🏥 MÉDECINE
final ProgramData medicineProgram = ProgramData(
  id: '5',
  name: 'Médecine',
  category: 'SANTÉ & SCIENCES',
  imageUrl: 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d',
  duration: '7 ans',
  durationType: 'Doctorat',
  demand: 'Très forte',
  salaryMin: '30 000',
  salaryMax: '80 000',
  matchPercentage: 70,
  matchDescription: 'Pour les esprits scientifiques et empathiques',
  skills: ['Biologie', 'Chimie', 'Anatomie', 'Diagnostic', 'Chirurgie'],
  relatedPassions: ['Sport', 'Beauté', 'Voyage'],
  requiredSkills: {
    'Sciences': 3.0,
    'Mathématiques': 2.0,
  },
  workEnvironments: ['Cadre Structuré', 'Travail en Équipe'],
  schools: [
    SchoolData(
      id: '6',
      name: 'UFR Sciences Médicales',
      city: 'Abidjan',
      distance: 8.3,
      imageUrl: '/lib/features/flieres/ui/assets/images/esatic_logo.png',
      websiteUrl: 'https://example.com',
    ),
  ],
);

/// ⚖️ DROIT
final ProgramData lawProgram = ProgramData(
  id: '6',
  name: 'Droit',
  category: 'JURIDIQUE & SOCIAL',
  imageUrl: 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f',
  duration: '5 ans',
  durationType: 'Master',
  demand: 'Forte',
  salaryMin: '20 000',
  salaryMax: '55 000',
  matchPercentage: 65,
  matchDescription: 'Pour les esprits analytiques et argumentatifs',
  skills: ['Argumentation', 'Rédaction', 'Analyse Juridique', 'Plaidoirie', 'Droit Civil'],
  relatedPassions: ['Voyage', 'Littérature'],
  requiredSkills: {
    'Littérature': 2.0,
    'Histoire-Géo': 2.0,
    'Langues': 2.0,
  },
  workEnvironments: ['Bureau', 'Cadre Structuré'],
  schools: [
    SchoolData(
      id: '7',
      name: 'UFR Sciences Juridiques',
      city: 'Abidjan',
      distance: 6.0,
      imageUrl: '/lib/features/flieres/ui/assets/images/esatic_logo.png',
      websiteUrl: 'https://example.com',
    ),
  ],
);

/// 📰 JOURNALISME
final ProgramData journalismProgram = ProgramData(
  id: '7',
  name: 'Journalisme',
  category: 'MÉDIAS & COMMUNICATION',
  imageUrl: 'https://images.unsplash.com/photo-1504711434969-e33886168f5c',
  duration: '3 ans',
  durationType: 'Licence',
  demand: 'Moyenne',
  salaryMin: '15 000',
  salaryMax: '35 000',
  matchPercentage: 60,
  matchDescription: 'Pour les curieux et communicants',
  skills: ['Rédaction', 'Investigation', 'Interview', 'Montage Vidéo', 'Réseaux Sociaux'],
  relatedPassions: ['Voyage', 'Musique', 'Tech', 'Mode'],
  requiredSkills: {
    'Langues': 2.0,
    'Littérature': 2.0,
  },
  workEnvironments: ['Terrain', 'Travail en Équipe', 'Bureau'],
  schools: [
    SchoolData(
      id: '8',
      name: 'ISTC',
      city: 'Abidjan',
      distance: 5.8,
      imageUrl: '/lib/features/flieres/ui/assets/images/esatic_logo.png',
      websiteUrl: 'https://example.com',
    ),
  ],
);

/// 💼 COMMERCE INTERNATIONAL
final ProgramData internationalBusinessProgram = ProgramData(
  id: '8',
  name: 'Commerce International',
  category: 'BUSINESS & FINANCE',
  imageUrl: 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40',
  duration: '3 ans',
  durationType: 'Licence',
  demand: 'Forte',
  salaryMin: '20 000',
  salaryMax: '50 000',
  matchPercentage: 70,
  matchDescription: 'Pour les entrepreneurs et négociateurs',
  skills: ['Négociation', 'Import/Export', 'Gestion', 'Langues Étrangères', 'Finance'],
  relatedPassions: ['Voyage', 'Mode', 'Cuisine'],
  requiredSkills: {
    'Langues': 2.0,
    'Mathématiques': 1.0,
    'Histoire-Géo': 1.0,
  },
  workEnvironments: ['Bureau', 'Travail en Équipe', 'Terrain'],
  schools: [
    SchoolData(
      id: '9',
      name: 'ESCAE',
      city: 'Abidjan',
      distance: 4.5,
      imageUrl: '/lib/features/flieres/ui/assets/images/esatic_logo.png',
      websiteUrl: 'https://example.com',
    ),
  ],
);

/// 💅 ESTHÉTIQUE & COSMÉTOLOGIE
final ProgramData cosmetologyProgram = ProgramData(
  id: '9',
  name: 'Esthétique & Cosmétologie',
  category: 'BEAUTÉ & BIEN-ÊTRE',
  imageUrl: 'https://images.unsplash.com/photo-1522337660859-02fbefca4702',
  duration: '2 ans',
  durationType: 'BTS',
  demand: 'Moyenne',
  salaryMin: '12 000',
  salaryMax: '30 000',
  matchPercentage: 75,
  matchDescription: 'Pour les passionnés de beauté et bien-être',
  skills: ['Soins du Visage', 'Maquillage', 'Manucure', 'Massage', 'Conseil Client'],
  relatedPassions: ['Beauté', 'Esthétique', 'Mode', 'Coiffure'],
  requiredSkills: {
    'Sciences': 1.0,
  },
  workEnvironments: ['Studio Créatif', 'Travail en Équipe'],
  schools: [
    SchoolData(
      id: '10',
      name: 'Institut de Beauté',
      city: 'Abidjan',
      distance: 3.2,
      imageUrl: '/lib/features/flieres/ui/assets/images/esatic_logo.png',
      websiteUrl: 'https://example.com',
    ),
  ],
);

/// 🎓 ENSEIGNEMENT
final ProgramData teachingProgram = ProgramData(
  id: '10',
  name: 'Sciences de l\'Éducation',
  category: 'ÉDUCATION & FORMATION',
  imageUrl: 'https://images.unsplash.com/photo-1503676260728-1c00da094a0b',
  duration: '4 ans',
  durationType: 'Licence + Master',
  demand: 'Forte',
  salaryMin: '18 000',
  salaryMax: '35 000',
  matchPercentage: 65,
  matchDescription: 'Pour les pédagogues et transmetteurs de savoir',
  skills: ['Pédagogie', 'Communication', 'Gestion de Classe', 'Évaluation', 'Psychologie'],
  relatedPassions: ['Sport', 'Musique', 'Art', 'Voyage'],
  requiredSkills: {
    'Langues': 2.0,
    'Littérature': 2.0,
  },
  workEnvironments: ['Cadre Structuré', 'Travail en Équipe'],
  schools: [
    SchoolData(
      id: '11',
      name: 'ENS',
      city: 'Abidjan',
      distance: 7.5,
      imageUrl: '/lib/features/flieres/ui/assets/images/esatic_logo.png',
      websiteUrl: 'https://example.com',
    ),
  ],
);

/// Liste de tous les programmes
final List<ProgramData> allPrograms = [
  softwareEngineeringProgram,
  uxDesignProgram,
  digitalMarketingProgram,
  architectureProgram,
  medicineProgram,
  lawProgram,
  journalismProgram,
  internationalBusinessProgram,
  cosmetologyProgram,
  teachingProgram,
];

