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
  
  // Загружаем сохранённый токен при старте (без редиректа)
  await ApiService.loadToken();
  
  // Если токен есть — тихо обновляем профиль в фоне
  if (ApiService.token != null) {
    try {
      final user = await ApiService.getProfile();
      print('✅ Пользователь авторизован: ${user.name}');
    } catch (e) {
      await ApiService.clearToken();
      print('❌ Токен невалидный, очищен');
    }
  }
  
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
        home: const HomeScreen(), // Всегда показываем HomeScreen
      ),
    );
  }
}