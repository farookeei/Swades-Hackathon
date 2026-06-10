import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/venue.dart';
import '../models/slot.dart';
import '../datasources/venue_api.dart';
import 'i_venue_repository.dart';
import '../../../core/exceptions/custom_exception.dart';

final venueRepositoryProvider = Provider.autoDispose<IVenueRepository>((ref) {
  final api = ref.watch(venueApiProvider);
  return VenueRepository(api);
});

class VenueRepository implements IVenueRepository {
  final VenueApi _venueApi;

  VenueRepository(this._venueApi);

  @override
  Future<List<Venue>> getVenues() async {
    try {
      final list = await _venueApi.fetchVenues();
      return list.map((json) => Venue.fromJson(json)).toList();
    } on CustomException {
      rethrow;
    } catch (e) {
      throw CustomException(message: 'Failed to process venues: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getSlots(int venueId, String date) async {
    try {
      final data = await _venueApi.fetchSlots(venueId, date);
      final slotsRaw = data['slots'] as List;
      final slots = slotsRaw.map((json) => Slot.fromJson(json)).toList();
      return {
        'venue': Venue.fromJson(data['venue']),
        'date': data['date'] as String,
        'slots': slots,
      };
    } on CustomException {
      rethrow;
    } catch (e) {
      throw CustomException(message: 'Failed to process slots: $e');
    }
  }
}
