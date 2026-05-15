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
  
  // Загружаем сохранённый токен при старте приложения
  await ApiService.loadToken();
  
  // Проверяем токен и обновляем профиль если нужно
  bool isLoggedIn = false;
  if (ApiService.token != null) {
    try {
      final user = await ApiService.getProfile();
      isLoggedIn = true;
      print('✅ Пользователь авторизован: ${user.name}');
    } catch (e) {
      // Токен невалидный, очищаем
      await ApiService.clearToken();
      print('❌ Токен невалидный, очищен');
    }
  }
  
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  
  const MyApp({super.key, this.isLoggedIn = false});

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
        home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
      ),
    );
  }
}