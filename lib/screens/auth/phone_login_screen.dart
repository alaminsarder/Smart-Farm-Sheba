import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:smart_farm_sheba/features/home/presentation/home_screen.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _phoneC = TextEditingController(text: "+880");
  final _otpC = TextEditingController();

  bool _sending = false;
  bool _verifying = false;

  bool _codeSent = false;
  String? _verificationId;

  // Web only
  ConfirmationResult? _confirmationResult;

  @override
  void dispose() {
    _phoneC.dispose();
    _otpC.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String _normalizePhone(String input) {
    var s = input.trim();

    // allow: 01XXXXXXXXX
    if (s.startsWith("01") && s.length == 11) {
      s = "+88$s";
    }

    // allow: 8801XXXXXXXXX
    if (s.startsWith("880") && !s.startsWith("+")) {
      s = "+$s";
    }

    return s;
  }

  InputDecoration _dec({
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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder:
          OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.6),
      ),
    );
  }

  Future<void> _sendOtp() async {
    FocusScope.of(context).unfocus();

    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    final phone = _normalizePhone(_phoneC.text);

    setState(() {
      _sending = true;
      _verifying = false;
      _codeSent = false;
      _verificationId = null;
      _confirmationResult = null;
      _otpC.clear();
    });

    try {
      // ✅ WEB flow: reCAPTCHA handled by Firebase internally
      if (kIsWeb) {
        final result = await FirebaseAuth.instance.signInWithPhoneNumber(phone);
        if (!mounted) return;
        setState(() {
          _confirmationResult = result;
          _codeSent = true;
          _sending = false;
        });
        _snack("OTP sent to $phone");
        return;
      }

      // ✅ Android/iOS flow
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto verify may happen on Android
          try {
            await FirebaseAuth.instance.signInWithCredential(credential);
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          } catch (e) {
            _snack("Auto verification failed: $e");
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          setState(() => _sending = false);
          _snack("Failed: ${e.message ?? e.code}");
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!mounted) return;
          setState(() {
            _sending = false;
            _codeSent = true;
            _verificationId = verificationId;
          });
          _snack("OTP sent to $phone");
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      _snack("Error: $e");
    }
  }

  Future<void> _verifyOtp() async {
    FocusScope.of(context).unfocus();

    final otp = _otpC.text.trim();
    if (otp.length < 4) {
      _snack("Enter OTP code");
      return;
    }

    setState(() => _verifying = true);

    try {
      // ✅ WEB confirm
      if (kIsWeb) {
        final confirm = _confirmationResult;
        if (confirm == null) throw Exception("Request OTP first");
        await confirm.confirm(otp);

        if (!mounted) return;
        setState(() => _verifying = false);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
        return;
      }

      // ✅ Mobile confirm
      final vId = _verificationId;
      if (vId == null) throw Exception("Request OTP first");

      final credential = PhoneAuthProvider.credential(
        verificationId: vId,
        smsCode: otp,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;
      setState(() => _verifying = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _verifying = false);
      _snack("OTP failed: ${e.message ?? e.code}");
    } catch (e) {
      if (!mounted) return;
      setState(() => _verifying = false);
      _snack("OTP error: $e");
    }
  }

  void _changeNumber() {
    setState(() {
      _codeSent = false;
      _verificationId = null;
      _confirmationResult = null;
      _otpC.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final busy = _sending || _verifying;

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
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          "Phone Login",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
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
                              "Login with OTP",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "আপনার ফোন নম্বরে OTP পাঠানো হবে।",
                              style: TextStyle(
                                fontSize: 13.5,
                                color: Colors.black.withOpacity(.55),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 18),
                            TextFormField(
                              controller: _phoneC,
                              enabled: !busy && !_codeSent,
                              keyboardType: TextInputType.phone,
                              decoration: _dec(
                                label: "Phone (+8801XXXXXXXXX)",
                                icon: Icons.phone_rounded,
                              ),
                              validator: (v) {
                                final s = _normalizePhone((v ?? ''));
                                if (s.trim().isEmpty) return "Phone required";
                                if (!s.startsWith("+"))
                                  return "Use country code (+880...)";
                                if (s.length < 11) return "Enter valid phone";
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              height: 52,
                              child: ElevatedButton.icon(
                                onPressed: busy || _codeSent ? null : _sendOtp,
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
                                icon: const SizedBox.shrink(),
                                label: Ink(
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
                                    child: _sending
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.sms_rounded,
                                                  color: Colors.white),
                                              SizedBox(width: 8),
                                              Text(
                                                "Send OTP",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 15.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: !_codeSent
                                  ? const SizedBox.shrink()
                                  : Column(
                                      key: const ValueKey("otpSection"),
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        TextFormField(
                                          controller: _otpC,
                                          enabled: !busy,
                                          keyboardType: TextInputType.number,
                                          decoration: _dec(
                                            label: "OTP Code",
                                            icon: Icons.lock_rounded,
                                            suffix: TextButton(
                                              onPressed:
                                                  busy ? null : _changeNumber,
                                              child: const Text("Change"),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          height: 52,
                                          child: FilledButton.icon(
                                            onPressed: busy ? null : _verifyOtp,
                                            icon: _verifying
                                                ? const SizedBox(
                                                    width: 18,
                                                    height: 18,
                                                    child:
                                                        CircularProgressIndicator(
                                                            strokeWidth: 2),
                                                  )
                                                : const Icon(
                                                    Icons.verified_rounded),
                                            label: Text(
                                              _verifying
                                                  ? "Verifying..."
                                                  : "Verify & Login",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w800),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextButton(
                                          onPressed: busy ? null : _sendOtp,
                                          child: const Text("Resend OTP"),
                                        ),
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      kIsWeb
                          ? "Web এ OTP এর জন্য reCAPTCHA লাগে। Firebase Auth settings এ localhost Authorized domain থাকতে হবে।"
                          : "Android real device এ OTP সহজে কাজ করে।",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black.withOpacity(.55),
                        fontSize: 12.5,
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
