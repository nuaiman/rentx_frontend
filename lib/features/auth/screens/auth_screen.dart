import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/constants/pngs.dart';
import '../notifiers/auth_notifier.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // void _submit() async {
  //   final email = _emailController.text.trim();
  //   final password = _passwordController.text.trim();
  //   print(email);
  //   final authNotifier = ref.read(authProvider.notifier);
  //   await authNotifier.authEmail(context, email, password);
  // }

  void _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final authNotifier = ref.read(authProvider.notifier);

    await authNotifier.authEmail(context, email, password);
  }

  // void _googleAuth() async {
  //   final authNotifier = ref.read(authProvider.notifier);
  //   try {
  //     final googleSignIn = GoogleSignIn.instance;
  //     final account = await googleSignIn.authenticate();
  //     final email = account.email;
  //     await authNotifier.authWithOAuthEmail(context, email);
  //   } catch (e) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text("Google login failed: $e")));
  //   }
  // }

  void _googleAuth() async {
    final authNotifier = ref.read(authProvider.notifier);
    try {
      final googleSignIn = GoogleSignIn.instance;
      final account = await googleSignIn.authenticate();
      final email = account.email;
      await authNotifier.authWithOAuthEmail(context, email);
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Google login failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: Colors.white,
      constraints: const BoxConstraints(maxWidth: 500),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Heading
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Authenticate',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 36,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "We’ve missed you! Please sign in to catch up on what you’ve missed",
                style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 24),

              // Google button
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.black12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Image.asset(Pngs.google, height: 20),
                label: const Text(
                  "Log in with Google",
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                onPressed: _googleAuth,
              ),
              const SizedBox(height: 24),

              // Divider
              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text("or"),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 24),

              // Email
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Password + Forgot
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Forgot Password",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),

              if (authState.hasError) ...[
                const SizedBox(height: 8),
                Text(
                  authState.error.toString(),
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 20),

              // Login button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: authState.isLoading ? null : _submit,
                child: const Text(
                  "Log in",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
