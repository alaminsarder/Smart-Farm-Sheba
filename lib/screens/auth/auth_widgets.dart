import 'package:flutter/material.dart';

class AuthPalette {
  static const Color bg = Color(0xFFF4F6F8);
  static const Color ink = Color(0xFF0B1220);
  static const Color muted = Color(0xFF5B6876);
  static const Color border = Color(0xFFE3E9EF);
  static const Color gold = Color(0xFFE9C46A);
  static const Color goldLight = Color(0xFFF6E3A8);
  static const Color emerald = Color(0xFF0E5C3A);
  static const Color deep = Color(0xFF062F23);
  static const Color danger = Color(0xFFC62828);
  static const List<Color> gradient = [
    Color(0xFF062F23),
    Color(0xFF0E5C3A),
    Color(0xFF2A8A4A),
  ];
}

void showAuthSnack(BuildContext context, String message, {bool error = false}) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? AuthPalette.danger : AuthPalette.deep,
        margin: const EdgeInsets.all(14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(message),
      ),
    );
}

InputDecoration authDecoration(
  String label, {
  IconData? icon,
  Widget? suffix,
}) {
  OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: c, width: w),
      );
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: AuthPalette.muted, fontSize: 14),
    floatingLabelStyle: const TextStyle(
      color: AuthPalette.emerald,
      fontWeight: FontWeight.w700,
    ),
    prefixIcon:
        icon == null ? null : Icon(icon, color: AuthPalette.emerald, size: 20),
    suffixIcon: suffix,
    filled: true,
    fillColor: AuthPalette.bg,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: border(AuthPalette.border),
    enabledBorder: border(AuthPalette.border),
    focusedBorder: border(AuthPalette.emerald, 1.6),
    errorBorder: border(AuthPalette.danger),
    focusedErrorBorder: border(AuthPalette.danger, 1.6),
  );
}

class AuthBubble extends StatelessWidget {
  const AuthBubble({super.key, required this.size, required this.alpha});

  final double size;
  final int alpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withAlpha(alpha),
      ),
    );
  }
}

class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AuthPalette.gradient,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned(
            right: -70,
            top: -70,
            child: AuthBubble(size: 260, alpha: 20),
          ),
          Positioned(
            left: -80,
            bottom: -90,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AuthPalette.gold.withAlpha(28),
              ),
            ),
          ),
          const Positioned(
            left: 40,
            top: 120,
            child: AuthBubble(size: 46, alpha: 16),
          ),
          SafeArea(child: child),
        ],
      ),
    );
  }
}

class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Image.asset(
        'assets/images/logo.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Icon(
          Icons.agriculture_rounded,
          color: AuthPalette.emerald,
          size: size * 0.52,
        ),
      ),
    );
  }
}

class AuthBrand extends StatelessWidget {
  const AuthBrand({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AuthLogo(size: 72),
        const SizedBox(height: 16),
        const Text(
          'Smart Farm Sheba',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Grow smarter, every season',
          style: TextStyle(
            color: Colors.white.withAlpha(200),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class AuthBrandPanel extends StatelessWidget {
  const AuthBrandPanel({super.key});

  static const List<String> _features = [
    'Track daily farm expenses',
    'Smart irrigation scheduling',
    'Best crop suggestions for the season',
    'Pesticide dose and safety guide',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AuthPalette.gradient,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned(
            right: -110,
            top: -110,
            child: AuthBubble(size: 230, alpha: 20),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AuthLogo(size: 68),
              const SizedBox(height: 26),
              const Text(
                'Smart Farm Sheba',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your complete digital farm companion.',
                style: TextStyle(
                  color: Colors.white.withAlpha(205),
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 30),
              for (final f in _features)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AuthPalette.gold.withAlpha(50),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: AuthPalette.goldLight,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          f,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatelessWidget {
  const AuthCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(46),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: child,
    );
  }
}

class AuthSplitCard extends StatelessWidget {
  const AuthSplitCard({super.key, required this.form});

  final Widget form;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(56),
            blurRadius: 44,
            offset: const Offset(0, 22),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Expanded(flex: 5, child: AuthBrandPanel()),
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.all(38),
                child: form,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthHeading extends StatelessWidget {
  const AuthHeading({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AuthPalette.ink,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: AuthPalette.muted,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.loading,
    required this.onTap,
  });

  final String label;
  final bool loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dimmed = onTap == null && !loading;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: dimmed ? 0.55 : 1,
      child: Container(
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(colors: AuthPalette.gradient),
          boxShadow: [
            BoxShadow(
              color: AuthPalette.emerald.withAlpha(90),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: loading ? null : onTap,
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.6,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class AuthSocialButton extends StatelessWidget {
  const AuthSocialButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Widget icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: icon,
        label: Text(
          label,
          style: const TextStyle(
            color: AuthPalette.ink,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: AuthPalette.border, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AuthPalette.border, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            text,
            style: const TextStyle(
              color: AuthPalette.muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AuthPalette.border, thickness: 1)),
      ],
    );
  }
}
