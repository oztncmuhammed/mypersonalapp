import 'package:flutter/material.dart';
import '../../../models/note.dart';

class NoteDetailDialog extends StatelessWidget {
  final Note note;

  const NoteDetailDialog({
    super.key,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(note.title),
      content: SingleChildScrollView(
        child: Text(note.content),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Kapat'),
        ),
      ],
    );
  }
}
