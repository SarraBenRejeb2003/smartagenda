class Parametres {
  final int? idParametres;
  final int delaiNotifDefaut;
  final String themeCouleur;
  final String formatHeure;
  final String langue;

  Parametres({
    this.idParametres,
    this.delaiNotifDefaut = 30,
    this.themeCouleur = '#6750A4',
    this.formatHeure = '24h',
    this.langue = 'fr',
  });

  Map<String, dynamic> toMap() {
    return {
      'idParametres': idParametres,
      'delaiNotifDefaut': delaiNotifDefaut,
      'themeCouleur': themeCouleur,
      'formatHeure': formatHeure,
      'langue': langue,
    };
  }

  factory Parametres.fromMap(Map<String, dynamic> map) {
    return Parametres(
      idParametres:
          (map['idParametres'] as num?)?.toInt(),
      delaiNotifDefaut:
          (map['delaiNotifDefaut'] as num?)?.toInt() ?? 30,
      themeCouleur:
          map['themeCouleur']?.toString() ?? '#6750A4',
      formatHeure:
          map['formatHeure']?.toString() ?? '24h',
      langue:
          map['langue']?.toString() ?? 'fr',
    );
  }
}