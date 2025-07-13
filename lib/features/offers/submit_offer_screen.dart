// lib/features/offers/screens/submit_offer_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../services/api_service.dart'; 

class SubmitOfferScreen extends StatefulWidget {
  final int requestId;

  const SubmitOfferScreen({super.key, required this.requestId});

  @override
  State<SubmitOfferScreen> createState() => _SubmitOfferScreenState();
}

class _SubmitOfferScreenState extends State<SubmitOfferScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  final _storage = const FlutterSecureStorage();
  bool _isLoading = false;

  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  @override
  void dispose() {
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmitOffer() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final token = await _storage.read(key: 'jwt_token');
      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('خطأ في المصادقة، يرجى تسجيل الدخول مرة أخرى')),
          );
        }
        setState(() { _isLoading = false; });
        return;
      }

      final response = await _apiService.submitOffer(
        token: token,
        requestId: widget.requestId,
        price: double.parse(_priceController.text),
        description: _descriptionController.text,
        imagesUrls: [], 
      );

      if (mounted) {
        setState(() { _isLoading = false; });

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تقديم عرضك بنجاح!')),
          );
          int count = 0;
          Navigator.of(context).popUntil((_) => count++ >= 2);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('فشل تقديم العرض. حاول مرة أخرى.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تقديم عرض على الطلب رقم ${widget.requestId}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'السعر المعروض',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال السعر';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'وصف وتفاصيل العرض',
                  hintText: 'اذكر تفاصيل العقار الذي تعرضه...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 5,
                 validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال وصف للعرض';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmitOffer,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text('إرسال العرض'),
              )
            ],
          ),
        ),
      ),
    );
  }
}