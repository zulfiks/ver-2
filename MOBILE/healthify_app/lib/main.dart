import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart'; // Import dashboard kembali

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark, 
    ),
  );
  
  runApp(const HealthifyApp());
}

class HealthifyApp extends StatelessWidget {
  const HealthifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Healthify',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white, 
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF10B981), 
          primary: const Color(0xFF10B981),
        ),
        fontFamily: 'Roboto', 
      ),
      // UBAH: initialRoute langsung ke dashboard
      home: const DashboardScreen(userData: null), 
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}