import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../models/social_user.dart';
import 'api_service.dart';

class SocialAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // ============================================
  // АВТОРИЗАЦИЯ ЧЕРЕЗ GOOGLE
  // ============================================
  static Future<SocialUser?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final SocialUser user = SocialUser(
        id: googleUser.id,
        email: googleUser.email,
        name: googleUser.displayName ?? googleUser.email.split('@').first,
        avatarUrl: googleUser.photoUrl,
        provider: 'google',
      );

      // Отправляем на бэкенд
      final response = await ApiService.socialLogin(user);
      
      if (response.containsKey('token')) {
        ApiService.setAuthToken(response['token']);
      }
      
      return user;
    } catch (e) {
      print('Google Sign-In error: $e');
      return null;
    }
  }

  // ============================================
  // АВТОРИЗАЦИЯ ЧЕРЕЗ APPLE
  // ============================================
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
      } else if (credential.fullName != null) {
        userName = credential.fullName!;
      }

      final SocialUser user = SocialUser(
        id: credential.userIdentifier ?? credential.authorizationCode,
        email: credential.email ?? '',
        name: userName,
        avatarUrl: null,
        provider: 'apple',
      );

      final response = await ApiService.socialLogin(user);
      
      if (response.containsKey('token')) {
        ApiService.setAuthToken(response['token']);
      }
      
      return user;
    } catch (e) {
      print('Apple Sign-In error: $e');
      return null;
    }
  }

  // ============================================
  // ВЫХОД
  // ============================================
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      print('SignOut error: $e');
    }
  }
}