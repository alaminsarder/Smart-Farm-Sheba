import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_farm_sheba/screens/auth/login_screen.dart';

class _Pal {
  static const bg = Color(0xFFF4F6F8);
  static const ink = Color(0xFF0B1220);
  static const muted = Color(0xFF5B6876);
  static const border = Color(0xFFE9EEF3);
  static const gold = Color(0xFFE9C46A);
  static const goldLight = Color(0xFFF6E3A8);
  static const emerald = Color(0xFF0E5C3A);
  static const deep = Color(0xFF062F23);
  static const danger = Color(0xFFC62828);
  static const headerGradient = [
    Color(0xFF062F23),
    Color(0xFF0E5C3A),
    Color(0xFF2A8A4A),
  ];
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  DocumentReference _userDoc(String uid) =>
      FirebaseFirestore.instance.collection('users').doc(uid);

  String _s(Map data, String key) => (data[key] ?? '').toString().trim();

  String _formatDate(dynamic value) {
    if (value is! Timestamp) return '';
    final d = value.toDate();
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
      'Dec'
    ];
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${months[d.month - 1]} ${d.year}, $h:$m';
  }

  Future<void> _openEdit(
    BuildContext context, {
    required String uid,
    required String email,
    required String name,
    required String phone,
    required String zila,
  }) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileSheet(
        uid: uid,
        email: email,
        name: name,
        phone: phone,
        zila: zila,
      ),
    );
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: _Pal.emerald,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: const Text('Profile updated successfully'),
        ),
      );
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Log out?',
          style: TextStyle(fontWeight: FontWeight.w800, color: _Pal.ink),
        ),
        content: const Text(
          'You will need to sign in again to access your farm data.',
          style: TextStyle(color: _Pal.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _Pal.danger),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await _logout(context);
    }
  }

  Future<void> _logout(BuildContext context) async {
    final nav = Navigator.of(context);
    await FirebaseAuth.instance.signOut();
    nav.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not signed in')));
    }
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: _Pal.bg,
      body: StreamBuilder(
        stream: _userDoc(user.uid).snapshots(),
        builder: (context, snapshot) {
          final raw = snapshot.data?.data();
          final Map data = raw is Map ? raw : {};
          final syncing = snapshot.connectionState == ConnectionState.waiting;

          final name = _s(data, 'name');
          final phone = _s(data, 'phone');
          final zila = _s(data, 'zila');
          final role = _s(data, 'role').isEmpty ? 'Farmer' : _s(data, 'role');
          final email = (user.email ?? _s(data, 'email'));
          final displayName = name.isNotEmpty
              ? name
              : ((user.displayName ?? '').isNotEmpty
                  ? user.displayName!
                  : 'Farmer');

          final missing = <String>[];
          if (name.isEmpty) missing.add('name');
          if (phone.isEmpty) missing.add('phone');
          if (zila.isEmpty) missing.add('zila');
          const steps = [100, 67, 33, 0];
          final percent = steps[missing.length];

          void edit() => _openEdit(
                context,
                uid: user.uid,
                email: email,
                name: name,
                phone: phone,
                zila: zila,
              );

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _ProfileHeader(
                  topPad: topPad,
                  name: displayName,
                  email: email,
                  role: role,
                  zila: zila,
                  syncing: syncing,
                  onBack: () => Navigator.of(context).maybePop(),
                  onEdit: edit,
                ),
              ),
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
                      child: Column(
                        children: [
                          _FadeIn(
                            index: 0,
                            child: _CompletionCard(
                              percent: percent,
                              missing: missing,
                              onTap: edit,
                            ),
                          ),
                          const SizedBox(height: 18),
                          _FadeIn(
                            index: 1,
                            child: _Group(
                              title: 'Contact',
                              children: [
                                _DetailTile(
                                  icon: Icons.phone_rounded,
                                  label: 'Phone',
                                  value: phone,
                                ),
                                _DetailTile(
                                  icon: Icons.mail_rounded,
                                  label: 'Email',
                                  value: email,
                                ),
                                _DetailTile(
                                  icon: Icons.location_on_rounded,
                                  label: 'Zila',
                                  value: zila,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          _FadeIn(
                            index: 2,
                            child: _Group(
                              title: 'Account',
                              children: [
                                _DetailTile(
                                  icon: Icons.verified_user_rounded,
                                  label: 'Role',
                                  value: role,
                                ),
                                _DetailTile(
                                  icon: Icons.fingerprint_rounded,
                                  label: 'User ID',
                                  value: user.uid.length > 14
                                      ? '${user.uid.substring(0, 14)}…'
                                      : user.uid,
                                  trailing: IconButton(
                                    tooltip: 'Copy',
                                    icon: const Icon(
                                      Icons.copy_rounded,
                                      size: 20,
                                      color: _Pal.muted,
                                    ),
                                    onPressed: () {
                                      Clipboard.setData(
                                        ClipboardData(text: user.uid),
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          behavior: SnackBarBehavior.floating,
                                          duration: const Duration(seconds: 1),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          content: const Text('User ID copied'),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                _DetailTile(
                                  icon: Icons.update_rounded,
                                  label: 'Last update',
                                  value: _formatDate(data['updatedAt']),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),
                          _FadeIn(
                            index: 3,
                            child: _GradientButton(
                              label: 'Edit Profile',
                              icon: Icons.edit_rounded,
                              onTap: edit,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _FadeIn(
                            index: 4,
                            child: SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _Pal.danger,
                                  side: BorderSide(
                                    color: _Pal.danger.withAlpha(90),
                                    width: 1.4,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () => _confirmLogout(context),
                                icon: const Icon(Icons.logout_rounded),
                                label: const Text(
                                  'Log out',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 26),
                          const _Footer(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends SliverPersistentHeaderDelegate {
  _ProfileHeader({
    required this.topPad,
    required this.name,
    required this.email,
    required this.role,
    required this.zila,
    required this.syncing,
    required this.onBack,
    required this.onEdit,
  });

  final double topPad;
  final String name;
  final String email;
  final String role;
  final String zila;
  final bool syncing;
  final VoidCallback onBack;
  final VoidCallback onEdit;

  static const double _collapsedBar = 64;
  static const double _expandedBody = 300;

  @override
  double get minExtent => topPad + _collapsedBar;

  @override
  double get maxExtent => topPad + _expandedBody;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final range = maxExtent - minExtent;
    final t = (shrinkOffset / range).clamp(0.0, 1.0).toDouble();
    final expandedOpacity = (1 - t * 1.8).clamp(0.0, 1.0).toDouble();
    final collapsedOpacity = ((t - 0.65) / 0.35).clamp(0.0, 1.0).toDouble();
    final initial = name.trim().isEmpty ? 'F' : name.trim()[0].toUpperCase();

    return ClipRect(
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _Pal.headerGradient,
                ),
              ),
            ),
          ),
          const Positioned(
              right: -50, top: -40, child: _Bubble(size: 190, alpha: 22)),
          const Positioned(
              left: -60, bottom: -30, child: _Bubble(size: 160, alpha: 14)),
          const Positioned(
              right: 70, bottom: 50, child: _Bubble(size: 40, alpha: 18)),
          Positioned(
            left: 0,
            right: 0,
            top: topPad + 52,
            bottom: 0,
            child: IgnorePointer(
              ignoring: expandedOpacity < 0.2,
              child: Opacity(
                opacity: expandedOpacity,
                child: OverflowBox(
                  alignment: Alignment.topCenter,
                  minHeight: 0,
                  maxHeight: 240,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Avatar(size: 92, initial: initial, badge: true),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withAlpha(190),
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _HeaderChip(
                            icon: Icons.agriculture_rounded,
                            label: role,
                          ),
                          if (zila.isNotEmpty)
                            _HeaderChip(
                              icon: Icons.location_on_rounded,
                              label: zila,
                            ),
                          if (syncing)
                            const _HeaderChip(
                              icon: Icons.sync_rounded,
                              label: 'Syncing',
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: topPad,
            height: _collapsedBar,
            child: Row(
              children: [
                const SizedBox(width: 10),
                _RoundIconButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: onBack,
                ),
                Expanded(
                  child: Opacity(
                    opacity: collapsedOpacity,
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _Avatar(size: 34, initial: initial, badge: false),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _RoundIconButton(icon: Icons.edit_rounded, onTap: onEdit),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _ProfileHeader old) =>
      old.topPad != topPad ||
      old.name != name ||
      old.email != email ||
      old.role != role ||
      old.zila != zila ||
      old.syncing != syncing;
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.size, required this.alpha});

  final double size;
  final int alpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withAlpha(alpha),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.size,
    required this.initial,
    required this.badge,
  });

  final double size;
  final String initial;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    final ring = size > 60 ? 3.5 : 2.0;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            padding: EdgeInsets.all(ring),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_Pal.goldLight, _Pal.gold],
              ),
            ),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: _Pal.deep,
              ),
              alignment: Alignment.center,
              child: Text(
                initial,
                style: TextStyle(
                  color: _Pal.gold,
                  fontSize: size * 0.42,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          if (badge)
            Positioned(
              right: -2,
              bottom: 2,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(40),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  size: 20,
                  color: Color(0xFF1DA1F2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(32),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: _Pal.goldLight),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withAlpha(36),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: Colors.white, size: 21),
        ),
      ),
    );
  }
}

class _CompletionCard extends StatelessWidget {
  const _CompletionCard({
    required this.percent,
    required this.missing,
    required this.onTap,
  });

  final int percent;
  final List<String> missing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final done = percent == 100;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _Pal.border),
        boxShadow: [
          BoxShadow(
            color: _Pal.deep.withAlpha(14),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 62,
            height: 62,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 62,
                  height: 62,
                  child: CircularProgressIndicator(
                    value: percent / 100,
                    strokeWidth: 6,
                    strokeCap: StrokeCap.round,
                    backgroundColor: _Pal.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      done ? _Pal.emerald : _Pal.gold,
                    ),
                  ),
                ),
                Text(
                  '$percent%',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: _Pal.ink,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  done ? 'Profile complete' : 'Profile strength',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _Pal.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  done
                      ? 'Great! Your profile has all the details.'
                      : 'Add your ${missing.join(', ')} to finish.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: _Pal.muted,
                    height: 1.35,
                  ),
                ),
                if (!done) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: onTap,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Complete now',
                          style: TextStyle(
                            color: _Pal.emerald,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: _Pal.emerald,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        items.add(
          const Divider(height: 1, indent: 70, color: _Pal.border),
        );
      }
      items.add(children[i]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6, bottom: 10),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w800,
              color: _Pal.muted,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _Pal.border),
            boxShadow: [
              BoxShadow(
                color: _Pal.deep.withAlpha(12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final empty = value.trim().isEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _Pal.emerald.withAlpha(20),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: _Pal.emerald, size: 21),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _Pal.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  empty ? 'Not added yet' : value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: empty ? FontWeight.w500 : FontWeight.w700,
                    fontStyle: empty ? FontStyle.italic : FontStyle.normal,
                    color: empty ? _Pal.muted.withAlpha(150) : _Pal.ink,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(colors: _Pal.headerGradient),
        boxShadow: [
          BoxShadow(
            color: _Pal.emerald.withAlpha(90),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: _Pal.goldLight, size: 20),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FadeIn extends StatelessWidget {
  const _FadeIn({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 420 + index * 110),
      curve: Curves.easeOutCubic,
      builder: (context, v, c) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, (1 - v) * 20),
          child: c,
        ),
      ),
      child: child,
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: _Pal.emerald.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.eco_rounded, color: _Pal.emerald, size: 20),
        ),
        const SizedBox(height: 8),
        const Text(
          'Smart Farm Sheba',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: _Pal.ink,
            fontSize: 13.5,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Grow smarter, every season',
          style: TextStyle(color: _Pal.muted, fontSize: 12),
        ),
      ],
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    required this.zila,
  });

  final String uid;
  final String email;
  final String name;
  final String phone;
  final String zila;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _zila;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.name);
    _phone = TextEditingController(text: widget.phone);
    _zila = TextEditingController(text: widget.zila);
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _zila.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label, IconData icon) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c, width: w),
        );
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: _Pal.emerald, size: 21),
      filled: true,
      fillColor: _Pal.bg,
      border: border(_Pal.border),
      enabledBorder: border(_Pal.border),
      focusedBorder: border(_Pal.emerald, 1.6),
      errorBorder: border(_Pal.danger),
      focusedErrorBorder: border(_Pal.danger, 1.6),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.uid).set(
        {
          'uid': widget.uid,
          'email': widget.email,
          'name': _name.text.trim(),
          'phone': _phone.text.trim(),
          'zila': _zila.text.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: _Pal.danger,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: const Text('Could not save. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: _Pal.border,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _Pal.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Keep your details up to date.',
                        style: TextStyle(color: _Pal.muted, fontSize: 13.5),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _name,
                        enabled: !_loading,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: _dec('Full name', Icons.person_rounded),
                        validator: (v) => (v == null || v.trim().length < 2)
                            ? 'Please enter your name'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _phone,
                        enabled: !_loading,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(11),
                        ],
                        decoration: _dec('Phone', Icons.phone_rounded),
                        validator: (v) {
                          final t = (v ?? '').trim();
                          if (!RegExp(r'^01\d{9}$').hasMatch(t)) {
                            return 'Enter 11 digits starting with 01';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _zila,
                        enabled: !_loading,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.done,
                        decoration: _dec('Zila', Icons.location_on_rounded),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter your zila'
                            : null,
                        onFieldSubmitted: (_) => _save(),
                      ),
                      const SizedBox(height: 22),
                      Container(
                        height: 56,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: _Pal.headerGradient,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: _loading ? null : _save,
                            child: Center(
                              child: _loading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.6,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Save changes',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
