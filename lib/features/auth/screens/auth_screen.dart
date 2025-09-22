import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:phone_input/phone_input_package.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../notifiers/auth_notifier.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

enum AuthMethod { phone, email }

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _phoneController = PhoneController(
    PhoneNumber(isoCode: IsoCode.BD, nsn: ''),
  );
  final LayerLink layerLink = LayerLink();

  AuthMethod authMethod = AuthMethod.phone;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final phone = _phoneController.value!.international.substring(1);
    // removed leading + from intl phone number

    final authNotifier = ref.read(authProvider.notifier);

    if (authMethod == AuthMethod.email) {
      await authNotifier.authEmail(context, email, password);
      // setState(() => _isLogin = false);
      // _passwordController.clear();
    } else {
      await authNotifier.authPhone(context, phone);
    }
  }

  void _googleAuth() async {
    final authNotifier = ref.read(authProvider.notifier);
    try {
      final googleSignIn = GoogleSignIn.instance;
      final account = await googleSignIn.authenticate();
      final email = account.email;
      await authNotifier.authWithOAuthEmail(context, email);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Google login failed: $e')));
    }
  }

  void _appleAuth() async {
    final authNotifier = ref.read(authProvider.notifier);
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email],
      );
      final email = credential.email;
      if (email == null) {
        throw Exception('Apple did not return email.');
      }
      await authNotifier.authWithOAuthEmail(context, email);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Apple login failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Center(
        child: Dialog(
          constraints: const BoxConstraints(maxWidth: 500),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Authenticate',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 18),

                // Content changes based on selected method
                authMethod == AuthMethod.phone
                    ? PhoneInput(
                        isCountrySelectionEnabled: false,
                        controller: _phoneController,
                        showArrow: false,
                        shouldFormat: true,
                        validator: PhoneValidator.compose([
                          PhoneValidator.required(),
                          PhoneValidator.valid(),
                        ]),
                        flagShape: BoxShape.circle,
                        showFlagInInput: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        countrySelectorNavigator:
                            CountrySelectorNavigator.dropdown(
                              layerLink: layerLink,
                            ),
                      )
                    : Column(
                        children: [
                          TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              hintText: 'Email',
                              filled: true,
                              fillColor: Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          // Password
                          TextField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              filled: true,
                              fillColor: Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            obscureText: true,
                          ),
                        ],
                      ),

                const SizedBox(height: 24),
                Text(
                  "We’ll call or text you to confirm your number. Standard message and data rates apply. Privacy Policy",
                  style: textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Error message
                if (authState.hasError)
                  Text(
                    authState.error.toString(),
                    style: const TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),

                const SizedBox(height: 8),

                // Continue button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: authState.isLoading ? null : _submit,
                  child: const Text(
                    "Continue",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),

                const SizedBox(height: 12),
                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('or, continue with'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    _socialButton(
                      icon: authMethod == AuthMethod.phone
                          ? Icons.email
                          : Icons.phone,
                      onPressed: () {
                        if (authMethod == AuthMethod.phone) {
                          setState(() {
                            authMethod = AuthMethod.email;
                          });
                        } else {
                          setState(() {
                            authMethod = AuthMethod.phone;
                          });
                        }
                      },
                    ),
                    _socialButton(
                      icon: Icons.g_mobiledata,
                      onPressed: _googleAuth,
                    ),
                    _socialButton(icon: Icons.apple, onPressed: _appleAuth),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: Card.outlined(
        color: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        child: ListTile(dense: true, onTap: onPressed, title: Icon(icon)),
      ),
    );
  }
}
