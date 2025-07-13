import 'package:aqar_app/features/auth/screens/login_screen.dart';
import 'package:aqar_app/features/requests/screens/create_request_screen.dart';
import 'package:aqar_app/models/request_model.dart';
import 'package:aqar_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:aqar_app/features/offers/screens/request_offers_screen.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final _storage = const FlutterSecureStorage();
  bool _isLoading = true;
  List<RequestModel> _myRequests = [];

  @override
  void initState() {
    super.initState();
    _fetchMyRequests();
  }

  Future<void> _fetchMyRequests() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    final requests = await _apiService.getMyRequests(token: token);
    if (mounted) {
      setState(() {
        _myRequests = requests;
        _isLoading = false;
      });
    }
  }

  void _logout() async {
    await _storage.delete(key: 'jwt_token');
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلباتي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'تسجيل الخروج',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchMyRequests,
              child: _myRequests.isEmpty
                  ? Center(child: Text('ليس لديك طلبات حاليًا.', style: Theme.of(context).textTheme.titleMedium))
                  : ListView.builder(
                      itemCount: _myRequests.length,
                      itemBuilder: (context, index) {
                        final request = _myRequests[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: ListTile(
                            title: Text(request.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('الحالة: ${request.status}'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => RequestOffersScreen(requestId: request.id, requestTitle: request.title),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const CreateRequestScreen()),
        ).then((_) => _fetchMyRequests()),
        label: const Text('إضافة طلب'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}