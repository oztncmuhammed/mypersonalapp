import 'package:flutter/material.dart' show TimeOfDay;

class Task {
  String title;
  bool isCompleted;
  DateTime date;
  DateTime deadline;
  TimeOfDay time;

  Task({
    required this.title,
    required this.isCompleted,
    required this.date,
    required this.deadline,
    required this.time,
  });
}
