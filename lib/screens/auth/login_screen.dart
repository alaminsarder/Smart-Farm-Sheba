import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:smart_farm_sheba/services/email_service.dart';
import 'package:smart_farm_sheba/services/google_auth_service.dart';
import 'package:smart_farm_sheba/features/home/presentation/home_screen.dart';
import 'package:smart_farm_sheba/screens/auth/auth_widgets.dart';
import 'package:smart_farm_sheba/screens/auth/forgot_password_screen.dart';
import 'package:smart_farm_sheba/screens/auth/register_screen.dart';

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
  bool _loading = false;
  bool _loadingGoogle = false;

  final _emailRegex = RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$");

  @override
  void dispose() {
    _emailC.dispose();
    _passC.dispose();
    super.dispose();
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    showAuthSnack(context, msg, error: error);
  }

  String _firebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return "No account found with this email.";
      case 'wrong-password':
      case 'invalid-credential':
        return "Wrong email or password.";
      case 'invalid-email':
        return "Invalid email address.";
      case 'user-disabled':
        return "This account has been disabled.";
      case 'too-many-requests':
        return "Too many attempts. Please try again later.";
      case 'network-request-failed':
        return "Network error. Check your connection.";
      default:
        return e.message ?? "Authentication error.";
    }
  }

  void _goHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  void _sendLoginMail() {
    final current = FirebaseAuth.instance.currentUser;
    if (current == null) return;
    final email = current.email;
    if (email == null || email.isEmpty) return;

    final name = (current.displayName ?? '').trim();
    EmailService.sendLoginAlert(
      toEmail: email,
      toName: name.isEmpty ? email.split('@').first : name,
    );
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailC.text.trim(),
        password: _passC.text,
      );

      _sendLoginMail();

      if (!mounted) return;
      setState(() => _loading = false);
      _goHome();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _snack(_firebaseError(e), error: true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _snack("Unexpected error: $e", error: true);
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
        _goHome();
      } else {
        _snack("Google sign in cancelled");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingGoogle = false);
      _snack("Google sign in failed: $e", error: true);
    }
  }

  Widget _form(bool busy) {
    return AutofillGroup(
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AuthHeading(
              title: 'Welcome back',
              subtitle: 'Log in to continue managing your farm.',
            ),
            const SizedBox(height: 26),
            TextFormField(
              controller: _emailC,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              decoration: authDecoration('Email', icon: Icons.mail_rounded),
              validator: (v) {
                final s = (v ?? '').trim();
                if (s.isEmpty) return "Email required";
                if (!_emailRegex.hasMatch(s)) return "Enter valid email";
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passC,
              obscureText: _obscure,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onFieldSubmitted: (_) {
                if (!busy) _login();
              },
              decoration: authDecoration(
                'Password',
                icon: Icons.lock_rounded,
                suffix: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    size: 20,
                    color: AuthPalette.muted,
                  ),
                ),
              ),
              validator: (v) {
                final s = v ?? '';
                if (s.isEmpty) return "Password required";
                if (s.length < 6) return "Minimum 6 characters";
                return null;
              },
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: busy
                    ? null
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen(),
                          ),
                        ),
                style: TextButton.styleFrom(
                  foregroundColor: AuthPalette.emerald,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            AuthPrimaryButton(
              label: 'Log in',
              loading: _loading,
              onTap: busy ? null : _login,
            ),
            const SizedBox(height: 22),
            const AuthDivider(text: 'or continue with'),
            const SizedBox(height: 18),
            Center(
              child: SizedBox(
                width: 190,
                height: 44,
                child: AuthSocialButton(
                  icon: _loadingGoogle
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(
                          Icons.g_mobiledata_rounded,
                          size: 24,
                          color: Color(0xFFDB4437),
                        ),
                  label: 'Google',
                  onTap: busy ? null : _loginWithGoogle,
                ),
              ),
            ),
            const SizedBox(height: 22),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    "Don't have an account?",
                    style: TextStyle(color: AuthPalette.muted, fontSize: 13.5),
                  ),
                  TextButton(
                    onPressed: busy
                        ? null
                        : () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            ),
                    style: TextButton.styleFrom(
                      foregroundColor: AuthPalette.emerald,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final busy = _loading || _loadingGoogle;
    final isWide = MediaQuery.of(context).size.width >= 860;

    return Scaffold(
      backgroundColor: AuthPalette.deep,
      body: AuthBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isWide ? 960 : 460),
              child: isWide
                  ? AuthSplitCard(form: _form(busy))
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const AuthBrand(),
                        const SizedBox(height: 26),
                        AuthCard(child: _form(busy)),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
