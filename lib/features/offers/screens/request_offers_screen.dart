import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../../models/offer_model.dart';
import '../../../services/api_service.dart';
import '../../chat/screens/chat_screen.dart';

class RequestOffersScreen extends StatefulWidget {
  final int requestId;
  final String requestTitle;

  const RequestOffersScreen({super.key, required this.requestId, required this.requestTitle});

  @override
  State<RequestOffersScreen> createState() => _RequestOffersScreenState();
}

class _RequestOffersScreenState extends State<RequestOffersScreen> {
  final ApiService _apiService = ApiService();
  final _storage = const FlutterSecureStorage();
  bool _isLoading = true;
  List<OfferModel> _offers = [];
  bool _isInitiatingChat = false; 

  @override
  void initState() {
    super.initState();
    _fetchOffers();
  }

  Future<void> _fetchOffers() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null || !mounted) return;
    setState(() => _isLoading = true);
    final fetchedOffers = await _apiService.getOffersForRequest(
      token: token,
      requestId: widget.requestId,
    );
    if (mounted) {
      setState(() {
        _offers = fetchedOffers;
        _isLoading = false;
      });
    }
  }


  Future<void> _handleInitiateChat(OfferModel offer) async {
    setState(() => _isInitiatingChat = true);

    final token = await _storage.read(key: 'jwt_token');
    if (token == null || !mounted) {
      setState(() => _isInitiatingChat = false);
      return;
    }

    final response = await _apiService.initiateChat(token: token, offerId: offer.id);

    if (mounted) {
      if (response.statusCode == 200) {
        final chatId = response.data['id'];
        
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        final currentUserId = decodedToken['userId'];
        final currentUserRole = decodedToken['role']; 

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatId: chatId,
              currentUserId: currentUserId,
              offerId: offer.id, 
              currentUserRole: currentUserRole, 
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فشل بدء المحادثة.')));
      }
      setState(() => _isInitiatingChat = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('العروض على: ${widget.requestTitle}')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _offers.isEmpty
              ? const Center(child: Text('لا توجد عروض على هذا الطلب بعد.'))
              : ListView.builder(
                  itemCount: _offers.length,
                  itemBuilder: (context, index) {
                    final offer = _offers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('عرض من: ${offer.agentName ?? 'صاحب عقار'}', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Text(offer.description ?? 'لا يوجد وصف.'),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text('${offer.price} \$', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
                            ),
                            const Divider(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _isInitiatingChat ? null : () => _handleInitiateChat(offer),
                                icon: const Icon(Icons.chat_bubble_outline),
                                label: const Text('بدء محادثة'),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}