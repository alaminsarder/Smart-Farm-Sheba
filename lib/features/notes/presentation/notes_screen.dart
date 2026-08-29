import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  static const _storageKey = 'notes_v1';

  final List<Note> _notes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw) as List<dynamic>;
      _notes
        ..clear()
        ..addAll(decoded.map((e) => Note.fromMap(e as Map<String, dynamic>)));
      // newest first
      _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }

    setState(() => _loading = false);
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_notes.map((n) => n.toMap()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  Future<void> _addNote() async {
    final text = await _openEditorDialog(title: 'New Note');
    if (text == null) return;

    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final now = DateTime.now();
    final note = Note(
      id: now.millisecondsSinceEpoch.toString(),
      text: trimmed,
      createdAt: now,
      updatedAt: now,
    );

    setState(() {
      _notes.insert(0, note);
    });
    await _saveNotes();
  }

  Future<void> _editNote(Note note) async {
    final text =
        await _openEditorDialog(title: 'Edit Note', initialText: note.text);
    if (text == null) return;

    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      final idx = _notes.indexWhere((n) => n.id == note.id);
      if (idx != -1) {
        _notes[idx] = note.copyWith(text: trimmed, updatedAt: DateTime.now());
        // move updated note to top
        final updated = _notes.removeAt(idx);
        _notes.insert(0, updated);
      }
    });
    await _saveNotes();
  }

  Future<void> _deleteNote(Note note) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete note?'),
        content: const Text('This note will be removed permanently.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete')),
        ],
      ),
    );

    if (ok != true) return;

    setState(() {
      _notes.removeWhere((n) => n.id == note.id);
    });
    await _saveNotes();
  }

  Future<String?> _openEditorDialog(
      {required String title, String initialText = ''}) async {
    final controller = TextEditingController(text: initialText);

    return showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 8,
          minLines: 4,
          textInputAction: TextInputAction.newline,
          decoration: const InputDecoration(
            hintText: 'Write your note...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            tooltip: 'Add note',
            onPressed: _addNote,
            icon: const Icon(Icons.note_add_rounded),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
              ? const _EmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _notes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final note = _notes[index];
                    return Dismissible(
                      key: ValueKey(note.id),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) async {
                        await _deleteNote(note);
                        return false; // we delete manually
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.delete_rounded,
                            color: Colors.white),
                      ),
                      child: InkWell(
                        onTap: () => _editNote(note),
                        borderRadius: BorderRadius.circular(14),
                        child: Card(
                          elevation: 0,
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  note.previewTitle,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  note.previewBody,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Text(
                                      _formatTime(note.updatedAt),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium,
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      tooltip: 'Edit',
                                      onPressed: () => _editNote(note),
                                      icon: const Icon(Icons.edit_rounded),
                                    ),
                                    IconButton(
                                      tooltip: 'Delete',
                                      onPressed: () => _deleteNote(note),
                                      icon: const Icon(
                                          Icons.delete_outline_rounded),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$y-$m-$d  $hh:$mm';
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_alt_rounded,
                size: 64, color: Theme.of(context).hintColor),
            const SizedBox(height: 12),
            Text(
              'No notes yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              'Tap + to create your first note.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class Note {
  final String id;
  final String text;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
  });

  String get previewTitle {
    final t = text.trim();
    if (t.isEmpty) return '(Untitled)';
    final firstLine = t.split('\n').first;
    return firstLine.isEmpty ? '(Untitled)' : firstLine;
  }

  String get previewBody {
    final t = text.trim();
    final lines = t.split('\n');
    if (lines.length <= 1) return '';
    return lines.skip(1).join('\n').trim();
  }

  Note copyWith({String? text, DateTime? updatedAt}) {
    return Note(
      id: id,
      text: text ?? this.text,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String,
      text: map['text'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
