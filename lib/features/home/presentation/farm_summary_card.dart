import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FarmSummaryCard extends StatefulWidget {
  const FarmSummaryCard({super.key, required this.uid});

  final String uid;

  @override
  State<FarmSummaryCard> createState() => _FarmSummaryCardState();
}

class _FarmSummaryCardState extends State<FarmSummaryCard> {
  static const Color _ink = Color(0xFF0B1220);
  static const Color _muted = Color(0xFF5B6876);
  static const Color _border = Color(0xFFE9EEF3);
  static const Color _gold = Color(0xFFE9C46A);
  static const Color _emerald = Color(0xFF0E5C3A);
  static const Color _orange = Color(0xFFE65100);
  static const Color _teal = Color(0xFF00897B);
  static const Color _red = Color(0xFFC62828);
  static const Color _purple = Color(0xFF7C3AED);
  static const Color _blue = Color(0xFF2563EB);

  late final Stream _expenseStream = FirebaseFirestore.instance
      .collection('expenses')
      .where('uid', isEqualTo: widget.uid)
      .snapshots();

  late final Stream _noteStream = FirebaseFirestore.instance
      .collection('notes')
      .where('uid', isEqualTo: widget.uid)
      .snapshots();

  late final Stream _irrigationStream = FirebaseFirestore.instance
      .collection('irrigation')
      .where('uid', isEqualTo: widget.uid)
      .snapshots();

  double _num(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse((v ?? '0').toString()) ?? 0;
  }

  String _money(double v) {
    final neg = v < 0;
    final s = v.abs().round().toString();
    final withCommas =
        s.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
    return '${neg ? '-' : ''}৳$withCommas';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _expenseStream,
      builder: (context, expSnap) {
        return StreamBuilder(
          stream: _noteStream,
          builder: (context, noteSnap) {
            return StreamBuilder(
              stream: _irrigationStream,
              builder: (context, irrSnap) {
                final failed = expSnap.hasError;
                final loading = !expSnap.hasData && !failed;

                double cost = 0;
                double profit = 0;
                int records = 0;

                if (expSnap.hasData) {
                  for (final doc in expSnap.data!.docs) {
                    final data = doc.data() as Map;
                    cost += _num(data['cost']);
                    profit += _num(data['profit']);
                    records++;
                  }
                }

                int irrigations = 0;
                double irrigationCost = 0;

                if (irrSnap.hasData) {
                  for (final doc in irrSnap.data!.docs) {
                    final data = doc.data() as Map;
                    irrigationCost += _num(data['costTaka']);
                    irrigations++;
                  }
                }

                final net = profit - cost;
                final notes = noteSnap.hasData ? noteSnap.data!.docs.length : 0;

                final irrigationText = irrigations == 0
                    ? '0 irrigation'
                    : '$irrigations ${irrigations == 1 ? 'irrigation' : 'irrigations'}'
                        '${irrigationCost > 0 ? ' · ${_money(irrigationCost)}' : ''}';

                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: _border),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 22,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 22,
                            decoration: BoxDecoration(
                              color: _gold,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'My Farm Summary',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: _ink,
                            ),
                          ),
                          const Spacer(),
                          if (loading)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (failed)
                        const Text(
                          'Could not load your data. Check Firestore rules.',
                          style: TextStyle(color: _red, fontSize: 13),
                        )
                      else
                        Row(
                          children: [
                            _Stat(
                              icon: Icons.south_west_rounded,
                              label: 'Total cost',
                              value: loading ? '—' : _money(cost),
                              color: _orange,
                            ),
                            const SizedBox(width: 10),
                            _Stat(
                              icon: Icons.north_east_rounded,
                              label: 'Total profit',
                              value: loading ? '—' : _money(profit),
                              color: _emerald,
                            ),
                            const SizedBox(width: 10),
                            _Stat(
                              icon: Icons.account_balance_wallet_rounded,
                              label: 'Net balance',
                              value: loading ? '—' : _money(net),
                              color: net < 0 ? _red : _teal,
                            ),
                          ],
                        ),
                      if (!failed && !loading) ...[
                        const SizedBox(height: 14),
                        Text(
                          records == 0
                              ? 'No records added yet.'
                              : '$records records in Farm Finance',
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 12.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _Pill(
                              icon: Icons.sticky_note_2_rounded,
                              text: '$notes ${notes == 1 ? 'note' : 'notes'}',
                              color: _purple,
                            ),
                            _Pill(
                              icon: Icons.water_drop_rounded,
                              text: irrigationText,
                              color: _blue,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5B6876),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
