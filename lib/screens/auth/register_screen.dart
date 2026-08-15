import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final zilaController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _loading = false;

  // ✅ Firebase Register
  void register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);
      try {
        // ✅ Create user in Firebase Auth
        final userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // ✅ Save profile info in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'uid': userCredential.user!.uid,
          'name': nameController.text.trim(),
          'phone': phoneController.text.trim(),
          'email': emailController.text.trim(),
          'zila': zilaController.text.trim(),
          'role': 'farmer',
          'createdAt': DateTime.now(),
        });

        setState(() => _loading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account created successfully")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } on FirebaseAuthException catch (e) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.message}")),
        );
      } catch (e) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Unexpected error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6EC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 25),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // 🌾 Header
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_add_alt_1,
                        size: 50,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Create Farmer Account",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    _input(nameController, "Full Name", Icons.person,
                        (v) => v!.isEmpty ? "Name required" : null),
                    const SizedBox(height: 12),

                    _input(phoneController, "Phone Number", Icons.phone,
                        (v) => v!.length < 11 ? "Enter valid phone" : null),
                    const SizedBox(height: 12),

                    _input(emailController, "Email", Icons.email,
                        (v) => v!.isEmpty ? "Email required" : null),
                    const SizedBox(height: 12),

                    _input(zilaController, "Zila", Icons.location_on,
                        (v) => v!.isEmpty ? "Zila required" : null),
                    const SizedBox(height: 12),

                    _passwordField(
                      controller: passwordController,
                      hint: "Password",
                      obscure: _obscurePassword,
                      toggle: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                      validator: (v) =>
                          v!.length < 4 ? "Minimum 4 chars" : null,
                    ),
                    const SizedBox(height: 12),

                    _passwordField(
                      controller: confirmPasswordController,
                      hint: "Confirm Password",
                      obscure: _obscureConfirmPassword,
                      toggle: () {
                        setState(() =>
                            _obscureConfirmPassword = !_obscureConfirmPassword);
                      },
                      validator: (v) => v != passwordController.text
                          ? "Password does not match"
                          : null,
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _loading ? null : register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: _loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Register",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),

                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Back to Login"),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(TextEditingController c, String hint, IconData icon,
      String? Function(String?) validator) {
    return TextFormField(
      controller: c,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback toggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: toggle,
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
