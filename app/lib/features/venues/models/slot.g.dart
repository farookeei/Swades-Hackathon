// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SlotImpl _$$SlotImplFromJson(Map<String, dynamic> json) => _$SlotImpl(
  time: json['time'] as String,
  isAvailable: json['isAvailable'] as bool,
  bookedBy: json['bookedBy'] as String?,
);

Map<String, dynamic> _$$SlotImplToJson(_$SlotImpl instance) =>
    <String, dynamic>{
      'time': instance.time,
      'isAvailable': instance.isAvailable,
      'bookedBy': instance.bookedBy,
    };
