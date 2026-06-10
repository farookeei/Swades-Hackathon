import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'awesome_dio_interceptor.dart';
import '../exceptions/custom_exception.dart';

final dioClientProvider = Provider.autoDispose<DioClient>((ref) {
  return DioClient(baseUrl: 'https://hackathon-production-bead.up.railway.app');
});

class DioClient {
  final Dio _dio;

  DioClient({required String baseUrl}) : _dio = Dio() {
    _dio
      ..options.baseUrl = baseUrl
      ..options.connectTimeout = const Duration(seconds: 15)
      ..options.receiveTimeout = const Duration(seconds: 15)
      ..interceptors.add(AwesomeDioInterceptor(baseUrl: baseUrl));
  }

  //?mock auth
  void setUserId(String userId) {
    _dio.options.headers['X-User-Id'] = userId;
  }

  void removeUserId() {
    _dio.options.headers.remove('X-User-Id');
  }

  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(url, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String url, {dynamic data}) async {
    try {
      return await _dio.post(url, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.delete(url, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  CustomException _handleError(DioException error) {
    String message = 'An unexpected error occurred';
    int? statusCode = error.response?.statusCode;

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      message = 'Connection timed out';
    } else if (error.response != null) {
      if (statusCode == 409) {
        message = 'Slot already booked';
      } else {
        message =
            error.response?.data['message'] ?? 'Server error ($statusCode)';
      }
    } else if (error.type == DioExceptionType.connectionError) {
      message = 'No internet connection or server is unreachable';
    }

    return CustomException(message: message, statusCode: statusCode);
  }
}
