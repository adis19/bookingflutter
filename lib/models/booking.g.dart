// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Booking _$BookingFromJson(Map<String, dynamic> json) => Booking(
  id: (json['id'] as num).toInt(),
  userId: (json['user_id'] as num).toInt(),
  hotelId: json['hotel_id'] as String,
  checkInDate: DateTime.parse(json['check_in_date'] as String),
  checkOutDate: DateTime.parse(json['check_out_date'] as String),
  guests: (json['guests'] as num).toInt(),
  status: json['status'] as String,
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  hotel:
      json['hotel'] == null
          ? null
          : Hotel.fromJson(json['hotel'] as Map<String, dynamic>),
  totalPriceValue: (json['total_price'] as num?)?.toDouble(),
);

Map<String, dynamic> _$BookingToJson(Booking instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'hotel_id': instance.hotelId,
  'check_in_date': instance.checkInDate.toIso8601String(),
  'check_out_date': instance.checkOutDate.toIso8601String(),
  'guests': instance.guests,
  'status': instance.status,
  'notes': instance.notes,
  'created_at': instance.createdAt.toIso8601String(),
  'hotel': instance.hotel,
  'total_price': instance.totalPriceValue,
};
