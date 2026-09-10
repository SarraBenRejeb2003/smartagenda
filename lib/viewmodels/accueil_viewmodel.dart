import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class AccueilViewModel extends ChangeNotifier {
  String get dateAujourdhui {
    return DateFormat('dd/MM/yyyy').format(DateTime.now());
  }
}