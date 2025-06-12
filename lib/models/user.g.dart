// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num).toInt(),
  email: json['email'] as String,
  username: json['username'] as String,
  fullName: json['full_name'] as String?,
  phone: json['phone'] as String?,
  isActive: json['is_active'] as bool,
  isAdmin: json['is_admin'] as bool,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'username': instance.username,
  'full_name': instance.fullName,
  'phone': instance.phone,
  'is_active': instance.isActive,
  'is_admin': instance.isAdmin,
  'created_at': instance.createdAt.toIso8601String(),
};
