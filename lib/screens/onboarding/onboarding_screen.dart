import 'package:flutter/material.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentPage = 0;

  final List<Map<String, dynamic>> pages = [
    {
      "icon": Icons.agriculture,
      "title": "Smart Farming",
      "desc": "Manage your farm digitally with modern tools.",
    },
    {
      "icon": Icons.calculate,
      "title": "Cost & Profit Tracker",
      "desc": "Track your expenses, income and net profit easily.",
    },
    {
      "icon": Icons.smart_toy,
      "title": "AI Farming Assistant",
      "desc": "Get instant farming advice with AI chatbot.",
    },
  ];

  void nextPage() {
    if (currentPage == pages.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6EC),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            page['icon'],
                            size: 80,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          page['title'],
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          page['desc'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ✅ Indicator dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: currentPage == index ? 25 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: currentPage == index
                        ? Colors.green
                        : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Next / Get Started Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: nextPage,
                  child: Text(
                    currentPage == pages.length - 1 ? "Get Started" : "Next",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
