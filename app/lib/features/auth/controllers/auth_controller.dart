import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';

final authProvider = StateNotifierProvider<AuthController, String?>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AuthController(dioClient);
});

class AuthController extends StateNotifier<String?> {
  final DioClient _dioClient;

  AuthController(this._dioClient) : super(null);

  void login(String userId) {
    state = userId;
    _dioClient.setUserId(userId);
  }

  void logout() {
    state = null;
    _dioClient.removeUserId();
  }
}
