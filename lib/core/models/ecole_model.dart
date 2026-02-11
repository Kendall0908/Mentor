class EcoleModel {
  final String numero;
  final String etablissement;
  final String ville;
  final String commune;
  final String capaciteAccueil;
  final String fraisInscription;
  final List<String> filieres;

  EcoleModel({
    required this.numero,
    required this.etablissement,
    required this.ville,
    required this.commune,
    required this.capaciteAccueil,
    required this.fraisInscription,
    required this.filieres,
  });

  factory EcoleModel.fromJson(Map<String, dynamic> json) {
    return EcoleModel(
      numero: json['numero']?.toString() ?? '',
      etablissement: json['etablissement']?.toString() ?? 'Non spécifié',
      ville: json['ville']?.toString() ?? '',
      commune: json['commune']?.toString() ?? '',
      capaciteAccueil: json['capacite_accueil']?.toString() ?? 'Non spécifiée',
      fraisInscription: json['frais_inscription']?.toString() ?? 'Non spécifiés',
      filieres: (json['filieres'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numero': numero,
      'etablissement': etablissement,
      'ville': ville,
      'commune': commune,
      'capacite_accueil': capaciteAccueil,
      'frais_inscription': fraisInscription,
      'filieres': filieres,
    };
  }
}
