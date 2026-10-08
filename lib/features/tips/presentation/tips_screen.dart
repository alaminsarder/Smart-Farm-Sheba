import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────
//  MODELS
// ─────────────────────────────────────────────────────────────

class TipItem {
  final String title;
  final String description;
  final IconData icon;

  /// Crop tags. Empty = general tip (applies to all crops)
  final List<String> crops;

  const TipItem({
    required this.title,
    required this.description,
    required this.icon,
    this.crops = const [],
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

// ─────────────────────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────────────────────

class _Palette {
  static const paddy = Color(0xFF14342A); // deep field green
  static const leaf = Color(0xFF2F7D4F); // fresh leaf
  static const sprout = Color(0xFF9BD67A); // young shoot
  static const harvest = Color(0xFFF2B93B); // ripe-grain gold

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
//  SCREEN
// ─────────────────────────────────────────────────────────────

class TipsScreen extends StatefulWidget {
  const TipsScreen({super.key});

  // ✅ Crop filter chips
  static const String cropAll = "All Crops";
  static const List<String> crops = [
    cropAll,
    "Tomato",
    "Onion",
    "Potato",
    "Chili",
    "Rice",
    "Wheat",
  ];

  // ---- Data (General farming guide + crop-specific tips) ----
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

        // Crop-specific irrigation examples
        TipItem(
          title: "Tomato: keep moisture steady",
          description:
              "Avoid irregular watering. Sudden dry→wet can cause cracking and blossom end rot risk.",
          icon: Icons.water_drop_rounded,
          crops: ["Tomato"],
        ),
        TipItem(
          title: "Onion: avoid late heavy irrigation",
          description:
              "Reduce irrigation near maturity to improve bulb curing and reduce rot.",
          icon: Icons.opacity_rounded,
          crops: ["Onion"],
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

        // Crop-specific pest/disease examples
        TipItem(
          title: "Tomato: watch for blight early",
          description:
              "Look for dark spots on leaves/stems after humid weather. Remove infected leaves and avoid wet foliage at night.",
          icon: Icons.coronavirus_rounded,
          crops: ["Tomato"],
        ),
        TipItem(
          title: "Onion: check thrips damage",
          description:
              "Silvery streaks and leaf curling are common thrips signs. Monitor weekly and act early.",
          icon: Icons.bug_report_rounded,
          crops: ["Onion"],
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

        // Crop-specific fertilizer examples
        TipItem(
          title: "Tomato: calcium helps fruit quality",
          description:
              "Balanced nutrition (including calcium) supports better fruit set and reduces blossom end rot risk.",
          icon: Icons.science_rounded,
          crops: ["Tomato"],
        ),
        TipItem(
          title: "Onion: avoid excess nitrogen late",
          description:
              "Too much nitrogen near bulb formation can reduce storage quality and increase diseases.",
          icon: Icons.warning_rounded,
          crops: ["Onion"],
        ),
      ],
    ),
  ];

  static List<TipItem> get _allTips =>
      categories.expand((c) => c.tips).toList(growable: false);

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  static const int _filterAll = -1;
  static const int _filterSaved = -2;

  final TextEditingController _searchCtrl = TextEditingController();
  final Set<String> _saved = <String>{};

  String _query = "";
  int _filter = _filterAll;

  // ✅ Crop filter state
  String _crop = TipsScreen.cropAll;

  int _shuffle = 0;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ───────────── helpers ─────────────

  bool _isSaved(TipItem t) => _saved.contains(t.title);

  void _toggleSave(TipItem t) {
    HapticFeedback.selectionClick();
    setState(() {
      if (!_saved.remove(t.title)) _saved.add(t.title);
    });
  }

  bool _matchesCrop(TipItem t) {
    if (_crop == TipsScreen.cropAll) return true;
    if (t.crops.isEmpty) return true; // general tip
    return t.crops.contains(_crop);
  }

  Future<void> _copy(TipItem t) async {
    await Clipboard.setData(
      ClipboardData(text: "${t.title}\n${t.description}"),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: _Palette.paddy,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          duration: const Duration(seconds: 2),
          content: const Text("Tip copied"),
        ),
      );
  }

  TipItem _tipOfTheDay() {
    final base = DateTime(2024, 1, 1);
    final days = DateTime.now().difference(base).inDays.abs();

    // Tip of the day respects crop filter (crop selected হলে general + crop tips)
    final filtered = TipsScreen._allTips.where(_matchesCrop).toList();
    final list = filtered.isEmpty ? TipsScreen._allTips : filtered;

    return list[(days + _shuffle) % list.length];
  }

  TipCategory _categoryOf(TipItem tip) {
    for (final c in TipsScreen.categories) {
      if (c.tips.contains(tip)) return c;
    }
    return TipsScreen.categories.first;
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return "Good morning";
    if (h < 17) return "Good afternoon";
    return "Good evening";
  }

  String get _dateLabel {
    const m = [
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
    final d = DateTime.now();
    return "${d.day} ${m[d.month - 1]}";
  }

  /// Categories (with their matching tips) after applying chip filter + crop + search.
  List<MapEntry<TipCategory, List<TipItem>>> _visible() {
    final q = _query.trim().toLowerCase();
    final result = <MapEntry<TipCategory, List<TipItem>>>[];

    for (var i = 0; i < TipsScreen.categories.length; i++) {
      if (_filter >= 0 && _filter != i) continue;
      final cat = TipsScreen.categories[i];

      final tips = cat.tips.where((t) {
        if (_filter == _filterSaved && !_isSaved(t)) return false;
        if (!_matchesCrop(t)) return false;

        if (q.isEmpty) return true;

        return t.title.toLowerCase().contains(q) ||
            t.description.toLowerCase().contains(q) ||
            cat.name.toLowerCase().contains(q);
      }).toList();

      if (tips.isNotEmpty) result.add(MapEntry(cat, tips));
    }
    return result;
  }

  // ───────────── build ─────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? _Palette.darkBg : _Palette.lightBg;
    final ink = isDark ? _Palette.darkInk : _Palette.lightInk;
    final visible = _visible();

    return Scaffold(
      backgroundColor: bg,
      body: ListView(
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(),
        children: [
          _header(context),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Transform.translate(
              offset: const Offset(0, -26),
              child: _searchField(isDark, ink),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _tipOfTheDayCard(),
          ),
          const SizedBox(height: 18),

          // ✅ NEW: crop chips (Tomato/Onion click করলে বোঝা যাবে)
          _cropChips(isDark, ink),
          const SizedBox(height: 14),

          _filterChips(isDark, ink),
          const SizedBox(height: 18),

          if (visible.isEmpty)
            _emptyState(isDark, ink)
          else
            ...visible.map(
              (e) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                child: _categorySection(e.key, e.value, isDark, ink),
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ───────────── header ─────────────

  Widget _header(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final total = TipsScreen._allTips.length;

    return Container(
      padding: EdgeInsets.fromLTRB(20, top + 14, 20, 52),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_Palette.paddy, Color(0xFF1F5A3F)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(34),
          bottomRight: Radius.circular(34),
        ),
      ),
      child: Stack(
        children: [
          Positioned(right: -50, top: -30, child: _ring(150, 0.07)),
          Positioned(right: 20, top: 40, child: _ring(70, 0.09)),
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
                      color: _tint(_Palette.sprout, 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.agriculture_rounded,
                            size: 14, color: _Palette.sprout),
                        SizedBox(width: 6),
                        Text(
                          "Smart Farm Sheba",
                          style: TextStyle(
                            color: _Palette.sprout,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                _greeting,
                style: TextStyle(
                  color: _tint(Colors.white, 0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Farming guide",
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
                "Simple habits for healthier crops and better yield.",
                style: TextStyle(
                  color: _tint(Colors.white, 0.72),
                  fontSize: 13.5,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _stat("$total", "tips"),
                  const SizedBox(width: 10),
                  _stat("${TipsScreen.categories.length}", "topics"),
                  const SizedBox(width: 10),
                  _stat("${_saved.length}", "saved", highlight: true),
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

  Widget _stat(String value, String label, {bool highlight = false}) {
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
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Text(
              value,
              key: ValueKey(value),
              style: TextStyle(
                color: highlight ? _Palette.harvest : Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
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

  // ───────────── search ─────────────

  Widget _searchField(bool isDark, Color ink) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? _Palette.darkCard : _Palette.lightCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _tint(_Palette.paddy, isDark ? 0.4 : 0.14),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _query = v),
        style: TextStyle(color: ink, fontSize: 15),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: "Search tips, e.g. urea, drip, weeds",
          hintStyle: TextStyle(color: _tint(ink, 0.45), fontSize: 14.5),
          prefixIcon: Icon(Icons.search_rounded, color: _tint(ink, 0.55)),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  icon: Icon(Icons.close_rounded, color: _tint(ink, 0.55)),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _query = "");
                  },
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  // ───────────── NEW: crop chips ─────────────

  Widget _cropChips(bool isDark, Color ink) {
    final baseColor = isDark ? _Palette.darkCard : _Palette.lightCard;

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: TipsScreen.crops.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final c = TipsScreen.crops[i];
          final selected = _crop == c;

          final chipBg = selected ? _Palette.leaf : baseColor;
          final textColor = selected ? Colors.white : ink;
          final iconColor = selected ? Colors.white : _Palette.leaf;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _crop = c);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: chipBg,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: selected ? _Palette.leaf : _tint(ink, 0.10),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    c == TipsScreen.cropAll
                        ? Icons.filter_alt_rounded
                        : Icons.local_florist_rounded,
                    size: 17,
                    color: iconColor,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    c,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ───────────── tip of the day ─────────────

  Widget _tipOfTheDayCard() {
    final tod = _tipOfTheDay();
    final cat = _categoryOf(tod);
    final saved = _isSaved(tod);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 380),
      switchInCurve: Curves.easeOutCubic,
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.04, 0),
            end: Offset.zero,
          ).animate(anim),
          child: child,
        ),
      ),
      child: Container(
        key: ValueKey("${tod.title}::$_crop"),
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 18, 14, 14),
        decoration: BoxDecoration(
          color: _Palette.paddy,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: _tint(_Palette.paddy, 0.35),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Stack(
            children: [
              Positioned(
                right: -34,
                bottom: -34,
                child: Icon(
                  tod.icon,
                  size: 150,
                  color: _tint(_Palette.sprout, 0.10),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: _tint(_Palette.harvest, 0.18),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.wb_sunny_rounded,
                            size: 16, color: _Palette.harvest),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Tip of the day",
                        style: TextStyle(
                          color: _Palette.harvest,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _dateLabel,
                        style: TextStyle(
                          color: _tint(Colors.white, 0.5),
                          fontSize: 12.5,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: saved ? "Remove bookmark" : "Save tip",
                        onPressed: () => _toggleSave(tod),
                        icon: Icon(
                          saved
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          color: saved
                              ? _Palette.harvest
                              : _tint(Colors.white, 0.75),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(right: 40),
                    child: Text(
                      tod.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(right: 24),
                    child: Text(
                      tod.description,
                      style: TextStyle(
                        color: _tint(Colors.white, 0.78),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _tint(Colors.white, 0.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(cat.icon, size: 13, color: _Palette.sprout),
                            const SizedBox(width: 6),
                            Text(
                              cat.name,
                              style: TextStyle(
                                color: _tint(Colors.white, 0.85),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => setState(() => _shuffle++),
                        style: TextButton.styleFrom(
                          foregroundColor: _Palette.sprout,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        icon: const Icon(Icons.shuffle_rounded, size: 18),
                        label: const Text(
                          "Another tip",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────── filter chips ─────────────

  Widget _filterChips(bool isDark, Color ink) {
    final items = <_ChipData>[
      _ChipData(_filterAll, "All", Icons.apps_rounded, _Palette.leaf, null),
      _ChipData(
        _filterSaved,
        "Saved",
        Icons.bookmark_rounded,
        _Palette.harvest,
        _saved.length,
      ),
      for (var i = 0; i < TipsScreen.categories.length; i++)
        _ChipData(
          i,
          TipsScreen.categories[i].name,
          TipsScreen.categories[i].icon,
          TipsScreen.categories[i].color,
          null,
        ),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final d = items[i];
          final selected = _filter == d.id;
          final baseColor = isDark ? _Palette.darkCard : _Palette.lightCard;

          return GestureDetector(
            onTap: () => setState(() => _filter = d.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: selected ? d.color : baseColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: selected ? d.color : _tint(ink, 0.10),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    d.icon,
                    size: 17,
                    color: selected ? Colors.white : d.color,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    d.label,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : ink,
                    ),
                  ),
                  if (d.badge != null && d.badge! > 0) ...[
                    const SizedBox(width: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: selected
                            ? _tint(Colors.white, 0.28)
                            : _tint(d.color, 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "${d.badge}",
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: selected ? Colors.white : ink,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ───────────── category section ─────────────

  Widget _categorySection(
    TipCategory cat,
    List<TipItem> tips,
    bool isDark,
    Color ink,
  ) {
    final cardColor = isDark ? _Palette.darkCard : _Palette.lightCard;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _tint(ink, isDark ? 0.08 : 0.06)),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: _tint(_Palette.paddy, 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            color: _tint(cat.color, isDark ? 0.14 : 0.08),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: cat.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(cat.icon, color: Colors.white, size: 21),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cat.name,
                        style: TextStyle(
                          color: ink,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tips.length == cat.tips.length
                            ? "${tips.length} practical tips"
                            : "${tips.length} of ${cat.tips.length} tips",
                        style:
                            TextStyle(color: _tint(ink, 0.6), fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tips
          for (var i = 0; i < tips.length; i++) ...[
            _tipRow(cat, tips[i], ink),
            if (i != tips.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                indent: 66,
                endIndent: 16,
                color: _tint(ink, 0.07),
              ),
          ],
        ],
      ),
    );
  }

  Widget _tipRow(TipCategory cat, TipItem tip, Color ink) {
    final saved = _isSaved(tip);

    return InkWell(
      onLongPress: () => _copy(tip),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 6, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _tint(cat.color, 0.13),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(tip.icon, size: 19, color: cat.color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tip.title,
                      style: TextStyle(
                        color: ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tip.description,
                      style: TextStyle(
                        color: _tint(ink, 0.68),
                        fontSize: 13.5,
                        height: 1.45,
                      ),
                    ),

                    // small indicator chips for crop-specific tips
                    if (tip.crops.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: tip.crops.take(2).map((c) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _tint(cat.color, 0.10),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: _tint(cat.color, 0.20)),
                            ),
                            child: Text(
                              c,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 11.5,
                                color: _tint(ink, 0.85),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Column(
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: saved ? "Remove bookmark" : "Save tip",
                  onPressed: () => _toggleSave(tip),
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (c, a) =>
                        ScaleTransition(scale: a, child: c),
                    child: Icon(
                      saved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      key: ValueKey(saved),
                      size: 22,
                      color: saved ? _Palette.harvest : _tint(ink, 0.4),
                    ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: "Copy tip",
                  onPressed: () => _copy(tip),
                  icon: Icon(Icons.copy_rounded,
                      size: 18, color: _tint(ink, 0.35)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ───────────── empty state ─────────────

  Widget _emptyState(bool isDark, Color ink) {
    final bool noSaved = _filter == _filterSaved && _query.trim().isEmpty;
    final cropHint = _crop == TipsScreen.cropAll ? "" : " for $_crop";

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 28, 32, 28),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: _tint(_Palette.leaf, 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              noSaved ? Icons.bookmark_add_outlined : Icons.search_off_rounded,
              size: 36,
              color: _Palette.leaf,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            noSaved ? "No saved tips yet" : "No tips found$cropHint",
            style: TextStyle(
              color: ink,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            noSaved
                ? "Tap the bookmark on any tip to keep it here."
                : "Try a different word or clear the search.",
            textAlign: TextAlign.center,
            style:
                TextStyle(color: _tint(ink, 0.6), fontSize: 13.5, height: 1.4),
          ),
          if (!noSaved && _query.isNotEmpty) ...[
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: () {
                _searchCtrl.clear();
                setState(() => _query = "");
              },
              child: const Text("Clear search"),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChipData {
  final int id;
  final String label;
  final IconData icon;
  final Color color;
  final int? badge;

  const _ChipData(this.id, this.label, this.icon, this.color, this.badge);
}
