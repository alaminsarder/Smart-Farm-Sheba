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
      NumberFormat.currency(locale: 'en_BD', symbol: '৳ ', decimalDigits: 2);
  final _dateFmt = DateFormat('dd MMM yyyy');

  final List<_FinanceRecord> _records = [];

  double get _totalCost => _records.fold(0, (sum, item) => sum + item.cost);

  double get _totalProfit => _records.fold(0, (sum, item) => sum + item.profit);

  double get _net => _totalProfit - _totalCost;

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _openAddEditSheet({_FinanceRecord? record, int? index}) async {
    final isEdit = record != null && index != null;

    final formKey = GlobalKey<FormState>();
    final titleC = TextEditingController(text: record?.title ?? '');
    final costC = TextEditingController(
        text: record == null ? '' : record.cost.toStringAsFixed(2));
    final profitC = TextEditingController(
        text: record == null ? '' : record.profit.toStringAsFixed(2));

    DateTime selectedDate = record?.date ?? DateTime.now();
    bool saving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            Future<void> pickDate() async {
              final picked = await showDatePicker(
                context: ctx,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                setSheetState(() => selectedDate = picked);
              }
            }

            double? parseMoney(String s) {
              final v = double.tryParse(s.trim());
              if (v == null) return null;
              return v;
            }

            Future<void> save() async {
              if (!(formKey.currentState?.validate() ?? false)) return;

              setSheetState(() => saving = true);

              final cost = parseMoney(costC.text);
              final profit = parseMoney(profitC.text);
              if (cost == null || profit == null) {
                setSheetState(() => saving = false);
                _snack("Invalid amount");
                return;
              }

              final newRecord = _FinanceRecord(
                title: titleC.text.trim(),
                cost: cost,
                profit: profit,
                date: selectedDate,
              );

              setState(() {
                if (isEdit) {
                  _records[index] = newRecord;
                } else {
                  _records.insert(0, newRecord);
                }
              });

              if (ctx.mounted) Navigator.pop(ctx);
              _snack(isEdit ? "Record updated" : "Record added");
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 6,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEdit ? "Edit Record" : "Add Record",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: titleC,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: "Title",
                        prefixIcon: Icon(Icons.receipt_long_rounded),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        final s = (v ?? '').trim();
                        if (s.isEmpty) return "Title required";
                        if (s.length < 2) return "Enter a valid title";
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: costC,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                        LengthLimitingTextInputFormatter(12),
                      ],
                      decoration: const InputDecoration(
                        labelText: "Cost",
                        prefixIcon: Icon(Icons.trending_down_rounded),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        final s = (v ?? '').trim();
                        final n = double.tryParse(s);
                        if (s.isEmpty) return "Cost required";
                        if (n == null || n < 0) return "Enter valid cost";
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: profitC,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      textInputAction: TextInputAction.done,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                        LengthLimitingTextInputFormatter(12),
                      ],
                      decoration: const InputDecoration(
                        labelText: "Profit",
                        prefixIcon: Icon(Icons.trending_up_rounded),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        final s = (v ?? '').trim();
                        final n = double.tryParse(s);
                        if (s.isEmpty) return "Profit required";
                        if (n == null || n < 0) return "Enter valid profit";
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: pickDate,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_rounded),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _dateFmt.format(selectedDate),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800),
                              ),
                            ),
                            const Icon(Icons.edit_calendar_rounded, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: saving ? null : save,
                        icon: saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.save_rounded),
                        label: Text(
                            saving ? "Saving..." : (isEdit ? "Update" : "Add")),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    titleC.dispose();
    costC.dispose();
    profitC.dispose();
  }

  void _deleteAt(int index) {
    final removed = _records.removeAt(index);
    setState(() {});
    _snack("Deleted: ${removed.title}");
  }

  @override
  Widget build(BuildContext context) {
    final net = _net;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Farm Finance"),
        actions: [
          IconButton(
            tooltip: "Add",
            onPressed: () => _openAddEditSheet(),
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddEditSheet(),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text("Add Record"),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
        children: [
          // Summary Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Summary",
                  style: TextStyle(
                      color: Colors.white70, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
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
                      label: "Net",
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

          const SizedBox(height: 14),

          // Empty State
          if (_records.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 30),
                child: Text(
                  "No records yet.\nTap “Add Record” to create your first entry.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: Colors.black54),
                ),
              ),
            ),

          // Records
          for (int i = 0; i < _records.length; i++)
            _RecordCard(
              record: _records[i],
              money: _money,
              dateFmt: _dateFmt,
              onTap: () => _openAddEditSheet(record: _records[i], index: i),
              onDelete: () => _deleteAt(i),
            ),
        ],
      ),
    );
  }
}

class _FinanceRecord {
  final String title;
  final double cost;
  final double profit;
  final DateTime date;

  const _FinanceRecord({
    required this.title,
    required this.cost,
    required this.profit,
    required this.date,
  });
}

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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                    color: Colors.white70, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: valueColor ?? Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  final _FinanceRecord record;
  final NumberFormat money;
  final DateFormat dateFmt;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _RecordCard({
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
      key: ValueKey(
          "${record.title}_${record.date.millisecondsSinceEpoch}_${record.cost}_${record.profit}"),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: const Color(0xFFFFE5E5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.red),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("Delete record?"),
                content: Text("“${record.title}” will be removed."),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel")),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white),
                    child: const Text("Delete"),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) => onDelete(),
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.receipt_long_rounded,
                      color: Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateFmt.format(record.date),
                        style: const TextStyle(
                            color: Colors.black54, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("Cost: ${money.format(record.cost)}",
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text("Profit: ${money.format(record.profit)}",
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                      "Net: ${money.format(net)}",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: net >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
