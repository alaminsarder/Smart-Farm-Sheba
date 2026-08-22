import 'package:flutter/material.dart';
import 'package:smart_farm_sheba/core/screens/feature_placeholder_screen.dart';

class IrrigationScreen extends StatelessWidget {
  const IrrigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderScreen(
      title: "Irrigation",
      icon: Icons.water_drop_rounded,
    );
  }
}
