import 'package:flutter/material.dart';

class UsageProvider extends ChangeNotifier {
  // AI Queries
  int _aiQueriesUsage = 0;
  int _aiQueriesLimit = 500;

  // Cases
  int _casesUsage = 1;
  int _casesLimit = 50;

  // Scan to PDF
  int _scanToPdfUsage = 0;
  int _scanToPdfLimit = 50;

  // Documents
  int _documentsUsage = 0;
  int _documentsLimit = 20;

  // Risk Analysis
  int _riskAnalysisUsage = 0;
  int _riskAnalysisLimit = 10;

  // AI Voice
  int _aiVoiceUsage = 0;
  int _aiVoiceLimit = 100;

  // Getters
  int get aiQueriesUsage => _aiQueriesUsage;
  int get aiQueriesLimit => _aiQueriesLimit;

  int get casesUsage => _casesUsage;
  int get casesLimit => _casesLimit;

  int get scanToPdfUsage => _scanToPdfUsage;
  int get scanToPdfLimit => _scanToPdfLimit;

  int get documentsUsage => _documentsUsage;
  int get documentsLimit => _documentsLimit;

  int get riskAnalysisUsage => _riskAnalysisUsage;
  int get riskAnalysisLimit => _riskAnalysisLimit;

  int get aiVoiceUsage => _aiVoiceUsage;
  int get aiVoiceLimit => _aiVoiceLimit;

  // Case Finder
  int _caseFinderUsage = 0;
  int _caseFinderLimit = 50;

  int get caseFinderUsage => _caseFinderUsage;
  int get caseFinderLimit => _caseFinderLimit;

  // Court Orders
  int _courtOrdersUsage = 0;
  int _courtOrdersLimit = 30;

  // Translator
  int _translatorUsage = 0;
  int _translatorLimit = 100;

  // Bare Acts
  int _bareActsUsage = 0;
  int _bareActsLimit = 1000;

  // Chat History
  int _chatHistoryUsage = 0;
  int _chatHistoryLimit = 100;

  int get courtOrdersUsage => _courtOrdersUsage;
  int get courtOrdersLimit => _courtOrdersLimit;

  int get translatorUsage => _translatorUsage;
  int get translatorLimit => _translatorLimit;

  int get bareActsUsage => _bareActsUsage;
  int get bareActsLimit => _bareActsLimit;

  int get chatHistoryUsage => _chatHistoryUsage;
  int get chatHistoryLimit => _chatHistoryLimit;

  // Methods to increment usage (for future use)
  void incrementAiQueries() {
    if (_aiQueriesUsage < _aiQueriesLimit) {
      _aiQueriesUsage++;
      notifyListeners();
    }
  }

  // Add other increment methods as needed
}
