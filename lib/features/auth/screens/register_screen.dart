import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String _selectedRole = 'investor';

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // في ملف register_screen.dart

void _handleRegistration() async {
  setState(() => _isLoading = true);

  final response = await _apiService.registerUser(
    email: _emailController.text.trim(),
    password: _passwordController.text,
    phoneNumber: _phoneController.text.trim(),
    role: _selectedRole,
    firstName: _firstNameController.text.trim(),
    lastName: _lastNameController.text.trim(),
    username: _usernameController.text.trim(),
    dateOfBirth: _dobController.text.trim(),
  );

  if (mounted) setState(() => _isLoading = false);

  if (!mounted) return;

  if (response.statusCode == 201) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إنشاء الحساب بنجاح! يمكنك الآن تسجيل الدخول.')),
    );
    Navigator.of(context).pop();
  } else {
    String errorMessage = 'فشل إنشاء الحساب. حدث خطأ غير متوقع.';
    
    print("Registration failed with status: ${response.statusCode}");
    print("Response body: ${response.data}");

    if (response.data != null && response.data is Map<String, dynamic>) {
      errorMessage = response.data['error'] ?? 'فشل إنشاء الحساب.';
    } else if (response.data != null) {
      errorMessage = response.data.toString();
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            Text('Sign Up', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: CustomButton(text: 'Investor', onPressed: () => setState(() => _selectedRole = 'investor'), color: _selectedRole == 'investor' ? Colors.blue : Colors.grey)),
                const SizedBox(width: 16),
                Expanded(child: CustomButton(text: 'Agent', onPressed: () => setState(() => _selectedRole = 'agent'), color: _selectedRole == 'agent' ? Colors.blue : Colors.grey)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: CustomTextField(controller: _firstNameController, labelText: 'First Name', icon: Icons.person)),
                const SizedBox(width: 16),
                Expanded(child: CustomTextField(controller: _lastNameController, labelText: 'Last Name', icon: Icons.person_outline)),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(controller: _usernameController, labelText: 'Username', icon: Icons.alternate_email),
            const SizedBox(height: 16),
            CustomTextField(controller: _emailController, labelText: 'Email', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            CustomTextField(controller: _phoneController, labelText: 'Mobile number', icon: Icons.phone_iphone, keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            CustomTextField(controller: _dobController, labelText: 'Date of Birth (YYYY-MM-DD)', icon: Icons.calendar_today, keyboardType: TextInputType.datetime),
            const SizedBox(height: 16),
            CustomTextField(controller: _passwordController, labelText: 'Password', isPassword: true, icon: Icons.lock_outline),
            const SizedBox(height: 20),
            CustomButton(
              onPressed: _isLoading ? null : _handleRegistration,
              text: _isLoading ? 'جاري الإنشاء...' : 'Sign Up',
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
