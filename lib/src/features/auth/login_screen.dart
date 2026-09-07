import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/shipkia_auth_scope.dart';
import '../../core/api/api.dart';
import '../../core/router/app_route_paths.dart';
import '../../design_system/design_system.dart';
import '../../theme/shipkia_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'arya@yopmail.com');
  final _passwordController = TextEditingController(text: 'P@ssword1');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      return;
    }

    try {
      await ShipKiaAuthScope.of(context)
          .login(email: email, password: password);
    } on ApiException {
      // ApiClient already maps and displays the user-facing error message.
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;

          return Stack(
            children: [
              const Positioned.fill(child: _AuthCanvas()),
              const Positioned.fill(child: _SignalDotField()),
              SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isWide ? 40 : 16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight:
                          constraints.maxHeight -
                          MediaQuery.paddingOf(context).vertical -
                          (isWide ? 80 : 32),
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1152),
                        child: isWide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Expanded(flex: 108, child: _AuthRail()),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    flex: 92,
                                    child: _AuthFormColumn(
                                      emailController: _emailController,
                                      passwordController: _passwordController,
                                      onLogin: _login,
                                      showMobileLogo: false,
                                    ),
                                  ),
                                ],
                              )
                            : _AuthFormColumn(
                                emailController: _emailController,
                                passwordController: _passwordController,
                                onLogin: _login,
                                showMobileLogo: true,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AuthCanvas extends StatelessWidget {
  const _AuthCanvas();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomPaint(
      painter: _AuthCanvasPainter(isDark: isDark),
      child: ColoredBox(
        color: isDark ? ShipKiaColors.night : ShipKiaColors.paper,
      ),
    );
  }
}

class _AuthCanvasPainter extends CustomPainter {
  const _AuthCanvasPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final base = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? const [Color(0xFF000000), Color(0xFF050505), Color(0xFF0D0D0D)]
            : const [Color(0xFFFFFFFF), Color(0xFFFAFBFF), Color(0xFFFFFFFF)],
      ).createShader(rect);
    canvas.drawRect(rect, base);

    void drawGlow(Offset center, double radius, double opacity) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            ShipKiaColors.shipkiaBlue.withValues(alpha: opacity),
            ShipKiaColors.shipkiaBlue.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, paint);
    }

    drawGlow(Offset(size.width * 0.40, size.height * 0.20), 360, 0.12);
    drawGlow(Offset(size.width * 0.82, 0), 320, 0.12);
    drawGlow(Offset(0, size.height * 0.50), 300, 0.08);
    drawGlow(Offset(size.width * 0.82, size.height), 340, 0.12);
  }

  @override
  bool shouldRepaint(_AuthCanvasPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

class _SignalDotField extends StatelessWidget {
  const _SignalDotField();

  static const _dots = [
    (0.07, 0.12, 0.20),
    (0.73, 0.16, 0.16),
    (0.61, 0.91, 0.18),
  ];

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              for (final dot in _dots)
                Positioned(
                  left: constraints.maxWidth * dot.$1,
                  top: constraints.maxHeight * dot.$2,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: ShipKiaColors.shipkiaBlue.withValues(
                        alpha: dot.$3,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const SizedBox.square(dimension: 6),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _AuthRail extends StatelessWidget {
  const _AuthRail();

  @override
  Widget build(BuildContext context) {
    final headline = Theme.of(context).textTheme.headlineMedium
        ?.copyWith(fontSize: 48, height: 0.98, fontWeight: FontWeight.w900);

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 560),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 192, child: _ShipKiaWordmark()),
            const SizedBox(height: 32),
            const _AuthEyebrow('Secure shipping console'),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                style: headline,
                children: const [
                  TextSpan(text: 'Move orders with '),
                  TextSpan(
                    text: 'less noise.',
                    style: TextStyle(color: ShipKiaColors.shipkiaBlue),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 512),
              child: Text(
                'Sign in to your operating dock for orders, courier actions, and delivery visibility.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ShipKiaColors.mutedInk,
                  fontSize: 14,
                  height: 1.75,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthFormColumn extends StatelessWidget {
  const _AuthFormColumn({
    required this.emailController,
    required this.passwordController,
    required this.onLogin,
    required this.showMobileLogo,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final Future<void> Function() onLogin;
  final bool showMobileLogo;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (showMobileLogo) ...[
          const SizedBox(width: 176, child: _ShipKiaWordmark()),
          const SizedBox(height: 32),
        ],
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: _AuthCard(
            child: _LoginForm(
              emailController: emailController,
              passwordController: passwordController,
              onLogin: onLogin,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          children: [
            Text(
              "Don't have an account?",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: ShipKiaColors.mutedInk,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            AppButton(
              label: 'Register Now',
              onPressed: () => context.push(AppRoutePaths.signUp),
              variant: AppButtonVariant.ghost,
              height: 28,
            ),
          ],
        ),
      ],
    );
  }
}

class _AuthCard extends StatelessWidget {
  const _AuthCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? ShipKiaColors.nightCard : ShipKiaColors.paper,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? ShipKiaColors.nightBorder
              : ShipKiaColors.neutralBorder,
        ),
      ),
      child: Padding(padding: const EdgeInsets.all(28), child: child),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.emailController,
    required this.passwordController,
    required this.onLogin,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final Future<void> Function() onLogin;

  @override
  Widget build(BuildContext context) {
    final auth = ShipKiaAuthScope.of(context);
    return AutofillGroup(
      child: AnimatedBuilder(
        animation: auth,
        builder: (context, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const _AuthEyebrow('Welcome back'),
              const SizedBox(height: 8),
              Text(
                'Login to ShipKia',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 24),
              _AuthField(
                label: 'Email',
                controller: emailController,
                hintText: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
              ),
              const SizedBox(height: 16),
              _AuthField(
                label: 'Password',
                controller: passwordController,
                hintText: 'Enter password',
                obscureText: true,
                autofillHints: const [AutofillHints.password],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: AppButton(
                  label: 'Forgot password?',
                  onPressed: auth.isSubmitting
                      ? null
                      : () => context.push(AppRoutePaths.forgotPassword),
                  variant: AppButtonVariant.ghost,
                  height: 28,
                ),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: auth.isSubmitting ? 'Logging in' : 'Login',
                onPressed: auth.isSubmitting ? null : onLogin,
                loading: auth.isSubmitting,
                fullWidth: true,
                height: 40,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.label,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.autofillHints,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 11,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 6),
        AppTextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          autofillHints: autofillHints,
          hintText: hintText,
          height: 40,
        ),
      ],
    );
  }
}

class _AuthEyebrow extends StatelessWidget {
  const _AuthEyebrow(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: ShipKiaColors.shipkiaBlue,
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 2.2,
      ),
    );
  }
}

class _ShipKiaWordmark extends StatelessWidget {
  const _ShipKiaWordmark();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/shipkia-logo.svg',
      fit: BoxFit.contain,
      semanticsLabel: 'ShipKia',
    );
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ReferenceAuthScreen(
      eyebrow: 'Account recovery',
      headline: const _AuthHeadlineLite(
        leading: 'Recover access to ',
        accent: 'ShipKia.',
      ),
      supportingText: 'Reset your account credentials without leaving the same calm shipping workspace.',
      footer: _sent ? null : _BackAuthLink(label: 'Back to Sign In'),
      child: _sent
          ? _AuthFeedback(
              icon: Icons.mark_email_read_outlined,
              title: 'Check your email',
              description:
                  "We've sent a password reset link to ${_emailController.text.trim().isEmpty ? 'your email' : _emailController.text.trim()}.",
              actionLabel: 'Back to Sign In',
              onAction: () => Navigator.of(context).pop(),
              secondaryActionLabel: 'Open update password',
              onSecondaryAction: () =>
                  context.pushReplacement(AppRoutePaths.resetPassword),
            )
          : _ReferenceAuthForm(
              kicker: 'Update access',
              title: 'Update password',
              children: [
                _AuthField(
                  label: 'Email Address',
                  controller: _emailController,
                  hintText: 'Enter email address',
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                ),
                _FullAuthButton(
                  label: 'Send reset link',
                  icon: Icons.mark_email_read_outlined,
                  onPressed: () => setState(() => _sent = true),
                ),
              ],
            ),
    );
  }
}

class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _success = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ReferenceAuthScreen(
      eyebrow: 'Account recovery',
      headline: const _AuthHeadlineLite(
        leading: 'Secure your ',
        accent: 'ShipKia',
        trailing: ' access.',
      ),
      supportingText:
          'Choose a strong new password to regain access to your account.',
      footer: _success ? null : _BackAuthLink(label: 'Back to Dashboard'),
      child: _success
          ? const _AuthFeedback(
              icon: Icons.check_circle_outline,
              title: 'Password updated',
              description: 'Your password has been changed. Return to login.',
            )
          : _ReferenceAuthForm(
              kicker: 'Reset access',
              title: 'Update password',
              children: [
                _AuthField(
                  label: 'New Password',
                  controller: _newPasswordController,
                  hintText: 'Enter new password',
                  obscureText: true,
                ),
                _AuthField(
                  label: 'Confirm New Password',
                  controller: _confirmPasswordController,
                  hintText: 'Confirm new password',
                  obscureText: true,
                ),
                _FullAuthButton(
                  label: 'Update password',
                  icon: Icons.key_outlined,
                  onPressed: () => setState(() => _success = true),
                ),
              ],
            ),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  int _step = 1;
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ReferenceAuthScreen(
      eyebrow: 'Start shipping cleaner',
      headline: const _AuthHeadlineLite(
        leading: 'Open a dock for ',
        accent: 'every order.',
      ),
      supportingText: 'Create your account and bring channels, pickups, and shipment decisions into one calm workspace.',
      footer: _step == 3
          ? null
          : _InlineAuthFooter(
              text: 'Already have an account?',
              action: 'Sign In',
              onAction: () => Navigator.of(context).pop(),
            ),
      child: AnimatedSwitcher(
        duration: ShipKiaMotion.normal,
        child: switch (_step) {
          1 => _ReferenceAuthForm(
            key: const ValueKey('email'),
            kicker: 'Step 1 of 3',
            title: 'Your Email',
            children: [
              _AuthField(
                label: 'Email Address',
                controller: _emailController,
                hintText: 'Enter email address',
                keyboardType: TextInputType.emailAddress,
              ),
              _FullAuthButton(
                label: 'Continue',
                icon: Icons.send_outlined,
                onPressed: () => setState(() => _step = 2),
              ),
            ],
          ),
          2 => _OtpAuthStep(
            key: const ValueKey('otp'),
            email: _emailController.text.trim().isEmpty
                ? 'your email'
                : _emailController.text.trim(),
            onEditEmail: () => setState(() => _step = 1),
            onVerified: () => setState(() => _step = 3),
          ),
          _ => _ReferenceAuthForm(
            key: const ValueKey('profile'),
            kicker: 'Step 3 of 3',
            title: 'Complete Profile',
            children: [
              Row(
                children: [
                  Expanded(
                    child: _AuthField(
                      label: 'First Name',
                      controller: _firstNameController,
                      hintText: 'First Name',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _AuthField(
                      label: 'Last Name',
                      controller: _lastNameController,
                      hintText: 'Last Name',
                    ),
                  ),
                ],
              ),
              _AuthField(
                label: 'Phone Number',
                controller: _phoneController,
                hintText: 'Phone Number',
                keyboardType: TextInputType.phone,
              ),
              _AuthField(
                label: 'Company Name',
                controller: _companyController,
                hintText: 'Company Name',
              ),
              _AuthField(
                label: 'Password',
                controller: _passwordController,
                hintText: 'Password',
                obscureText: true,
              ),
              _AuthField(
                label: 'Confirm Password',
                controller: _confirmPasswordController,
                hintText: 'Confirm Password',
                obscureText: true,
              ),
              _FullAuthButton(
                label: 'Register',
                icon: Icons.send_outlined,
                onPressed: () => context.pushReplacement(
                  Uri(
                    path: AppRoutePaths.registerVerify,
                    queryParameters: {
                      'email': _emailController.text.trim().isEmpty
                          ? 'user@example.com'
                          : _emailController.text.trim(),
                    },
                  ).toString(),
                ),
              ),
            ],
          ),
        },
      ),
    );
  }
}

class RegisterVerifyScreen extends StatefulWidget {
  const RegisterVerifyScreen({required this.email, super.key});

  final String email;

  @override
  State<RegisterVerifyScreen> createState() => _RegisterVerifyScreenState();
}

class _RegisterVerifyScreenState extends State<RegisterVerifyScreen> {
  bool _success = false;

  @override
  Widget build(BuildContext context) {
    return _ReferenceAuthScreen(
      eyebrow: 'Finish onboarding',
      headline: const _AuthHeadlineLite(
        leading: 'Tune your dock for ',
        accent: 'smarter shipping.',
      ),
      supportingText: 'Complete the workspace profile once, then hand off orders with cleaner defaults.',
      footer: _BackAuthLink(label: 'Back'),
      child: _success
          ? _AuthFeedback(
              icon: Icons.check_circle_outline,
              title: 'Registration completed',
              description: 'Your account is registered. Opening login...',
              actionLabel: 'Go to Login',
              onAction: () => context.go(AppRoutePaths.login),
            )
          : _ReferenceAuthForm(
              kicker: 'Final step',
              title: 'Create your workspace',
              children: [
                _StaticAuthField(label: 'Email ID', value: widget.email),
                const _PasswordChecklist(),
                _FullAuthButton(
                  label: 'Register',
                  icon: Icons.person_add_alt_1_outlined,
                  onPressed: () => setState(() => _success = true),
                ),
              ],
            ),
    );
  }
}

class _ReferenceAuthScreen extends StatelessWidget {
  const _ReferenceAuthScreen({
    required this.eyebrow,
    required this.headline,
    required this.supportingText,
    required this.child,
    this.footer,
  });

  final String eyebrow;
  final Widget headline;
  final String supportingText;
  final Widget child;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;

          return Stack(
            children: [
              const Positioned.fill(child: _AuthCanvas()),
              const Positioned.fill(child: _SignalDotField()),
              SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isWide ? 40 : 16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight:
                          constraints.maxHeight -
                          MediaQuery.paddingOf(context).vertical -
                          (isWide ? 80 : 32),
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1152),
                        child: isWide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 108,
                                    child: _ReferenceAuthRail(
                                      eyebrow: eyebrow,
                                      headline: headline,
                                      supportingText: supportingText,
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    flex: 92,
                                    child: _ReferenceAuthColumn(
                                      footer: footer,
                                      showMobileLogo: false,
                                      child: child,
                                    ),
                                  ),
                                ],
                              )
                            : _ReferenceAuthColumn(
                                footer: footer,
                                showMobileLogo: true,
                                child: child,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ReferenceAuthRail extends StatelessWidget {
  const _ReferenceAuthRail({
    required this.eyebrow,
    required this.headline,
    required this.supportingText,
  });

  final String eyebrow;
  final Widget headline;
  final String supportingText;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 560),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 192, child: _ShipKiaWordmark()),
            const SizedBox(height: 32),
            _AuthEyebrow(eyebrow),
            const SizedBox(height: 10),
            headline,
            const SizedBox(height: 16),
            Text(
              supportingText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: ShipKiaColors.mutedInk,
                fontSize: 14,
                height: 1.75,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReferenceAuthColumn extends StatelessWidget {
  const _ReferenceAuthColumn({
    required this.showMobileLogo,
    required this.child,
    this.footer,
  });

  final bool showMobileLogo;
  final Widget child;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (showMobileLogo) ...[
          const SizedBox(width: 176, child: _ShipKiaWordmark()),
          const SizedBox(height: 32),
        ],
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: _AuthCard(child: child),
        ),
        if (footer != null) ...[const SizedBox(height: 24), footer!],
      ],
    );
  }
}

class _ReferenceAuthForm extends StatelessWidget {
  const _ReferenceAuthForm({
    required this.kicker,
    required this.title,
    required this.children,
    super.key,
  });

  final String kicker;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _AuthEyebrow(kicker),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 24),
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1) const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _AuthHeadlineLite extends StatelessWidget {
  const _AuthHeadlineLite({
    required this.leading,
    required this.accent,
    this.trailing = '',
  });

  final String leading;
  final String accent;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.headlineMedium
        ?.copyWith(fontSize: 48, height: 0.98, fontWeight: FontWeight.w900);

    return RichText(
      text: TextSpan(
        style: style,
        children: [
          TextSpan(text: leading),
          TextSpan(
            text: accent,
            style: const TextStyle(color: ShipKiaColors.shipkiaBlue),
          ),
          if (trailing.isNotEmpty) TextSpan(text: trailing),
        ],
      ),
    );
  }
}

class _OtpAuthStep extends StatefulWidget {
  const _OtpAuthStep({
    required this.email,
    required this.onEditEmail,
    required this.onVerified,
    super.key,
  });

  final String email;
  final VoidCallback onEditEmail;
  final VoidCallback onVerified;

  @override
  State<_OtpAuthStep> createState() => _OtpAuthStepState();
}

class _OtpAuthStepState extends State<_OtpAuthStep> {
  final _controllers = List.generate(6, (_) => TextEditingController());

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ReferenceAuthForm(
      kicker: 'Step 2 of 3',
      title: 'Verify your email',
      children: [
        Text(
          "We've sent an email to ${widget.email}. Enter the code below to confirm your address.",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: ShipKiaColors.mutedInk,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final controller in _controllers) ...[
              SizedBox(
                width: 42,
                child: AppTextField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  keyboardType: TextInputType.number,
                  height: 48,
                ),
              ),
              if (controller != _controllers.last) const SizedBox(width: 6),
            ],
          ],
        ),
        const Divider(),
        Align(
          alignment: Alignment.centerLeft,
          child: _SmallAuthLink(
            label: 'edit your email address',
            muted: true,
            onPressed: widget.onEditEmail,
          ),
        ),
        _FullAuthButton(label: 'Verify', onPressed: widget.onVerified),
      ],
    );
  }
}

class _FullAuthButton extends StatelessWidget {
  const _FullAuthButton({
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      fullWidth: true,
      height: 40,
    );
  }
}

class _SmallAuthLink extends StatelessWidget {
  const _SmallAuthLink({
    required this.label,
    required this.onPressed,
    this.muted = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      variant: muted ? AppButtonVariant.secondary : AppButtonVariant.ghost,
      height: 28,
    );
  }
}

class _InlineAuthFooter extends StatelessWidget {
  const _InlineAuthFooter({
    required this.text,
    required this.action,
    required this.onAction,
  });

  final String text;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: ShipKiaColors.mutedInk,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        _SmallAuthLink(label: action, onPressed: onAction),
      ],
    );
  }
}

class _BackAuthLink extends StatelessWidget {
  const _BackAuthLink({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: label,
      icon: Icons.arrow_back,
      onPressed: () => Navigator.of(context).pop(),
      variant: AppButtonVariant.ghost,
      height: 28,
    );
  }
}

class _AuthFeedback extends StatelessWidget {
  const _AuthFeedback({
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: ShipKiaColors.success.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: ShipKiaColors.success.withValues(alpha: 0.2),
            ),
          ),
          child: Icon(icon, color: ShipKiaColors.success, size: 24),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: ShipKiaColors.mutedInk,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: 20),
          _FullAuthButton(label: actionLabel!, onPressed: onAction!),
        ],
        if (secondaryActionLabel != null && onSecondaryAction != null) ...[
          const SizedBox(height: 8),
          _SmallAuthLink(
            label: secondaryActionLabel!,
            onPressed: onSecondaryAction!,
          ),
        ],
      ],
    );
  }
}

class _StaticAuthField extends StatelessWidget {
  const _StaticAuthField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          height: 40,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: ShipKiaColors.surfaceMuted(context),
            borderRadius: ShipKiaRadius.mdBorder,
            border: Border.all(color: ShipKiaColors.border(context)),
          ),
          child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}

class _PasswordChecklist extends StatelessWidget {
  const _PasswordChecklist();

  @override
  Widget build(BuildContext context) {
    const items = [
      'At least 8 characters long',
      'One lower case character',
      'One upper case character',
      'One number, symbol or special character',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: ShipKiaColors.success.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ShipKiaColors.success.withValues(alpha: 0.28),
                    ),
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 11,
                    color: ShipKiaColors.success,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: ShipKiaColors.mutedInk, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
