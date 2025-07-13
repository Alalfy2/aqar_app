import 'package:aqar_app/features/auth/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../models/request_model.dart';
import '../../../services/api_service.dart';
import '../../requests/screens/request_details_screen.dart';

class AgentHomeScreen extends StatefulWidget {
  const AgentHomeScreen({super.key});

  @override
  State<AgentHomeScreen> createState() => _AgentHomeScreenState();
}

class _AgentHomeScreenState extends State<AgentHomeScreen> {
  final ApiService _apiService = ApiService();
  final _storage = const FlutterSecureStorage();
  bool _isLoading = true;
  List<RequestModel> _requests = [];

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) {
       if (mounted) setState(() => _isLoading = false);
      return;
    }
    final fetchedRequests = await _apiService.getOpenRequests(token: token);
    if (mounted) {
      setState(() {
        _requests = fetchedRequests;
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
        title: const Text('الطلبات المتاحة'),
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
              onRefresh: _fetchRequests,
              child: _requests.isEmpty
                  ? Center(child: Text('لا توجد طلبات متاحة حالياً.', style: Theme.of(context).textTheme.titleMedium))
                  : ListView.builder(
                      itemCount: _requests.length,
                      itemBuilder: (context, index) {
                        final request = _requests[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          elevation: 4,
                          child: ListTile(
                            title: Text(request.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('بواسطة: ${request.investorName ?? 'غير معروف'}'),
                            trailing: Text('${request.price ?? 'N/A'} \$', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => RequestDetailsScreen(request: request)),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}