import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/tropica_theme.dart';

class WelcomeSignInScreen extends StatefulWidget {
  final AuthService authService;

  const WelcomeSignInScreen({
    super.key,
    required this.authService,
  });

  @override
  State<WelcomeSignInScreen> createState() => _WelcomeSignInScreenState();
}

class _WelcomeSignInScreenState extends State<WelcomeSignInScreen> {
  final _emailController = TextEditingController(
    text: 'howard@tropicaguide.app',
  );
  final _passwordController = TextEditingController(text: 'Tropica2026!');
  final _nameController = TextEditingController();
  bool _isRegisterMode = false;
  String? _statusMessage;
  bool _isError = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submitEmailAuth() async {
    setState(() {
      _statusMessage = null;
      _isError = false;
    });

    try {
      if (_isRegisterMode) {
        await widget.authService.registerWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
          displayName: _nameController.text,
        );
      } else {
        await widget.authService.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }
    } on AuthException catch (e) {
      setState(() {
        _statusMessage = e.message;
        _isError = true;
      });
    }
  }

  Future<void> _handlePasswordReset() async {
    try {
      await widget.authService.sendPasswordResetEmail(_emailController.text);
      setState(() {
        _statusMessage =
            'Password reset instructions sent to ${_emailController.text.trim()}.';
        _isError = false;
      });
    } on AuthException catch (e) {
      setState(() {
        _statusMessage = e.message;
        _isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 88,
                    width: 88,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: TropicaTheme.oceanTeal.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.explore_rounded,
                      size: 48,
                      color: TropicaTheme.oceanTeal,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'TropicaGuide',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: TropicaTheme.deepNavy,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Collaborative Travel Planner — shared itineraries, checklists & packing in real time.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.blueGrey.shade700,
                        ),
                  ),
                  const SizedBox(height: 24),
                  if (_statusMessage != null) ...[
                    Container(
                      key: const Key('auth_status_banner'),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isError
                            ? Colors.red.shade50
                            : Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isError
                              ? Colors.red.shade300
                              : Colors.teal.shade300,
                        ),
                      ),
                      child: Text(
                        _statusMessage!,
                        style: TextStyle(
                          color: _isError
                              ? Colors.red.shade900
                              : Colors.teal.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_isRegisterMode) ...[
                    TextField(
                      key: const Key('display_name_input'),
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextField(
                    key: const Key('email_input'),
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('password_input'),
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    key: const Key('primary_auth_button'),
                    onPressed: _submitEmailAuth,
                    child: Text(_isRegisterMode ? 'Create Account' : 'Sign In'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    key: const Key('google_sign_in_button'),
                    onPressed: () => widget.authService.signInWithGoogle(),
                    icon: const Icon(Icons.g_mobiledata, size: 26),
                    label: const Text('Continue with Google'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      TextButton(
                        key: const Key('toggle_register_mode_button'),
                        onPressed: () {
                          setState(() {
                            _isRegisterMode = !_isRegisterMode;
                            _statusMessage = null;
                          });
                        },
                        child: Text(
                          _isRegisterMode
                              ? 'Already have an account? Sign In'
                              : 'Need an account? Register',
                        ),
                      ),
                      TextButton(
                        key: const Key('forgot_password_button'),
                        onPressed: _handlePasswordReset,
                        child: const Text('Reset Password'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
