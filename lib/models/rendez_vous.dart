class RendezVous {
  final int? idRendezVous;
  final String dateRDV;
  final String heureDebut;
  final String heureFin;
  final String typeRDV;
  final String titre;
  final String? description;
  final String? lieu;
  final int? idProfessionnel;
  final int? idDocteur;

  RendezVous({
    this.idRendezVous,
    required this.dateRDV,
    required this.heureDebut,
    required this.heureFin,
    required this.typeRDV,
    required this.titre,
    this.description,
    this.lieu,
    this.idProfessionnel,
    this.idDocteur,
  });

  // Convertir l'objet en données SQLite
  Map<String, dynamic> toMap() {
    return {
      'idRendezVous': idRendezVous,
      'dateRDV': dateRDV,
      'heureDebut': heureDebut,
      'heureFin': heureFin,
      'typeRDV': typeRDV,
      'titre': titre,
      'description': description,
      'lieu': lieu,
      'idProfessionnel': idProfessionnel,
      'idDocteur': idDocteur,
    };
  }

  // Créer un objet RendezVous depuis SQLite
  factory RendezVous.fromMap(Map<String, dynamic> map) {
    return RendezVous(
      idRendezVous: map['idRendezVous'],
      dateRDV: map['dateRDV'],
      heureDebut: map['heureDebut'],
      heureFin: map['heureFin'],
      typeRDV: map['typeRDV'],
      titre: map['titre'],
      description: map['description'],
      lieu: map['lieu'],
      idProfessionnel: map['idProfessionnel'],
      idDocteur: map['idDocteur'],
    );
  }
}