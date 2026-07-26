import 'package:flutter/material.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void logout() {
    RegisterScreen.userName = null;
    RegisterScreen.userPhone = null;
    RegisterScreen.userZila = null;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = RegisterScreen.userName;
    final phone = RegisterScreen.userPhone;
    final zila = RegisterScreen.userZila;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            onPressed: editProfile,
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: name == null
          ? const Center(child: Text("No user data"))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.person, size: 50),
                  ),
                  const SizedBox(height: 20),
                  Text(name,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text("Phone: $phone"),
                  const SizedBox(height: 5),
                  Text("Zila: $zila"),
                ],
              ),
            ),
    );
  }
}