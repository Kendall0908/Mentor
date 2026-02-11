# 🎓 Guide d'Utilisation - Système de Recommandation IA

## 📱 Pour l'utilisateur final

### Comment ça marche ?

1. **Complétez le questionnaire en 3 étapes**
   - ✅ Étape 1 : Sélectionnez vos passions (Mode, Tech, Sport, etc.)
   - ✅ Étape 2 : Évaluez vos compétences (Maths, Langues, Sciences, etc.)
   - ✅ Étape 3 : Classez vos environnements de travail idéaux

2. **L'IA analyse votre profil**
   - Comparaison avec 10+ filières
   - Calcul de compatibilité intelligent
   - Génération de recommandations personnalisées

3. **Recevez vos résultats**
   - Top 5 filières recommandées
   - Pourcentage de compatibilité (0-100%)
   - Raison de chaque recommandation
   - Compétences clés à développer

### Exemples de profils

#### 👨‍💻 Profil Tech
**Passions** : Tech, Gaming, Musique  
**Compétences** : Mathématiques (Avancé), Sciences (Avancé)  
**Environnement** : Bureau, Cadre Structuré  
**→ Recommandation** : Ingénierie Logicielle (95%)

#### 🎨 Profil Créatif
**Passions** : Art, Mode, Esthétique  
**Compétences** : Langues (Moyen), Littérature (Moyen)  
**Environnement** : Studio Créatif, Travail en Équipe  
**→ Recommandation** : Design UX/UI (88%)

#### 💼 Profil Business
**Passions** : Voyage, Mode, Cuisine  
**Compétences** : Langues (Avancé), Mathématiques (Moyen)  
**Environnement** : Bureau, Travail en Équipe  
**→ Recommandation** : Commerce International (85%)

#### 💅 Profil Beauté
**Passions** : Beauté, Esthétique, Mode, Coiffure  
**Compétences** : Sciences (Moyen)  
**Environnement** : Studio Créatif, Travail en Équipe  
**→ Recommandation** : Esthétique & Cosmétologie (92%)

---

## 👨‍💻 Pour les développeurs

### Installation

1. **Vérifier les dépendances** (déjà dans `pubspec.yaml`)
   ```yaml
   dependencies:
     http: ^1.2.1
     flutter_dotenv: ^5.2.1
     firebase_core: ^4.4.0
     cloud_firestore: ^6.1.2
   ```

2. **Configurer l'API Key**
   
   Créer/modifier `.env` :
   ```env
   DEEPSEEK_API_KEY=sk-votre-clé-ici
   ```

3. **Charger dotenv dans main.dart**
   ```dart
   import 'package:flutter_dotenv/flutter_dotenv.dart';
   
   Future<void> main() async {
     await dotenv.load(fileName: ".env");
     runApp(MyApp());
   }
   ```

### Structure du code

```
lib/features/Quest/
├── data/
│   └── ai_recommendation_service.dart  # Service IA
├── ui/screens/
│   ├── quest_interests_screen.dart     # Étape 1: Passions
│   ├── quest_skills_screen.dart        # Étape 2: Compétences
│   ├── quest_environment_screen.dart   # Étape 3: Environnement
│   ├── quest_results_processing_screen.dart  # Traitement IA
│   └── quest_results_screen.dart       # Affichage résultats
└── README.md

lib/features/flieres/
└── data/
    └── program_data.dart               # 10 filières + métadonnées
```

### API du service

```dart
// Utilisation basique
final service = AIRecommendationService();

final recommendations = await service.generateRecommendations(
  passions: ['Tech', 'Gaming'],
  skills: {'Mathématiques': 2.0, 'Sciences': 2.0},
  environmentRanking: ['Bureau', 'Cadre Structuré'],
);

// Résultat
for (final rec in recommendations) {
  print('${rec.programData.name}: ${rec.matchPercentage}%');
  print('Raison: ${rec.matchReason}');
}
```

### Ajouter une nouvelle filière

1. **Créer le ProgramData** dans `program_data.dart`
   ```dart
   final ProgramData newProgram = ProgramData(
     id: '11',
     name: 'Votre Filière',
     category: 'VOTRE CATÉGORIE',
     imageUrl: 'https://...',
     duration: '3 ans',
     durationType: 'Licence',
     demand: 'Forte',
     salaryMin: '20 000',
     salaryMax: '40 000',
     matchPercentage: 0, // Sera calculé dynamiquement
     matchDescription: 'Description',
     skills: ['Compétence 1', 'Compétence 2'],
     
     // Métadonnées pour le matching
     relatedPassions: ['Passion1', 'Passion2'],
     requiredSkills: {
       'Mathématiques': 1.0,
       'Langues': 2.0,
     },
     workEnvironments: ['Bureau', 'Terrain'],
     schools: [...],
   );
   ```

2. **Ajouter à la liste**
   ```dart
   final List<ProgramData> allPrograms = [
     softwareEngineeringProgram,
     // ... autres programmes
     newProgram, // ← Ajouter ici
   ];
   ```

### Personnaliser l'algorithme

#### Modifier les poids

Dans `ai_recommendation_service.dart` :
```dart
// Score basé sur les passions (40%)
score += passionScore * 0.4;

// Score basé sur les compétences (35%)
score += skillScore * 0.35;

// Score basé sur l'environnement (25%)
score += envScore * 0.25;
```

Vous pouvez ajuster ces pourcentages selon vos besoins.

#### Ajouter un nouveau critère

1. Ajouter le champ dans `ProgramData`
2. Créer une fonction `_calculateXScore()`
3. Intégrer dans `_calculateLocalScores()`

### Tests

```bash
# Lancer les tests
flutter test test/ai_recommendation_test.dart

# Avec coverage
flutter test --coverage
```

### Débogage

Activer les logs détaillés :
```dart
// Dans ai_recommendation_service.dart
debugPrint('Passions: $passions');
debugPrint('Skills: $skillsMap');
debugPrint('Local scores: ${localScores.map((r) => r.matchPercentage)}');
```

### Performance

- **Temps de calcul local** : ~50-100ms pour 10 filières
- **Appel API IA** : ~1-3 secondes (selon réseau)
- **Total** : ~2-4 secondes pour des recommandations complètes

### Limitations actuelles

1. **API IA optionnelle** : Fonctionne même sans clé API (scores locaux uniquement)
2. **10 filières** : Extensible facilement
3. **Critères limités** : Passions, compétences, environnement (peut être étendu)

### Roadmap

- [ ] Cache des recommandations
- [ ] Historique des résultats
- [ ] Comparaison de filières
- [ ] Feedback utilisateur
- [ ] ML local (TensorFlow Lite)
- [ ] Plus de filières (50+)
- [ ] Recommandations de métiers spécifiques

---

## 🔒 Sécurité

### Firestore Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null 
                        && request.auth.uid == userId;
    }
  }
}
```

### API Key

⚠️ **Ne jamais commiter `.env` dans Git !**

Ajouter à `.gitignore` :
```
.env
```

---

## 📞 Support

Pour toute question ou problème :
1. Consulter la documentation dans `README.md`
2. Vérifier les logs de débogage
3. Tester avec les exemples de profils ci-dessus

Bon développement ! 🚀
