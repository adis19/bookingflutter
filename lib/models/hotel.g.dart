// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hotel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Hotel _$HotelFromJson(Map<String, dynamic> json) => Hotel(
  id: (json['id'] as num).toInt(),
  placeId: json['place_id'] as String,
  name: json['name'] as String,
  address: json['address'] as String,
  vicinity: json['vicinity'] as String?,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  rating: (json['rating'] as num?)?.toDouble(),
  userRatingsTotal: (json['user_ratings_total'] as num?)?.toInt(),
  photos: (json['photos'] as List<dynamic>?)?.map((e) => e as String).toList(),
  priceLevel: (json['priceLevel'] as num?)?.toInt(),
  typesList:
      (json['types'] as List<dynamic>?)?.map((e) => e as String).toList(),
  phoneNumberDirect: json['phone_number'] as String?,
  websiteDirect: json['website'] as String?,
  placeTypeString: json['place_type'] as String?,
  details: json['details'] as Map<String, dynamic>?,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$HotelToJson(Hotel instance) => <String, dynamic>{
  'id': instance.id,
  'place_id': instance.placeId,
  'name': instance.name,
  'address': instance.address,
  'vicinity': instance.vicinity,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'rating': instance.rating,
  'user_ratings_total': instance.userRatingsTotal,
  'photos': instance.photos,
  'priceLevel': instance.priceLevel,
  'types': instance.typesList,
  'phone_number': instance.phoneNumberDirect,
  'website': instance.websiteDirect,
  'place_type': instance.placeTypeString,
  'details': instance.details,
  'created_at': instance.createdAt.toIso8601String(),
};
