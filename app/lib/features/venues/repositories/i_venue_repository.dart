import '../models/venue.dart';

abstract class IVenueRepository {
  Future<List<Venue>> getVenues();
  Future<Map<String, dynamic>> getSlots(int venueId, String date);
}
