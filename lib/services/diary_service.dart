import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/features/diary/diary_page.dart'; // For DiaryEntry model

class DiaryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // Get stream of diary entries
  Stream<List<DiaryEntry>> getDiaryEntriesStream() {
    if (_userId == null) return Stream.value([]);

    return _db
        .collection('users')
        .doc(_userId)
        .collection('diary')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return DiaryEntry(
          id: doc.id,
          title: data['title'] ?? '',
          content: data['content'] ?? '',
          date: (data['date'] as Timestamp).toDate(),
          mood: data['mood'] ?? 'Neutral',
          aiSuggestion: data['aiSuggestion'],
        );
      }).toList();
    });
  }

  // Add new entry
  Future<void> addEntry(DiaryEntry entry) async {
    if (_userId == null) return;

    await _db.collection('users').doc(_userId).collection('diary').add({
      'title': entry.title,
      'content': entry.content,
      'date': Timestamp.fromDate(entry.date),
      'mood': entry.mood,
      'aiSuggestion': entry.aiSuggestion,
    });
  }

  // Delete entry
  Future<void> deleteEntry(String id) async {
    if (_userId == null) return;
    await _db
        .collection('users')
        .doc(_userId)
        .collection('diary')
        .doc(id)
        .delete();
  }
}
