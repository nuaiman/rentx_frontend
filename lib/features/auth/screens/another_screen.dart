import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late final GoogleSignIn googleSignIn;

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Sign-In Web Demo')),
      body: Center(
        child: StreamBuilder<GoogleSignInCredentials?>(
          stream: googleSignIn.authenticationState,
          builder: (context, snapshot) {
            final credentials = snapshot.data;
            final isSignedIn = credentials != null;

            // Print credentials if signed in
            if (isSignedIn) {
              print('Access Token: ${credentials.accessToken}');
              print('Scopes: ${credentials.scopes.join(', ')}');
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (kIsWeb)
                  // Web requires the built-in Google sign-in button
                  googleSignIn.signInButton() ?? const SizedBox.shrink()
                else
                  ElevatedButton(
                    onPressed: isSignedIn
                        ? googleSignIn.signOut
                        : googleSignIn.signIn,
                    child: Text(isSignedIn ? 'Sign Out' : 'Sign In'),
                  ),
                const SizedBox(height: 20),
                if (isSignedIn) ...[
                  Text('Access Token: ${credentials.accessToken}'),
                  const SizedBox(height: 10),
                  Text('Scopes: ${credentials.scopes.join(', ')}'),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
