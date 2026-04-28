import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';
import '../services/security_service.dart';
import 'register_screen.dart';
import 'home_screen.dart';

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
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите email и пароль')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: реальный запрос к API
      await Future.delayed(const Duration(seconds: 1));

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.setUserEmail(email);
      
      if (_rememberMe) {
        await AuthService.register(email: email, name: email.split('@').first);
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1E2A) : const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Логотип
                Container(
                  width: 80.w, height: 80.w,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)]),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: const Color(0xFF4F46E5).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: Icon(Icons.auto_awesome, color: Colors.white, size: 40.sp),
                ),
                SizedBox(height: 32.h),
                Text('Вход', style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 8.h),
                Text('Войдите, чтобы сохранять презентации', style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
                SizedBox(height: 40.h),

                // Email
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                SizedBox(height: 16.h),

                // Пароль
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Пароль',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                SizedBox(height: 12.h),

                // Запомнить + Забыли пароль
                Row(
                  children: [
                    Checkbox(value: _rememberMe, onChanged: (v) => setState(() => _rememberMe = v!), activeColor: const Color(0xFF4F46E5)),
                    Text('Запомнить меня', style: TextStyle(fontSize: 13.sp)),
                    const Spacer(),
                    TextButton(onPressed: () {}, child: Text('Забыли пароль?', style: TextStyle(fontSize: 13.sp))),
                  ],
                ),
                SizedBox(height: 20.h),

                // Кнопка входа
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    child: _isLoading
                        ? SizedBox(width: 24.w, height: 24.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text('Войти', style: TextStyle(fontSize: 16.sp)),
                  ),
                ),
                SizedBox(height: 16.h),

                // Регистрация
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('Нет аккаунта?', style: TextStyle(color: Colors.grey[600])),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                    child: const Text('Зарегистрироваться'),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}