import '../models/booking.dart';

abstract class IBookingRepository {
  Future<List<Booking>> getUserBookings(String userId);
  Future<Booking> createBooking({
    required int venueId,
    required String userId,
    required String date,
    required String slot,
  });
  Future<void> cancelBooking(int bookingId);
}
