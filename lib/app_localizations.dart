import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(
          context,
          AppLocalizations,
        ) ??
        AppLocalizations(const Locale('fr', 'FR'));
  }

  bool get isEnglish => locale.languageCode == 'en';
  bool get isArabic => locale.languageCode == 'ar';

  String get appName => 'SmartAgenda';

  String get calendar => _translate(
        fr: 'Calendrier',
        en: 'Calendar',
        ar: 'التقويم',
      );

  String get settings => _translate(
        fr: 'Paramètres',
        en: 'Settings',
        ar: 'الإعدادات',
      );

  String get add => _translate(
        fr: 'Ajouter',
        en: 'Add',
        ar: 'إضافة',
      );

  String get edit => _translate(
        fr: 'Modifier',
        en: 'Edit',
        ar: 'تعديل',
      );

  String get delete => _translate(
        fr: 'Supprimer',
        en: 'Delete',
        ar: 'حذف',
      );

  String get save => _translate(
        fr: 'Enregistrer',
        en: 'Save',
        ar: 'حفظ',
      );

  String get cancel => _translate(
        fr: 'Annuler',
        en: 'Cancel',
        ar: 'إلغاء',
      );

  String get appointment => _translate(
        fr: 'Rendez-vous',
        en: 'Appointment',
        ar: 'موعد',
      );

  String get appointments => _translate(
        fr: 'Rendez-vous',
        en: 'Appointments',
        ar: 'المواعيد',
      );

  String get professional => _translate(
        fr: 'Professionnel',
        en: 'Professional',
        ar: 'مهني',
      );

  String get doctor => _translate(
        fr: 'Docteur',
        en: 'Doctor',
        ar: 'طبيب',
      );

  String get privateAppointment => _translate(
        fr: 'Privé',
        en: 'Private',
        ar: 'خاص',
      );

  String get title => _translate(
        fr: 'Titre',
        en: 'Title',
        ar: 'العنوان',
      );

  String get description => _translate(
        fr: 'Description',
        en: 'Description',
        ar: 'الوصف',
      );

  String get location => _translate(
        fr: 'Lieu',
        en: 'Location',
        ar: 'المكان',
      );

  String get status => _translate(
        fr: 'Statut',
        en: 'Status',
        ar: 'الحالة',
      );

  String get favorite => _translate(
        fr: 'Favori',
        en: 'Favorite',
        ar: 'المفضلة',
      );

  String get date => _translate(
        fr: 'Date',
        en: 'Date',
        ar: 'التاريخ',
      );

  String get start => _translate(
        fr: 'Début',
        en: 'Start',
        ar: 'البداية',
      );

  String get end => _translate(
        fr: 'Fin',
        en: 'End',
        ar: 'النهاية',
      );

  String get contact => _translate(
        fr: 'Contact',
        en: 'Contact',
        ar: 'جهة الاتصال',
      );

  String get notifications => _translate(
        fr: 'Notifications',
        en: 'Notifications',
        ar: 'الإشعارات',
      );

  String get appearance => _translate(
        fr: 'Apparence',
        en: 'Appearance',
        ar: 'المظهر',
      );

  String get language => _translate(
        fr: 'Langue',
        en: 'Language',
        ar: 'اللغة',
      );

  String get themeColor => _translate(
        fr: 'Couleur du thème',
        en: 'Theme color',
        ar: 'لون المظهر',
      );

  String get timeFormat => _translate(
        fr: 'Format de l’heure',
        en: 'Time format',
        ar: 'تنسيق الوقت',
      );

  String get appLanguage => _translate(
        fr: 'Langue de l’application',
        en: 'Application language',
        ar: 'لغة التطبيق',
      );

  String get saveSettings => _translate(
        fr: 'Enregistrer les paramètres',
        en: 'Save settings',
        ar: 'حفظ الإعدادات',
      );

  String get settingsSaved => _translate(
        fr: 'Paramètres enregistrés avec succès ✓',
        en: 'Settings saved successfully ✓',
        ar: 'تم حفظ الإعدادات بنجاح ✓',
      );

  String get noAppointments => _translate(
        fr: 'Aucun rendez-vous pour cette date.',
        en: 'No appointments for this date.',
        ar: 'لا توجد مواعيد لهذا التاريخ.',
      );

  String get scheduled => _translate(
        fr: 'Planifié',
        en: 'Scheduled',
        ar: 'مجدول',
      );

  String get completed => _translate(
        fr: 'Terminé',
        en: 'Completed',
        ar: 'مكتمل',
      );

  String get cancelled => _translate(
        fr: 'Annulé',
        en: 'Cancelled',
        ar: 'ملغى',
      );
  
String get todayAppointments => _translate(
      fr: 'Rendez-vous du jour',
      en: "Today's appointments",
      ar: 'مواعيد اليوم',
    );

String get appointmentDetails => _translate(
      fr: 'Détails du rendez-vous',
      en: 'Appointment details',
      ar: 'تفاصيل الموعد',
    );

String get time => _translate(
      fr: 'Horaire',
      en: 'Time',
      ar: 'الوقت',
    );

String get yes => _translate(
      fr: 'Oui',
      en: 'Yes',
      ar: 'نعم',
    );

String get no => _translate(
      fr: 'Non',
      en: 'No',
      ar: 'لا',
    );

String get noAppointmentsForDate => _translate(
      fr: 'Aucun rendez-vous pour cette date.',
      en: 'No appointments for this date.',
      ar: 'لا توجد مواعيد لهذا التاريخ.',
    );

String get modifyStatus => _translate(
      fr: 'Modifier le statut',
      en: 'Change status',
      ar: 'تغيير الحالة',
    );

String get favoriteAdded => _translate(
      fr: 'Rendez-vous ajouté aux favoris.',
      en: 'Appointment added to favorites.',
      ar: 'تمت إضافة الموعد إلى المفضلة.',
    );

String get favoriteRemoved => _translate(
      fr: 'Rendez-vous retiré des favoris.',
      en: 'Appointment removed from favorites.',
      ar: 'تمت إزالة الموعد من المفضلة.',
    );

String get statusModified => _translate(
      fr: 'Statut modifié',
      en: 'Status changed',
      ar: 'تم تغيير الحالة',
    );

String get selectAppointment => _translate(
      fr: 'Veuillez sélectionner un rendez-vous.',
      en: 'Please select an appointment.',
      ar: 'يرجى اختيار موعد.',
    );

String get deleteAppointment => _translate(
      fr: 'Supprimer le rendez-vous',
      en: 'Delete appointment',
      ar: 'حذف الموعد',
    );

String get confirmDeleteAppointment => _translate(
      fr: 'Voulez-vous vraiment supprimer le rendez-vous',
      en: 'Are you sure you want to delete the appointment',
      ar: 'هل تريد حقًا حذف الموعد',
    );

String get deletedSuccessfully => _translate(
      fr: 'Rendez-vous supprimé avec succès.',
      en: 'Appointment deleted successfully.',
      ar: 'تم حذف الموعد بنجاح.',
    );

String get errorDeleting => _translate(
      fr: 'Erreur lors de la suppression.',
      en: 'Error while deleting.',
      ar: 'حدث خطأ أثناء الحذف.',
    );

String get removeFromFavorites => _translate(
      fr: 'Retirer des favoris',
      en: 'Remove from favorites',
      ar: 'إزالة من المفضلة',
    );

String get addToFavorites => _translate(
      fr: 'Ajouter aux favoris',
      en: 'Add to favorites',
      ar: 'إضافة إلى المفضلة',
    );

String get type => _translate(
      fr: 'Type',
      en: 'Type',
      ar: 'النوع',
    );

String get detailsDate => _translate(
      fr: 'Date',
      en: 'Date',
      ar: 'التاريخ',
    );

String get detailsContact => _translate(
      fr: 'Contact',
      en: 'Contact',
      ar: 'جهة الاتصال',
    );

String get detailsPlace => _translate(
      fr: 'Lieu',
      en: 'Location',
      ar: 'المكان',
    );

String get detailsDescription => _translate(
      fr: 'Description',
      en: 'Description',
      ar: 'الوصف',
    );

String get detailsDoctor => _translate(
      fr: 'Docteur',
      en: 'Doctor',
      ar: 'طبيب',
    );

String get detailsProfessional => _translate(
      fr: 'Professionnel',
      en: 'Professional',
      ar: 'مهني',
    );

String get detailsContactGeneric => _translate(
      fr: 'Contact',
      en: 'Contact',
      ar: 'جهة الاتصال',
    );

String get addButton => _translate(
      fr: 'Ajouter',
      en: 'Add',
      ar: 'إضافة',
    );

String get editButton => _translate(
      fr: 'Modifier',
      en: 'Edit',
      ar: 'تعديل',
    );

String get deleteButton => _translate(
      fr: 'Supprimer',
      en: 'Delete',
      ar: 'حذف',
    );
  String get confirmation => _translate(
      fr: 'Confirmation',
      en: 'Confirmation',
      ar: 'تأكيد',
    );

String get noAppointmentsRecorded => _translate(
      fr: 'Aucun rendez-vous enregistré.',
      en: 'No appointments recorded.',
      ar: 'لا توجد مواعيد مسجلة.',
    );
String get medical => _translate(
  fr: 'Médical',
  en: 'Medical',
  ar: 'طبي',
);
String get newAppointment => _translate(
      fr: 'Nouveau',
      en: 'New',
      ar: 'جديد',
    );

String get errorChangingFavorite => _translate(
      fr: 'Erreur lors de la modification du favori.',
      en: 'Error while changing favorite.',
      ar: 'حدث خطأ أثناء تعديل المفضلة.',
    );

String get errorChangingStatus => _translate(
      fr: 'Erreur lors de la modification du statut.',
      en: 'Error while changing status.',
      ar: 'حدث خطأ أثناء تعديل الحالة.',
    );
String get addAppointment => _translate(
  fr: 'Ajouter un rendez-vous',
  en: 'Add an appointment',
  ar: 'إضافة موعد',
);

String get editAppointment => _translate(
  fr: 'Modifier le rendez-vous',
  en: 'Edit appointment',
  ar: 'تعديل الموعد',
);

String get appointmentType => _translate(
  fr: 'Type de rendez-vous',
  en: 'Appointment type',
  ar: 'نوع الموعد',
);

String get startTime => _translate(
  fr: 'Heure début',
  en: 'Start time',
  ar: 'وقت البداية',
);

String get endTime => _translate(
  fr: 'Heure fin',
  en: 'End time',
  ar: 'وقت النهاية',
);



String get favoriteDescription => _translate(
  fr: 'Marquer ce rendez-vous comme favori',
  en: 'Mark this appointment as a favorite',
  ar: 'وضع علامة على هذا الموعد كمفضل',
);

String get saving => _translate(
  fr: 'Enregistrement...',
  en: 'Saving...',
  ar: 'جارٍ الحفظ...',
);

String get enterTitle => _translate(
  fr: 'Veuillez saisir un titre.',
  en: 'Please enter a title.',
  ar: 'يرجى إدخال عنوان.',
);

String get endTimeAfterStart => _translate(
  fr: 'L’heure de fin doit être après l’heure de début.',
  en: 'The end time must be after the start time.',
  ar: 'يجب أن يكون وقت النهاية بعد وقت البداية.',
);

String get selectProfessional => _translate(
  fr: 'Veuillez sélectionner un professionnel.',
  en: 'Please select a professional.',
  ar: 'يرجى اختيار مهني.',
);
String get doctors => _translate(
  fr: 'Docteurs',
  en: 'Doctors',
  ar: 'الأطباء',
);

String get noDoctors => _translate(
  fr: 'Aucun docteur',
  en: 'No doctors',
  ar: 'لا يوجد أطباء',
);
String get doctorName => _translate(
  fr: 'Nom du docteur',
  en: 'Doctor name',
  ar: 'اسم الطبيب',
);

String get doctorNameRequired => _translate(
  fr: 'Le nom est obligatoire',
  en: 'Name is required',
  ar: 'الاسم إجباري',
);

String get specialty => _translate(
  fr: 'Spécialité',
  en: 'Specialty',
  ar: 'التخصص',
);


String get reminderDelay => _translate(
  fr: 'Délai du rappel',
  en: 'Reminder delay',
  ar: 'مدة التذكير',
);

String get minutesBefore5 => _translate(
  fr: '5 minutes avant',
  en: '5 minutes before',
  ar: 'قبل 5 دقائق',
);

String get minutesBefore10 => _translate(
  fr: '10 minutes avant',
  en: '10 minutes before',
  ar: 'قبل 10 دقائق',
);

String get minutesBefore15 => _translate(
  fr: '15 minutes avant',
  en: '15 minutes before',
  ar: 'قبل 15 دقيقة',
);

String get minutesBefore30 => _translate(
  fr: '30 minutes avant',
  en: '30 minutes before',
  ar: 'قبل 30 دقيقة',
);

String get hourBefore1 => _translate(
  fr: '1 heure avant',
  en: '1 hour before',
  ar: 'قبل ساعة واحدة',
);

String get hoursBefore2 => _translate(
  fr: '2 heures avant',
  en: '2 hours before',
  ar: 'قبل ساعتين',
);



String get twentyFourHours => _translate(
  fr: '24 heures — 14:30',
  en: '24 hours — 14:30',
  ar: '24 ساعة — 14:30',
);

String get twelveHours => _translate(
  fr: '12 heures — 2:30 PM',
  en: '12 hours — 2:30 PM',
  ar: '12 ساعة — 2:30 PM',
);



String get errorSavingSettings => _translate(
  fr: 'Erreur lors de l’enregistrement.',
  en: 'Error while saving.',
  ar: 'حدث خطأ أثناء الحفظ.',
);

String get themeColorDialog => _translate(
  fr: 'Couleur du thème',
  en: 'Theme color',
  ar: 'لون المظهر',
);
String get officeAddress => _translate(
  fr: 'Adresse du cabinet',
  en: 'Office address',
  ar: 'عنوان العيادة',
);

String get unexpectedErrorDoctor => _translate(
  fr: 'Une erreur est survenue.',
  en: 'An error occurred.',
  ar: 'حدث خطأ.',
);
String get confirmDeleteDoctor => _translate(
  fr: 'Voulez-vous vraiment supprimer ce docteur ?',
  en: 'Do you really want to delete this doctor?',
  ar: 'هل تريد حقًا حذف هذا الطبيب؟',
);

String get errorDeletingDoctor => _translate(
  fr: 'Erreur lors de la suppression du docteur.',
  en: 'Error deleting the doctor.',
  ar: 'حدث خطأ أثناء حذف الطبيب.',
);
String get professionalName => _translate(
  fr: 'Nom du professionnel',
  en: 'Professional name',
  ar: 'اسم المهني',
);

String get professionalNameRequired => _translate(
  fr: 'Le nom est obligatoire',
  en: 'Name is required',
  ar: 'الاسم إجباري',
);


String get selectDoctor => _translate(
  fr: 'Veuillez sélectionner un docteur.',
  en: 'Please select a doctor.',
  ar: 'يرجى اختيار طبيب.',
);

String get unexpectedError => _translate(
  fr: 'Une erreur est survenue.',
  en: 'An error occurred.',
  ar: 'حدث خطأ ما.',
);

String get professionals => _translate(
  fr: 'Professionnels',
  en: 'Professionals',
  ar: 'المهنيون',
);

String get noProfessionals => _translate(
  fr: 'Aucun professionnel',
  en: 'No professionals',
  ar: 'لا يوجد مهنيون',
);

String get notProvided => _translate(
  fr: 'Non renseigné',
  en: 'Not provided',
  ar: 'غير محدد',
);

String get deleteProfessional => _translate(
  fr: 'Supprimer le professionnel',
  en: 'Delete professional',
  ar: 'حذف المهني',
);

String get confirmDeleteProfessional => _translate(
  fr: 'Voulez-vous vraiment supprimer ce professionnel ?',
  en: 'Are you sure you want to delete this professional?',
  ar: 'هل تريد حقًا حذف هذا المهني؟',
);

String get errorDeletingProfessional => _translate(
  fr: 'Erreur lors de la suppression du professionnel.',
  en: 'Error while deleting the professional.',
  ar: 'حدث خطأ أثناء حذف المهني.',
);

String get company => _translate(
  fr: 'Société',
  en: 'Company',
  ar: 'الشركة',
);

String get profession => _translate(
  fr: 'Fonction / Profession',
  en: 'Position / Profession',
  ar: 'الوظيفة / المهنة',
);

String get phone => _translate(
  fr: 'Téléphone',
  en: 'Phone',
  ar: 'الهاتف',
);

String get email => _translate(
  fr: 'Email',
  en: 'Email',
  ar: 'البريد الإلكتروني',
);



  String get french => 'Français';

  String get english => 'English';

  String get arabic => 'العربية';

  String _translate({
    required String fr,
    required String en,
    required String ar,
  }) {
    if (isEnglish) return en;
    if (isArabic) return ar;
    return fr;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['fr', 'en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) {
    return false;
  }
}