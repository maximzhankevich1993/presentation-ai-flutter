import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'providers/logo_provider.dart';
import 'providers/history_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        home: const AuthWrapper(),
      ),
    );
  }
}

// Обёртка для загрузки пользователя
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final userProvider = context.read<UserProvider>();
    
    // Загружаем пользователя из токена
    await userProvider.loadUser();
    
    setState(() {
      _isAuthenticated = userProvider.isLoggedIn;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF1DB954),
          ),
        ),
      );
    }
    
    return _isAuthenticated ? const HomeScreen() : const LoginScreen();
  }
}