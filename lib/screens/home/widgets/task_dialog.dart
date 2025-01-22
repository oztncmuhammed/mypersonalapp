import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class TaskDialog extends StatefulWidget {
  final String? initialTitle;
  final DateTime? initialDate;
  final TimeOfDay? initialTime;
  final Function(String, DateTime, TimeOfDay) onSave;

  const TaskDialog({
    super.key,
    this.initialTitle,
    this.initialDate,
    this.initialTime,
    required this.onSave,
  });

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  late TextEditingController taskController;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    taskController = TextEditingController(text: widget.initialTitle);
    selectedDate = widget.initialDate;
    selectedTime = widget.initialTime ?? TimeOfDay.now();
  }

  void _showTimePicker() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() {
        selectedTime = time;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          Text(widget.initialTitle == null ? 'Yeni Görev' : 'Görevi Düzenle'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: taskController,
            decoration: const InputDecoration(
              hintText: 'Görev başlığını giriniz',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildDatePicker()),
              IconButton(
                icon: const Icon(Icons.access_time, color: Colors.blue),
                onPressed: _showTimePicker,
              ),
              Text(
                selectedTime != null
                    ? '${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                    : 'Saat Seç',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        TextButton(
          onPressed: () {
            if (taskController.text.isNotEmpty &&
                selectedDate != null &&
                selectedTime != null) {
              widget.onSave(taskController.text, selectedDate!, selectedTime!);
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Lütfen tüm alanları doldurunuz'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          child: const Text('Kaydet'),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text('Sona Erme Tarihi: '),
            Text(
              selectedDate != null
                  ? '${selectedDate!.day}.${selectedDate!.month}.${selectedDate!.year}'
                  : 'Tarih Seç',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.calendar_today, color: Colors.blue),
          onPressed: _showCalendarDialog,
        ),
      ],
    );
  }

  void _showCalendarDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: SizedBox(
            width: 300,
            height: 400,
            child: TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: selectedDate ?? DateTime.now(),
              selectedDayPredicate: (day) => isSameDay(day, selectedDate),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  selectedDate = selectedDay;
                });
                Navigator.pop(context);
              },
              calendarStyle: const CalendarStyle(
                outsideDaysVisible: false,
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              availableGestures: AvailableGestures.all,
              locale: 'tr_TR',
            ),
          ),
        );
      },
    );
  }
}
