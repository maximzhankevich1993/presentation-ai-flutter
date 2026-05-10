import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'register_screen.dart';
import 'home_screen.dart';

// ═══════════════════════════════════════════════════════════════
// DESIGN TOKENS
// ═══════════════════════════════════════════════════════════════
class _T {
  static const bgBase    = Color(0xFF121212);
  static const bgSurface = Color(0xFF1A1A1A);
  static const bgCard    = Color(0xFF1E1E1E);
  static const bgHover   = Color(0xFF252525);
  static const border    = Color(0xFF2A2A2A);
  static const txtPrimary   = Colors.white;
  static const txtSecondary = Color(0xFF9A9A9A);
  static const txtMuted     = Color(0xFF4A4A4A);
  static const accent       = Color(0xFF1DB954);
  static const accentLight  = Color(0xFF1ED760);
  static const accentDim    = Color(0xFF1DB95420);
  static const danger       = Color(0xFFFF3B30);
  static const gold         = Color(0xFFFFD700);
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _emailNode = FocusNode();
  final _passwordNode = FocusNode();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _emailNode.dispose();
    _passwordNode.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    // Валидация
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Введите корректный email');
      return;
    }
    if (password.isEmpty) {
      setState(() => _error = 'Введите пароль');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Пароль должен быть не менее 6 символов');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Имитация входа (заменить на реальный API-запрос)
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Сохраняем пользователя
      final up = Provider.of<UserProvider>(context, listen: false);
      await up.setUserEmail(email);
      await up.setUserName(email.split('@').first);

      // Показываем успех
      _showSuccess();

      // Задержка чтобы снекбар был виден
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // Переход на главный экран
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Неверный email или пароль');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_T.accent, _T.accentLight]),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 10),
          const Text(
            'С возвращением! 🎉',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ]),
        backgroundColor: _T.accent.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _T.bgBase,
      appBar: AppBar(
        backgroundColor: _T.bgBase,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: _T.txtSecondary, size: 17),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Войти',
          style: TextStyle(color: _T.txtPrimary, fontWeight: FontWeight.w600, fontSize: 15),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // ── Лого ──────────────────────────────────────────
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_T.accent, _T.accentLight]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _T.accent.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 20),

              // ── Заголовок ─────────────────────────────────────
              const Text(
                'С возвращением!',
                style: TextStyle(
                  color: _T.txtPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Войдите чтобы продолжить работу',
                style: TextStyle(color: _T.txtSecondary, fontSize: 13, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // ── Ошибка ────────────────────────────────────────
              if (_error != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _T.danger.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _T.danger.withOpacity(0.2)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.error_outline_rounded, color: _T.danger, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: _T.danger, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _error = null),
                      child: const Icon(Icons.close_rounded, color: _T.danger, size: 14),
                    ),
                  ]),
                ),

              // ── Поле Email ────────────────────────────────────
              _FormField(
                controller: _emailCtrl,
                focusNode: _emailNode,
                hint: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                nextNode: _passwordNode,
              ),
              const SizedBox(height: 12),

              // ── Поле Пароль ──────────────────────────────────
              _FormField(
                controller: _passwordCtrl,
                focusNode: _passwordNode,
                hint: 'Пароль',
                icon: Icons.lock_outline_rounded,
                obscure: _obscure,
                onSubmit: _login,
                suffix: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: _T.txtMuted,
                    size: 18,
                  ),
                  splashRadius: 16,
                ),
              ),

              // ── Забыли пароль ────────────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: forgot password
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.only(top: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Забыли пароль?',
                    style: TextStyle(color: _T.txtSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Кнопка ────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: _loading ? null : _login,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: _loading
                          ? null
                          : const LinearGradient(
                              colors: [Color(0xFF169C46), _T.accent, _T.accentLight],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                      color: _loading ? _T.bgHover : null,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: _loading
                          ? null
                          : [
                              BoxShadow(
                                color: _T.accent.withOpacity(0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                    ),
                    child: Center(
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: _T.accent, strokeWidth: 2),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Войти',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Нет аккаунта ─────────────────────────────────
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text(
                  'Нет аккаунта? ',
                  style: TextStyle(color: _T.txtSecondary, fontSize: 13),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: const Text(
                    'Зарегистрироваться',
                    style: TextStyle(
                      color: _T.accentLight,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// FORM FIELD
// ═══════════════════════════════════════════════════════════════
class _FormField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final FocusNode? nextNode;
  final VoidCallback? onSubmit;
  final bool obscure;
  final Widget? suffix;

  const _FormField({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.nextNode,
    this.onSubmit,
    this.obscure = false,
    this.suffix,
  });

  @override
  State<_FormField> createState() => _FormFieldState();
}

class _FormFieldState extends State<_FormField> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() {
      if (mounted) setState(() => _focused = widget.focusNode.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: _T.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _focused ? _T.accent.withOpacity(0.5) : _T.border,
          width: _focused ? 1.5 : 1,
        ),
        boxShadow: _focused
            ? [BoxShadow(color: _T.accent.withOpacity(0.1), blurRadius: 8)]
            : null,
      ),
      child: Row(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
          child: Icon(
            widget.icon,
            color: _focused ? _T.accentLight : _T.txtMuted,
            size: 18,
          ),
        ),
        Expanded(
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            obscureText: widget.obscure,
            style: const TextStyle(color: _T.txtPrimary, fontSize: 14, fontWeight: FontWeight.w500),
            keyboardType: widget.keyboardType,
            textInputAction: widget.nextNode != null
                ? TextInputAction.next
                : widget.onSubmit != null
                    ? TextInputAction.done
                    : null,
            onSubmitted: (_) {
              if (widget.nextNode != null) {
                widget.nextNode!.requestFocus();
              } else {
                widget.onSubmit?.call();
              }
            },
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(color: _T.txtMuted, fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(right: 16, top: 14, bottom: 14),
              isDense: true,
            ),
          ),
        ),
        if (widget.suffix != null) widget.suffix!,
        if (widget.suffix == null) const SizedBox(width: 8),
      ]),
    );
  }
}