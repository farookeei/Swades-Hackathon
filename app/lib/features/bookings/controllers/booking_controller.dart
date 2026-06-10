import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../venues/controllers/venue_detail_controller.dart';
import '../models/booking.dart';
import '../repositories/i_booking_repository.dart';
import '../repositories/booking_repository.dart';

final bookingControllerProvider =
    AutoDisposeNotifierProvider<BookingController, AsyncValue<List<Booking>>>(() {
  return BookingController();
});

class BookingController extends AutoDisposeNotifier<AsyncValue<List<Booking>>> {
  late final IBookingRepository _repository;

  @override
  AsyncValue<List<Booking>> build() {
    _repository = ref.watch(bookingRepositoryProvider);
    final userId = ref.watch(authProvider);
    if (userId == null) {
      return const AsyncValue.data([]);
    }
    
    // Defer the initial fetch until state is returned
    Future.microtask(() => _fetchBookings(userId));
    return const AsyncLoading();
  }

  Future<void> _fetchBookings(String userId) async {
    try {
      final list = await _repository.getUserBookings(userId);
      state = AsyncValue.data(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> bookSlot({
    required int venueId,
    required DateTime date,
    required String slot,
    required BuildContext context,
  }) async {
    final userId = ref.read(authProvider);
    if (userId == null) return;

    try {
      final dateStr = _formatDate(date);
      await _repository.createBooking(
        venueId: venueId,
        userId: userId,
        date: dateStr,
        slot: slot,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Slot booked successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Refresh booking list and slots details grid
      _fetchBookings(userId);
      ref.read(venueDetailControllerProvider(venueId).notifier).refresh();

    } catch (e) {
      if (context.mounted) {
        final errorMsg = e.toString().replaceAll('CustomException:', '').trim();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Booking Failed'),
            content: Text(errorMsg),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> cancel({required int bookingId, int? refreshVenueId}) async {
    final userId = ref.read(authProvider);
    if (userId == null) return;

    try {
      await _repository.cancelBooking(bookingId);
      _fetchBookings(userId);

      if (refreshVenueId != null) {
        ref.read(venueDetailControllerProvider(refreshVenueId).notifier).refresh();
      }
    } catch (e) {
      // Handle error
    }
  }
}
