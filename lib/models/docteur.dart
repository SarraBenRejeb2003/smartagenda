class Docteur {
  final int? idDocteur;
  final String nom;
  final String? specialite;
  final String? telephone;
  final String? adresseCabinet;

  Docteur({
    this.idDocteur,
    required this.nom,
    this.specialite,
    this.telephone,
    this.adresseCabinet,
  });

  Map<String, dynamic> toMap() {
    return {
      'idDocteur': idDocteur,
      'nom': nom,
      'specialite': specialite,
      'telephone': telephone,
      'adresseCabinet': adresseCabinet,
    };
  }

  factory Docteur.fromMap(Map<String, dynamic> map) {
    return Docteur(
      idDocteur: map['idDocteur'],
      nom: map['nom'],
      specialite: map['specialite'],
      telephone: map['telephone'],
      adresseCabinet: map['adresseCabinet'],
    );
  }
}