import 'package:flutter/material.dart';
import 'package:smart_farm_sheba/core/screens/feature_placeholder_screen.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderScreen(
      title: "Notes",
      icon: Icons.note_alt_rounded,
    );
  }
}
