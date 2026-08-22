import 'package:flutter/material.dart';

import 'package:smart_farm_sheba/features/expense/presentation/expense_screen.dart';
import 'package:smart_farm_sheba/features/profile/presentation/profile_screen.dart';
import 'package:smart_farm_sheba/features/weather/presentation/weather_screen.dart';

import 'package:smart_farm_sheba/features/irrigation/presentation/irrigation_screen.dart';
import 'package:smart_farm_sheba/features/pesticide/presentation/pesticide_screen.dart';
import 'package:smart_farm_sheba/features/tips/presentation/tips_screen.dart';
import 'package:smart_farm_sheba/features/notes/presentation/notes_screen.dart';
import 'package:smart_farm_sheba/features/crop_suggestion/presentation/crop_suggestion_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _navigate(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 260),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved =
              CurvedAnimation(parent: animation, curve: Curves.easeOut);
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, .02),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    final crossAxisCount = size.width >= 900
        ? 4
        : size.width >= 650
            ? 3
            : 2;

    final items = <_DashboardItem>[
      _DashboardItem(
        title: "Weather",
        subtitle: "Forecast & rain alert",
        icon: Icons.cloud_rounded,
        gradient: const [Color(0xFF00B4DB), Color(0xFF0083B0)],
        onTap: () => _navigate(context, const WeatherScreen()),
      ),
      _DashboardItem(
        title: "Expense",
        subtitle: "Track daily cost",
        icon: Icons.calculate_rounded,
        gradient: const [Color(0xFF11998E), Color(0xFF38EF7D)],
        onTap: () => _navigate(context, const ExpenseScreen()),
      ),
      _DashboardItem(
        title: "Irrigation",
        subtitle: "Schedule & control",
        icon: Icons.water_drop_rounded,
        gradient: const [Color(0xFF1D976C), Color(0xFF93F9B9)],
        onTap: () => _navigate(context, const IrrigationScreen()),
      ),
      _DashboardItem(
        title: "Pesticide",
        subtitle: "Dose & safety tips",
        icon: Icons.pest_control_rounded,
        gradient: const [Color(0xFFFF512F), Color(0xFFF09819)],
        onTap: () => _navigate(context, const PesticideScreen()),
      ),
      _DashboardItem(
        title: "Crop Suggestion",
        subtitle: "Best crop for season",
        icon: Icons.grass_rounded,
        gradient: const [Color(0xFF56AB2F), Color(0xFFA8E063)],
        onTap: () => _navigate(context, const CropSuggestionScreen()),
      ),
      _DashboardItem(
        title: "Tips",
        subtitle: "Smart farming guide",
        icon: Icons.lightbulb_rounded,
        gradient: const [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
        onTap: () => _navigate(context, const TipsScreen()),
      ),
      _DashboardItem(
        title: "Notes",
        subtitle: "Farm logbook",
        icon: Icons.note_alt_rounded,
        gradient: const [Color(0xFF232526), Color(0xFF414345)],
        onTap: () => _navigate(context, const NotesScreen()),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              elevation: 0,
              backgroundColor: const Color(0xFFF5F7FA),
              expandedHeight: 170,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8),
                            Text(
                              "Smart Farm Sheba",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: .2,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Manage your farm smartly",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => _navigate(context, const ProfileScreen()),
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          padding: const EdgeInsets.all(2.5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.18),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                                color: Colors.white.withOpacity(.35)),
                          ),
                          child: const CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person_rounded,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: () =>
                            _navigate(context, const IrrigationScreen()),
                        child: const _QuickChip(
                          icon: Icons.water_drop_rounded,
                          label: "Irrigation",
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: () =>
                            _navigate(context, const PesticideScreen()),
                        child: const _QuickChip(
                          icon: Icons.pest_control_rounded,
                          label: "Pesticide",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => DashboardCard(item: items[index]),
                  childCount: items.length,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.05,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _QuickChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback? onTap;

  const _DashboardItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    this.onTap,
  });
}

class DashboardCard extends StatelessWidget {
  final _DashboardItem item;

  const DashboardCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE7EDF3)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x11000000),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                item.gradient[0].withOpacity(.12),
                item.gradient[1].withOpacity(.06),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: item.gradient),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(item.icon, color: Colors.white, size: 22),
                ),
                const Spacer(),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0B1220),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF5B6876),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
