import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../models/social_user.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import '../services/social_auth_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isSocialLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Заполните все поля');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.login(
        email: email,
        password: password,
      );

      final up = Provider.of<UserProvider>(context, listen: false);
      
      if (response.containsKey('user')) {
        final user = User.fromJson(response['user']);
        final token = response['token'];
        
        up.setUser(user, token: token);
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } else {
        _showError('Ошибка входа');
      }
    } catch (e) {
      _showError(e.toString().replaceAll('Exception:', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _socialLogin(Future<SocialUser?> Function() signInMethod, String providerName) async {
    setState(() => _isSocialLoading = true);
    
    try {
      final socialUser = await signInMethod();
      
      if (socialUser == null) {
        _showError('Авторизация через $providerName отменена');
        return;
      }
      
      final up = Provider.of<UserProvider>(context, listen: false);
      final response = await ApiService.socialLogin(socialUser);
      
      if (response.containsKey('user')) {
        final user = User.fromJson(response['user']);
        final token = response['token'];
        
        up.setUser(user, token: token);
        
        if (