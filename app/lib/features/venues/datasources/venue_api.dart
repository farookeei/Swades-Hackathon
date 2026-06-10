import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';

final venueApiProvider = Provider.autoDispose<VenueApi>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return VenueApi(dioClient);
});

class VenueApi {
  final DioClient _dioClient;

  VenueApi(this._dioClient);

  Future<List<dynamic>> fetchVenues() async {
    final response = await _dioClient.get('/venues');
    return response.data as List;
  }

  Future<Map<String, dynamic>> fetchSlots(int venueId, String date) async {
    final response = await _dioClient.get(
      '/venues/$venueId/slots',
      queryParameters: {'date': date},
    );
    return response.data as Map<String, dynamic>;
  }
}
