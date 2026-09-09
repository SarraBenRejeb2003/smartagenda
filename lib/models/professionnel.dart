class Professionnel {
  final int? idProfessionnel;
  final String nom;
  final String societe;
  final String fonction;
  final String telephone;
  final String email;

  Professionnel({
    this.idProfessionnel,
    required this.nom,
    this.societe = '',
    this.fonction = '',
    this.telephone = '',
    this.email = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'idProfessionnel': idProfessionnel,
      'nom': nom,
      'societe': societe,
      'fonction': fonction,
      'telephone': telephone,
      'email': email,
    };
  }

  factory Professionnel.fromMap(Map<String, dynamic> map) {
    return Professionnel(
      idProfessionnel: map['idProfessionnel'],
      nom: map['nom'] ?? '',
      societe: map['societe'] ?? '',
      fonction: map['fonction'] ?? '',
      telephone: map['telephone'] ?? '',
      email: map['email'] ?? '',
    );
  }
}