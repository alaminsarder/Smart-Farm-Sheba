import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:smart_farm_sheba/features/expense/presentation/expense_screen.dart';
import 'package:smart_farm_sheba/features/profile/presentation/profile_screen.dart';

import 'package:smart_farm_sheba/features/irrigation/presentation/irrigation_screen.dart';
import 'package:smart_farm_sheba/features/pesticide/presentation/pesticide_screen.dart';
import 'package:smart_farm_sheba/features/tips/presentation/tips_screen.dart';
import 'package:smart_farm_sheba/features/notes/presentation/notes_screen.dart';
import 'package:smart_farm_sheba/features/crop_suggestion/presentation/crop_suggestion_screen.dart';

class AppPalette {
  static const Color background = Color(0xFFF4F6F8);
  static const Color ink = Color(0xFF0B1220);
  static const Color muted = Color(0xFF5B6876);
  static const Color border = Color(0xFFE9EEF3);
  static const Color gold = Color(0xFFE9C46A);
  static const Color emerald = Color(0xFF0E5C3A);
  static const List<Color> header = [
    Color(0xFF062F23),
    Color(0xFF0E5C3A),
    Color(0xFF2A8A4A),
  ];
}

class FadeSlideRoute<T> extends PageRouteBuilder<T> {
  FadeSlideRoute({required Widget page})
      : super(
          transitionDuration: const Duration(milliseconds: 280),
          reverseTransitionDuration: const Duration(milliseconds: 220),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeIn,
            );
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, .03),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        );
}

class DashboardItem {
  final String title;
  final String subtitle;
  final String actionLabel;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback? onTap;

  const DashboardItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    this.actionLabel = "Open",
    this.onTap,
  });
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _open(Widget page) {
    Navigator.of(context).push(FadeSlideRoute<void>(page: page));
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    final items = <DashboardItem>[
      DashboardItem(
        title: "Expense",
        subtitle: "Track daily cost",
        actionLabel: "Add expense",
        icon: Icons.calculate_rounded,
        gradient: const [Color(0xFF11998E), Color(0xFF38EF7D)],
        onTap: () => _open(ExpenseScreen()),
      ),
      DashboardItem(
        title: "Irrigation",
        subtitle: "Schedule & control",
        actionLabel: "Manage water",
        icon: Icons.water_drop_rounded,
        gradient: const [Color(0xFF1D976C), Color(0xFF93F9B9)],
        onTap: () => _open(IrrigationScreen()),
      ),
      DashboardItem(
        title: "Crop Suggestion",
        subtitle: "Best crop for season",
        actionLabel: "Get suggestion",
        icon: Icons.grass_rounded,
        gradient: const [Color(0xFF56AB2F), Color(0xFFA8E063)],
        onTap: () => _open(CropSuggestionScreen()),
      ),
      DashboardItem(
        title: "Notes",
        subtitle: "Farm logbook",
        actionLabel: "Open logbook",
        icon: Icons.note_alt_rounded,
        gradient: const [Color(0xFF232526), Color(0xFF414345)],
        onTap: () => _open(NotesScreen()),
      ),
      DashboardItem(
        title: "Tips",
        subtitle: "Smart farming guide",
        actionLabel: "Read tips",
        icon: Icons.lightbulb_rounded,
        gradient: const [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
        onTap: () => _open(TipsScreen()),
      ),
      DashboardItem(
        title: "Pesticide",
        subtitle: "Dose & safety tips",
        actionLabel: "View guide",
        icon: Icons.pest_control_rounded,
        gradient: const [Color(0xFFFF512F), Color(0xFFF09819)],
        onTap: () => _open(PesticideScreen()),
      ),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppPalette.background,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _HeaderDelegate(
                topPadding: topPadding,
                onProfileTap: () => _open(ProfileScreen()),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: _Reveal(
                  animation: _controller,
                  index: 0,
                  child: _FeaturedCarousel(items: items),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _Reveal(
                animation: _controller,
                index: 1,
                child: const _SectionHeader(
                  title: "Farm Tools",
                  subtitle: "Everything you need, in one place",
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(18, 0, 18, 24 + bottomPadding),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _Reveal(
                    animation: _controller,
                    index: index + 2,
                    child: DashboardCard(item: items[index]),
                  ),
                  childCount: items.length,
                ),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 260,
                  mainAxisExtent: 168,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _greeting(DateTime now) {
  if (now.hour < 12) return "Good Morning";
  if (now.hour < 17) return "Good Afternoon";
  return "Good Evening";
}

String _dateLabel(DateTime now) {
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return "${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}";
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  final double topPadding;
  final VoidCallback onProfileTap;

  const _HeaderDelegate({
    required this.topPadding,
    required this.onProfileTap,
  });

  static const double _collapsedBar = 64;
  static const double _expandedBody = 140;

  @override
  double get minExtent => topPadding + _collapsedBar;

  @override
  double get maxExtent => topPadding + _expandedBody;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final range = maxExtent - minExtent;
    final t = (shrinkOffset / range).clamp(0.0, 1.0);
    final expandedOpacity = (1 - t * 1.8).clamp(0.0, 1.0);
    final collapsedOpacity = ((t - .55) / .45).clamp(0.0, 1.0);
    final now = DateTime.now();
    final radius = Radius.circular(28 - 10 * t);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppPalette.header,
        ),
        borderRadius: BorderRadius.vertical(bottom: radius),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -60,
            child: _Bubble(size: 150, color: Colors.white.withAlpha(20)),
          ),
          Positioned(
            left: -50,
            bottom: -70,
            child: _Bubble(
              size: 130,
              color: AppPalette.gold.withAlpha(30),
            ),
          ),
          Positioned(
            left: 20,
            right: 76,
            bottom: 18,
            child: Opacity(
              opacity: expandedOpacity,
              child: Transform.translate(
                offset: Offset(0, -10 * t),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(36),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white.withAlpha(64)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppPalette.gold,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            _dateLabel(now),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: .3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _greeting(now),
                      style: TextStyle(
                        color: Colors.white.withAlpha(200),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: .3,
                      ),
                    ),
                    const SizedBox(height: 1),
                    const Text(
                      "Smart Farm Sheba",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 76,
            top: topPadding,
            height: 64,
            child: Opacity(
              opacity: collapsedOpacity,
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppPalette.gold,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.agriculture_rounded,
                      size: 20,
                      color: Color(0xFF062F23),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "Smart Farm Sheba",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 20,
            top: topPadding + 10,
            child: _ProfileButton(onTap: onProfileTap),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _HeaderDelegate oldDelegate) {
    return oldDelegate.topPadding != topPadding;
  }
}

class _ProfileButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ProfileButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: "Profile",
      child: Material(
        color: Colors.white.withAlpha(40),
        shape: CircleBorder(
          side: BorderSide(color: Colors.white.withAlpha(90), width: 1.2),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: const SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final double size;
  final Color color;

  const _Bubble({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

class _Reveal extends StatelessWidget {
  final Animation<double> animation;
  final int index;
  final Widget child;

  const _Reveal({
    required this.animation,
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final start = (index * 0.07).clamp(0.0, 0.6);
    final end = (start + 0.4).clamp(0.0, 1.0);
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, .08),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: AppPalette.gold,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppPalette.ink,
                    letterSpacing: .1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: AppPalette.muted,
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

class _FeaturedCarousel extends StatefulWidget {
  final List<DashboardItem> items;

  const _FeaturedCarousel({required this.items});

  @override
  State<_FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<_FeaturedCarousel> {
  static const Duration _interval = Duration(seconds: 3);

  late final PageController _pageController;
  late int _page;
  Timer? _timer;

  int get _count => widget.items.length;
  int get _activeIndex => _page % _count;

  @override
  void initState() {
    super.initState();
    _page = _count * 1000;
    _pageController = PageController(
      viewportFraction: .92,
      initialPage: _page,
    );
    _startAutoPlay();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _timer?.cancel();
    _timer = Timer.periodic(_interval, (_) {
      if (!mounted || !_pageController.hasClients) return;
      _pageController.animateToPage(
        _page + 1,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.depth != 0) return false;
    if (notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      _timer?.cancel();
    } else if (notification is ScrollEndNotification) {
      _startAutoPlay();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 176,
              child: NotificationListener<ScrollNotification>(
                onNotification: _onScroll,
                child: PageView.builder(
                  controller: _pageController,
                  clipBehavior: Clip.none,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (value) => setState(() => _page = value),
                  itemBuilder: (context, i) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 8,
                      ),
                      child: _FeaturedCard(item: widget.items[i % _count]),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_count, (i) {
                final active = i == _activeIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 22 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: active
                        ? AppPalette.emerald
                        : AppPalette.emerald.withAlpha(50),
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final DashboardItem item;

  const _FeaturedCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(26);
    final accent = item.gradient.first;

    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: item.gradient,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withAlpha(80),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: item.onTap,
          splashColor: Colors.white.withAlpha(40),
          highlightColor: Colors.transparent,
          child: Stack(
            children: [
              Positioned(
                right: -34,
                top: -34,
                child: _Bubble(size: 150, color: Colors.white.withAlpha(30)),
              ),
              Positioned(
                right: 40,
                bottom: -56,
                child: _Bubble(size: 120, color: Colors.white.withAlpha(22)),
              ),
              Positioned(
                right: 24,
                top: 24,
                child: Icon(
                  item.icon,
                  size: 62,
                  color: Colors.white.withAlpha(235),
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 96, 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withAlpha(225),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.actionLabel,
                              style: TextStyle(
                                color: accent,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: accent,
                            ),
                          ],
                        ),
                      ),
                    ],
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

class DashboardCard extends StatefulWidget {
  final DashboardItem item;

  const DashboardCard({super.key, required this.item});

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final radius = BorderRadius.circular(22);

    return AnimatedScale(
      scale: _pressed ? .97 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 22,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.white,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: item.onTap,
            onHighlightChanged: (value) => setState(() => _pressed = value),
            splashColor: item.gradient.first.withAlpha(30),
            highlightColor: Colors.transparent,
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: radius,
                border: Border.all(color: AppPalette.border),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    item.gradient.first.withAlpha(28),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -26,
                    bottom: -26,
                    child: _Bubble(
                      size: 100,
                      color: item.gradient.last.withAlpha(26),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: item.gradient,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: item.gradient.last.withAlpha(90),
                                    blurRadius: 14,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Icon(
                                item.icon,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: item.gradient.first.withAlpha(26),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.north_east_rounded,
                                size: 16,
                                color: item.gradient.first,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppPalette.ink,
                            letterSpacing: .1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            height: 1.3,
                            color: AppPalette.muted,
                            fontWeight: FontWeight.w500,
                          ),
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
}
