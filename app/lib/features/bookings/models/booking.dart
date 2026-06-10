import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking.freezed.dart';
part 'booking.g.dart';

@freezed
class Booking with _$Booking {
  const factory Booking({
    required int id,
    @JsonKey(name: 'venue_id') required int venueId,
    @JsonKey(name: 'user_id') required String userId,
    required String date,
    required String slot,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'venue_name') String? venueName,
    @JsonKey(name: 'venue_location') String? venueLocation,
  }) = _Booking;

  factory Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);
}
