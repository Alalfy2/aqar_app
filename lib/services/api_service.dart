import 'package:dio/dio.dart';
import '../models/request_model.dart';
import '../models/offer_model.dart';

class ApiService {
 //'http://10.0.2.2:3001/api'  محاكي أندرويد
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:3001/api'));

  // --- Auth Functions ---
  Future<Response> registerUser({
    required String email,
    required String password,
    String? phoneNumber,
    String? role,
    required String firstName,
    required String lastName,
    required String username,
    String? dateOfBirth,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        'phone_number': phoneNumber,
        'role': role,
        'first_name': firstName,
        'last_name': lastName,
        'username': username,
        'date_of_birth': dateOfBirth,
      });
      return response;
    } on DioException catch (e) {
      return e.response ?? Response(requestOptions: RequestOptions(path: ''));
    }
  }

  Future<Response> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return response;
    } on DioException catch (e) {
      return e.response ?? Response(requestOptions: RequestOptions(path: ''));
    }
  }

  Future<Response> forgotPassword({required String email}) async {
    try {
      final response = await _dio.post(
        '/auth/forgot-password',
        data: {'email': email},
      );
      return response;
    } on DioException catch (e) {
      return e.response ?? Response(requestOptions: RequestOptions(path: ''));
    }
  }

  Future<Response> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/reset-password',
        data: {'token': token, 'newPassword': newPassword},
      );
      return response;
    } on DioException catch (e) {
      return e.response ?? Response(requestOptions: RequestOptions(path: ''));
    }
  }
  
  Future<Response> googleLogin({
    required String googleToken,
    required String platform,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/google-login',
        data: {
          'token': googleToken,
          'platform': platform,
        },
      );
      return response;
    } on DioException catch (e) {
      return e.response ?? Response(requestOptions: RequestOptions(path: ''));
    }
  }

  // --- Request Functions ---
  Future<List<RequestModel>> getMyRequests({required String token}) async {
    try {
      final response = await _dio.get(
        '/my-requests',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => RequestModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching my requests: $e');
      return [];
    }
  }

  Future<List<RequestModel>> getOpenRequests({required String token}) async {
    try {
      final response = await _dio.get(
        '/requests',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => RequestModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching open requests: $e');
      return [];
    }
  }

  Future<Response> createRequest({
    required String token,
    required String title,
    String? description,
    String? country,
    String? city,
    double? price,
    Map<String, dynamic>? specs,
  }) async {
    try {
      final response = await _dio.post(
        '/requests',
        data: {
          'title': title,
          'description': description,
          'country': country,
          'city': city,
          'price': price,
          'specs': specs,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response;
    } on DioException catch (e) {
      return e.response ?? Response(requestOptions: RequestOptions(path: ''));
    }
  }

  // --- Offer Functions ---
  Future<List<OfferModel>> getOffersForRequest({
    required String token,
    required int requestId,
  }) async {
    try {
      final response = await _dio.get(
        '/requests/$requestId/offers',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => OfferModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching offers: $e');
      return [];
    }
  }

  Future<Response> submitOffer({
    required String token,
    required int requestId,
    required double price,
    String? description,
    List<String>? imagesUrls,
  }) async {
    try {
      final response = await _dio.post(
        '/requests/$requestId/offers',
        data: {
          'price': price,
          'description': description,
          'images_urls': imagesUrls,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response;
    } on DioException catch (e) {
      return e.response ?? Response(requestOptions: RequestOptions(path: ''));
    }
  }
  
  // --- Deal Flow Functions ---
  Future<Response> initiateChat({
    required String token,
    required int offerId,
  }) async {
    try {
      final response = await _dio.post(
        '/offers/$offerId/initiate-chat',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response;
    } on DioException catch (e) {
      return e.response ?? Response(requestOptions: RequestOptions(path: ''));
    }
  }

  Future<Response> requestDealClosure({
    required String token,
    required int offerId,
    double? finalPrice,
  }) async {
    try {
      final response = await _dio.post(
        '/offers/$offerId/request-closure',
        data: {'final_price': finalPrice},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response;
    } on DioException catch (e) {
      return e.response ?? Response(requestOptions: RequestOptions(path: ''));
    }
  }

  Future<Response> confirmDeal({required String token, required int dealId}) async {
    try {
      final response = await _dio.post('/deals/$dealId/confirm', options: Options(headers: {'Authorization': 'Bearer $token'}));
      return response;
    } on DioException catch (e) {
      return e.response ?? Response(requestOptions: RequestOptions(path: ''));
    }
  }

  Future<Response> rejectDeal({required String token, required int dealId}) async {
    try {
      final response = await _dio.post('/deals/$dealId/reject', options: Options(headers: {'Authorization': 'Bearer $token'}));
      return response;
    } on DioException catch (e) {
      return e.response ?? Response(requestOptions: RequestOptions(path: ''));
    }
  }
}