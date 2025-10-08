import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart';

final googleSignIn = GoogleSignIn(
  params: const GoogleSignInParams(
    clientId:
        '1057406041251-rvug878aolk7vicrtun457t307ctgeo0.apps.googleusercontent.com',
    scopes: ['openid', 'profile', 'email'],
  ),
);
