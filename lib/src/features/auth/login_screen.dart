import 'package:flutter/material.dart';

import '../../shell/shipkia_shell.dart';
import '../../theme/shipkia_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'ops@shipkia.com');
  final _passwordController = TextEditingController(text: 'shipkia-demo');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const ShipKiaShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 36),
            const _BrandMark(),
            const SizedBox(height: 32),
            Text('ShipKia', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text(
              'Sign in to manage orders, courier actions, tracking, and delivery operations.',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: ShipKiaColors.mutedInk),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.mail_outline, size: 18),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline, size: 18),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _login,
              icon: const Icon(Icons.login, size: 18),
              label: const Text('Sign in'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {},
              child: const Text('Forgot password'),
            ),
            const SizedBox(height: 24),
            const _AuthNote(),
          ],
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: ShipKiaColors.shipkiaBlue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Icon(Icons.local_shipping, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}

class _AuthNote extends StatelessWidget {
  const _AuthNote();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ShipKiaColors.neutralMuted,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          'Demo mode uses local sample data. Wire this screen to /auth/login, /auth/token/renew, and /auth/user/profile when the API environment is ready.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
