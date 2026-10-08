import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// ✅ absolute imports used to prevent path breaking
import 'package:smart_farm_sheba/services/google_auth_service.dart';
import 'package:smart_farm_sheba/features/home/presentation/home_screen.dart';
import 'package:smart_farm_sheba/screens/auth/register_screen.dart';

// ✅ ADD THIS
import 'package:smart_farm_sheba/screens/auth/phone_login_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailC = TextEditingController();
  final _passC = TextEditingController();

  bool _obscure = true;
  bool _loadingEmail = false;
  bool _loadingGoogle = false;

  final _emailRegex = RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$");

  @override
  void dispose() {
    _emailC.dispose();
    _passC.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(14),
      ),
    );
  }

  String _firebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return "ইমেইল ঠিক নেই";
      case 'user-not-found':
        return "এই ইমেইলে কোনো অ্যাকাউন্ট নেই";
      case 'wrong-password':
        return "পাসওয়ার্ড ভুল";
      case 'invalid-credential':
        return "ইমেইল/পাসওয়ার্ড ভুল";
      case 'too-many-requests':
        return "অনেকবার চেষ্টা করা হয়েছে, পরে আবার চেষ্টা করুন";
      default:
        return e.message ?? "লগইন করা যায়নি";
    }
  }

  Future<void> _loginWithEmail() async {
    FocusScope.of(context).unfocus();

    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    setState(() => _loadingEmail = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailC.text.trim(),
        password: _passC.text.trim(),
      );

      if (!mounted) return;
      setState(() => _loadingEmail = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _loadingEmail = false);
      _snack("Login failed: ${_firebaseError(e)}");
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingEmail = false);
      _snack("Unexpected error: $e");
    }
  }

  Future<void> _loginWithGoogle() async {
    FocusScope.of(context).unfocus();

    setState(() => _loadingGoogle = true);
    try {
      final user = await GoogleAuthService.signInWithGoogle();

      if (!mounted) return;
      setState(() => _loadingGoogle = false);

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        _snack("Google login cancelled");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingGoogle = false);
      _snack("Google login failed: $e");
    }
  }

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF2E7D32)),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF6F8F6),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.black.withOpacity(.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.black.withOpacity(.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final busy = _loadingEmail || _loadingGoogle;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F5E9), Color(0xFFF5F7FA)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Branding / logo section
                    Column(
                      children: [
                        Container(
                          width: 78,
                          height: 78,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF43A047).withOpacity(.35),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.agriculture_rounded,
                            color: Colors.white,
                            size: 38,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Smart Farm Sheba",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1B5E20),
                            letterSpacing: .2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "আপনার ডিজিটাল কৃষি সহকারী",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black.withOpacity(.55),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Card
                    Container(
                      padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.06),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              "Welcome back 👋",
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Login to continue using your account",
                              style: TextStyle(
                                fontSize: 13.5,
                                color: Colors.black.withOpacity(.55),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 22),

                            // Email
                            TextFormField(
                              controller: _emailC,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: _fieldDecoration(
                                label: "Email",
                                icon: Icons.email_rounded,
                              ),
                              validator: (v) {
                                final s = (v ?? '').trim();
                                if (s.isEmpty) return "Email required";
                                if (!_emailRegex.hasMatch(s)) {
                                  return "Enter a valid email";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // Password
                            TextFormField(
                              controller: _passC,
                              obscureText: _obscure,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) =>
                                  busy ? null : _loginWithEmail(),
                              decoration: _fieldDecoration(
                                label: "Password",
                                icon: Icons.lock_rounded,
                                suffix: IconButton(
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                    color: Colors.black45,
                                  ),
                                ),
                              ),
                              validator: (v) {
                                final s = (v ?? '');
                                if (s.isEmpty) return "Password required";
                                if (s.length < 6) return "Minimum 6 characters";
                                return null;
                              },
                            ),

                            const SizedBox(height: 22),

                            // Email login button
                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: busy ? null : _loginWithEmail,
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ).copyWith(
                                  elevation: WidgetStateProperty.all(0),
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF1B5E20),
                                        Color(0xFF43A047),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: _loadingEmail
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: const [
                                              Icon(Icons.login_rounded,
                                                  color: Colors.white),
                                              SizedBox(width: 8),
                                              Text(
                                                "Login with Email",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            // Divider
                            Row(
                              children: [
                                Expanded(
                                    child: Divider(
                                        color: Colors.black.withOpacity(.1))),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text(
                                    "or continue with",
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: Colors.black.withOpacity(.45),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                    child: Divider(
                                        color: Colors.black.withOpacity(.1))),
                              ],
                            ),

                            const SizedBox(height: 18),

                            // Google login
                            SizedBox(
                              height: 52,
                              child: OutlinedButton.icon(
                                onPressed: busy ? null : _loginWithGoogle,
                                icon: _loadingGoogle
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : const Icon(Icons.g_mobiledata_rounded,
                                        size: 28, color: Colors.redAccent),
                                label: Text(
                                  _loadingGoogle
                                      ? "Please wait..."
                                      : "Continue with Google",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                      color: Colors.black.withOpacity(.15)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Phone login
                            SizedBox(
                              height: 52,
                              child: OutlinedButton.icon(
                                onPressed: busy
                                    ? null
                                    : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const PhoneLoginScreen(),
                                          ),
                                        );
                                      },
                                icon: const Icon(Icons.phone_rounded,
                                    color: Color(0xFF2E7D32)),
                                label: const Text(
                                  "Login with Phone",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                      color: Colors.black.withOpacity(.15)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "No account? ",
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(.6),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextButton(
                                  onPressed: busy
                                      ? null
                                      : () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const RegisterScreen(),
                                            ),
                                          );
                                        },
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFF1B5E20),
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    "Create New Account",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * .02),
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
