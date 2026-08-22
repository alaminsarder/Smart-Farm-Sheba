import 'package:flutter/material.dart';

class FeaturePlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const FeaturePlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.green),
            const SizedBox(height: 12),
            const Text(
              "ডেভেলপার এখন ব্যস্ত আছে, পরে অ্যাড করবে।",
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontWeight: FontWeight.w700, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
