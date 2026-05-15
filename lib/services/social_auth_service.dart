import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../models/social_user.dart';
import 'api_service.dart';

class SocialAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  static Future<SocialUser?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      return SocialUser(
        id: googleUser.id,
        email: googleUser.email,
        name: googleUser.displayName ?? googleUser.email.split('@').first,
        avatarUrl: googleUser.photoUrl,
        provider: 'google',
      );
    } catch (e) {
      print('Google Sign-In error: $e');
      return null;
    }
  }

  static Future<SocialUser?> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      String userName = 'Пользователь Apple';
      if (credential.givenName != null) {
        userName = credential.givenName!;
        if (credential.familyName != null) {
          userName = '$userName ${credential.familyName}';
        }
      }

      return SocialUser(
        id: credential.userIdentifier ?? credential.authorizationCode,
        email: credential.email ?? '',
        name: userName,
        avatarUrl: null,
        provider: 'apple',
      );
    } catch (e) {
      print('Apple Sign-In error: $e');
      return null;
    }
  }
}