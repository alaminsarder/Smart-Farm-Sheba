import 'package:flutter/material.dart';
import '../expense/expense_screen.dart';
import '../profile/profile_screen.dart';
import '../weather/weather_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void navigate(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [

            // ✅ Header with Profile Icon
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1B5E20),
                    Color(0xFF43A047),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(35),
                  bottomRight: Radius.circular(35),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Smart Farm Sheba 🌾",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
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
                  InkWell(
                    onTap: () {
                      navigate(context, const ProfileScreen());
                    },
                    child: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person,
                          color: Colors.green),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  children: [

                    PremiumCard(
                      title: "Weather",
                      icon: Icons.cloud,
                      onTap: () =>
                          navigate(context, const WeatherScreen()),
                    ),

                    PremiumCard(
                      title: "Expense",
                      icon: Icons.calculate,
                      onTap: () =>
                          navigate(context, const ExpenseScreen()),
                    ),

                    const PremiumCard(
                      title: "Crop Suggestion",
                      icon: Icons.grass,
                    ),

                    const PremiumCard(
                      title: "Market Price",
                      icon: Icons.attach_money,
                    ),

                    const PremiumCard(
                      title: "Tips",
                      icon: Icons.lightbulb,
                    ),

                    const PremiumCard(
                      title: "Notes",
                      icon: Icons.note,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PremiumCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const PremiumCard({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 32,
                  color: Colors.green),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}