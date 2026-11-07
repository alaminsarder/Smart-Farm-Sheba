import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// ======================================================================
// THEME + CATEGORIES
// ======================================================================

const _ink = Color(0xFF1B1F23);
const _bg = Color(0xFFF4F7F4);
const _dark = Color(0xFF14532D);
const _mid = Color(0xFF2E7D32);
const _light = Color(0xFF43A047);
const _gain = Color(0xFF15803D);
const _loss = Color(0xFFDC2626);

class _Category {
  final String name;
  final IconData icon;
  final Color color;
  const _Category(this.name, this.icon, this.color);
}

const _categories = <_Category>[
  _Category('Seeds', Icons.grass_rounded, Color(0xFF2E7D32)),
  _Category('Fertilizer', Icons.science_rounded, Color(0xFF0D9488)),
  _Category('Labor', Icons.groups_rounded, Color(0xFF2563EB)),
  _Category('Irrigation', Icons.water_drop_rounded, Color(0xFF0284C7)),
  _Category('Equipment', Icons.build_rounded, Color(0xFF7C3AED)),
  _Category('Sales', Icons.storefront_rounded, Color(0xFFF59E0B)),
  _Category('Other', Icons.category_rounded, Color(0xFF64748B)),
];

enum _Filter { all, profitable, loss }

// ======================================================================
// MODEL
// ======================================================================

class _FinanceRecord {
  final String id;
  final String title;
  final int category;
  final double cost;
  final double profit;
  final DateTime date;

  const _FinanceRecord({
    required this.id,
    required this.title,
    required this.category,
    required this.cost,
    required this.profit,
    required this.date,
  });

  double get net => profit - cost;
}

// ======================================================================
// SCREEN
// ======================================================================

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final _money =
      NumberFormat.currency(locale: 'en_US', symbol: '৳ ', decimalDigits: 2);
  final _dateFmt = DateFormat('dd MMM yyyy');
  final _monthFmt = DateFormat('MMMM yyyy');

  final List<_FinanceRecord> _records = [];
  _Filter _filter = _Filter.all;

  double get _totalCost => _records.fold(0.0, (s, r) => s + r.cost);
  double get _totalProfit => _records.fold(0.0, (s, r) => s + r.profit);
  double get _net => _totalProfit - _totalCost;

  String _signed(double v) => "${v >= 0 ? '+' : '−'} ${_money.format(v.abs())}";

  List<_FinanceRecord> get _visible {
    final list = _records.where((r) {
      switch (_filter) {
        case _Filter.all:
          return true;
        case _Filter.profitable:
          return r.net >= 0;
        case _Filter.loss:
          return r.net < 0;
      }
    }).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  void _toast(String msg, {SnackBarAction? action}) {
    if (!mounted) return;
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

  Future<void> _openSheet({_FinanceRecord? record}) async {
    final result = await showModalBottomSheet<_FinanceRecord>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FinanceFormSheet(record: record, dateFmt: _dateFmt),
    );

    if (!mounted || result == null) return;

    setState(() {
      if (record != null) {
        final i = _records.indexWhere((r) => r.id == record.id);
        if (i >= 0) _records[i] = result;
      } else {
        _records.insert(0, result);
      }
    });

    _toast(record != null ? 'Record updated' : 'Record added');
  }

  void _delete(_FinanceRecord record) {
    final index = _records.indexWhere((r) => r.id == record.id);
    if (index < 0) return;

    setState(() => _records.removeAt(index));
    HapticFeedback.mediumImpact();

    _toast(
      'Deleted “${record.title}”',
      action: SnackBarAction(
        label: 'UNDO',
        textColor: const Color(0xFF86EFAC),
        onPressed: () => setState(() => _records.insert(index, record)),
      ),
    );
  }

  // ---------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    final list = _visible;

    return Scaffold(
      backgroundColor: _bg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openSheet(),
        backgroundColor: _mid,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add record',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _header()),
          SliverToBoxAdapter(child: _filters()),
          if (_records.isEmpty)
            SliverFillRemaining(hasScrollBody: false, child: _emptyState())
          else if (list.isEmpty)
            SliverFillRemaining(hasScrollBody: false, child: _noResults())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
              sliver: SliverList(
                delegate: SliverChildListDelegate(_groupedChildren(list)),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _groupedChildren(List<_FinanceRecord> list) {
    final groups = <String, List<_FinanceRecord>>{};
    for (final r in list) {
      groups.putIfAbsent(_monthFmt.format(r.date), () => []).add(r);
    }

    final children = <Widget>[];
    groups.forEach((month, items) {
      final monthNet = items.fold(0.0, (s, r) => s + r.net);

      children.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
          child: Row(
            children: [
              Text(
                month.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w800,
                  color: Colors.black.withOpacity(.5),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Divider(color: Colors.black.withOpacity(.08))),
              const SizedBox(width: 10),
              Text(
                _signed(monthNet),
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: monthNet >= 0 ? _gain : _loss,
                ),
              ),
            ],
          ),
        ),
      );

      for (final r in items) {
        children.add(
          _RecordCard(
            key: ValueKey(r.id),
            record: r,
            money: _money,
            dateFmt: _dateFmt,
            signed: _signed,
            onTap: () => _openSheet(record: r),
            onDelete: () => _delete(r),
          ),
        );
      }
    });
    return children;
  }

  Widget _header() {
    final net = _net;
    final total = _totalCost + _totalProfit;
    final costFlex = total == 0 ? 1 : (_totalCost / total * 1000).round();
    final profitFlex = total == 0 ? 1 : (_totalProfit / total * 1000).round();
    final canPop = Navigator.of(context).canPop();

    return Container(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 14, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_dark, _mid, _light],
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
                  'Farm Finance',
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
                child: const Icon(Icons.account_balance_wallet_rounded,
                    color: Colors.white, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            'NET BALANCE',
            style: TextStyle(
              color: Colors.white.withOpacity(.75),
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _signed(net),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: -.5,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color:
                  (net >= 0 ? const Color(0xFFB9FFCB) : const Color(0xFFFFC2C2))
                      .withOpacity(.22),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  net >= 0
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  size: 15,
                  color: net >= 0
                      ? const Color(0xFFB9FFCB)
                      : const Color(0xFFFFC2C2),
                ),
                const SizedBox(width: 5),
                Text(
                  _records.isEmpty
                      ? 'No records yet'
                      : net >= 0
                          ? 'You are in profit'
                          : 'Spending exceeds profit',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: net >= 0
                        ? const Color(0xFFB9FFCB)
                        : const Color(0xFFFFC2C2),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _miniStat(
                  'Total cost',
                  _money.format(_totalCost),
                  Icons.south_east_rounded,
                  const Color(0xFFFFC2C2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _miniStat(
                  'Total profit',
                  _money.format(_totalProfit),
                  Icons.north_east_rounded,
                  const Color(0xFFB9FFCB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  Expanded(
                    flex: costFlex < 1 ? 1 : costFlex,
                    child: Container(
                        color: total == 0
                            ? Colors.white24
                            : const Color(0xFFFFB4B4)),
                  ),
                  const SizedBox(width: 3),
                  Expanded(
                    flex: profitFlex < 1 ? 1 : profitFlex,
                    child: Container(
                        color: total == 0
                            ? Colors.white24
                            : const Color(0xFFB9FFCB)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cost vs profit ratio',
            style: TextStyle(
              color: Colors.white.withOpacity(.7),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, IconData icon, Color tint) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.16),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: tint, size: 17),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: Colors.white.withOpacity(.75),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(value,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filters() {
    Widget chip(String label, IconData icon, _Filter f) {
      final selected = _filter == f;
      return GestureDetector(
        onTap: () => setState(() => _filter = f),
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
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            chip('All records', Icons.grid_view_rounded, _Filter.all),
            const SizedBox(width: 10),
            chip('Profitable', Icons.trending_up_rounded, _Filter.profitable),
            const SizedBox(width: 10),
            chip('Loss', Icons.trending_down_rounded, _Filter.loss),
          ],
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
                  colors: [_mid.withOpacity(.18), _mid.withOpacity(.05)],
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
                  child: const Icon(Icons.receipt_long_rounded,
                      size: 42, color: _mid),
                ),
              ),
            ),
            const SizedBox(height: 26),
            const Text('No records yet',
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w900, color: _ink)),
            const SizedBox(height: 8),
            Text(
              'Track your seed, fertilizer, labor and\nsales to see how your farm is performing.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  height: 1.55,
                  color: Colors.black.withOpacity(.55)),
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
              onPressed: () => _openSheet(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add first record',
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
            Icon(Icons.filter_alt_off_rounded,
                size: 54, color: Colors.black.withOpacity(.25)),
            const SizedBox(height: 14),
            const Text('Nothing here',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800, color: _ink)),
            const SizedBox(height: 6),
            Text('No records match this filter.',
                style: TextStyle(color: Colors.black.withOpacity(.55))),
          ],
        ),
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
  final String Function(double) signed;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _RecordCard({
    super.key,
    required this.record,
    required this.money,
    required this.dateFmt,
    required this.signed,
    required this.onTap,
    required this.onDelete,
  });

  Future<bool> _confirm(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            icon: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFFDE8E8),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  color: _loss, size: 28),
            ),
            title: const Text('Delete record?',
                style: TextStyle(fontWeight: FontWeight.w800)),
            content: Text(
              '“${record.title}” will be removed. You can undo right after.',
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: _loss,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final cat = _categories[record.category];
    final net = record.net;
    final positive = net >= 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: ValueKey('dismiss_${record.id}'),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) => _confirm(context),
        onDismissed: (_) => onDelete(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: _loss,
            borderRadius: BorderRadius.circular(20),
          ),
          child:
              const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
        ),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black.withOpacity(.04)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.04),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: cat.color.withOpacity(.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(cat.icon, color: cat.color, size: 24),
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
                              style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                color: _ink,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${cat.name} · ${dateFmt.format(record.date)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: Colors.black.withOpacity(.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            signed(net),
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w900,
                              color: positive ? _gain : _loss,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: (positive ? _gain : _loss).withOpacity(.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              positive ? 'Profit' : 'Loss',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: positive ? _gain : _loss,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F8F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _kv(Icons.south_east_rounded, 'Cost',
                              money.format(record.cost), _loss),
                        ),
                        Container(
                            width: 1,
                            height: 24,
                            color: Colors.black.withOpacity(.08)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _kv(Icons.north_east_rounded, 'Profit',
                              money.format(record.profit), _gain),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _kv(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black.withOpacity(.5))),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(value,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: _ink)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ======================================================================
// FORM SHEET
// ======================================================================

class _FinanceFormSheet extends StatefulWidget {
  final _FinanceRecord? record;
  final DateFormat dateFmt;

  const _FinanceFormSheet({required this.record, required this.dateFmt});

  @override
  State<_FinanceFormSheet> createState() => _FinanceFormSheetState();
}

class _FinanceFormSheetState extends State<_FinanceFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleC;
  late final TextEditingController _costC;
  late final TextEditingController _profitC;

  late DateTime _date;
  late int _category;

  bool get _isEdit => widget.record != null;

  @override
  void initState() {
    super.initState();
    final r = widget.record;
    _titleC = TextEditingController(text: r?.title ?? '');
    _costC = TextEditingController(text: r == null ? '' : _plain(r.cost));
    _profitC = TextEditingController(text: r == null ? '' : _plain(r.profit));
    _date = r?.date ?? DateTime.now();
    _category = r?.category ?? 0;
  }

  String _plain(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

  @override
  void dispose() {
    _titleC.dispose();
    _costC.dispose();
    _profitC.dispose();
    super.dispose();
  }

  double get _costVal => double.tryParse(_costC.text.trim()) ?? 0;
  double get _profitVal => double.tryParse(_profitC.text.trim()) ?? 0;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
                primary: _mid,
                onPrimary: Colors.white,
              ),
        ),
        child: child!,
      ),
    );
    if (!mounted || picked == null) return;
    setState(() => _date = picked);
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    Navigator.of(context).pop(
      _FinanceRecord(
        id: widget.record?.id ?? '${DateTime.now().microsecondsSinceEpoch}',
        title: _titleC.text.trim(),
        category: _category,
        cost: _costVal,
        profit: _profitVal,
        date: _date,
      ),
    );
  }

  InputDecoration _deco(String label, IconData icon, {String? prefix}) {
    OutlineInputBorder b(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c, width: w),
        );
    return InputDecoration(
      labelText: label,
      prefixText: prefix,
      prefixIcon: Icon(icon, color: _mid, size: 21),
      filled: true,
      fillColor: const Color(0xFFF6F8F6),
      floatingLabelStyle: const TextStyle(color: _mid),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      border: b(Colors.transparent),
      enabledBorder: b(Colors.black12),
      focusedBorder: b(_mid, 1.6),
      errorBorder: b(_loss),
      focusedErrorBorder: b(_loss, 1.6),
    );
  }

  List<TextInputFormatter> get _moneyFormatters => [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
        LengthLimitingTextInputFormatter(12),
      ];

  String? _amountValidator(String? v, String name) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return '$name required';
    final n = double.tryParse(t);
    if (n == null || n < 0) return 'Enter valid $name';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final net = _profitVal - _costVal;
    final positive = net >= 0;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
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
                          color: _mid.withOpacity(.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _isEdit ? Icons.edit_rounded : Icons.add_card_rounded,
                          color: _mid,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _isEdit ? 'Edit record' : 'New record',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: _ink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Category
                  const Text('Category',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.black54)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(_categories.length, (i) {
                      final c = _categories[i];
                      final sel = i == _category;
                      return GestureDetector(
                        onTap: () => setState(() => _category = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: sel ? c.color : c.color.withOpacity(.08),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: sel ? c.color : c.color.withOpacity(.25),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(c.icon,
                                  size: 16,
                                  color: sel ? Colors.white : c.color),
                              const SizedBox(width: 6),
                              Text(
                                c.name,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: sel ? Colors.white : c.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 18),

                  TextFormField(
                    controller: _titleC,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: _deco('Title', Icons.title_rounded),
                    validator: (v) {
                      final t = (v ?? '').trim();
                      if (t.isEmpty) return 'Title required';
                      if (t.length < 2) return 'Enter a valid title';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _costC,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          textInputAction: TextInputAction.next,
                          inputFormatters: _moneyFormatters,
                          onChanged: (_) => setState(() {}),
                          decoration: _deco('Cost', Icons.south_east_rounded,
                              prefix: '৳ '),
                          validator: (v) => _amountValidator(v, 'cost'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _profitC,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          textInputAction: TextInputAction.done,
                          inputFormatters: _moneyFormatters,
                          onChanged: (_) => setState(() {}),
                          decoration: _deco('Profit', Icons.north_east_rounded,
                              prefix: '৳ '),
                          validator: (v) => _amountValidator(v, 'profit'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Date
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F8F6),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded,
                              color: _mid, size: 21),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.dateFmt.format(_date),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, color: _ink),
                            ),
                          ),
                          const Icon(Icons.edit_calendar_rounded,
                              size: 18, color: Colors.black38),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Live net preview
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: (positive ? _gain : _loss).withOpacity(.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: (positive ? _gain : _loss).withOpacity(.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          positive
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          color: positive ? _gain : _loss,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Net result',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.black.withOpacity(.6),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${positive ? '+' : '−'} ৳ ${net.abs().toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: positive ? _gain : _loss,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _ink,
                            side: const BorderSide(color: Colors.black12),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Cancel',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          onPressed: _save,
                          style: FilledButton.styleFrom(
                            backgroundColor: _mid,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          icon: const Icon(Icons.check_rounded, size: 20),
                          label: Text(
                            _isEdit ? 'Update record' : 'Save record',
                            style: const TextStyle(fontWeight: FontWeight.w800),
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
      ),
    );
  }
}
