import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../models/reminder.dart';

class NotificationsPage extends StatelessWidget {
  final List<Task> tasks;
  final List<Reminder> reminders;

  const NotificationsPage({
    super.key,
    required this.tasks,
    required this.reminders,
  });

  List<dynamic> get _todaysNotifications {
    final now = DateTime.now();
    final currentTime = TimeOfDay.now();

    // Günün görevleri
    final todaysTasks = tasks.where((task) {
      return task.deadline.year == now.year &&
          task.deadline.month == now.month &&
          task.deadline.day == now.day &&
          !task.isCompleted;
    }).toList();

    // Zamanı gelmiş hatırlatıcılar
    final dueReminders = reminders.where((reminder) {
      final reminderMinutes = reminder.time.hour * 60 + reminder.time.minute;
      final currentMinutes = currentTime.hour * 60 + currentTime.minute;
      return reminder.date.year == now.year &&
          reminder.date.month == now.month &&
          reminder.date.day == now.day &&
          reminderMinutes <= currentMinutes;
    }).toList();

    return [...todaysTasks, ...dueReminders];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler'),
      ),
      body: _todaysNotifications.isEmpty
          ? const Center(
              child: Text('Bildirim bulunmuyor'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _todaysNotifications.length,
              itemBuilder: (context, index) {
                final notification = _todaysNotifications[index];
                return Card(
                  child: ListTile(
                    leading: Icon(
                      notification is Task ? Icons.task : Icons.notifications,
                      color: Colors.blue,
                    ),
                    title: Text(notification.title),
                    subtitle: Text(
                      notification is Task
                          ? 'Görev - ${notification.time.hour}:${notification.time.minute.toString().padLeft(2, '0')}'
                          : 'Hatırlatıcı - ${notification.time.hour}:${notification.time.minute.toString().padLeft(2, '0')}',
                    ),
                  ),
                );
              },
            ),
    );
  }
}
