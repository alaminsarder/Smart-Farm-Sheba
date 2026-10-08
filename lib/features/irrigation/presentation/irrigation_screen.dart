import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wrapper screen so Dashboard can call IrrigationScreen()
class IrrigationScreen extends StatelessWidget {
  const IrrigationScreen({super.key});

  @override
  Widget build(BuildContext context) => const IrrigationLogScreen();
}

class IrrigationLogScreen extends StatefulWidget {
  const IrrigationLogScreen({super.key});

  @override
  State<IrrigationLogScreen> createState() => _IrrigationLogScreenState();
}

class _IrrigationLogScreenState extends State<IrrigationLogScreen> {
  static const _storageKey = "irrigation_records_v1";

  // Default crop suggestions.
  // User can also add any custom crop.
  final List<String> crops = const [
    "Rice",
    "Wheat",
    "Vegetables",
    "Fruits",
    "Jute",
  ];

  List<IrrigationRecord> _records = [];
  String _filterCrop = "All";
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);

      if (raw == null || raw.isEmpty) {
        if (!mounted) return;

        setState(() {
          _records = [];
          _loading = false;
        });
        return;
      }

      final decoded = jsonDecode(raw);
      final list = (decoded as List).cast<dynamic>();

      final items = list
          .whereType<Map>()
          .map(
            (m) => IrrigationRecord.fromJson(
              m.cast<String, dynamic>(),
            ),
          )
          .toList()
        ..sort(
          (a, b) => b.dateTime.compareTo(a.dateTime),
        );

      if (!mounted) return;

      setState(() {
        _records = items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _records = [];
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();

    final list = _records.map((e) => e.toJson()).toList();

    await prefs.setString(
      _storageKey,
      jsonEncode(list),
    );
  }

  List<IrrigationRecord> get _filtered {
    if (_filterCrop == "All") return _records;

    return _records.where((e) => e.crop == _filterCrop).toList();
  }

  double get _totalCost {
    return _filtered.fold(
      0.0,
      (sum, e) => sum + e.costTaka,
    );
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat("dd MMM yyyy, hh:mm a");
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Irrigation Log",
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: "Clear all",
            icon: const Icon(
              Icons.delete_sweep_rounded,
            ),
            onPressed: _records.isEmpty ? null : _confirmClearAll,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        elevation: 5,
        onPressed: _openAddSheet,
        icon: const Icon(Icons.water_drop_rounded),
        label: const Text(
          "Add Irrigation",
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          16,
          12,
          16,
          100,
        ),
        children: [
          // Premium header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withOpacity(.75),
                  colorScheme.tertiary.withOpacity(.75),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(.18),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  height: 58,
                  width: 58,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.18),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.water_drop_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 15),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Smart Irrigation",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Track your irrigation activities easily",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Filter section
          const Text(
            "Filter by Crop",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip(
                  label: "All",
                  selected: _filterCrop == "All",
                ),

                ...crops.map(
                  (crop) => _buildFilterChip(
                    label: crop,
                    selected: _filterCrop == crop,
                  ),
                ),

                // Add custom crop filter automatically
                ..._records
                    .map((e) => e.crop)
                    .where(
                      (crop) => !crops.contains(crop),
                    )
                    .toSet()
                    .map(
                      (crop) => _buildFilterChip(
                        label: crop,
                        selected: _filterCrop == crop,
                      ),
                    ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Summary cards
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  icon: Icons.receipt_long_rounded,
                  title: "Entries",
                  value: "${_filtered.length}",
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.payments_rounded,
                  title: "Total Cost",
                  value: "৳${_totalCost.toStringAsFixed(0)}",
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          if (_loading)
            const _LoadingBlock()
          else if (_filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 55),
              child: Column(
                children: [
                  Icon(
                    Icons.water_drop_outlined,
                    size: 60,
                  ),
                  SizedBox(height: 12),
                  Text(
                    "No irrigation record found.",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Tap 'Add Irrigation' to create your first record.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          else
            ..._filtered.map(
              (r) => _buildIrrigationCard(
                r,
                df,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        selected: selected,
        onSelected: (_) {
          setState(() {
            _filterCrop = label;
          });
        },
      ),
    );
  }

  Widget _buildIrrigationCard(
    IrrigationRecord r,
    DateFormat df,
  ) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Dismissible(
      key: ValueKey(r.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(.10),
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Icon(
          Icons.delete_rounded,
          color: Colors.red,
          size: 28,
        ),
      ),
      onDismissed: (_) async {
        setState(() {
          _records.removeWhere(
            (e) => e.id == r.id,
          );
        });

        await _save();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: theme.cardColor,
          border: Border.all(
            color: theme.dividerColor.withOpacity(.25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  // Crop icon
                  Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        colors: [
                          primary.withOpacity(.18),
                          primary.withOpacity(.07),
                        ],
                      ),
                    ),
                    child: Icon(
                      _cropIcon(r.crop),
                      color: primary,
                      size: 29,
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Crop name + date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                r.crop,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 7),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: primary.withOpacity(.10),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "Irrigated",
                                style: TextStyle(
                                  color: primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 13,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                df.format(r.dateTime),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Cost
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "COST",
                        style: TextStyle(
                          fontSize: 9,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "৳${r.costTaka.toStringAsFixed(0)}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // Bottom info bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withOpacity(.45),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.water_drop_rounded,
                      size: 17,
                      color: primary,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      "Irrigation record saved",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.swipe_left_rounded,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      "Delete",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _cropIcon(String crop) {
    final value = crop.toLowerCase();

    if (value.contains("rice")) {
      return Icons.grass_rounded;
    }

    if (value.contains("wheat")) {
      return Icons.grass_rounded;
    }

    if (value.contains("vegetable")) {
      return Icons.eco_rounded;
    }

    if (value.contains("fruit")) {
      return Icons.apple_rounded;
    }

    if (value.contains("jute")) {
      return Icons.grass_rounded;
    }

    return Icons.spa_rounded;
  }

  Future<void> _openAddSheet() async {
    final saved = await showModalBottomSheet<IrrigationRecord>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (_) => _AddIrrigationSheet(
        crops: crops,
      ),
    );

    if (saved == null) return;

    setState(() {
      _records.insert(0, saved);

      _records.sort(
        (a, b) => b.dateTime.compareTo(a.dateTime),
      );
    });

    await _save();
  }

  Future<void> _confirmClearAll() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          "Clear all records?",
        ),
        content: const Text(
          "সব irrigation record মুছে যাবে।",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Clear"),
          ),
        ],
      ),
    );

    if (ok != true) return;

    setState(() {
      _records = [];
    });

    await _save();
  }
}

class _AddIrrigationSheet extends StatefulWidget {
  final List<String> crops;

  const _AddIrrigationSheet({
    required this.crops,
  });

  @override
  State<_AddIrrigationSheet> createState() => _AddIrrigationSheetState();
}

class _AddIrrigationSheetState extends State<_AddIrrigationSheet> {
  final _formKey = GlobalKey<FormState>();

  late String _crop;

  DateTime _dateTime = DateTime.now();

  final _costCtrl = TextEditingController(
    text: "0",
  );

  final _customCropCtrl = TextEditingController();

  bool _customCrop = false;

  @override
  void initState() {
    super.initState();

    _crop =
        widget.crops.contains("Vegetables") ? "Vegetables" : widget.crops.first;
  }

  @override
  void dispose() {
    _costCtrl.dispose();
    _customCropCtrl.dispose();
    super.dispose();
  }

  double _cost() {
    return double.tryParse(
          _costCtrl.text.trim(),
        ) ??
        0;
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat(
      "dd MMM yyyy, hh:mm a",
    );

    final bottom = MediaQuery.of(context).viewInsets.bottom;

    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          16 + bottom,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: primary.withOpacity(.12),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        Icons.water_drop_rounded,
                        color: primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Add Irrigation",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Create a new irrigation record",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Crop selector
                const Text(
                  "Crop",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 8),

                DropdownButtonFormField<String>(
                  value: _customCrop ? null : _crop,
                  items: [
                    ...widget.crops.map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.grass_rounded,
                              size: 19,
                            ),
                            const SizedBox(width: 9),
                            Text(c),
                          ],
                        ),
                      ),
                    ),
                    const DropdownMenuItem(
                      value: "__custom__",
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_rounded,
                            size: 19,
                          ),
                          SizedBox(width: 9),
                          Text(
                            "Write my own crop",
                          ),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == "__custom__") {
                      setState(() {
                        _customCrop = true;
                        _crop = "";
                      });
                    } else if (value != null) {
                      setState(() {
                        _customCrop = false;
                        _crop = value;
                        _customCropCtrl.clear();
                      });
                    }
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.spa_rounded,
                    ),
                  ),
                ),

                // Custom crop field
                if (_customCrop) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _customCropCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: "Crop name",
                      hintText: "Example: Potato, Tomato, Maize",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(
                        Icons.edit_rounded,
                      ),
                    ),
                    validator: (value) {
                      if (!_customCrop) return null;

                      if (value == null || value.trim().isEmpty) {
                        return "Enter crop name";
                      }

                      return null;
                    },
                  ),
                ],

                const SizedBox(height: 14),

                // Cost
                TextFormField(
                  controller: _costCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: "Cost (৳)",
                    hintText: "Enter irrigation cost",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.payments_rounded,
                    ),
                  ),
                  validator: (v) {
                    final d = double.tryParse(
                      (v ?? "").trim(),
                    );

                    if (d == null) {
                      return "Enter cost";
                    }

                    if (d < 0) {
                      return "Cost cannot be negative";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 14),

                // Date & time
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _pickDateTime,
                    icon: const Icon(
                      Icons.event_rounded,
                    ),
                    label: Text(
                      "Date/Time: ${df.format(_dateTime)}",
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Cancel",
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _saveRecord,
                        icon: const Icon(
                          Icons.check_rounded,
                        ),
                        label: const Text(
                          "Save Record",
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
  }

  void _saveRecord() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final cropName = _customCrop ? _customCropCtrl.text.trim() : _crop;

    if (cropName.isEmpty) {
      return;
    }

    final record = IrrigationRecord(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      crop: cropName,
      dateTime: _dateTime,
      costTaka: _cost(),
    );

    Navigator.pop(context, record);
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();

    final d = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
      initialDate: _dateTime,
    );

    if (d == null) return;

    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );

    if (t == null) return;

    setState(() {
      _dateTime = DateTime(
        d.year,
        d.month,
        d.day,
        t.hour,
        t.minute,
      );
    });
  }
}

class IrrigationRecord {
  final String id;
  final String crop;
  final DateTime dateTime;
  final double costTaka;

  IrrigationRecord({
    required this.id,
    required this.crop,
    required this.dateTime,
    required this.costTaka,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "crop": crop,
        "dateTime": dateTime.millisecondsSinceEpoch,
        "costTaka": costTaka,
      };

  static IrrigationRecord fromJson(
    Map<String, dynamic> j,
  ) {
    return IrrigationRecord(
      id: (j["id"] ?? "").toString(),
      crop: (j["crop"] ?? "").toString(),
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        (j["dateTime"] as num).toInt(),
      ),
      costTaka: (j["costTaka"] as num).toDouble(),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(context).cardColor,
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: primary.withOpacity(.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: primary,
              size: 21,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingBlock extends StatelessWidget {
  const _LoadingBlock();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: primary.withOpacity(.07),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: primary,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            "Loading irrigation records...",
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
