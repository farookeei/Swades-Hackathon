// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BookingImpl _$$BookingImplFromJson(Map<String, dynamic> json) =>
    _$BookingImpl(
      id: (json['id'] as num).toInt(),
      venueId: (json['venue_id'] as num).toInt(),
      userId: json['user_id'] as String,
      date: json['date'] as String,
      slot: json['slot'] as String,
      createdAt: json['created_at'] as String?,
      venueName: json['venue_name'] as String?,
      venueLocation: json['venue_location'] as String?,
    );

Map<String, dynamic> _$$BookingImplToJson(_$BookingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'venue_id': instance.venueId,
      'user_id': instance.userId,
      'date': instance.date,
      'slot': instance.slot,
      'created_at': instance.createdAt,
      'venue_name': instance.venueName,
      'venue_location': instance.venueLocation,
    };
