import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'user.g.dart';

@JsonSerializable()
class User extends Equatable {
  final int id;
  final String email;
  final String username;
  @JsonKey(name: 'full_name')
  final String? fullName;
  final String? phone;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'is_admin')
  final bool isAdmin;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    required this.username,
    this.fullName,
    this.phone,
    required this.isActive,
    required this.isAdmin,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  List<Object?> get props => [id, email, username, fullName, phone, isActive, isAdmin, createdAt];
} 