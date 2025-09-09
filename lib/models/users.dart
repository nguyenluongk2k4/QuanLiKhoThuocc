import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

part 'users.g.dart';

@HiveType(typeId: 1)
class Users extends HiveObject {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String? email;

  @HiveField(2)
  final String? phone;

  @HiveField(3)
  final String? fullName;

  @HiveField(4)
  final DateTime? createdAt;

  @HiveField(5)
  final DateTime? updatedAt;

  @HiveField(6)
  final bool? emailConfirmed;

  Users({
    this.id,
    this.email,
    this.phone,
    this.fullName,
    this.createdAt,
    this.updatedAt,
    this.emailConfirmed,
  });

  factory Users.fromMap(Map<String, dynamic> map) {
    return Users(
      id: map['id'] as String? ?? '',
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      fullName: map['user_metadata'] is Map && (map['user_metadata']['full_name'] != null)
          ? map['user_metadata']['full_name'] as String
          : (map['user_metadata'] is Map && map['user_metadata']['name'] != null)
              ? map['user_metadata']['name'] as String
              : null,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'] as String) : null,
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at'] as String) : null,
      emailConfirmed: map['email_confirmed_at'] != null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'full_name': fullName,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'email_confirmed': emailConfirmed,
    };
  }
}