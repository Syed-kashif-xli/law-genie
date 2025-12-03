import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/features/diary/diary_page.dart';
import 'package:myapp/services/diary_service.dart';

class DiaryProvider with ChangeNotifier {
  final DiaryService _diaryService = DiaryService();
  List<DiaryEntry> _entries = [];
  StreamSubscription<List<DiaryEntry>>? _subscription;
  bool _isLoading = true;

  DiaryProvider() {
    _init();
  }

  void _init() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _subscription?.cancel();
      if (user != null) {
        _isLoading = true;
        notifyListeners();

        _subscription = _diaryService.getDiaryEntriesStream().listen(
          (entries) {
            _entries = entries;
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            debugPrint('Error listening to diary entries: $error');
            _isLoading = false;
            notifyListeners();
          },
        );
      } else {
        _entries = [];
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  List<DiaryEntry> get entries => _entries;
  bool get isLoading => _isLoading;

  Future<void> addEntry(DiaryEntry entry) async {
    await _diaryService.addEntry(entry);
  }

  Future<void> deleteEntry(String id) async {
    await _diaryService.deleteEntry(id);
  }
}
