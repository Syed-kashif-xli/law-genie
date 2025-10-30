import 'package:myapp/features/home/models/timeline_model.dart';

class Case {
  final String title;
  final String status;
  final double progress;
  final List<TimelineModel> timeline;

  Case({
    required this.title,
    required this.status,
    required this.progress,
    required this.timeline,
  });
}
