
import '../models/rendez_vous.dart';
import '../repositories/rendez_vous_repository.dart';

class SmartAssistantService {
  final RendezVousRepository _repository;

  SmartAssistantService({
    RendezVousRepository? repository,
  }) : _repository = repository ?? RendezVousRepository();

  Future<String> processMessage(String message) async {
    final question = message.toLowerCase().trim();
    final language = _detectLanguage(question);

    final rendezVous = await _repository.getRendezVous();

    // ─────────────────────────────────────────────
    // TODAY
    // ─────────────────────────────────────────────
    if (_isTodayQuestion(question)) {
      return _appointmentsForDate(
        rendezVous,
        DateTime.now(),
        language,
      );
    }

    // ─────────────────────────────────────────────
    // TOMORROW
    // ─────────────────────────────────────────────
    if (_isTomorrowQuestion(question)) {
      return _appointmentsForDate(
        rendezVous,
        DateTime.now().add(const Duration(days: 1)),
        language,
      );
    }

    // ─────────────────────────────────────────────
    // NEXT APPOINTMENT
    // ─────────────────────────────────────────────
    if (_isNextQuestion(question)) {
      return _nextAppointment(rendezVous, language);
    }

    // ─────────────────────────────────────────────
    // NUMBER OF APPOINTMENTS
    // ─────────────────────────────────────────────
    if (_isCountQuestion(question)) {
      return _appointmentCount(rendezVous, language);
    }

    // ─────────────────────────────────────────────
    // FAVORITES
    // ─────────────────────────────────────────────
    if (_isFavoriteQuestion(question)) {
      return _favoriteAppointments(rendezVous, language);
    }

    return _helpMessage(language);
  }

  // ═══════════════════════════════════════════════
  // LANGUAGE DETECTION
  // ═══════════════════════════════════════════════

  String _detectLanguage(String question) {
    if (RegExp(r'[\u0600-\u06FF]').hasMatch(question)) {
      return 'ar';
    }

    if (_containsAny(question, [
      'today',
      'tomorrow',
      'next',
      'how many',
      'how much',
      'favorite',
      'favorites',
      'favourite',
      'favourites',
      'appointment',
      'appointments',
      'agenda',
      'busy',
      'planned',
    ])) {
      return 'en';
    }

    return 'fr';
  }

  // ═══════════════════════════════════════════════
  // TODAY
  // ═══════════════════════════════════════════════

  bool _isTodayQuestion(String question) {
    return _containsAny(question, [
      // French
      'aujourd',
      'aujourd’hui',
      'aujourd\'hui',
      'ce jour',
      'prévu aujourd',
      'prevu aujourd',
      'quelque chose aujourd',

      // English
      'today',
      'this day',
      'planned today',
      'anything today',
      'busy today',
      'free today',

      // Arabic / Tunisian
      'اليوم',
      'اليوم؟',
      'عندي اليوم',
      'شنوة عندي اليوم',
      'شنوّة عندي اليوم',
    ]);
  }

  // ═══════════════════════════════════════════════
  // TOMORROW
  // ═══════════════════════════════════════════════

  bool _isTomorrowQuestion(String question) {
    return _containsAny(question, [
      // French
      'demain',
      'prévu demain',
      'prevu demain',
      'quelque chose demain',

      // English
      'tomorrow',
      'planned tomorrow',
      'anything tomorrow',
      'busy tomorrow',
      'free tomorrow',

      // Arabic / Tunisian
      'غدوة',
      'غدًا',
      'غدا',
      'عندي غدوة',
      'شنوة عندي غدوة',
      'شنوّة عندي غدوة',
    ]);
  }

  // ═══════════════════════════════════════════════
  // NEXT APPOINTMENT
  // ═══════════════════════════════════════════════

  bool _isNextQuestion(String question) {
    return _containsAny(question, [
      // French
      'prochain',
      'prochaine',
      'prochains',
      'prochaines',
      'à venir',
      'a venir',
      'qui vient',
      'rendez-vous suivant',

      // English
      'next',
      'upcoming',
      'coming',
      'what comes next',
      'next appointment',

      // Arabic
      'القادم',
      'القادمة',
      'القادم؟',
      'الموعد القادم',
      'الموعد التالي',
      'موعدي القادم',
    ]);
  }

  // ═══════════════════════════════════════════════
  // COUNT
  // ═══════════════════════════════════════════════

  bool _isCountQuestion(String question) {
    return _containsAny(question, [
      // French
      'combien',
      'nombre de',
      'combien ai-je',
      'combien j’ai',
      'combien jai',
      'j’ai combien',
      'jai combien',

      // English
      'how many',
      'how much',
      'number of appointments',
      'how many appointments',
      'how many do i have',

      // Arabic / Tunisian
      'كم',
      'عدد',
      'قداش',
      'عندي قداش',
      'قداش عندي',
    ]);
  }

  // ═══════════════════════════════════════════════
  // FAVORITES
  // ═══════════════════════════════════════════════

  bool _isFavoriteQuestion(String question) {
    return _containsAny(question, [
      // French
      'favori',
      'favoris',
      'favorite',
      'favorites',

      // English
      'favourite',
      'favourites',
      'favorite appointment',

      // Arabic
      'المفضلة',
      'المفضل',
      'مواعيدي المفضلة',
    ]);
  }

  // ═══════════════════════════════════════════════
  // APPOINTMENTS FOR DATE
  // ═══════════════════════════════════════════════

  String _appointmentsForDate(
    List<RendezVous> rendezVous,
    DateTime date,
    String language,
  ) {
    final dateString = _formatDate(date);

    final appointments = rendezVous.where((rdv) {
      return rdv.dateRDV == dateString &&
          rdv.statut != 'Annule';
    }).toList();

    appointments.sort(
      (a, b) => a.heureDebut.compareTo(b.heureDebut),
    );

    if (appointments.isEmpty) {
      if (language == 'en') {
        return 'You have no appointments on ${_displayDate(date)}.';
      }

      if (language == 'ar') {
        return 'ليس لديك أي موعد بتاريخ ${_displayDate(date)}.';
      }

      return 'Aucun rendez-vous pour le ${_displayDate(date)}.';
    }

    final buffer = StringBuffer();

    if (language == 'en') {
      buffer.writeln(
        'Here are your appointments for ${_displayDate(date)}:',
      );
    } else if (language == 'ar') {
      buffer.writeln(
        'هذه هي مواعيدك بتاريخ ${_displayDate(date)}:',
      );
    } else {
      buffer.writeln(
        'Voici vos rendez-vous du ${_displayDate(date)} :',
      );
    }

    for (final rdv in appointments) {
      buffer.writeln(
        '• ${rdv.heureDebut} - ${rdv.heureFin} : ${rdv.titre}',
      );
    }

    return buffer.toString().trim();
  }

  // ═══════════════════════════════════════════════
  // NEXT APPOINTMENT
  // ═══════════════════════════════════════════════

  String _nextAppointment(
    List<RendezVous> rendezVous,
    String language,
  ) {
    final now = DateTime.now();

    final upcoming = rendezVous.where((rdv) {
      final date = _parseDateTime(rdv);

      return date != null &&
          date.isAfter(now) &&
          rdv.statut == 'Planifie';
    }).toList();

    if (upcoming.isEmpty) {
      if (language == 'en') {
        return 'You do not have any upcoming appointments.';
      }

      if (language == 'ar') {
        return 'ليس لديك أي موعد قادم.';
      }

      return 'Vous n’avez aucun prochain rendez-vous.';
    }

    upcoming.sort((a, b) {
      final dateA = _parseDateTime(a)!;
      final dateB = _parseDateTime(b)!;

      return dateA.compareTo(dateB);
    });

    final next = upcoming.first;
    final nextDate = _parseDateTime(next)!;

    if (language == 'en') {
      return 'Your next appointment is on '
          '${_displayDate(nextDate)} '
          'at ${next.heureDebut}: ${next.titre}.';
    }

    if (language == 'ar') {
      return 'موعدك القادم هو بتاريخ '
          '${_displayDate(nextDate)} '
          'على الساعة ${next.heureDebut}: ${next.titre}.';
    }

    return 'Votre prochain rendez-vous est le '
        '${_displayDate(nextDate)} '
        'à ${next.heureDebut} : ${next.titre}.';
  }

  // ═══════════════════════════════════════════════
  // COUNT
  // ═══════════════════════════════════════════════

  String _appointmentCount(
    List<RendezVous> rendezVous,
    String language,
  ) {
    final count = rendezVous
        .where((rdv) => rdv.statut != 'Annule')
        .length;

    if (language == 'en') {
      return 'You have $count appointment(s) recorded.';
    }

    if (language == 'ar') {
      return 'لديك $count موعدًا مسجلاً.';
    }

    return 'Vous avez $count rendez-vous enregistré(s).';
  }

  // ═══════════════════════════════════════════════
  // FAVORITES
  // ═══════════════════════════════════════════════

  String _favoriteAppointments(
    List<RendezVous> rendezVous,
    String language,
  ) {
    final favorites = rendezVous
        .where(
          (rdv) =>
              rdv.estFavori &&
              rdv.statut != 'Annule',
        )
        .toList();

    favorites.sort((a, b) {
      final dateComparison =
          a.dateRDV.compareTo(b.dateRDV);

      if (dateComparison != 0) {
        return dateComparison;
      }

      return a.heureDebut.compareTo(b.heureDebut);
    });

    if (favorites.isEmpty) {
      if (language == 'en') {
        return 'You do not have any favorite appointments.';
      }

      if (language == 'ar') {
        return 'ليس لديك أي موعد مفضل.';
      }

      return 'Vous n’avez aucun rendez-vous favori.';
    }

    final buffer = StringBuffer();

    if (language == 'en') {
      buffer.writeln(
        'Here are your favorite appointments:',
      );
    } else if (language == 'ar') {
      buffer.writeln(
        'هذه هي مواعيدك المفضلة:',
      );
    } else {
      buffer.writeln(
        'Voici vos rendez-vous favoris :',
      );
    }

    for (final rdv in favorites) {
      if (language == 'ar') {
        buffer.writeln(
          '• ${rdv.dateRDV} على الساعة ${rdv.heureDebut} : ${rdv.titre}',
        );
      } else {
        buffer.writeln(
          '• ${rdv.dateRDV} at ${rdv.heureDebut} : ${rdv.titre}',
        );
      }
    }

    return buffer.toString().trim();
  }

  // ═══════════════════════════════════════════════
  // HELP
  // ═══════════════════════════════════════════════

  String _helpMessage(String language) {
    if (language == 'en') {
      return '''
I can help you manage your agenda.

Try for example:
• What are my appointments today?
• Am I busy today?
• Do I have anything planned tomorrow?
• What is my next appointment?
• How many appointments do I have?
• What are my favorite appointments?
''';
    }

    if (language == 'ar') {
      return '''
يمكنني مساعدتك في إدارة مواعيدك.

جرّب مثلاً:
• ما هي مواعيدي اليوم؟
• عندي مواعيد اليوم؟
• عندي حاجة غدوة؟
• ما هو موعدي القادم؟
• كم عدد مواعيدي؟
• ما هي مواعيدي المفضلة؟
''';
    }

    return '''
Je peux vous aider avec votre agenda.

Essayez par exemple :
• Quels sont mes rendez-vous aujourd’hui ?
• Est-ce que j’ai quelque chose de prévu aujourd’hui ?
• J’ai quelque chose de prévu demain ?
• Quel est mon prochain rendez-vous ?
• Combien ai-je de rendez-vous ?
• Quels sont mes rendez-vous favoris ?
''';
  }

  // ═══════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════

  bool _containsAny(
    String text,
    List<String> words,
  ) {
    return words.any(text.contains);
  }

  String _formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _displayDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  DateTime? _parseDateTime(RendezVous rdv) {
    try {
      final dateParts = rdv.dateRDV.split('-');
      final timeParts = rdv.heureDebut.split(':');

      if (dateParts.length != 3 ||
          timeParts.length < 2) {
        return null;
      }

      return DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );
    } catch (_) {
      return null;
    }
  }
}
