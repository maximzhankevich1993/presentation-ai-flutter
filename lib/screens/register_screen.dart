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
  bool _obscureEmail = true;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Очищаем ввод от опасных символов
    final email = SecurityService.sanitizeString(_emailController.text.trim());
    final name = SecurityService.sanitizeString(_nameController.text.trim());
    
    setState(() => _isLoading = true);
    
    final success = await AuthService.register(
      email: email,
      name: name.isNotEmpty ? name : null,
      newsletter: _acceptNewsletter,
    );
    
    setState(() => _isLoading = false);
    
    if (mounted) {
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        
        if (widget.isOptional) {
          Navigator.pop(context, true);
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                SizedBox(width: 12.w),
                const Text('Ошибка регистрации. Проверьте данные.'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
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
      backgroundColor: isDark ? const Color(0xFF1E1E2A) : const Color(0xFFFAFAFA),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Иконка
                Center(
                  child: Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4F46E5).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(Icons.person_outline, color: Colors.white, size: 50.sp),
                  ),
                ),
                
                SizedBox(height: 32.h),
                
                // Заголовок
                Text(
                  'Создай аккаунт',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Сохраняй презентации и получай новости об обновлениях',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
                
                SizedBox(height: 32.h),
                
                // Поле имени
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Имя (необязательно)',
                    hintText: 'Как к вам обращаться?',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                
                SizedBox(height: 16.h),
                
                // Поле email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'your@email.com',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureEmail ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () => setState(() => _obscureEmail = !_obscureEmail),
                    ),
                  ),
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
                
                SizedBox(height: 24.h),
                
                // Безопасность данных
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock, color: Colors.green, size: 20),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'Ваши данные защищены шифрованием и не передаются третьим лицам',
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 24.h),
                
                // Чекбокс рассылки
                CheckboxListTile(
                  value: _acceptNewsletter,
                  onChanged: (value) {
                    setState(() => _acceptNewsletter = value ?? true);
                  },
                  title: Text(
                    'Получать новости и специальные предложения',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                
                SizedBox(height: 24.h),
                
                // Кнопка регистрации
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 24.w,
                            height: 24.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Зарегистрироваться',
                            style: TextStyle(fontSize: 16.sp),
                          ),
                  ),
                ),
                
                SizedBox(height: 16.h),
                
                // Кнопка пропуска
                if (widget.isOptional)
                  Center(
                    child: TextButton(
                      onPressed: _skip,
                      child: Text(
                        'Пропустить',
                        style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                      ),
                    ),
                  ),
                
                SizedBox(height: 24.h),
                
                // Условия
                Center(
                  child: Text(
                    'Регистрируясь, вы соглашаетесь с\nУсловиями использования и Политикой конфиденциальности',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}