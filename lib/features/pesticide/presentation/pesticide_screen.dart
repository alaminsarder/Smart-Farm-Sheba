import 'package:flutter/material.dart';

class PesticideScreen extends StatefulWidget {
  const PesticideScreen({super.key});

  @override
  State<PesticideScreen> createState() => _PesticideScreenState();
}

class _PesticideScreenState extends State<PesticideScreen> {
  String selectedProblem = "Insects";
  String selectedCrop = "Vegetables";

  final TextEditingController doseMlPerLiterCtrl =
      TextEditingController(text: "2");
  final TextEditingController tankVolumeLiterCtrl =
      TextEditingController(text: "16");
  final TextEditingController tanksCountCtrl = TextEditingController(text: "1");

  static const List<String> problems = ["Insects", "Fungus", "Weeds"];
  static const List<String> crops = [
    "Rice",
    "Wheat",
    "Vegetables",
    "Fruits",
    "Jute"
  ];

  @override
  void dispose() {
    doseMlPerLiterCtrl.dispose();
    tankVolumeLiterCtrl.dispose();
    tanksCountCtrl.dispose();
    super.dispose();
  }

  double _parseDouble(String v, {double fallback = 0}) =>
      double.tryParse(v.trim()) ?? fallback;
  int _parseInt(String v, {int fallback = 0}) =>
      int.tryParse(v.trim()) ?? fallback;

  @override
  Widget build(BuildContext context) {
    final doseMlPerLiter = _parseDouble(doseMlPerLiterCtrl.text, fallback: 0);
    final tankLiters = _parseDouble(tankVolumeLiterCtrl.text, fallback: 0);
    final tanks = _parseInt(tanksCountCtrl.text, fallback: 0).clamp(0, 999);

    final totalWater = tankLiters * tanks;
    final totalProductMl = (doseMlPerLiter * totalWater);

    final plan = _planFor(selectedProblem);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pesticide",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showDisclaimer(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6D00), Color(0xFFFFA726)],
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
                  child: const Icon(Icons.bug_report,
                      color: Colors.white, size: 30),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Smart Farm Sheba",
                          style:
                              TextStyle(color: Colors.white70, fontSize: 13)),
                      SizedBox(height: 4),
                      Text(
                        "Dose & Safety Guide",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Problem + Crop selector
          Row(
            children: [
              Expanded(
                child: _dropdownCard(
                  context,
                  title: "Problem Type",
                  value: selectedProblem,
                  items: problems,
                  icon: Icons.warning_amber_rounded,
                  onChanged: (v) => setState(() => selectedProblem = v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _dropdownCard(
                  context,
                  title: "Crop",
                  value: selectedCrop,
                  items: crops,
                  icon: Icons.spa_rounded,
                  onChanged: (v) => setState(() => selectedCrop = v),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action plan (general)
          _sectionCard(
            context,
            icon: plan.icon,
            title: "Recommended Approach",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _bullet("Monitor: ${plan.monitor}"),
                _bullet("Prevention: ${plan.prevention}"),
                _bullet("When to spray: ${plan.whenToSpray}"),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Dosage calculator
          _sectionCard(
            context,
            icon: Icons.calculate_rounded,
            title: "Dosage Calculator (Label-based)",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Enter dose from the pesticide label (ml per liter).",
                  style: TextStyle(fontSize: 13, height: 1.35),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _numberField(
                        controller: doseMlPerLiterCtrl,
                        label: "Dose (ml/L)",
                        icon: Icons.science_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _numberField(
                        controller: tankVolumeLiterCtrl,
                        label: "Tank (L)",
                        icon: Icons.water_drop_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _numberField(
                  controller: tanksCountCtrl,
                  label: "Number of Tanks",
                  icon: Icons.format_list_numbered_rounded,
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withOpacity(0.45),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_rounded,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Total water: ${totalWater.toStringAsFixed(1)} L\n"
                          "Total pesticide: ${totalProductMl.toStringAsFixed(1)} ml",
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Crop selected: $selectedCrop",
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Safety checklist
          _sectionCard(
            context,
            icon: Icons.health_and_safety_rounded,
            title: "Safety Checklist",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _CheckRow(
                    text: "Wear mask/cloth cover, gloves and long sleeves."),
                _CheckRow(text: "Do not spray against wind (avoid drift)."),
                _CheckRow(
                    text:
                        "Keep children/animals away from field during spraying."),
                _CheckRow(
                    text: "Avoid spraying during strong sun or before rain."),
                _CheckRow(text: "Do not eat/drink/smoke while spraying."),
                _CheckRow(
                    text: "After spraying wash hands, clothes, and equipment."),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Mixing steps
          _sectionCard(
            context,
            icon: Icons.list_alt_rounded,
            title: "Mixing Steps (General)",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _StepRow(n: 1, text: "Read label instructions carefully."),
                _StepRow(n: 2, text: "Fill tank half with clean water."),
                _StepRow(n: 3, text: "Add measured pesticide, then mix."),
                _StepRow(n: 4, text: "Fill remaining water, mix again."),
                _StepRow(n: 5, text: "Spray evenly. Avoid over-spraying."),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Emergency
          _sectionCard(
            context,
            icon: Icons.local_hospital_rounded,
            title: "If Exposure Happens",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _bulletText("Skin: Wash with soap and water immediately."),
                _bulletText("Eyes: Rinse with clean water for 10–15 minutes."),
                _bulletText("Inhalation: Move to fresh air quickly."),
                _bulletText(
                    "Swallowed: Seek medical help immediately and show the label/container."),
              ],
            ),
          ),

          const SizedBox(height: 22),
        ],
      ),
    );
  }

  // ---------- UI helpers ----------

  Widget _dropdownCard(
    BuildContext context, {
    required String title,
    required String value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Row(
                      children: [
                        Icon(icon, size: 18, color: const Color(0xFFFF6D00)),
                        const SizedBox(width: 8),
                        Flexible(child: Text(e)),
                      ],
                    ),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.35),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _numberField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("•  ", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: const TextStyle(height: 1.35))),
        ],
      ),
    );
  }

  void _showDisclaimer(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Important"),
        content: const Text(
          "Always follow the pesticide label and local agriculture officer advice. "
          "This app provides general guidance only.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  _ProblemPlan _planFor(String problem) {
    switch (problem) {
      case "Fungus":
        return const _ProblemPlan(
          icon: Icons.coronavirus_rounded,
          monitor: "Look for spots, leaf burn, powdery growth, rotting.",
          prevention:
              "Good spacing, remove infected leaves, avoid wet foliage at night.",
          whenToSpray: "At early symptoms; avoid spraying before rain.",
        );
      case "Weeds":
        return const _ProblemPlan(
          icon: Icons.grass_rounded,
          monitor: "Check weeds at early stage (2–4 leaf stage).",
          prevention: "Mulching, timely weeding, clean field borders.",
          whenToSpray:
              "Early stage weeds; avoid wind to prevent drift to crops.",
        );
      case "Insects":
      default:
        return const _ProblemPlan(
          icon: Icons.bug_report_rounded,
          monitor: "Check underside of leaves for eggs/larvae and damage.",
          prevention:
              "Field hygiene, remove heavily infested parts, use traps if possible.",
          whenToSpray:
              "Early infestation; spray in morning/evening for better effect.",
        );
    }
  }
}

class _ProblemPlan {
  final IconData icon;
  final String monitor;
  final String prevention;
  final String whenToSpray;

  const _ProblemPlan({
    required this.icon,
    required this.monitor,
    required this.prevention,
    required this.whenToSpray,
  });
}

class _CheckRow extends StatelessWidget {
  final String text;
  const _CheckRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline,
              size: 18, color: Color(0xFF2E7D32)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(height: 1.35))),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final int n;
  final String text;
  const _StepRow({required this.n, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: const Color(0xFFFF6D00).withOpacity(0.15),
            child: Text("$n",
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(height: 1.35))),
        ],
      ),
    );
  }
}

class _bulletText extends StatelessWidget {
  final String text;
  const _bulletText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("•  ", style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
