import 'package:flutter/material.dart';

class TimelineModel {
  final String title;
  final String time;
  final String type;
  final IconData icon;

  TimelineModel(
      {required this.title, required this.time, required this.type, required this.icon});
}
