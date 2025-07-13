// lib/features/auth/screens/auth_check_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../home/screens/agent_home_screen.dart';
import '../../home/screens/home_screen.dart';
import 'login_screen.dart';

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  void _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 1));

    final token = await _storage.read(key: 'jwt_token');
    final role = await _storage.read(key: 'user_role');

    if (mounted) {
      if (token != null && role != null) {
        Widget homeScreen = (role == 'agent') 
            ? const AgentHomeScreen() 
            : const HomeScreen();

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => homeScreen),
        );

      } else {

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}