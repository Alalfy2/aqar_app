import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;

  void _handleForgotPassword() async {
    if (_emailController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _message = null;
    });

    final response = await _apiService.forgotPassword(email: _emailController.text.trim());
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        _isSuccess = response.statusCode == 200;
        if (response.data != null && response.data is Map) {
          _message = response.data['message'] ?? response.data['error'] ?? 'حدث خطأ غير متوقع.';
        } else {
          _message = _isSuccess ? 'تم إرسال الطلب بنجاح.' : 'فشل الاتصال بالسيرفر.';
        }
      });

      if (_isSuccess) {
         Future.delayed(const Duration(seconds: 2), () {
             if(mounted) {
                 Navigator.of(context).push(
                     MaterialPageRoute(builder: (context) => ResetPasswordScreen(email: _emailController.text.trim())),
                 );
             }
         });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('استعادة كلمة المرور')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('أدخل بريدك الإلكتروني المسجل لدينا لطلب إعادة تعيين كلمة المرور.'),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'البريد الإلكتروني',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleForgotPassword,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _isLoading 
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white)) 
                  : const Text('إرسال طلب'),
            ),
            const SizedBox(height: 20),
            if (_message != null)
              Text(
                _message!,
                style: TextStyle(color: _isSuccess ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              )
          ],
        ),
      ),
    );
  }
}