# Système de Recommandation IA pour MentOr

## 📋 Vue d'ensemble

Ce système utilise l'intelligence artificielle pour analyser les réponses aux questionnaires d'orientation et générer des recommandations de filières personnalisées avec des pourcentages de compatibilité.

## 🎯 Fonctionnalités

### 1. Collecte de données
Le questionnaire collecte :
- **Passions** : Mode, Tech, Sport, Art, etc.
- **Compétences** : Niveau en Mathématiques, Langues, Sciences, etc. (0-3)
- **Environnement** : Bureau, Terrain, Studio Créatif, etc.

### 2. Algorithme de matching local

L'algorithme calcule un score de compatibilité basé sur :

#### Score de Passions (40%)
- Compare les passions de l'utilisateur avec celles liées à chaque filière
- Exemple : Un utilisateur passionné par "Tech" et "Gaming" aura un score élevé pour "Ingénierie Logicielle"

#### Score de Compétences (35%)
- Évalue l'adéquation entre le niveau de l'utilisateur et les compétences requises
- Formule : `1.0 - (|niveau_utilisateur - niveau_requis| / 3.0)`
- Exemple : Médecine requiert Sciences=3.0, si l'utilisateur a 2.0, le score sera bon mais pas parfait

#### Score d'Environnement (25%)
- Privilégie les filières dont l'environnement correspond aux préférences de l'utilisateur
- Plus l'environnement est haut dans le classement de l'utilisateur, plus le score est élevé

### 3. Amélioration par IA (DeepSeek)

L'IA peut :
- Affiner les scores avec une analyse sémantique
- Ajouter un boost de +5 points aux filières particulièrement adaptées
- Générer des raisons de compatibilité personnalisées

## 📊 Filières disponibles

1. **Ingénierie Logicielle** - Tech, Gaming, Musique
2. **Design UX/UI** - Art, Tech, Mode, Esthétique
3. **Marketing Digital** - Tech, Mode, Voyage, Musique
4. **Architecture** - Art, Voyage, Esthétique
5. **Médecine** - Sport, Beauté, Voyage
6. **Droit** - Voyage, Littérature
7. **Journalisme** - Voyage, Musique, Tech, Mode
8. **Commerce International** - Voyage, Mode, Cuisine
9. **Esthétique & Cosmétologie** - Beauté, Esthétique, Mode, Coiffure
10. **Sciences de l'Éducation** - Sport, Musique, Art, Voyage

## 🔧 Architecture technique

### Fichiers créés/modifiés

1. **`ai_recommendation_service.dart`**
   - Service singleton pour les recommandations
   - Algorithme de matching local
   - Intégration API DeepSeek
   - Combinaison des scores

2. **`program_data.dart`**
   - Extension du modèle ProgramData
   - Ajout de 10 filières diverses
   - Métadonnées de matching (passions, compétences, environnements)

3. **`quest_results_processing_screen.dart`**
   - Récupération des données Firestore
   - Appel du service IA
   - Sauvegarde des résultats

4. **`quest_results_screen.dart`**
   - Affichage dynamique des recommandations
   - Cartes avec pourcentages et raisons
   - Icônes et couleurs par catégorie

## 🚀 Utilisation

### Flux utilisateur

1. L'utilisateur complète le questionnaire (3 étapes)
2. Les données sont sauvegardées dans Firestore :
   ```json
   {
     "orientation_passions": ["Tech", "Gaming"],
     "orientation_skills": {
       "Mathématiques": 2.0,
       "Sciences": 2.0
     },
     "orientation_environment_ranking": ["Bureau", "Cadre Structuré"]
   }
   ```

3. L'écran de traitement :
   - Récupère les données
   - Génère les recommandations (local + IA)
   - Sauvegarde les résultats

4. L'écran de résultats affiche :
   - Top 5 filières recommandées
   - Pourcentage de compatibilité
   - Raison de la recommandation
   - Compétences clés

### Exemple de résultat

```dart
ProgramRecommendation(
  programData: softwareEngineeringProgram,
  matchPercentage: 95,
  matchReason: "Excellente correspondance avec vos passions"
)
```

## 🔑 Configuration

### Variables d'environnement (.env)

```env
DEEPSEEK_API_KEY=sk-xxxxxxxxxxxxx
```

### Firestore Security Rules

Assurez-vous que les utilisateurs peuvent lire/écrire leurs données :

```javascript
match /users/{userId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}
```

## 📈 Amélirations futures

1. **Machine Learning local**
   - Entraîner un modèle sur les données historiques
   - Prédictions hors ligne

2. **Plus de critères**
   - Personnalité (MBTI, Big Five)
   - Valeurs personnelles
   - Contraintes géographiques/financières

3. **Feedback utilisateur**
   - Permettre aux utilisateurs de noter les recommandations
   - Améliorer l'algorithme avec le temps

4. **Recommandations de carrières**
   - Aller au-delà des filières
   - Suggérer des métiers spécifiques

## 🐛 Débogage

### Logs importants

```dart
debugPrint('Passions: $passions');
debugPrint('Skills: $skillsMap');
debugPrint('Recommendations: ${recommendations.length}');
```

### Erreurs communes

1. **API Key manquante** : Vérifier `.env`
2. **Données Firestore vides** : Vérifier que le questionnaire a été complété
3. **Aucune recommandation** : Vérifier les logs du service IA

## 📝 Licence

Ce système fait partie de l'application MentOr.
