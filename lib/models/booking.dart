import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'hotel.dart';

part 'booking.g.dart';

@JsonSerializable()
class Booking extends Equatable {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'hotel_id')
  final String hotelId;
  @JsonKey(name: 'check_in_date')
  final DateTime checkInDate;
  @JsonKey(name: 'check_out_date')
  final DateTime checkOutDate;
  final int guests;
  final String status;
  final String? notes;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  final Hotel? hotel;
  @JsonKey(name: 'total_price')
  final double? totalPriceValue;

  const Booking({
    required this.id,
    required this.userId,
    required this.hotelId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.guests,
    required this.status,
    this.notes,
    required this.createdAt,
    this.hotel,
    this.totalPriceValue,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);

  Map<String, dynamic> toJson() => _$BookingToJson(this);

  int get durationDays => checkOutDate.difference(checkInDate).inDays;

  bool get isPending => status == 'pending';
  
  bool get isConfirmed => status == 'confirmed';
  
  bool get isCancelled => status == 'cancelled';
  
  DateTime get checkIn => checkInDate;
  DateTime get checkOut => checkOutDate;
  int get totalPrice => totalPriceValue?.toInt() ?? 0;

  String get hotelName => hotel?.name ?? 'Неизвестный отель';

  @override
  List<Object?> get props => [
    id, 
    userId, 
    hotelId, 
    checkInDate, 
    checkOutDate, 
    guests, 
    status, 
    notes, 
    createdAt, 
    hotel,
    totalPriceValue
  ];
} 