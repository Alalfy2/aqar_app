
import 'package:flutter/material.dart';
import '../../../models/request_model.dart';
import '/features/offers/submit_offer_screen.dart'; 

class RequestDetailsScreen extends StatelessWidget {
  final RequestModel request;

  const RequestDetailsScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('تفاصيل الطلب: ${request.title}'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('العنوان: ${request.title}', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('بواسطة: ${request.investorName ?? "غير معروف"}', style: Theme.of(context).textTheme.titleSmall),
              const Divider(height: 32),
              Text('الوصف:', style: Theme.of(context).textTheme.titleMedium),
              Text(request.description ?? "لا يوجد وصف تفصيلي."),
              const SizedBox(height: 16),
              Text('السعر المطلوب: ${request.price ?? "N/A"} \$', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
              const SizedBox(height: 16),
              Text('الموقع: ${request.city ?? "-"}, ${request.country ?? "-"}'),
              const Spacer(), 

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SubmitOfferScreen(requestId: request.id),
                      ),
                    );
                  },
                  // ------------------------------------
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: const Text('تقديم عرض على هذا الطلب'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}