import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final _money =
      NumberFormat.currency(locale: 'en_US', symbol: '৳ ', decimalDigits: 2);

  final _dateFmt = DateFormat('dd MMM yyyy');

  final List<_FinanceRecord> _records = [];

  int _idCounter = 0;

  static const _primary = Color(0xFF2E7D32);
  static const _primaryDark = Color(0xFF1B5E20);
  static const _primaryLight = Color(0xFF43A047);

  String _nextId() {
    _idCounter++;
    return "${DateTime.now().microsecondsSinceEpoch}_$_idCounter";
  }

  double get _totalCost => _records.fold(0.0, (sum, item) => sum + item.cost);

  double get _totalProfit =>
      _records.fold(0.0, (sum, item) => sum + item.profit);

  double get _net => _totalProfit - _totalCost;

  void _snack(String msg) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(14),
      ),
    );
  }

  Future<void> _openAddEditSheet({
    _FinanceRecord? record,
    int? index,
  }) async {
    final isEdit = record != null && index != null;

    final result = await showModalBottomSheet<_FinanceRecord>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return _FinanceFormSheet(
          record: record,
          isEdit: isEdit,
          dateFmt: _dateFmt,
        );
      },
    );

    if (!mounted || result == null) return;

    setState(() {
      if (isEdit) {
        _records[index!] = result;
      } else {
        _records.insert(0, result);
      }
    });

    _snack(
      isEdit ? "Record updated" : "Record added",
    );
  }

  void _deleteAt(int index) {
    if (index < 0 || index >= _records.length) return;

    final removed = _records[index];

    setState(() {
      _records.removeAt(index);
    });

    _snack("Deleted: ${removed.title}");
  }

  @override
  Widget build(BuildContext context) {
    final net = _net;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "Farm Finance",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE8F5E9), Color(0xFFF5F7FA)],
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: "Add",
            onPressed: () => _openAddEditSheet(),
            icon: const Icon(
              Icons.add_circle_outline_rounded,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddEditSheet(),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          "Add Record",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          16,
          8,
          16,
          90,
        ),
        children: [
          // ------------------------------------------------------------
          // SUMMARY CARD
          // ------------------------------------------------------------
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_primaryDark, _primaryLight],
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: _primaryLight.withOpacity(.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.insights_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Financial Summary",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _SummaryPill(
                      label: "Total Cost",
                      value: _money.format(_totalCost),
                      icon: Icons.trending_down_rounded,
                    ),
                    _SummaryPill(
                      label: "Total Profit",
                      value: _money.format(_totalProfit),
                      icon: Icons.trending_up_rounded,
                    ),
                    _SummaryPill(
                      label: "Net Balance",
                      value: _money.format(net),
                      icon: Icons.account_balance_wallet_rounded,
                      valueColor: net >= 0
                          ? const Color(0xFFB9FFCB)
                          : const Color(0xFFFFC2C2),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ------------------------------------------------------------
          // EMPTY STATE
          // ------------------------------------------------------------
          if (_records.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _primaryLight.withOpacity(0.18),
                          _primaryLight.withOpacity(0.08),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      size: 56,
                      color: _primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "No Records Yet",
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Tap “Add Record” to track your\nfarm costs and profits.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black.withOpacity(.5),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

          // ------------------------------------------------------------
          // RECORDS
          // ------------------------------------------------------------
          if (_records.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 4),
              child: Text(
                "Recent Records",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: Colors.black.withOpacity(.6),
                ),
              ),
            ),
            for (int i = 0; i < _records.length; i++)
              _RecordCard(
                key: ValueKey(_records[i].id),
                record: _records[i],
                money: _money,
                dateFmt: _dateFmt,
                onTap: () => _openAddEditSheet(
                  record: _records[i],
                  index: i,
                ),
                onDelete: () => _deleteAt(i),
              ),
          ],
        ],
      ),
    );
  }
}

// ======================================================================
// FINANCE FORM SHEET
// ======================================================================

class _FinanceFormSheet extends StatefulWidget {
  final _FinanceRecord? record;
  final bool isEdit;
  final DateFormat dateFmt;

  const _FinanceFormSheet({
    required this.record,
    required this.isEdit,
    required this.dateFmt,
  });

  @override
  State<_FinanceFormSheet> createState() => _FinanceFormSheetState();
}

class _FinanceFormSheetState extends State<_FinanceFormSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _costController;
  late final TextEditingController _profitController;

  late DateTime _selectedDate;

  bool _saving = false;

  static const _primary = Color(0xFF2E7D32);

  @override
  void initState() {
    super.initState();

    final record = widget.record;

    _titleController = TextEditingController(
      text: record?.title ?? '',
    );

    _costController = TextEditingController(
      text: record == null ? '' : record.cost.toStringAsFixed(2),
    );

    _profitController = TextEditingController(
      text: record == null ? '' : record.profit.toStringAsFixed(2),
    );

    _selectedDate = record?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _costController.dispose();
    _profitController.dispose();

    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (!mounted) return;

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  double? _parseMoney(String value) {
    final parsed = double.tryParse(
      value.trim(),
    );

    return parsed;
  }

  Future<void> _save() async {
    final formState = _formKey.currentState;

    if (formState == null || !formState.validate()) {
      return;
    }

    final cost = _parseMoney(
      _costController.text,
    );

    final profit = _parseMoney(
      _profitController.text,
    );

    if (cost == null || profit == null) {
      _showSnack("Invalid amount");
      return;
    }

    if (cost < 0 || profit < 0) {
      _showSnack("Amount cannot be negative");
      return;
    }

    setState(() {
      _saving = true;
    });

    final oldRecord = widget.record;

    final newRecord = _FinanceRecord(
      id: oldRecord?.id ?? "${DateTime.now().microsecondsSinceEpoch}",
      title: _titleController.text.trim(),
      cost: cost,
      profit: profit,
      date: _selectedDate,
    );

    // Return the record to the parent screen.
    //
    // IMPORTANT:
    // We do NOT manually dispose the controllers here.
    // dispose() is handled by _FinanceFormSheetState when
    // the bottom sheet is removed from the widget tree.
    if (!mounted) return;

    Navigator.of(context).pop(newRecord);
  }

  void _showSnack(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(14),
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: _primary),
      filled: true,
      fillColor: const Color(0xFFF6F8F6),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        top: 4,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --------------------------------------------------------
              // TITLE
              // --------------------------------------------------------
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _primary.withOpacity(.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.isEdit
                          ? Icons.edit_note_rounded
                          : Icons.note_add_rounded,
                      color: _primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.isEdit ? "Edit Record" : "Add Record",
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // --------------------------------------------------------
              // TITLE FIELD
              // --------------------------------------------------------
              TextFormField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                decoration: _fieldDecoration(
                  label: "Title",
                  icon: Icons.receipt_long_rounded,
                ),
                validator: (value) {
                  final text = (value ?? '').trim();

                  if (text.isEmpty) {
                    return "Title required";
                  }

                  if (text.length < 2) {
                    return "Enter a valid title";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14),

              // --------------------------------------------------------
              // COST FIELD
              // --------------------------------------------------------
              TextFormField(
                controller: _costController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[\d.]'),
                  ),
                  LengthLimitingTextInputFormatter(12),
                ],
                decoration: _fieldDecoration(
                  label: "Cost",
                  icon: Icons.trending_down_rounded,
                ),
                validator: (value) {
                  final text = (value ?? '').trim();
                  final number = double.tryParse(text);

                  if (text.isEmpty) {
                    return "Cost required";
                  }

                  if (number == null || number < 0) {
                    return "Enter valid cost";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14),

              // --------------------------------------------------------
              // PROFIT FIELD
              // --------------------------------------------------------
              TextFormField(
                controller: _profitController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[\d.]'),
                  ),
                  LengthLimitingTextInputFormatter(12),
                ],
                decoration: _fieldDecoration(
                  label: "Profit",
                  icon: Icons.trending_up_rounded,
                ),
                validator: (value) {
                  final text = (value ?? '').trim();
                  final number = double.tryParse(text);

                  if (text.isEmpty) {
                    return "Profit required";
                  }

                  if (number == null || number < 0) {
                    return "Enter valid profit";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14),

              // --------------------------------------------------------
              // DATE PICKER
              // --------------------------------------------------------
              InkWell(
                onTap: _saving ? null : _pickDate,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: const Color(0xFFF6F8F6),
                    border: Border.all(
                      color: Colors.black.withOpacity(.06),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month_rounded,
                        color: _primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.dateFmt.format(
                            _selectedDate,
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.edit_calendar_rounded,
                        size: 18,
                        color: Colors.black.withOpacity(.4),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // --------------------------------------------------------
              // SAVE BUTTON
              // --------------------------------------------------------
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ).copyWith(
                    elevation: WidgetStateProperty.all(0),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: _saving
                          ? null
                          : const LinearGradient(
                              colors: [
                                Color(0xFF1B5E20),
                                Color(0xFF43A047),
                              ],
                            ),
                      color: _saving ? Colors.grey.shade400 : null,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.save_rounded,
                                    color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  widget.isEdit ? "Update" : "Add",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15.5,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================================================================
// FINANCE RECORD MODEL
// ======================================================================

class _FinanceRecord {
  final String id;
  final String title;
  final double cost;
  final double profit;
  final DateTime date;

  const _FinanceRecord({
    required this.id,
    required this.title,
    required this.cost,
    required this.profit,
    required this.date,
  });
}

// ======================================================================
// SUMMARY PILL
// ======================================================================

class _SummaryPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _SummaryPill({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(.22),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: valueColor ?? Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ======================================================================
// RECORD CARD
// ======================================================================

class _RecordCard extends StatelessWidget {
  final _FinanceRecord record;
  final NumberFormat money;
  final DateFormat dateFmt;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  static const _primary = Color(0xFF2E7D32);

  const _RecordCard({
    super.key,
    required this.record,
    required this.money,
    required this.dateFmt,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final net = record.profit - record.cost;

    return Dismissible(
      key: ValueKey(record.id),
      direction: DismissDirection.endToStart,

      // --------------------------------------------------------------
      // DELETE BACKGROUND
      // --------------------------------------------------------------
      background: Container(
        margin: const EdgeInsets.only(
          bottom: 12,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: const Color(0xFFFFE5E5),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(
          Icons.delete_rounded,
          color: Colors.red,
        ),
      ),

      // --------------------------------------------------------------
      // DELETE CONFIRMATION
      // --------------------------------------------------------------
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (dialogContext) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  title: Row(
                    children: const [
                      Icon(Icons.warning_amber_rounded, color: Colors.red),
                      SizedBox(width: 10),
                      Text(
                        "Delete record?",
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  content: Text(
                    "“${record.title}” will be permanently removed.",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(
                          dialogContext,
                          false,
                        );
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(
                          dialogContext,
                          true,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Delete",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                );
              },
            ) ??
            false;
      },

      onDismissed: (_) => onDelete(),

      // --------------------------------------------------------------
      // RECORD CARD
      // --------------------------------------------------------------
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // ------------------------------------------------------
                // ICON
                // ------------------------------------------------------
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _primary.withOpacity(.18),
                        _primary.withOpacity(.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: _primary,
                  ),
                ),

                const SizedBox(width: 12),

                // ------------------------------------------------------
                // TITLE + DATE
                // ------------------------------------------------------
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 13,
                            color: Colors.black.withOpacity(.4),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            dateFmt.format(record.date),
                            style: TextStyle(
                              color: Colors.black.withOpacity(.55),
                              fontWeight: FontWeight.w600,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // ------------------------------------------------------
                // COST + PROFIT + NET
                // ------------------------------------------------------
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Cost: ${money.format(record.cost)}",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                        color: Colors.black.withOpacity(.7),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Profit: ${money.format(record.profit)}",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                        color: Colors.black.withOpacity(.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: net >= 0
                            ? Colors.green.withOpacity(.12)
                            : Colors.red.withOpacity(.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Net: ${money.format(net)}",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12.5,
                          color: net >= 0 ? Colors.green : Colors.red,
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
}
