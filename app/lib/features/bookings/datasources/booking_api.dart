import '../../../core/network/dio_client.dart';

class BookingApi {
  final DioClient _dioClient;

  BookingApi(this._dioClient);

  Future<List<dynamic>> fetchBookings(String userId) async {
    try {
      final response = await _dioClient.get('/bookings', queryParameters: {'user_id': userId});
      return response.data as List;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createBooking({
    required int venueId,
    required String userId,
    required String date,
    required String slot,
  }) async {
    try {
      final response = await _dioClient.post(
        '/bookings',
        data: {
          'venue_id': venueId,
          'user_id': userId,
          'date': date,
          'slot': slot,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cancelBooking(int bookingId) async {
    try {
      await _dioClient.delete('/bookings/$bookingId');
    } catch (e) {
      rethrow;
    }
  }
}
