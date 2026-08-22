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
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Future<void> _openEditSheet(
    BuildContext context, {
    required String uid,
    required Map<String, dynamic> data,
    required String email,
  }) async {
    final formKey = GlobalKey<FormState>();

    final nameC =
        TextEditingController(text: (data['name'] ?? '') as String? ?? '');
    final phoneC =
        TextEditingController(text: (data['phone'] ?? '') as String? ?? '');
    final zilaC =
        TextEditingController(text: (data['zila'] ?? '') as String? ?? '');

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
            Future<void> save() async {
              if (!formKey.currentState!.validate()) return;

              setSheetState(() => saving = true);
              try {
                await _userDoc(uid).set({
                  'uid': uid,
                  'name': nameC.text.trim(),
                  'phone': phoneC.text.trim(),
                  'zila': zilaC.text.trim(),
                  'email': email,
                  'updatedAt': FieldValue.serverTimestamp(),
                }, SetOptions(merge: true));

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

            return Padding(
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
                    const Text(
                      "Edit Profile",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: nameC,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: "Full Name",
                        prefixIcon: Icon(Icons.person_rounded),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? "Name required"
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: phoneC,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: "Phone",
                        prefixIcon: Icon(Icons.phone_rounded),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        final s = (v ?? '').trim();
                        if (s.isEmpty) return "Phone required";
                        if (s.length < 11) return "Enter valid phone";
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: zilaC,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: "Zila",
                        prefixIcon: Icon(Icons.location_on_rounded),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? "Zila required"
                          : null,
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
                        label: Text(saving ? "Saving..." : "Save Changes"),
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

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _userDoc(uid).snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() ?? {};
        final name = (data['name'] ?? '') as String? ?? '';
        final phone = (data['phone'] ?? '') as String? ?? '';
        final zila = (data['zila'] ?? '') as String? ?? '';
        final role = (data['role'] ?? 'farmer') as String? ?? 'farmer';

        final title =
            name.isNotEmpty ? name : (email.isNotEmpty ? email : "Farmer");
        final initials = _initials(title);

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                elevation: 0,
                backgroundColor: const Color(0xFFF5F7FA),
                expandedHeight: 220,
                automaticallyImplyLeading: false,
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
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 32,
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    initials,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                      color: Color(0xFF1B5E20),
                                    ),
                                  ),
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
                                      const SizedBox(height: 4),
                                      Text(
                                        role,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(.14),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(.22),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.verified_user_rounded,
                                      color: Colors.white, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      email.isEmpty ? "Email not found" : email,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
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
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
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
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 48,
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _openEditSheet(
                            context,
                            uid: uid,
                            data: data,
                            email: email,
                          ),
                          icon: const Icon(Icons.edit_rounded),
                          label: const Text("Edit Profile"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
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
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
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
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.green),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF5B6876),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0B1220),
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
