import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/venue.dart';
import '../models/slot.dart';
import '../datasources/venue_api.dart';
import 'i_venue_repository.dart';

final venueRepositoryProvider = Provider.autoDispose<IVenueRepository>((ref) {
  final api = ref.watch(venueApiProvider);
  return VenueRepository(api);
});

class VenueRepository implements IVenueRepository {
  final VenueApi _venueApi;

  VenueRepository(this._venueApi);

  @override
  Future<List<Venue>> getVenues() async {
    final list = await _venueApi.fetchVenues();
    return list.map((json) => Venue.fromJson(json)).toList();
  }

  @override
  Future<Map<String, dynamic>> getSlots(int venueId, String date) async {
    final data = await _venueApi.fetchSlots(venueId, date);
    final slotsRaw = data['slots'] as List;
    final slots = slotsRaw.map((json) => Slot.fromJson(json)).toList();
    return {
      'venue': Venue.fromJson(data['venue']),
      'date': data['date'] as String,
      'slots': slots,
    };
  }
}
