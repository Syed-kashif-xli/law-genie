import 'package:myapp/features/home/models/timeline_model.dart';

class CaseModel {
  final String title;
  final String caseNumber;
  final String court;
  final String status;
  final List<TimelineModel> timeline;

  CaseModel({
    required this.title,
    required this.caseNumber,
    required this.court,
    required this.status,
    required this.timeline,
  });
}
