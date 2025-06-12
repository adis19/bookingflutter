import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'hotel.dart';

part 'favorite.g.dart';

@JsonSerializable()
class Favorite extends Equatable {
  final int id;
  final int userId;
  final int hotelId;
  final DateTime createdAt;
  final Hotel? hotel;

  const Favorite({
    required this.id,
    required this.userId,
    required this.hotelId,
    required this.createdAt,
    this.hotel,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) => _$FavoriteFromJson(json);

  Map<String, dynamic> toJson() => _$FavoriteToJson(this);

  @override
  List<Object?> get props => [id, userId, hotelId, createdAt, hotel];
}