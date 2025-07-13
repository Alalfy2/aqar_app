import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../services/api_service.dart';
import '../../home/screens/home_screen.dart';
import '../../home/screens/agent_home_screen.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  final _storage = const FlutterSecureStorage();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

 final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile'],
    clientId: Platform.isIOS 
        ? '868140966409-ljgssc9pnvrb7ojc5kk3rry6tm17hm.apps.googleusercontent.com' // <-- هذا هو الصحيح
        : null,
  );

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorMessage('يرجى إدخال البريد الإلكتروني وكلمة المرور');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.loginUser(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) setState(() => _isLoading = false);

      if (mounted && response.statusCode == 200) {
        final token = response.data['token'];
        final userRole = response.data['user']['role'];
        await _storage.write(key: 'jwt_token', value: token);

        await _storage.write(key: 'user_role', value: userRole);

        Widget destinationScreen = (userRole == 'agent')
            ? const AgentHomeScreen()
            : const HomeScreen();

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => destinationScreen),
          (Route<dynamic> route) => false,
        );
      } else if (mounted) {

        print('Login failed. Server response: ${response.data}');

        final errorMessage = response.data?['error'] ?? 'بيانات الدخول غير صحيحة.';
        _showErrorMessage(errorMessage);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorMessage('حدث خطأ أثناء تسجيل الدخول. يرجى المحاولة مرة أخرى.');
      }
    }
  }

  void _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      await _googleSignIn.signOut();
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('فشل في الحصول على معلومات التوثيق من Google');
      }

      print('Google Access Token: ${googleAuth.accessToken}');
      print('Google ID Token: ${googleAuth.idToken}');
      
      final platform = Platform.isAndroid ? 'android' : 'ios';
      
      final response = await _apiService.googleLogin(
        googleToken: googleAuth.idToken!,
        platform: platform,
      );

      if (mounted) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          final token = response.data['token'];
          final userRole = response.data['user']['role'];
          await _storage.write(key: 'jwt_token', value: token);
          

          await _storage.write(key: 'user_role', value: userRole);
              
          Widget destinationScreen = (userRole == 'agent') 
              ? const AgentHomeScreen() 
              : const HomeScreen();
              
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => destinationScreen),
            (Route<dynamic> route) => false,
          );
        } else {
          setState(() => _isLoading = false);
          

          print('Google Sign-In failed. Server response: ${response.data}');

          final errorMessage = response.data?['error'] ?? 'فشل تسجيل الدخول عبر Google.';
          _showErrorMessage(errorMessage);
        }
      }
    } catch (error) {
      print('Google Sign-In Error: $error');
      if (mounted) {
        setState(() => _isLoading = false);
        
        String errorMessage;
        if (error.toString().contains('network_error')) {
          errorMessage = 'خطأ في الاتصال بالإنترنت. يرجى المحاولة مرة أخرى.';
        } else if (error.toString().contains('sign_in_canceled')) {
          errorMessage = 'تم إلغاء عملية تسجيل الدخول.';
        } else if (error.toString().contains('sign_in_failed')) {
          errorMessage = 'فشل تسجيل الدخول عبر Google. يرجى المحاولة مرة أخرى.';
        } else {
          errorMessage = 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';
        }
        
        _showErrorMessage(errorMessage);
      }
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              const Text(
                'مرحباً بعودتك!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'سجل الدخول للمتابعة',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              CustomTextField(
                controller: _emailController,
                labelText: 'البريد الإلكتروني',
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _passwordController,
                labelText: 'كلمة المرور',
                isPassword: true,
                icon: Icons.lock_outline,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ForgotPasswordScreen(),
                    ),
                  ),
                  child: const Text('هل نسيت كلمة المرور؟'),
                ),
              ),
              const SizedBox(height: 20),
              CustomButton(
                onPressed: _isLoading ? null : _handleLogin,
                text: _isLoading ? 'جاري الدخول...' : 'تسجيل الدخول',
              ),
              const SizedBox(height: 16),
              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('أو'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
  onPressed: _isLoading ? null : _handleGoogleSignIn,
  icon: const Icon(Icons.g_mobiledata, size: 24), 
  label: Text(
    _isLoading ? 'جاري تسجيل الدخول...' : 'تسجيل الدخول باستخدام Google',
  ),
  style: ElevatedButton.styleFrom(
    minimumSize: const Size(double.infinity, 50),
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    side: BorderSide(color: Colors.grey.shade300),
    elevation: 1,
  ),
),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('ليس لديك حساب؟'),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    ),
                    child: const Text('أنشئ حساباً'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}