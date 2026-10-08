import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────
//  DESIGN TOKENS (same family as Dashboard & Tips)
// ─────────────────────────────────────────────────────────────

class _Palette {
  static const paddy = Color(0xFF14342A);
  static const paddyLight = Color(0xFF1F5A3F);
  static const sprout = Color(0xFF9BD67A);
  static const harvest = Color(0xFFF2B93B);
  static const spray = Color(0xFFE5602B); // pesticide accent

  static const lightBg = Color(0xFFF1F5F1);
  static const lightCard = Colors.white;
  static const lightInk = Color(0xFF14211B);

  static const darkBg = Color(0xFF0E1512);
  static const darkCard = Color(0xFF17211C);
  static const darkInk = Color(0xFFE6EEE8);
}

Color _tint(Color c, double opacity) =>
    c.withAlpha((opacity.clamp(0.0, 1.0) * 255).round());

// ─────────────────────────────────────────────────────────────
//  MODEL
// ─────────────────────────────────────────────────────────────

class SprayRecord {
  final String id;
  final String medicine; // ki ousudh
  final String field; // kon jomite
  final DateTime when; // kobe + koto time a

  const SprayRecord({
    required this.id,
    required this.medicine,
    required this.field,
    required this.when,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'medicine': medicine,
        'field': field,
        'when': when.toIso8601String(),
      };

  factory SprayRecord.fromJson(Map<String, dynamic> j) => SprayRecord(
        id: j['id'] as String,
        medicine: j['medicine'] as String,
        field: j['field'] as String,
        when: DateTime.parse(j['when'] as String),
      );
}

// ─────────────────────────────────────────────────────────────
//  FORMATTING HELPERS
// ─────────────────────────────────────────────────────────────

const _months = [
  "Jan",
  "Feb",
  "Mar",
  "Apr",
  "May",
  "Jun",
  "Jul",
  "Aug",
  "Sep",
  "Oct",
  "Nov",
  "Dec"
];

String _timeLabel(DateTime d) {
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final m = d.minute.toString().padLeft(2, '0');
  return "$h:$m ${d.hour < 12 ? 'AM' : 'PM'}";
}

String _dateLabel(DateTime d, {bool relative = true}) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(d.year, d.month, d.day);
  final diff = today.difference(day).inDays;
  if (relative && diff == 0) return "Today";
  if (relative && diff == 1) return "Yesterday";
  return "${d.day} ${_months[d.month - 1]} ${d.year}";
}

String _ordinal(int n) {
  if (n % 100 >= 11 && n % 100 <= 13) return "${n}th";
  switch (n % 10) {
    case 1:
      return "${n}st";
    case 2:
      return "${n}nd";
    case 3:
      return "${n}rd";
    default:
      return "${n}th";
  }
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

// ─────────────────────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────────────────────

class PesticideScreen extends StatefulWidget {
  const PesticideScreen({super.key});

  @override
  State<PesticideScreen> createState() => _PesticideScreenState();
}

class _PesticideScreenState extends State<PesticideScreen> {
  static const String _prefsKey = 'spray_log_v1';

  List<SprayRecord> _records = [];
  bool _loading = true;
  String? _fieldFilter; // null = all fields

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ───────────── storage ─────────────

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null) {
        final list = jsonDecode(raw) as List<dynamic>;
        _records = list
            .map((e) => SprayRecord.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      _records = [];
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefsKey,
        jsonEncode(_records.map((r) => r.toJson()).toList()),
      );
    } catch (_) {
      // Ignore write errors; data stays in memory for this session.
    }
  }

  // ───────────── derived data ─────────────

  List<String> get _fields {
    final seen = <String>{};
    final list = <String>[];
    final sorted = [..._records]..sort((a, b) => b.when.compareTo(a.when));
    for (final r in sorted) {
      if (seen.add(r.field.toLowerCase())) list.add(r.field);
    }
    return list;
  }

  List<String> get _medicines {
    final seen = <String>{};
    final list = <String>[];
    final sorted = [..._records]..sort((a, b) => b.when.compareTo(a.when));
    for (final r in sorted) {
      if (seen.add(r.medicine.toLowerCase())) list.add(r.medicine);
    }
    return list;
  }

  /// "How many times" — the nth time this medicine was used on this field.
  Map<String, int> get _ordinals {
    final asc = [..._records]..sort((a, b) => a.when.compareTo(b.when));
    final counter = <String, int>{};
    final result = <String, int>{};
    for (final r in asc) {
      final key = "${r.medicine.toLowerCase()}|${r.field.toLowerCase()}";
      final n = (counter[key] ?? 0) + 1;
      counter[key] = n;
      result[r.id] = n;
    }
    return result;
  }

  List<SprayRecord> get _filtered {
    final list = _records
        .where((r) =>
            _fieldFilter == null ||
            r.field.toLowerCase() == _fieldFilter!.toLowerCase())
        .toList()
      ..sort((a, b) => b.when.compareTo(a.when));
    return list;
  }

  // ───────────── actions ─────────────

  Future<void> _openSheet({SprayRecord? existing}) async {
    final result = await showModalBottomSheet<SprayRecord>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SpraySheet(
        existing: existing,
        medicineSuggestions: _medicines,
        fieldSuggestions: _fields,
        defaultField: _fieldFilter ?? (_fields.isNotEmpty ? _fields.first : ""),
      ),
    );
    if (result == null) return;

    setState(() {
      final i = _records.indexWhere((r) => r.id == result.id);
      if (i >= 0) {
        _records[i] = result;
      } else {
        _records.add(result);
      }
    });
    _persist();
    HapticFeedback.lightImpact();
  }

  void _delete(SprayRecord r) {
    final index = _records.indexWhere((x) => x.id == r.id);
    if (index < 0) return;
    setState(() => _records.removeAt(index));
    _persist();

    // If the active filter no longer has any records, reset it.
    if (_fieldFilter != null &&
        !_records
            .any((x) => x.field.toLowerCase() == _fieldFilter!.toLowerCase())) {
      _fieldFilter = null;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: _Palette.paddy,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          content: const Text("Spray record deleted"),
          action: SnackBarAction(
            label: "Undo",
            textColor: _Palette.harvest,
            onPressed: () {
              setState(
                  () => _records.insert(index.clamp(0, _records.length), r));
              _persist();
            },
          ),
        ),
      );
  }

  // ───────────── build ─────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? _Palette.darkBg : _Palette.lightBg;
    final ink = isDark ? _Palette.darkInk : _Palette.lightInk;

    return Scaffold(
      backgroundColor: bg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openSheet(),
        backgroundColor: _Palette.spray,
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          "Add spray",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              children: [
                _header(context),
                if (_records.isEmpty)
                  _emptyState(ink, firstTime: true)
                else ...[
                  if (_fields.length > 1) ...[
                    Transform.translate(
                      offset: const Offset(0, -22),
                      child: _fieldChips(isDark, ink),
                    ),
                    const SizedBox(height: 0),
                  ] else
                    const SizedBox(height: 4),
                  ..._groupedList(isDark, ink),
                ],
                const SizedBox(height: 96),
              ],
            ),
    );
  }

  // ───────────── header ─────────────

  Widget _header(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final sorted = [..._records]..sort((a, b) => b.when.compareTo(a.when));
    final last = sorted.isEmpty ? "—" : _dateLabel(sorted.first.when);
    final hasChipsBelow = _records.isNotEmpty && _fields.length > 1;

    return Container(
      padding: EdgeInsets.fromLTRB(20, top + 14, 20, hasChipsBelow ? 48 : 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_Palette.paddy, _Palette.paddyLight],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(34),
          bottomRight: Radius.circular(34),
        ),
      ),
      child: Stack(
        children: [
          Positioned(right: -50, top: -30, child: _ring(150, 0.07)),
          Positioned(right: 24, top: 44, child: _ring(60, 0.09)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (Navigator.of(context).canPop())
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => Navigator.of(context).maybePop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _tint(Colors.white, 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back_rounded,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _tint(_Palette.spray, 0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.pest_control_rounded,
                            size: 14, color: Color(0xFFFFB08A)),
                        SizedBox(width: 6),
                        Text(
                          "Smart Farm Sheba",
                          style: TextStyle(
                            color: Color(0xFFFFB08A),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                "Spray log",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Record what you sprayed, when, and where.",
                style: TextStyle(
                  color: _tint(Colors.white, 0.72),
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _stat("${_records.length}", "sprays"),
                  const SizedBox(width: 10),
                  _stat("${_fields.length}", "fields"),
                  const SizedBox(width: 10),
                  _stat(last, "last", highlight: true, valueSize: 14),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ring(double size, double opacity) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: _tint(Colors.white, opacity), width: 14),
        ),
      );

  Widget _stat(String value, String label,
      {bool highlight = false, double valueSize = 18}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: _tint(Colors.white, 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _tint(Colors.white, 0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            value,
            style: TextStyle(
              color: highlight ? _Palette.harvest : Colors.white,
              fontSize: valueSize,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(color: _tint(Colors.white, 0.7), fontSize: 12.5),
          ),
        ],
      ),
    );
  }

  // ───────────── field filter ─────────────

  Widget _fieldChips(bool isDark, Color ink) {
    final fields = _fields;
    final cardColor = isDark ? _Palette.darkCard : _Palette.lightCard;

    Widget chip(String label, bool selected, VoidCallback onTap,
        {IconData icon = Icons.landscape_rounded}) {
      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? _Palette.spray : cardColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? _Palette.spray : _tint(ink, 0.10),
            ),
            boxShadow: [
              BoxShadow(
                color: _tint(_Palette.paddy, isDark ? 0.3 : 0.10),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 16, color: selected ? Colors.white : _Palette.spray),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : ink,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: fields.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          if (i == 0) {
            return chip("All fields", _fieldFilter == null,
                () => setState(() => _fieldFilter = null),
                icon: Icons.apps_rounded);
          }
          final f = fields[i - 1];
          return chip(
            f,
            _fieldFilter?.toLowerCase() == f.toLowerCase(),
            () => setState(() => _fieldFilter = f),
          );
        },
      ),
    );
  }

  // ───────────── grouped list ─────────────

  List<Widget> _groupedList(bool isDark, Color ink) {
    final list = _filtered;
    if (list.isEmpty) {
      return [_emptyState(ink, firstTime: false)];
    }

    final ordinals = _ordinals;
    final widgets = <Widget>[];
    var i = 0;

    while (i < list.length) {
      final day = list[i].when;
      final group = <SprayRecord>[];
      while (i < list.length && _sameDay(list[i].when, day)) {
        group.add(list[i]);
        i++;
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 6, 22, 8),
          child: Row(
            children: [
              Text(
                _dateLabel(day),
                style: TextStyle(
                  color: ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(width: 8),
              if (_dateLabel(day) == "Today" || _dateLabel(day) == "Yesterday")
                Text(
                  _dateLabel(day, relative: false),
                  style: TextStyle(color: _tint(ink, 0.5), fontSize: 12.5),
                ),
            ],
          ),
        ),
      );

      widgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? _Palette.darkCard : _Palette.lightCard,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _tint(ink, isDark ? 0.08 : 0.06)),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: _tint(_Palette.paddy, 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 7),
                      ),
                    ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var k = 0; k < group.length; k++) ...[
                  _recordRow(group[k], ordinals[group[k].id] ?? 1, ink, isDark),
                  if (k != group.length - 1)
                    Divider(
                      height: 1,
                      indent: 70,
                      endIndent: 16,
                      color: _tint(ink, 0.07),
                    ),
                ],
              ],
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  Widget _recordRow(SprayRecord r, int nth, Color ink, bool isDark) {
    return Dismissible(
      key: ValueKey(r.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _delete(r),
      background: Container(
        color: const Color(0xFFD64545),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      child: Material(
        color: isDark ? _Palette.darkCard : _Palette.lightCard,
        child: InkWell(
          onTap: () => _openSheet(existing: r),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _tint(_Palette.spray, isDark ? 0.22 : 0.13),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(Icons.pest_control_rounded,
                      color: _Palette.spray, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.medicine,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: ink,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.landscape_rounded,
                              size: 14, color: _tint(ink, 0.5)),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              r.field,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: _tint(ink, 0.68),
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(Icons.schedule_rounded,
                              size: 14, color: _tint(ink, 0.5)),
                          const SizedBox(width: 4),
                          Text(
                            _timeLabel(r.when),
                            style: TextStyle(
                              color: _tint(ink, 0.68),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: nth > 1
                        ? _tint(_Palette.harvest, isDark ? 0.22 : 0.22)
                        : _tint(ink, 0.07),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "${_ordinal(nth)} time",
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: nth > 1
                          ? (isDark
                              ? _Palette.harvest
                              : const Color(0xFF8A5B00))
                          : _tint(ink, 0.65),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ───────────── empty state ─────────────

  Widget _emptyState(Color ink, {required bool firstTime}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 24),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _tint(_Palette.spray, 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              firstTime ? Icons.edit_note_rounded : Icons.landscape_rounded,
              size: 40,
              color: _Palette.spray,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            firstTime ? "No sprays recorded yet" : "No sprays on this field",
            style: TextStyle(
              color: ink,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            firstTime
                ? "Tap Add spray to log the date, pesticide name, time and field."
                : "Choose another field or add a new spray.",
            textAlign: TextAlign.center,
            style:
                TextStyle(color: _tint(ink, 0.6), fontSize: 13.5, height: 1.45),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  ADD / EDIT SHEET
// ─────────────────────────────────────────────────────────────

class _SpraySheet extends StatefulWidget {
  final SprayRecord? existing;
  final List<String> medicineSuggestions;
  final List<String> fieldSuggestions;
  final String defaultField;

  const _SpraySheet({
    required this.existing,
    required this.medicineSuggestions,
    required this.fieldSuggestions,
    required this.defaultField,
  });

  @override
  State<_SpraySheet> createState() => _SpraySheetState();
}

class _SpraySheetState extends State<_SpraySheet> {
  late final TextEditingController _medicineCtrl;
  late final TextEditingController _fieldCtrl;
  late DateTime _when;
  String? _error;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _medicineCtrl = TextEditingController(text: e?.medicine ?? "");
    _fieldCtrl = TextEditingController(text: e?.field ?? widget.defaultField);
    _when = e?.when ?? DateTime.now();
  }

  @override
  void dispose() {
    _medicineCtrl.dispose();
    _fieldCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _when.isAfter(now) ? now : _when,
      firstDate: DateTime(2020),
      lastDate: now,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
                primary: _Palette.spray,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _when = DateTime(
            picked.year, picked.month, picked.day, _when.hour, _when.minute);
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _when.hour, minute: _when.minute),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
                primary: _Palette.spray,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _when = DateTime(
            _when.year, _when.month, _when.day, picked.hour, picked.minute);
      });
    }
  }

  void _save() {
    final medicine = _medicineCtrl.text.trim();
    final field = _fieldCtrl.text.trim();

    if (medicine.isEmpty || field.isEmpty) {
      setState(() => _error = medicine.isEmpty
          ? "Enter the pesticide name."
          : "Enter the field name.");
      return;
    }

    Navigator.pop(
      context,
      SprayRecord(
        id: widget.existing?.id ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        medicine: medicine,
        field: field,
        when: _when,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? _Palette.darkInk : _Palette.lightInk;
    final sheetColor = isDark ? _Palette.darkCard : Colors.white;
    final isEdit = widget.existing != null;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: sheetColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _tint(ink, 0.18),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isEdit ? "Edit spray" : "Add spray",
                style: TextStyle(
                  color: ink,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 18),

              // Medicine
              _label("Pesticide name", ink),
              const SizedBox(height: 6),
              _textField(
                controller: _medicineCtrl,
                hint: "e.g. Imidacloprid, Mancozeb",
                icon: Icons.pest_control_rounded,
                ink: ink,
                isDark: isDark,
              ),
              _suggestions(
                widget.medicineSuggestions,
                _medicineCtrl,
                ink,
              ),

              const SizedBox(height: 16),

              // Field
              _label("Field", ink),
              const SizedBox(height: 6),
              _textField(
                controller: _fieldCtrl,
                hint: "e.g. North plot, Rice field 2",
                icon: Icons.landscape_rounded,
                ink: ink,
                isDark: isDark,
              ),
              _suggestions(
                widget.fieldSuggestions,
                _fieldCtrl,
                ink,
              ),

              const SizedBox(height: 16),

              // Date + time
              Row(
                children: [
                  Expanded(
                    child: _pickerTile(
                      label: "Date",
                      value: _dateLabel(_when),
                      icon: Icons.event_rounded,
                      onTap: _pickDate,
                      ink: ink,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _pickerTile(
                      label: "Time",
                      value: _timeLabel(_when),
                      icon: Icons.schedule_rounded,
                      onTap: _pickTime,
                      ink: ink,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        size: 16, color: Color(0xFFD64545)),
                    const SizedBox(width: 6),
                    Text(
                      _error!,
                      style: const TextStyle(
                          color: Color(0xFFD64545), fontSize: 13),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: _Palette.spray,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    isEdit ? "Save changes" : "Save spray",
                    style: const TextStyle(
                        fontSize: 15.5, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────── sheet helpers ─────────────

  Widget _label(String text, Color ink) => Text(
        text,
        style: TextStyle(
          color: _tint(ink, 0.75),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      );

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color ink,
    required bool isDark,
  }) {
    return TextField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      style: TextStyle(color: ink, fontSize: 15),
      onChanged: (_) {
        if (_error != null) setState(() => _error = null);
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: _tint(ink, 0.4), fontSize: 14),
        prefixIcon: Icon(icon, size: 20, color: _Palette.spray),
        filled: true,
        fillColor: _tint(ink, isDark ? 0.08 : 0.04),
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _Palette.spray, width: 1.4),
        ),
      ),
    );
  }

  Widget _suggestions(
      List<String> items, TextEditingController ctrl, Color ink) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: items.take(6).map((s) {
          final selected = ctrl.text.trim().toLowerCase() == s.toLowerCase();
          return GestureDetector(
            onTap: () => setState(() {
              ctrl.text = s;
              ctrl.selection = TextSelection.collapsed(offset: s.length);
              _error = null;
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                color:
                    selected ? _tint(_Palette.spray, 0.16) : _tint(ink, 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? _Palette.spray : Colors.transparent,
                ),
              ),
              child: Text(
                s,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: selected ? _Palette.spray : _tint(ink, 0.75),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _pickerTile({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
    required Color ink,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _tint(ink, isDark ? 0.08 : 0.04),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: _Palette.spray),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style:
                          TextStyle(color: _tint(ink, 0.55), fontSize: 11.5)),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      color: ink,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
