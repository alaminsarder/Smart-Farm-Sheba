import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:smart_farm_sheba/screens/auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid);
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  String _initials(String nameOrEmail) {
    final s = nameOrEmail.trim();
    if (s.isEmpty) return "F";
    final parts = s.split(RegExp(r"\s+"));
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts[0].characters.first + parts[1].characters.first)
        .toUpperCase();
  }

  String _roleLabel(String role) {
    final r = role.trim().toLowerCase();
    if (r.isEmpty) return "Farmer";
    return "${r.characters.first.toUpperCase()}${r.substring(1)}";
  }

  String _prettyWhen(Timestamp? ts) {
    if (ts == null) return "-";
    final dt = ts.toDate();
    // small, readable (no intl dependency needed)
    final two = (int n) => n.toString().padLeft(2, '0');
    return "${dt.year}-${two(dt.month)}-${two(dt.day)}  ${two(dt.hour)}:${two(dt.minute)}";
  }

  Future<void> _openEditSheet(
    BuildContext context, {
    required String uid,
    required Map<String, dynamic> data,
    required String email,
  }) async {
    final formKey = GlobalKey<FormState>();

    final nameC = TextEditingController(text: (data['name'] ?? '').toString());
    final phoneC =
        TextEditingController(text: (data['phone'] ?? '').toString());
    final zilaC = TextEditingController(text: (data['zila'] ?? '').toString());

    bool saving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;

        InputDecoration deco(String label, IconData icon) => InputDecoration(
              labelText: label,
              prefixIcon: Icon(icon),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            );

        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            Future<void> save() async {
              if (!(formKey.currentState?.validate() ?? false)) return;

              setSheetState(() => saving = true);
              try {
                await _userDoc(uid).set(
                  {
                    'uid': uid,
                    'name': nameC.text.trim(),
                    'phone': phoneC.text.trim(),
                    'zila': zilaC.text.trim(),
                    'email': email,
                    'updatedAt': FieldValue.serverTimestamp(),
                  },
                  SetOptions(merge: true),
                );

                if (ctx.mounted) Navigator.pop(ctx);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Profile updated")),
                  );
                }
              } catch (e) {
                setSheetState(() => saving = false);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Update failed: $e")),
                  );
                }
              }
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 6,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.edit_rounded),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              "Edit Profile",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w900),
                            ),
                          ),
                          if (saving)
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: nameC,
                        textInputAction: TextInputAction.next,
                        decoration: deco("Full Name", Icons.person_rounded),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? "Name required"
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: phoneC,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        decoration: deco("Phone", Icons.phone_rounded),
                        validator: (v) {
                          final s = (v ?? '').trim();
                          if (s.isEmpty) return "Phone required";
                          // Bangladesh সাধারণ ফরম্যাট: 01XXXXXXXXX (11 digits)
                          if (s.length != 11 || !s.startsWith("01")) {
                            return "Enter valid phone (01XXXXXXXXX)";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: zilaC,
                        textInputAction: TextInputAction.done,
                        decoration: deco("Zila", Icons.location_on_rounded),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? "Zila required"
                            : null,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed:
                                  saving ? null : () => Navigator.pop(ctx),
                              child: const Text("Cancel"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: saving ? null : save,
                              icon: const Icon(Icons.save_rounded),
                              label: const Text("Save"),
                              style: FilledButton.styleFrom(
                                backgroundColor: cs.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    nameC.dispose();
    phoneC.dispose();
    zilaC.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const LoginScreen();

    final uid = user.uid;
    final email = user.email ?? "";
    final photoUrl = user.photoURL;

    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? cs.surface : const Color(0xFFF5F7FA);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _userDoc(uid).snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() ?? {};

        final name = (data['name'] ?? '').toString();
        final phone = (data['phone'] ?? '').toString();
        final zila = (data['zila'] ?? '').toString();
        final role = _roleLabel((data['role'] ?? 'farmer').toString());

        final updatedAt = data['updatedAt'] is Timestamp
            ? data['updatedAt'] as Timestamp
            : null;

        final title =
            name.isNotEmpty ? name : (email.isNotEmpty ? email : "Farmer");
        final initials = _initials(title);

        return Scaffold(
          backgroundColor: bg,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                elevation: 0,
                backgroundColor: bg,
                expandedHeight: 250,
                automaticallyImplyLeading: false,
                leading: IconButton(
                  tooltip: "Back",
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    tooltip: "Edit",
                    onPressed: () => _openEditSheet(
                      context,
                      uid: uid,
                      data: data,
                      email: email,
                    ),
                    icon: const Icon(Icons.edit_rounded),
                  ),
                  IconButton(
                    tooltip: "Logout",
                    onPressed: () => _logout(context),
                    icon: const Icon(Icons.logout_rounded),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF1B5E20),
                          const Color(0xFF43A047),
                          const Color(0xFF1B5E20).withOpacity(0.95),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(28),
                        bottomRight: Radius.circular(28),
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),

                            // Top identity row
                            Row(
                              children: [
                                _Avatar(
                                  initials: initials,
                                  photoUrl: photoUrl,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          _Badge(
                                            icon: Icons.verified_user_rounded,
                                            text: role,
                                          ),
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting)
                                            const _Badge(
                                              icon: Icons.sync_rounded,
                                              text: "Syncing...",
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const Spacer(),

                            // Email card
                            _GlassRow(
                              icon: Icons.alternate_email_rounded,
                              label: "Email",
                              value: email.isEmpty ? "Email not found" : email,
                            ),
                            const SizedBox(height: 10),

                            // Last update small line
                            Text(
                              "Last update: ${_prettyWhen(updatedAt)}",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      _SectionTitle(title: "Profile details"),
                      const SizedBox(height: 10),
                      _InfoCard(
                        icon: Icons.phone_rounded,
                        title: "Phone",
                        value: phone.isEmpty ? "-" : phone,
                      ),
                      const SizedBox(height: 12),
                      _InfoCard(
                        icon: Icons.location_on_rounded,
                        title: "Zila",
                        value: zila.isEmpty ? "-" : zila,
                      ),
                      const SizedBox(height: 12),
                      _InfoCard(
                        icon: Icons.key_rounded,
                        title: "User ID",
                        value: uid.length > 10
                            ? "${uid.substring(0, 10)}..."
                            : uid,
                      ),
                      const SizedBox(height: 18),
                      _SectionTitle(title: "Actions"),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 48,
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => _openEditSheet(
                            context,
                            uid: uid,
                            data: data,
                            email: email,
                          ),
                          icon: const Icon(Icons.edit_rounded),
                          label: const Text("Edit Profile"),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF1B5E20),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 48,
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _logout(context),
                          icon: const Icon(Icons.logout_rounded),
                          label: const Text("Logout"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ───────────────────────── UI bits ─────────────────────────

class _Avatar extends StatelessWidget {
  final String initials;
  final String? photoUrl;

  const _Avatar({required this.initials, required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(.16),
        border: Border.all(color: Colors.white.withOpacity(.30)),
      ),
      child: ClipOval(
        child: ColoredBox(
          color: Colors.white,
          child: photoUrl == null || photoUrl!.trim().isEmpty
              ? Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                )
              : Image.network(
                  photoUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Badge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _GlassRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(.22)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Text(
            "$label:",
            style: TextStyle(
              color: Colors.white.withOpacity(.85),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(.75);
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        letterSpacing: .8,
        fontWeight: FontWeight.w900,
        color: c,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cs.primaryContainer.withOpacity(.55),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: cs.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withOpacity(.7),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
