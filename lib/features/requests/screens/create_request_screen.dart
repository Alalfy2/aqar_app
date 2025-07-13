import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/services/api_service.dart'; 

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  // --- State and Services ---
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  // --- Controllers ---
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _specsController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _priceController.dispose();
    _specsController.dispose();
    super.dispose();
  }

  // --- Main Logic to Handle Request Creation ---
  void _handleCreateRequest() async {
    // Basic validation to ensure title is not empty
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال عنوان للطلب')),
      );
      return;
    }

    const String tempToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJpbnZlc3RvciIsImlhdCI6MTc1MTUwMTY5MSwiZXhwIjoxNzUxNTg4MDkxfQ.7Kn7t1EsM_Q5FMSg3sy-RcU9AYC4voJ1tf3y0m5M_o8";

    setState(() {
      _isLoading = true;
    });

    // Call the API
    final response = await _apiService.createRequest(
      token: tempToken,
      title: _titleController.text,
      description: _descriptionController.text,
      country: _countryController.text,
      city: _cityController.text,
      price: double.tryParse(_priceController.text) ?? 0.0, // Convert price from text to number
      specs: {'details': _specsController.text}, // Convert specs text to a simple JSON object
    );

    // Hide loading indicator
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    // Handle the server's response
    if (mounted) {
      if (response.statusCode == 201) {
        // On Success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إنشاء الطلب بنجاح!')),
        );
        Navigator.of(context).pop(); // Go back to the previous screen
      } else {
        // On Failure
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل إنشاء الطلب. يرجى المحاولة مرة أخرى.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء طلب جديد'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'العنوان',
                  hintText: 'مثال: شقة من ثلاث غرف نوم',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 16.0),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'الوصف',
                  hintText: 'اكتب وصفاً كاملاً للعقار المطلوب',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16.0),

              // Country and City Fields
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _countryController,
                      decoration: const InputDecoration(
                        labelText: 'البلد',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.public),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'المدينة',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_city),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // Price Field
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'السعر',
                  hintText: 'أدخل السعر المطلوب',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16.0),

              // Specifications Field
              TextFormField(
                controller: _specsController,
                decoration: const InputDecoration(
                  labelText: 'المواصفات',
                  hintText: 'مثال: مساحة 150 متر مربع، 2 حمام',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.settings),
                ),
              ),
              const SizedBox(height: 32.0),

              // Create Request Button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleCreateRequest, // Disable button while loading
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white) // Show progress indicator
                    : const Text('إنشاء الطلب'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}