import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;

  void _handleResetPassword() async {
    if (_tokenController.text.isEmpty || _passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء إدخال الرمز وكلمة المرور الجديدة.')),
        );
        return;
    }

    setState(() => _isLoading = true);

    final response = await _apiService.resetPassword(
      token: _tokenController.text.trim(),
      newPassword: _passwordController.text,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تغيير كلمة المرور بنجاح! يمكنك الآن تسجيل الدخول.')),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false
        );
      } else {
        final errorMessage = response.data?['error'] ?? 'حدث خطأ ما.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إعادة تعيين كلمة المرور')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('تم إرسال رمز إعادة التعيين إلى ${widget.email}.\n\nفي التطبيق الحقيقي، سيصل هذا في رابط عبر الإيميل. **لغرض الاختبار، انسخ الرمز من الـ console الخاص بالـ Backend والصقه هنا.**'),
            const SizedBox(height: 20),
            TextField(
              controller: _tokenController,
              decoration: const InputDecoration(labelText: 'الرمز (Token)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'كلمة المرور الجديدة', border: OutlineInputBorder()),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleResetPassword,
               style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('إعادة التعيين'),
            ),
          ],
        ),
      ),
    );
  }
}