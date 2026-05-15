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
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } else {
        _showError('Ошибка входа через $providerName');
      }
    } catch (e) {
      _showError(e.toString().replaceAll('Exception:', ''));
    } finally {
      if (mounted) setState(() => _isSocialLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF3B30),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 34,
              height: 34,
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 18),
            ),
          ),
        ),
        title: const Text(
          'Вход',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: _isSocialLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      color: Color(0xFF1DB954),
                      strokeWidth: 3,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Подключение...',
                    style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 14),
                  ),
                ],
              ),
            )
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Логотип
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1DB954), Color(0xFF1ED760)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1DB954).withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      const Text(
                        'Добро пожаловать',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Войдите в свой аккаунт',
                        style: TextStyle(
                          color: Color(0xFF9A9A9A),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // Поле Email
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF2A2A2A)),
                        ),
                        child: TextField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'Email',
                            hintStyle: TextStyle(color: Color(0xFF4A4A4A)),
                            prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF1DB954)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Поле Пароль
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF2A2A2A)),
                        ),
                        child: TextField(
                          controller: _passwordController,
                          style: const TextStyle(color: Colors.white),
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: 'Пароль',
                            hintStyle: const TextStyle(color: Color(0xFF4A4A4A)),
                            prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF1DB954)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: const Color(0xFF4A4A4A),
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Забыли пароль?
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                            );
                          },
                          child: const Text(
                            'Забыли пароль?',
                            style: TextStyle(color: Color(0xFF1DB954), fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Кнопка входа
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: _isLoading ? null : _login,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: _isLoading
                                  ? null
                                  : const LinearGradient(
                                      colors: [Color(0xFF1DB954), Color(0xFF1ED760)],
                                    ),
                              color: _isLoading ? const Color(0xFF2A2A2A) : null,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF1DB954),
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text(
                                      'Войти',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      const Row(
                        children: [
                          Expanded(child: Divider(color: Color(0xFF2A2A2A))),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Или войдите через',
                              style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 12),
                            ),
                          ),
                          Expanded(child: Divider(color: Color(0xFF2A2A2A))),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Google
                          _SocialButton(
                            icon: Icons.g_mobiledata,
                            label: 'Google',
                            color: const Color(0xFFDB4437),
                            onTap: () => _socialLogin(
                              () => SocialAuthService.signInWithGoogle(),
                              'Google',
                            ),
                          ),
                          const SizedBox(width: 20),
                          
                          // Apple
                          _SocialButton(
                            icon: Icons.apple,
                            label: 'Apple',
                            color: Colors.white,
                            onTap: () => _socialLogin(
                              () => SocialAuthService.signInWithApple(),
                              'Apple',
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Регистрация
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Нет аккаунта?',
                            style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 13),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const RegisterScreen()),
                              );
                            },
                            child: const Text(
                              'Создать',
                              style: TextStyle(
                                color: Color(0xFF1DB954),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}