import 'package:flutter/material.dart';
import 'package:myapp/features/home/models/timeline_model.dart';
import 'package:iconsax/iconsax.dart';

class TimelineProvider with ChangeNotifier {
  List<TimelineModel> _events = [];
  bool _isLoading = false;

  List<TimelineModel> get events => _events;
  bool get isLoading => _isLoading;

  Future<void> fetchEvents() async {
    _isLoading = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    _events = [
      TimelineModel(
        title: 'Contract Review Deadline',
        time: 'Tomorrow - 2:00 PM',
        type: 'deadline',
        icon: Iconsax.calendar_1,
      ),
      TimelineModel(
        title: 'Court Hearing - Smith v. Johnson',
        time: 'Oct 25 - 10:00 AM',
        type: 'hearing',
        icon: Iconsax.calendar_1,
      ),
      TimelineModel(
        title: 'Client Meeting',
        time: 'Oct 26 - 11:00 AM',
        type: 'meeting',
        icon: Iconsax.user_octagon,
      ),
      TimelineModel(
        title: 'Submit Legal Brief',
        time: 'Oct 28 - 5:00 PM',
        type: 'deadline',
        icon: Iconsax.document_upload,
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }
}
