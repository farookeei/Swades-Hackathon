import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/i_venue_repository.dart';
import '../repositories/venue_repository.dart';
import '../models/venue.dart';

// AutoDisposeNotifier Controller
final venueControllerProvider =
    AutoDisposeNotifierProvider<VenueController, AsyncValue<List<Venue>>>(() {
      return VenueController();
    });

class VenueController extends AutoDisposeNotifier<AsyncValue<List<Venue>>> {
  late final IVenueRepository _repository;

  @override
  AsyncValue<List<Venue>> build() {
    _repository = ref.watch(venueRepositoryProvider);
    _fetchVenues();
    return const AsyncLoading();
  }

  Future<void> _fetchVenues() async {
    state = const AsyncLoading();
    try {
      final venues = await _repository.getVenues();
      state = AsyncValue.data(venues);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refresh() async {
    await _fetchVenues();
  }
}
