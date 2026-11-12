import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:smart_farm_sheba/services/email_service.dart';
import 'package:smart_farm_sheba/services/google_auth_service.dart';
import 'package:smart_farm_sheba/features/home/presentation/home_screen.dart';
import 'package:smart_farm_sheba/screens/auth/auth_widgets.dart';
import 'package:smart_farm_sheba/screens/auth/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstC = TextEditingController();
  final _lastC = TextEditingController();
  final _phoneC = TextEditingController();
  final _emailC = TextEditingController();
  final _zilaC = TextEditingController();
  final _passC = TextEditingController();

  bool _obscure = true;
  bool _agree = true;
  bool _loading = false;
  bool _loadingGoogle = false;

  final _emailRegex = RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$");
  final _phoneRegex = RegExp(r"^01[3-9]\d{8}$");

  @override
  void dispose() {
    _firstC.dispose();
    _lastC.dispose();
    _phoneC.dispose();
    _emailC.dispose();
    _zilaC.dispose();
    _passC.dispose();
    super.dispose();
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    showAuthSnack(context, msg, error: error);
  }

  String _firebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return "This email is already in use.";
      case 'invalid-email':
        return "Invalid email address.";
      case 'weak-password':
        return "Password is too weak (try 6+ characters).";
      case 'operation-not-allowed':
        return "Email/password auth is not enabled.";
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

  Future<void> _register() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_agree) {
      _snack("Please agree to the Terms & Conditions", error: true);
      return;
    }

    setState(() => _loading = true);

    try {
      final auth = FirebaseAuth.instance;
      final fs = FirebaseFirestore.instance;

      final fullName = "${_firstC.text.trim()} ${_lastC.text.trim()}".trim();
      final email = _emailC.text.trim();

      final cred = await auth.createUserWithEmailAndPassword(
        email: email,
        password: _passC.text,
      );

      final user = cred.user!;
      final uid = user.uid;
      await user.updateDisplayName(fullName);

      await fs.collection('users').doc(uid).set({
        'uid': uid,
        'name': fullName,
        'firstName': _firstC.text.trim(),
        'lastName': _lastC.text.trim(),
        'phone': _phoneC.text.trim(),
        'email': email,
        'zila': _zilaC.text.trim(),
        'role': 'farmer',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final sent = await EmailService.sendWelcome(
        toEmail: email,
        toName: fullName,
      );

      if (!mounted) return;
      setState(() => _loading = false);
      _snack(
        sent
            ? "Account created. A welcome email was sent to $email"
            : "Account created successfully.",
      );
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

  Future<void> _registerWithGoogle() async {
    FocusScope.of(context).unfocus();
    setState(() => _loadingGoogle = true);
    try {
      final user = await GoogleAuthService.signInWithGoogle();
      if (!mounted) return;
      setState(() => _loadingGoogle = false);
      if (user != null) {
        _goHome();
      } else {
        _snack("Google sign up cancelled");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingGoogle = false);
      _snack("Google sign up failed: $e", error: true);
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
              title: 'Create account',
              subtitle: 'Join Smart Farm Sheba in less than a minute.',
            ),
            const SizedBox(height: 26),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstC,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    autofillHints: const [AutofillHints.givenName],
                    decoration: authDecoration('First name'),
                    validator: (v) =>
                        (v ?? '').trim().isEmpty ? "Required" : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lastC,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    autofillHints: const [AutofillHints.familyName],
                    decoration: authDecoration('Last name'),
                    validator: (v) =>
                        (v ?? '').trim().isEmpty ? "Required" : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _phoneC,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.telephoneNumber],
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              decoration: authDecoration(
                'Phone (01XXXXXXXXX)',
                icon: Icons.phone_rounded,
              ),
              validator: (v) {
                final s = (v ?? '').trim();
                if (s.isEmpty) return "Phone required";
                if (!_phoneRegex.hasMatch(s)) {
                  return "Enter valid BD phone (e.g. 01XXXXXXXXX)";
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
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
              controller: _zilaC,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration:
                  authDecoration('Zila', icon: Icons.location_on_rounded),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? "Zila required" : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passC,
              obscureText: _obscure,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              onFieldSubmitted: (_) {
                if (!busy) _register();
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
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _agree,
                    onChanged: (v) => setState(() => _agree = v ?? false),
                    activeColor: AuthPalette.emerald,
                    checkColor: Colors.white,
                    side:
                        const BorderSide(color: AuthPalette.muted, width: 1.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: 'I agree to the ',
                      style: TextStyle(
                        color: AuthPalette.muted,
                        fontSize: 12.5,
                      ),
                      children: [
                        TextSpan(
                          text: 'Terms & Conditions',
                          style: TextStyle(
                            color: AuthPalette.emerald,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            AuthPrimaryButton(
              label: 'Create account',
              loading: _loading,
              onTap: busy ? null : _register,
            ),
            const SizedBox(height: 22),
            const AuthDivider(text: 'or register with'),
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
                  onTap: busy ? null : _registerWithGoogle,
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
                    'Already have an account?',
                    style: TextStyle(color: AuthPalette.muted, fontSize: 13.5),
                  ),
                  TextButton(
                    onPressed: busy
                        ? null
                        : () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            ),
                    style: TextButton.styleFrom(
                      foregroundColor: AuthPalette.emerald,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Log in',
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
