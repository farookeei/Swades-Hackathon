// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Booking _$BookingFromJson(Map<String, dynamic> json) => Booking(
  id: (json['id'] as num).toInt(),
  venueId: (json['venue_id'] as num).toInt(),
  userId: json['user_id'] as String,
  date: json['date'] as String,
  slot: json['slot'] as String,
  createdAt: json['created_at'] as String?,
  venueName: json['venue_name'] as String?,
  venueLocation: json['venue_location'] as String?,
);

Map<String, dynamic> _$BookingToJson(Booking instance) => <String, dynamic>{
  'id': instance.id,
  'venue_id': instance.venueId,
  'user_id': instance.userId,
  'date': instance.date,
  'slot': instance.slot,
  'created_at': instance.createdAt,
  'venue_name': instance.venueName,
  'venue_location': instance.venueLocation,
};

_$BookingImpl _$$BookingImplFromJson(Map<String, dynamic> json) =>
    _$BookingImpl(
      id: (json['id'] as num).toInt(),
      venueId: (json['venueId'] as num).toInt(),
      userId: json['userId'] as String,
      date: json['date'] as String,
      slot: json['slot'] as String,
      createdAt: json['createdAt'] as String?,
      venueName: json['venueName'] as String?,
      venueLocation: json['venueLocation'] as String?,
    );

Map<String, dynamic> _$$BookingImplToJson(_$BookingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'venueId': instance.venueId,
      'userId': instance.userId,
      'date': instance.date,
      'slot': instance.slot,
      'createdAt': instance.createdAt,
      'venueName': instance.venueName,
      'venueLocation': instance.venueLocation,
    };
