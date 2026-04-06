import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();

  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final String userName = prefs.getString('userName') ?? "Estudiante";
  final String userEmail = prefs.getString('userEmail') ?? "";

  runApp(CCUApp(
    isLoggedIn: isLoggedIn,
    userName: userName,
    userEmail: userEmail,
  ));
}

class CCUApp extends StatefulWidget {
  final bool isLoggedIn;
  final String userName;
  final String userEmail;

  const CCUApp({
    super.key,
    required this.isLoggedIn,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<CCUApp> createState() => _CCUAppState();
}

class _CCUAppState extends State<CCUApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CCU',
      themeMode: _themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      home: widget.isLoggedIn
          ? HomeScreen(
              userName: widget.userName,
              userEmail: widget.userEmail,
              onToggleTheme: toggleTheme,
            )
          : LoginScreen(onToggleTheme: toggleTheme),
    );
  }
}