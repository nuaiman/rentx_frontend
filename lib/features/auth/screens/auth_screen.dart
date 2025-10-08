import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart';
import '../notifiers/auth_notifier.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  late final GoogleSignIn googleSignIn;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    googleSignIn = GoogleSignIn(
      params: const GoogleSignInParams(
        clientId:
            '1057406041251-rvug878aolk7vicrtun457t307ctgeo0.apps.googleusercontent.com',
        scopes: ['openid', 'profile', 'email'],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Email + password login
  void _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    await ref.read(authProvider.notifier).authEmail(context, email, password);
  }

  // Google Sign-In handler
  void _handleGoogleSignIn(GoogleSignInCredentials creds) {
    if (creds.idToken != null && creds.accessToken.isNotEmpty) {
      ref
          .read(authProvider.notifier)
          .googleAuthToBackend(
            context,
            idToken: creds.idToken!,
            accessToken: creds.accessToken,
          );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to retrieve Google tokens')),
      );
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
      child: StreamBuilder<GoogleSignInCredentials?>(
        stream: googleSignIn.authenticationState,
        builder: (context, snapshot) {
          final creds = snapshot.data;
          final isSignedIn = creds != null;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  _buildHeader(textTheme),
                  const SizedBox(height: 24),

                  // Google Sign-In
                  kIsWeb
                      ? googleSignIn.signInButton(
                              config: GSIAPButtonConfig(
                                onSignIn: _handleGoogleSignIn,
                                onSignOut: () {},
                              ),
                            ) ??
                            const SizedBox.shrink()
                      : ElevatedButton(
                          onPressed: isSignedIn
                              ? googleSignIn.signOut
                              : googleSignIn.signIn,
                          child: Text(isSignedIn ? 'Sign Out' : 'Sign In'),
                        ),
                  const SizedBox(height: 24),

                  // Divider
                  _buildDivider(),
                  const SizedBox(height: 24),

                  // Email & Password
                  _buildEmailField(),
                  const SizedBox(height: 16),
                  _buildPasswordField(),
                  const SizedBox(height: 8),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Forgot Password",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),

                  // Error
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
          );
        },
      ),
    );
  }

  Widget _buildHeader(TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Authenticate',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 36,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: const [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text("or"),
        ),
        Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: "Email",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: true,
      decoration: InputDecoration(
        labelText: "Password",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// -----------------------------------------------------------------------------

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart';

// class AuthScreen extends StatefulWidget {
//   const AuthScreen({super.key});

//   @override
//   State<AuthScreen> createState() => _AuthScreenState();
// }

// class _AuthScreenState extends State<AuthScreen> {
//   late final GoogleSignIn googleSignIn;

//   @override
//   void initState() {
//     super.initState();
//     googleSignIn = GoogleSignIn(
//       params: const GoogleSignInParams(
//         clientId:
//             '1057406041251-rvug878aolk7vicrtun457t307ctgeo0.apps.googleusercontent.com',
//         scopes: ['openid', 'profile', 'email'],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Google Sign-In Web Demo')),
//       body: Center(
//         child: StreamBuilder<GoogleSignInCredentials?>(
//           stream: googleSignIn.authenticationState,
//           builder: (context, snapshot) {
//             final credentials = snapshot.data;
//             final isSignedIn = credentials != null;

//             // Print credentials if signed in
//             if (isSignedIn) {
//               print('Access Token: ${credentials.accessToken}');
//               print('Scopes: ${credentials.scopes.join(', ')}');
//             }

//             return Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 if (kIsWeb)
//                   // Web requires the built-in Google sign-in button
//                   googleSignIn.signInButton() ?? const SizedBox.shrink()
//                 else
//                   ElevatedButton(
//                     onPressed: isSignedIn
//                         ? googleSignIn.signOut
//                         : googleSignIn.signIn,
//                     child: Text(isSignedIn ? 'Sign Out' : 'Sign In'),
//                   ),
//                 const SizedBox(height: 20),
//                 if (isSignedIn) ...[
//                   Text('Access Token: ${credentials.accessToken}'),
//                   const SizedBox(height: 10),
//                   Text('Scopes: ${credentials.scopes.join(', ')}'),
//                 ],
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// -----------------------------------------------------------------------------

// import 'dart:async';
// import 'dart:convert';
// import 'dart:js_interop';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:google_sign_in_web/web_only.dart';
// import 'package:http/http.dart' as http;
// import '../notifiers/auth_notifier.dart';
// import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';

// class AuthScreen extends ConsumerStatefulWidget {
//   const AuthScreen({super.key});

//   @override
//   ConsumerState<AuthScreen> createState() => _AuthScreenState();
// }

// class _AuthScreenState extends ConsumerState<AuthScreen> {
//   late final GoogleSignIn gsi;
//   StreamSubscription<GoogleSignInAuthenticationEvent>? _gsiSub;

//   final googleSignInWebClientId =
//       '1057406041251-rvug878aolk7vicrtun457t307ctgeo0.apps.googleusercontent.com';

//   @override
//   void initState() {
//     super.initState();

//     // initialize GSI Web
//     if (kIsWeb) {
//       gsi = GoogleSignIn.instance;
//       gsi.initialize(clientId: googleSignInWebClientId);

//       // Listen for credentials when FedCM returns a token
//       _gsiSub = gsi.authenticationEvents.listen((event) {
//         print('event: ${event}');
//         print('Calling Sign In: ------------------------------');
//         _signInWithGoogle();
//       });
//     }
//   }

//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();

//   // Email + password login
//   void _submit() async {
//     final email = _emailController.text.trim();
//     final password = _passwordController.text.trim();
//     final authNotifier = ref.read(authProvider.notifier);
//     await authNotifier.authEmail(context, email, password);
//   }

//   //
//   Future<void> _signInWithGoogle() async {
//     try {
//       final account = await gsi.authenticate();

//       final auth = await account.authentication;

//       print("ID Token (JWT): ${auth.idToken}");
//       print("Name: ${account.displayName}");
//       print("Email: ${account.email}");
//       print("Photo URL: ${account.photoUrl}");

//       // Send JWT to backend
//       // await _handleGoogleCredential(auth.idToken!);
//     } catch (e) {
//       print("Google Sign-In error: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authState = ref.watch(authProvider);
//     final textTheme = Theme.of(context).textTheme;

//     return Dialog(
//       backgroundColor: Colors.white,
//       constraints: const BoxConstraints(maxWidth: 500),
//       insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // Heading
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Authenticate',
//                     style: textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 36,
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.close),
//                     onPressed: () => Navigator.of(context).pop(),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 "We’ve missed you! Please sign in to catch up on what you’ve missed",
//                 style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
//               ),
//               const SizedBox(height: 24),

//               // Google button (works for mobile; web requires FedCM or SDK button)
//               renderButton(
//                 configuration: GSIButtonConfiguration(
//                   locale: 'en',
//                   minimumWidth: 600,
//                 ),
//               ),

//               const SizedBox(height: 24),

//               // Divider
//               Row(
//                 children: const [
//                   Expanded(child: Divider()),
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 8),
//                     child: Text("or"),
//                   ),
//                   Expanded(child: Divider()),
//                 ],
//               ),
//               const SizedBox(height: 24),

//               // Email
//               TextField(
//                 controller: _emailController,
//                 decoration: InputDecoration(
//                   labelText: "Email",
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 keyboardType: TextInputType.emailAddress,
//               ),
//               const SizedBox(height: 16),

//               // Password + Forgot
//               TextField(
//                 controller: _passwordController,
//                 obscureText: true,
//                 decoration: InputDecoration(
//                   labelText: "Password",
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   TextButton(
//                     onPressed: () {},
//                     child: const Text(
//                       "Forgot Password",
//                       style: TextStyle(color: Colors.black),
//                     ),
//                   ),
//                 ],
//               ),

//               if (authState.hasError) ...[
//                 const SizedBox(height: 8),
//                 Text(
//                   authState.error.toString(),
//                   style: const TextStyle(color: Colors.red),
//                   textAlign: TextAlign.center,
//                 ),
//               ],

//               const SizedBox(height: 20),

//               // Login button
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.black,
//                   padding: const EdgeInsets.symmetric(vertical: 18),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 onPressed: authState.isLoading ? null : _submit,
//                 child: const Text(
//                   "Log in",
//                   style: TextStyle(color: Colors.white, fontSize: 16),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
