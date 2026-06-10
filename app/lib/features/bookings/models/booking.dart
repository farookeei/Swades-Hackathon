import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking.freezed.dart';
part 'booking.g.dart';

@freezed
@JsonSerializable(fieldRename: FieldRename.snake)
class Booking with _$Booking {
  const factory Booking({
    required int id,
    required int venueId,
    required String userId,
    required String date,
    required String slot,
    String? createdAt,
    String? venueName,
    String? venueLocation,
  }) = _Booking;

  factory Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);
}
