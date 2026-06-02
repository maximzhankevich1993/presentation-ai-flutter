import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'providers/logo_provider.dart';
import 'providers/history_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Загружаем токен из SharedPreferences при старте
  await ApiService.loadToken();
  
  // Создаём провайдер и пробуем загрузить пользователя (если токен есть)
  final userProvider = UserProvider();
  await userProvider.loadUser();
  
  runApp(MyApp(userProvider: userProvider));
}

class MyApp extends StatelessWidget {
  final UserProvider userProvider;
  
  const MyApp({super.key, required this.userProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: userProvider),
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
        home: Consumer<UserProvider>(
          builder: (context, userProvider, _) {
            if (userProvider.isLoading) {
              return const Scaffold(
                backgroundColor: Color(0xFF121212),
                body: Center(
                  child: CircularProgressIndicator(color: Color(0xFF1DB954)),
                ),
              );
            }
            // Если пользователь залогинен — показываем HomeScreen, иначе — LoginScreen
            return userProvider.isLoggedIn ? const HomeScreen() : const LoginScreen();
          },
        ),
      ),
    );
  }
}