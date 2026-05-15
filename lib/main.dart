import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'providers/logo_provider.dart';
import 'providers/history_provider.dart';
import 'services/api_service.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Загружаем сохранённый токен при старте
  await ApiService.loadToken();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => BrandKitProvider()),
        ChangeNotifierProvider(create: (_) => UserHistoryProvider()),
      ],
      child: MaterialApp(
        title: 'Презентатор ИИ',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF121212),
          fontFamily: 'Inter',
          useMaterial3: true,
        ),
        home: const AuthWrapper(), // ← Используем обёртку вместо прямого HomeScreen
      ),
    );
  }
}

// Обёртка для проверки авторизации
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = ApiService.token;
    
    if (token != null && token.isNotEmpty) {
      try {
        final user = await ApiService.getProfile();
        // Устанавливаем пользователя в UserProvider
        context.read<UserProvider>().setUser(user, token: token);
        _isLoggedIn = true;
        print('✅ Пользователь авторизован: ${user.name}');
      } catch (e) {
        await ApiService.clearToken();
        _isLoggedIn = false;
        print('❌ Токен невалидный, очищен');
      }
    } else {
      _isLoggedIn = false;
    }
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF1DB954)),
        ),
      );
    }
    
    return _isLoggedIn ? const HomeScreen() : const LoginScreen();
  }
}