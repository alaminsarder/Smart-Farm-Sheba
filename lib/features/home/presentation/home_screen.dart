import 'package:flutter/material.dart';

import 'package:smart_farm_sheba/features/dashboard/presentation/dashboard_screen.dart';
import 'package:smart_farm_sheba/features/weather/presentation/weather_screen.dart';
import 'package:smart_farm_sheba/features/expense/presentation/expense_screen.dart';
import 'package:smart_farm_sheba/features/profile/presentation/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final PageStorageBucket _bucket = PageStorageBucket();

  late final List<Widget> _pages = [
    const DashboardScreen(),
    WeatherScreen(), // const না থাকলে safe
    ExpenseScreen(), // const না থাকলে safe
    ProfileScreen(), // const না থাকলে safe
  ];

  void _onDestinationSelected(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: PageStorage(
        bucket: _bucket,
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        indicatorColor: colorScheme.primary.withOpacity(0.12),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.cloud_outlined),
            selectedIcon: Icon(Icons.cloud_rounded),
            label: "Weather",
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate_rounded),
            label: "Expense",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
