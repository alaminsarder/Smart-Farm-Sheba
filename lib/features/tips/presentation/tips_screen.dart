import 'package:flutter/material.dart';

class TipItem {
  final String title;
  final String description;
  final IconData icon;

  const TipItem({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class TipCategory {
  final String name;
  final IconData icon;
  final Color color;
  final List<TipItem> tips;

  const TipCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.tips,
  });
}

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  // ---- Data (General farming guide) ----
  static const List<TipCategory> categories = [
    TipCategory(
      name: "Irrigation Tips",
      icon: Icons.water_drop_rounded,
      color: Color(0xFF1E88E5),
      tips: [
        TipItem(
          title: "Water at the right time",
          description:
              "Best time is early morning (5–8 AM) or late afternoon to reduce evaporation.",
          icon: Icons.schedule_rounded,
        ),
        TipItem(
          title: "Check soil before watering",
          description:
              "If soil is wet 2 inches deep, skip irrigation to prevent root problems and save water.",
          icon: Icons.fact_check_rounded,
        ),
        TipItem(
          title: "Avoid waterlogging",
          description:
              "Keep drainage channels clear, especially during rainy season.",
          icon: Icons.warning_rounded,
        ),
        TipItem(
          title: "Prefer drip/furrow when possible",
          description:
              "Drip saves water; furrow reduces leaf wetness and disease risk.",
          icon: Icons.tune_rounded,
        ),
      ],
    ),
    TipCategory(
      name: "Pest & Disease Monitoring",
      icon: Icons.bug_report_rounded,
      color: Color(0xFFFF6D00),
      tips: [
        TipItem(
          title: "Inspect leaves regularly",
          description:
              "Check underside of leaves 2–3 times a week for eggs, spots, curling, or holes.",
          icon: Icons.search_rounded,
        ),
        TipItem(
          title: "Act early",
          description:
              "Early control is easier and cheaper than treating a severe infestation.",
          icon: Icons.flash_on_rounded,
        ),
        TipItem(
          title: "Remove infected parts",
          description:
              "Cut and destroy infected leaves/branches to reduce spreading.",
          icon: Icons.content_cut_rounded,
        ),
        TipItem(
          title: "Keep field clean",
          description:
              "Weeds and leftover crop debris often host pests and diseases.",
          icon: Icons.cleaning_services_rounded,
        ),
      ],
    ),
    TipCategory(
      name: "Fertilizer & Soil Basics",
      icon: Icons.eco_rounded,
      color: Color(0xFF2E7D32),
      tips: [
        TipItem(
          title: "Use compost/organic matter",
          description:
              "Compost improves soil structure, water holding capacity, and long-term fertility.",
          icon: Icons.grass_rounded,
        ),
        TipItem(
          title: "Apply fertilizer based on crop stage",
          description:
              "Too much fertilizer at the wrong time can reduce yield and increase disease risk.",
          icon: Icons.science_rounded,
        ),
        TipItem(
          title: "Don’t overuse urea",
          description:
              "Excess nitrogen causes weak growth and attracts pests. Balance with other nutrients.",
          icon: Icons.balance_rounded,
        ),
        TipItem(
          title: "Maintain soil moisture after fertilizing",
          description:
              "Light irrigation after applying fertilizer helps nutrient uptake (avoid heavy flooding).",
          icon: Icons.opacity_rounded,
        ),
      ],
    ),
  ];

  static List<TipItem> get _allTips =>
      categories.expand((c) => c.tips).toList(growable: false);

  TipItem _tipOfTheDay() {
    final base = DateTime(2024, 1, 1);
    final days = DateTime.now().difference(base).inDays.abs();
    final list = _allTips;
    return list[days % list.length];
  }

  @override
  Widget build(BuildContext context) {
    final tod = _tipOfTheDay();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Tips",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header + Tip of the day
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lightbulb_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Smart Farm Sheba",
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "General Farming Guide",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withOpacity(0.45),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(tod.icon,
                    color: Theme.of(context).colorScheme.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Tip of the Day",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        tod.title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tod.description,
                        style: const TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            "📌 Categories",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          ...categories.map((c) => _categoryCard(context, c)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _categoryCard(BuildContext context, TipCategory category) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side:
            BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.35)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: category.color.withOpacity(0.14),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(category.icon, color: category.color),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("${category.tips.length} tips"),
        children: category.tips
            .map(
              (t) => Padding(
                padding: const EdgeInsets.only(top: 10),
                child: _tipRow(context, t),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _tipRow(BuildContext context, TipItem tip) {
    final muted =
        Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.75);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(tip.icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tip.title,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text(
                tip.description,
                style: TextStyle(fontSize: 13, height: 1.35, color: muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
