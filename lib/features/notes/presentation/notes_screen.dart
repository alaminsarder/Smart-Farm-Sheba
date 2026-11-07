import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class _NoteTone {
  final String name;
  final Color accent;
  final Color soft;
  const _NoteTone(this.name, this.accent, this.soft);
}

const _tones = <_NoteTone>[
  _NoteTone('Green', Color(0xFF2E7D32), Color(0xFFEAF6EB)),
  _NoteTone('Amber', Color(0xFFF59E0B), Color(0xFFFFF6E0)),
  _NoteTone('Blue', Color(0xFF2563EB), Color(0xFFE8F0FE)),
  _NoteTone('Rose', Color(0xFFE11D48), Color(0xFFFDE8EE)),
  _NoteTone('Purple', Color(0xFF7C3AED), Color(0xFFF0E9FD)),
  _NoteTone('Teal', Color(0xFF0D9488), Color(0xFFE0F5F2)),
];

class Note {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final int tone;
  final bool pinned;

  const Note({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.tone = 0,
    this.pinned = false,
  });
}

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  static const _ink = Color(0xFF1B1F23);
  static const _bg = Color(0xFFF4F7F4);
  static const _dark = Color(0xFF14532D);
  static const _mid = Color(0xFF2E7D32);

  final _col = FirebaseFirestore.instance.collection('notes');
  final _searchC = TextEditingController();
  final Set _hidden = {};

  late final _stream = _col.where('uid', isEqualTo: _uid).snapshots();

  List<Note> _notes = [];
  String _query = '';
  bool _onlyPinned = false;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  Note _fromMap(String id, Map data) {
    final t = data['tone'];
    int tone = t is int ? t : 0;
    if (tone < 0 || tone >= _tones.length) tone = 0;
    final ts = data['date'];
    return Note(
      id: id,
      title: (data['title'] ?? '').toString(),
      description: (data['description'] ?? '').toString(),
      date: ts is Timestamp ? ts.toDate() : DateTime.now(),
      tone: tone,
      pinned: data['pinned'] == true,
    );
  }

  List<Note> get _visible {
    final q = _query.trim().toLowerCase();
    final list = _notes.where((n) {
      if (_onlyPinned && !n.pinned) return false;
      if (q.isEmpty) return true;
      return n.title.toLowerCase().contains(q) ||
          n.description.toLowerCase().contains(q);
    }).toList();

    list.sort((a, b) {
      if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
      return b.date.compareTo(a.date);
    });
    return list;
  }

  int get _pinnedCount => _notes.where((n) => n.pinned).length;

  String _formatDate(DateTime d) {
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final min = d.minute.toString().padLeft(2, '0');
    final p = d.hour >= 12 ? 'PM' : 'AM';
    return '${d.day} ${m[d.month - 1]} ${d.year} · $h:$min $p';
  }

  void _toast(String msg, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          action: action,
          behavior: SnackBarBehavior.floating,
          backgroundColor: _ink,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 90),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
  }

  Future<void> _deleteNote(Note note) async {
    final uid = _uid;
    if (uid == null) return;
    setState(() => _hidden.add(note.id));
    HapticFeedback.mediumImpact();
    try {
      await _col.doc(note.id).delete();
    } catch (e) {
      if (!mounted) return;
      setState(() => _hidden.remove(note.id));
      _toast('Could not delete. Check connection or Firestore rules.');
      return;
    }
    if (!mounted) return;
    _toast(
      'Note deleted',
      action: SnackBarAction(
        label: 'UNDO',
        textColor: const Color(0xFF86EFAC),
        onPressed: () async {
          try {
            await _col.doc(note.id).set({
              'uid': uid,
              'title': note.title,
              'description': note.description,
              'date': Timestamp.fromDate(note.date),
              'tone': note.tone,
              'pinned': note.pinned,
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            });
            if (!mounted) return;
            setState(() => _hidden.remove(note.id));
          } catch (e) {
            if (!mounted) return;
            _toast('Could not restore the note.');
          }
        },
      ),
    );
  }

  Future<void> _togglePin(Note note) async {
    HapticFeedback.selectionClick();
    try {
      await _col.doc(note.id).update({
        'pinned': !note.pinned,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (!mounted) return;
      _toast('Could not update the note.');
    }
  }

  Future<void> _confirmDelete(Note note) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Color(0xFFFDE8EE),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.delete_outline_rounded,
              color: Color(0xFFE11D48), size: 28),
        ),
        title: const Text('Delete this note?',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text(
          'You can undo right after deleting.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) _deleteNote(note);
  }

  void _openEditor({Note? note}) {
    final titleC = TextEditingController(text: note?.title ?? '');
    final descC = TextEditingController(text: note?.description ?? '');
    int tone = note?.tone ?? 0;
    bool pinned = note?.pinned ?? false;
    String? titleErr;
    String? descErr;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            final accent = _tones[tone].accent;

            InputDecoration deco(String label, String hint, String? err) {
              OutlineInputBorder b(Color c, [double w = 1]) =>
                  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: c, width: w),
                  );
              return InputDecoration(
                labelText: label,
                hintText: hint,
                errorText: err,
                alignLabelWithHint: true,
                filled: true,
                fillColor: const Color(0xFFF6F8F6),
                floatingLabelStyle: TextStyle(color: accent),
                border: b(Colors.transparent),
                enabledBorder: b(Colors.black12),
                focusedBorder: b(accent, 1.6),
                errorBorder: b(const Color(0xFFE11D48)),
                focusedErrorBorder: b(const Color(0xFFE11D48), 1.6),
              );
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 12, 22, 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 44,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _tones[tone].soft,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                note == null
                                    ? Icons.edit_note_rounded
                                    : Icons.edit_rounded,
                                color: accent,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                note == null ? 'New note' : 'Edit note',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: _ink,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: pinned ? 'Unpin' : 'Pin',
                              onPressed: () => setSheet(() => pinned = !pinned),
                              icon: Icon(
                                pinned
                                    ? Icons.push_pin_rounded
                                    : Icons.push_pin_outlined,
                                color: pinned ? accent : Colors.black38,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: titleC,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.sentences,
                          decoration:
                              deco('Title', 'e.g. Potato field', titleErr),
                          onChanged: (_) {
                            if (titleErr != null) {
                              setSheet(() => titleErr = null);
                            }
                          },
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: descC,
                          minLines: 4,
                          maxLines: 7,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: deco(
                              'Details', 'Write your farming note...', descErr),
                          onChanged: (_) {
                            if (descErr != null) {
                              setSheet(() => descErr = null);
                            }
                          },
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Color label',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: List.generate(_tones.length, (i) {
                            final selected = i == tone;
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: GestureDetector(
                                onTap: () => setSheet(() => tone = i),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: _tones[i].accent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: selected
                                          ? Colors.white
                                          : Colors.transparent,
                                      width: 3,
                                    ),
                                    boxShadow: selected
                                        ? [
                                            BoxShadow(
                                              color: _tones[i]
                                                  .accent
                                                  .withOpacity(.55),
                                              blurRadius: 10,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: selected
                                      ? const Icon(Icons.check_rounded,
                                          color: Colors.white, size: 18)
                                      : null,
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(ctx),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _ink,
                                  side: const BorderSide(color: Colors.black12),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                ),
                                child: const Text('Cancel',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: accent,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                ),
                                onPressed: () async {
                                  final t = titleC.text.trim();
                                  final d = descC.text.trim();
                                  if (t.isEmpty || d.isEmpty) {
                                    setSheet(() {
                                      titleErr = t.isEmpty
                                          ? 'Title is required'
                                          : null;
                                      descErr = d.isEmpty
                                          ? 'Details are required'
                                          : null;
                                    });
                                    return;
                                  }

                                  final uid = _uid;
                                  if (uid == null) return;

                                  Navigator.pop(ctx);

                                  try {
                                    if (note == null) {
                                      await _col.add({
                                        'uid': uid,
                                        'title': t,
                                        'description': d,
                                        'date':
                                            Timestamp.fromDate(DateTime.now()),
                                        'tone': tone,
                                        'pinned': pinned,
                                        'createdAt':
                                            FieldValue.serverTimestamp(),
                                        'updatedAt':
                                            FieldValue.serverTimestamp(),
                                      });
                                    } else {
                                      await _col.doc(note.id).update({
                                        'title': t,
                                        'description': d,
                                        'tone': tone,
                                        'pinned': pinned,
                                        'updatedAt':
                                            FieldValue.serverTimestamp(),
                                      });
                                    }
                                    if (!mounted) return;
                                    _toast(note == null
                                        ? 'Note saved'
                                        : 'Note updated');
                                  } catch (e) {
                                    if (!mounted) return;
                                    _toast(
                                        'Could not save. Check connection or Firestore rules.');
                                  }
                                },
                                icon: const Icon(Icons.check_rounded, size: 20),
                                label: Text(
                                  note == null ? 'Save note' : 'Update note',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_uid == null) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(child: Text('Not signed in')),
      );
    }

    return StreamBuilder(
      stream: _stream,
      builder: (context, snap) {
        if (snap.hasError) {
          return const Scaffold(
            backgroundColor: _bg,
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Could not load notes. Check your connection or Firestore rules.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        if (!snap.hasData) {
          return const Scaffold(
            backgroundColor: _bg,
            body: Center(child: CircularProgressIndicator(color: _mid)),
          );
        }

        final fresh = <Note>[];
        for (final d in snap.data!.docs) {
          if (_hidden.contains(d.id)) continue;
          fresh.add(_fromMap(d.id, d.data()));
        }
        _notes = fresh;

        final list = _visible;

        return Scaffold(
          backgroundColor: _bg,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openEditor(),
            backgroundColor: _mid,
            foregroundColor: Colors.white,
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            icon: const Icon(Icons.add_rounded),
            label: const Text('New note',
                style: TextStyle(fontWeight: FontWeight.w800)),
          ),
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.translucent,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _header()),
                SliverToBoxAdapter(child: _filters()),
                if (_notes.isEmpty)
                  SliverFillRemaining(
                      hasScrollBody: false, child: _emptyState())
                else if (list.isEmpty)
                  SliverFillRemaining(hasScrollBody: false, child: _noResults())
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
                    sliver: SliverList.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _noteCard(list[i]),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _header() {
    final canPop = Navigator.of(context).canPop();

    return Container(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 14, 20, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_dark, _mid, Color(0xFF43A047)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (canPop)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.16),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white, size: 22),
                    ),
                  ),
                ),
              const Expanded(
                child: Text(
                  'My Notes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .2,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.agriculture_rounded,
                    color: Colors.white, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Your farm journal, always at hand',
            style: TextStyle(
              color: Colors.white.withOpacity(.8),
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _statChip(
                  Icons.sticky_note_2_rounded, '${_notes.length}', 'Total'),
              const SizedBox(width: 10),
              _statChip(Icons.push_pin_rounded, '$_pinnedCount', 'Pinned'),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchC,
            onChanged: (v) => setState(() => _query = v),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search notes...',
              hintStyle: const TextStyle(color: Colors.black38),
              prefixIcon:
                  const Icon(Icons.search_rounded, color: Colors.black45),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: Colors.black45),
                      onPressed: () {
                        _searchC.clear();
                        setState(() => _query = '');
                      },
                    ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 17),
          const SizedBox(width: 8),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 15)),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withOpacity(.85),
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5)),
        ],
      ),
    );
  }

  Widget _filters() {
    Widget chip(String label, IconData icon, bool selected, VoidCallback tap) {
      return GestureDetector(
        onTap: tap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? _mid : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: selected ? _mid : Colors.black12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 16, color: selected ? Colors.white : Colors.black54),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: selected ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      child: Row(
        children: [
          chip('All', Icons.grid_view_rounded, !_onlyPinned,
              () => setState(() => _onlyPinned = false)),
          const SizedBox(width: 10),
          chip('Pinned', Icons.push_pin_rounded, _onlyPinned,
              () => setState(() => _onlyPinned = true)),
        ],
      ),
    );
  }

  Widget _noteCard(Note note) {
    final tone = _tones[note.tone];

    return Dismissible(
      key: ValueKey(note.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteNote(note),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFE11D48),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: 0,
        shadowColor: Colors.black12,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _openEditor(note: note),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: tone.accent.withOpacity(.14)),
              boxShadow: [
                BoxShadow(
                  color: tone.accent.withOpacity(.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(width: 6, color: tone.accent),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 6, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    note.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w800,
                                      color: _ink,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  tooltip: note.pinned ? 'Unpin' : 'Pin',
                                  onPressed: () => _togglePin(note),
                                  icon: Icon(
                                    note.pinned
                                        ? Icons.push_pin_rounded
                                        : Icons.push_pin_outlined,
                                    size: 20,
                                    color: note.pinned
                                        ? tone.accent
                                        : Colors.black26,
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert_rounded,
                                      color: Colors.black38, size: 22),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                  onSelected: (v) {
                                    if (v == 'edit') _openEditor(note: note);
                                    if (v == 'delete') _confirmDelete(note);
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Row(children: [
                                        Icon(Icons.edit_rounded, size: 19),
                                        SizedBox(width: 10),
                                        Text('Edit'),
                                      ]),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(children: [
                                        Icon(Icons.delete_rounded,
                                            size: 19, color: Color(0xFFE11D48)),
                                        SizedBox(width: 10),
                                        Text('Delete'),
                                      ]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Text(
                                note.description,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                  color: Colors.black.withOpacity(.68),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 9, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: tone.soft,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    tone.name,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: tone.accent,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Icon(Icons.schedule_rounded,
                                    size: 13, color: Colors.black38),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    _formatDate(note.date),
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black45,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 90),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _mid.withOpacity(.18),
                    _mid.withOpacity(.05),
                  ],
                ),
              ),
              child: Center(
                child: Container(
                  width: 82,
                  height: 82,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Color(0x1A2E7D32),
                          blurRadius: 18,
                          offset: Offset(0, 8)),
                    ],
                  ),
                  child: const Icon(Icons.edit_note_rounded,
                      size: 44, color: _mid),
                ),
              ),
            ),
            const SizedBox(height: 26),
            const Text(
              'No notes yet',
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w900, color: _ink),
            ),
            const SizedBox(height: 8),
            Text(
              'Track crops, expenses, reminders and\nimportant farm information in one place.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.55,
                color: Colors.black.withOpacity(.55),
              ),
            ),
            const SizedBox(height: 26),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: _mid,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => _openEditor(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create your first note',
                  style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _noResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 90),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded,
                size: 56, color: Colors.black.withOpacity(.25)),
            const SizedBox(height: 14),
            const Text(
              'No matching notes',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800, color: _ink),
            ),
            const SizedBox(height: 6),
            Text(
              _onlyPinned && _query.isEmpty
                  ? 'Pin a note to see it here.'
                  : 'Try a different keyword.',
              style: TextStyle(color: Colors.black.withOpacity(.55)),
            ),
          ],
        ),
      ),
    );
  }
}
