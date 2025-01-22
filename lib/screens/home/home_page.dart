import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../models/task.dart';
import '../../models/weather.dart';
import '../../services/weather_service.dart';
import '../settings/settings_drawer.dart';
import 'widgets/weather_card.dart';
import 'widgets/task_list.dart';
import 'widgets/task_dialog.dart';
import '../notes/notes_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../notifications/notifications_page.dart';
import 'widgets/reminder_list.dart';
import '../../models/reminder.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _logger = Logger();
  int _selectedIndex = 0;
  String selectedCity = 'Mersin';
  final WeatherService _weatherService = WeatherService();
  Weather? _currentWeather;
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  final List<Task> _tasks = [
    Task(
      title: 'Görev 1',
      isCompleted: false,
      date: DateTime.now(),
      deadline: DateTime.now().add(const Duration(days: 1)),
      time: TimeOfDay.now(),
    ),
    Task(
      title: 'Görev 2',
      isCompleted: true,
      date: DateTime.now(),
      deadline: DateTime.now().add(const Duration(days: 2)),
      time: TimeOfDay.now(),
    ),
  ];

  final List<Reminder> _reminders = [];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _initializeNotifications();
    _loadWeather();
  }

  Future<void> _initializeNotifications() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await _notifications.initialize(initializationSettings);
  }

  Future<void> _loadWeather() async {
    try {
      final weather = await _weatherService.getWeather(selectedCity);
      setState(() {
        _currentWeather = weather;
      });
    } catch (e) {
      _logger.e('Hava durumu yüklenirken hata: $e');
    }
  }

  void _addTask() {
    showDialog(
      context: context,
      builder: (context) => TaskDialog(
        onSave: (title, deadline, time) {
          setState(() {
            _tasks.add(Task(
              title: title,
              isCompleted: false,
              date: DateTime.now(),
              deadline: deadline,
              time: time,
            ));
          });
          _scheduleNotification(title, deadline, time);
        },
      ),
    );
  }

  void _editTask(Task task) {
    showDialog(
      context: context,
      builder: (context) => TaskDialog(
        initialTitle: task.title,
        initialDate: task.deadline,
        initialTime: task.time,
        onSave: (title, deadline, time) {
          setState(() {
            task.title = title;
            task.deadline = deadline;
            task.time = time;
          });
          _scheduleNotification(title, deadline, time);
        },
      ),
    );
  }

  void _deleteTask(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Görevi Sil'),
        content: const Text('Bu görevi silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _tasks.remove(task);
              });
              Navigator.pop(context);
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _scheduleNotification(
      String title, DateTime deadline, TimeOfDay time) async {
    final now = DateTime.now();
    final notificationTime = tz.TZDateTime.from(
      DateTime(
        deadline.year,
        deadline.month,
        deadline.day,
        time.hour,
        time.minute,
      ),
      tz.local,
    );

    if (notificationTime.isAfter(now)) {
      await _notifications.zonedSchedule(
        title.hashCode,
        'Görev Hatırlatması',
        title,
        notificationTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_reminders',
            'Görev Hatırlatmaları',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      _logger.i('Bildirim planlandı: $title - ${notificationTime.toString()}');
    }
  }

  bool get _hasTasksForToday {
    final now = DateTime.now();
    return _tasks.any((task) =>
        task.deadline.year == now.year &&
        task.deadline.month == now.month &&
        task.deadline.day == now.day &&
        !task.isCompleted);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications),
                if (_hasTasksForToday)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationsPage(
                    tasks: _tasks,
                    reminders: _reminders,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      drawer: const SettingsDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WeatherCard(
              currentWeather: _currentWeather,
              selectedCity: selectedCity,
              onCitySelect: (String city) {
                setState(() {
                  selectedCity = city;
                });
                _loadWeather();
              },
            ),
            const SizedBox(height: 16),
            TaskList(
              title: 'Görevler',
              tasks: _tasks,
              onEdit: _editTask,
              onDelete: _deleteTask,
              onStatusChanged: (task, value) {
                setState(() {
                  task.isCompleted = value ?? false;
                });
              },
            ),
            const SizedBox(height: 16),
            ReminderList(
              title: 'Hatırlatıcılar',
              reminders: _reminders,
              onEdit: _editReminder,
              onDelete: _deleteReminder,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotesPage()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: 'Notlar',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ne eklemek istersiniz?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.task),
              title: const Text('Görev'),
              onTap: () {
                Navigator.pop(context);
                _addTask();
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Hatırlatıcı'),
              onTap: () {
                Navigator.pop(context);
                _addReminder();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addReminder() {
    final titleController = TextEditingController();
    TimeOfDay? selectedTime;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Hatırlatıcı'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: 'Hatırlatıcı başlığı',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            StatefulBuilder(
              builder: (context, setState) => ElevatedButton(
                onPressed: () async {
                  final TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                    builder: (context, child) {
                      return MediaQuery(
                        data: MediaQuery.of(context)
                            .copyWith(alwaysUse24HourFormat: true),
                        child: child!,
                      );
                    },
                  );
                  if (time != null) {
                    setState(() => selectedTime = time);
                  }
                },
                child: Text(
                  selectedTime != null
                      ? 'Saat: ${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                      : 'Saat Seç',
                ),
              ),
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
              if (titleController.text.isNotEmpty && selectedTime != null) {
                setState(() {
                  _reminders.add(Reminder(
                    title: titleController.text,
                    time: selectedTime!,
                    date: DateTime.now(),
                  ));
                });
                Navigator.pop(context);
                _scheduleReminderNotification(
                    titleController.text, selectedTime!);
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _editReminder(Reminder reminder) {
    final titleController = TextEditingController(text: reminder.title);
    TimeOfDay selectedTime = reminder.time;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hatırlatıcıyı Düzenle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: 'Hatırlatıcı başlığı',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            StatefulBuilder(
              builder: (context, setState) => ElevatedButton(
                onPressed: () async {
                  final TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                    builder: (context, child) {
                      return MediaQuery(
                        data: MediaQuery.of(context)
                            .copyWith(alwaysUse24HourFormat: true),
                        child: child!,
                      );
                    },
                  );
                  if (time != null) {
                    setState(() => selectedTime = time);
                  }
                },
                child: Text(
                  'Saat: ${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}',
                ),
              ),
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
              if (titleController.text.isNotEmpty) {
                setState(() {
                  reminder.title = titleController.text;
                  reminder.time = selectedTime;
                  reminder.date = DateTime.now();
                });
                Navigator.pop(context);
                _scheduleReminderNotification(
                    titleController.text, selectedTime);
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _deleteReminder(Reminder reminder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hatırlatıcıyı Sil'),
        content:
            const Text('Bu hatırlatıcıyı silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _reminders.remove(reminder);
              });
              Navigator.pop(context);
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _scheduleReminderNotification(String title, TimeOfDay time) async {
    final now = DateTime.now();
    final reminderTime = tz.TZDateTime.from(
      DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      ),
      tz.local,
    );

    if (reminderTime.isAfter(now)) {
      await _notifications.zonedSchedule(
        title.hashCode,
        'Hatırlatıcı',
        title,
        reminderTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reminder_notifications',
            'Hatırlatıcılar',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      _logger.i('Hatırlatıcı planlandı: $title - ${reminderTime.toString()}');
    }
  }
}
