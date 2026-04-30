import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/auth_service.dart';
import '../services/security_service.dart';

class RegisterScreen extends StatefulWidget {
  final bool isOptional;
  const RegisterScreen({super.key, this.isOptional = false});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isLoading = false;
  bool _acceptNewsletter = true;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final email =
        SecurityService.sanitizeString(_emailController.text.trim());
    final name =
        SecurityService.sanitizeString(_nameController.text.trim());

    setState(() => _isLoading = true);

    try {
      final success = await AuthService.register(
        email: email,
        name: name.isNotEmpty ? name : null,
        newsletter: _acceptNewsletter,
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12.w),
                const Text('Регистрация успешна!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        if (widget.isOptional) {
          Navigator.pop(context, true);
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ошибка регистрации'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _skip() {
    if (widget.isOptional) {
      Navigator.pop(context, false);
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF1E1E2A) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        leading: widget.isOptional
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context, false),
              )
            : null,
        title: const Text('Регистрация'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите email';
                    }
                    if (!SecurityService.isValidEmail(value.trim())) {
                      return 'Введите корректный email';
                    }
                    return null;
                  },
                ),

                CheckboxListTile(
                  value: _acceptNewsletter,
                  onChanged: (value) {
                    setState(() {
                      _acceptNewsletter = value ?? false; // FIX
                    });
                  },
                  title: const Text('Новости'),
                ),

                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Зарегистрироваться'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}