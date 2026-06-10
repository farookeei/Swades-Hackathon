import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../datasources/booking_api.dart';
import '../models/booking.dart';
import 'i_booking_repository.dart';

import '../../../core/exceptions/custom_exception.dart';

final bookingApiProvider = Provider.autoDispose<BookingApi>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return BookingApi(dioClient);
});

final bookingRepositoryProvider = Provider.autoDispose<IBookingRepository>((ref) {
  final api = ref.watch(bookingApiProvider);
  return BookingRepository(api);
});

class BookingRepository implements IBookingRepository {
  final BookingApi _bookingApi;

  BookingRepository(this._bookingApi);

  @override
  Future<List<Booking>> getUserBookings(String userId) async {
    try {
      final list = await _bookingApi.fetchBookings(userId);
      return list.map((json) => Booking.fromJson(json)).toList();
    } on CustomException {
      rethrow;
    } catch (e) {
      throw CustomException(message: 'Failed to process user bookings: $e');
    }
  }

  @override
  Future<Booking> createBooking({
    required int venueId,
    required String userId,
    required String date,
    required String slot,
  }) async {
    try {
      final data = await _bookingApi.createBooking(
        venueId: venueId,
        userId: userId,
        date: date,
        slot: slot,
      );
      return Booking.fromJson(data);
    } on CustomException {
      rethrow;
    } catch (e) {
      throw CustomException(message: 'Failed to process create booking: $e');
    }
  }

  @override
  Future<void> cancelBooking(int bookingId) async {
    try {
      await _bookingApi.cancelBooking(bookingId);
    } on CustomException {
      rethrow;
    } catch (e) {
      throw CustomException(message: 'Failed to process cancel booking: $e');
    }
  }
}
