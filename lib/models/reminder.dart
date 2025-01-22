import 'package:flutter/material.dart' show TimeOfDay;

class Reminder {
  String title;
  TimeOfDay time;
  DateTime date;

  Reminder({
    required this.title,
    required this.time,
    required this.date,
  });
}
