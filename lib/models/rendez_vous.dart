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

  // Nouveaux champs
  final String statut;
  final bool estFavori;

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
    this.statut = 'Planifie',
    this.estFavori = false,
  });

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

      // Nouveaux champs
      'statut': statut,
      'estFavori': estFavori ? 1 : 0,
    };
  }

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

      // Nouveaux champs
      statut: map['statut'] ?? 'Planifie',
      estFavori: (map['estFavori'] ?? 0) == 1,
    );
  }
}