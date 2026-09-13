import 'package:flutter/foundation.dart';

import '../services/smart_assistant_service.dart';

class SmartAssistantViewModel extends ChangeNotifier {
  final SmartAssistantService _service;

  bool _isLoading = false;
  String? _errorMessage;

  SmartAssistantViewModel({
    SmartAssistantService? service,
  }) : _service = service ?? SmartAssistantService();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<String> sendMessage(String message) async {
    if (message.trim().isEmpty) {
      return '';
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _service.processMessage(message);
      return response;
    } catch (e) {
      _errorMessage =
          'Une erreur est survenue avec l’assistant.';
      return 'Désolé, une erreur est survenue.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}