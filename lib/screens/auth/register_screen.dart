import 'package:flutter/material.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static String? userName;
  static String? userPhone;
  static String? userZila;
  static String? userPassword;

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final zilaController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void register() {
    if (_formKey.currentState!.validate()) {
      RegisterScreen.userName = nameController.text;
      RegisterScreen.userPhone = phoneController.text;
      RegisterScreen.userZila = zilaController.text;
      RegisterScreen.userPassword = passwordController.text;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 25),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text(
                      "Create Account",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 25),

                    TextFormField(
                      controller: nameController,
                      decoration:
                          const InputDecoration(labelText: "Full Name"),
                      validator: (value) =>
                          value!.isEmpty ? "Name required" : null,
                    ),
                    const SizedBox(height: 15),

                    TextFormField(
                      controller: phoneController,
                      decoration:
                          const InputDecoration(labelText: "Phone Number"),
                      validator: (value) =>
                          value!.length < 11
                              ? "Enter valid phone"
                              : null,
                    ),
                    const SizedBox(height: 15),

                    TextFormField(
                      controller: zilaController,
                      decoration:
                          const InputDecoration(labelText: "Zila"),
                      validator: (value) =>
                          value!.isEmpty ? "Zila required" : null,
                    ),
                    const SizedBox(height: 15),

                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration:
                          const InputDecoration(labelText: "Password"),
                      validator: (value) =>
                          value!.length < 4
                              ? "Minimum 4 characters"
                              : null,
                    ),
                    const SizedBox(height: 15),

                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: "Confirm Password"),
                      validator: (value) =>
                          value != passwordController.text
                              ? "Password not match"
                              : null,
                    ),
                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: register,
                        child: const Text("Submit"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}