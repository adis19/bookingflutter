// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Favorite _$FavoriteFromJson(Map<String, dynamic> json) => Favorite(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  hotelId: (json['hotelId'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  hotel:
      json['hotel'] == null
          ? null
          : Hotel.fromJson(json['hotel'] as Map<String, dynamic>),
);

Map<String, dynamic> _$FavoriteToJson(Favorite instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'hotelId': instance.hotelId,
  'createdAt': instance.createdAt.toIso8601String(),
  'hotel': instance.hotel,
};
