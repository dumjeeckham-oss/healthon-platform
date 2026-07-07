import 'package:flutter/foundation.dart';

/// ===============================================================
///
/// HealthON User Model
///
/// 로그인된 사용자의 기본 정보
///
/// Supabase users 테이블과 1:1 매핑된다.
///
/// ===============================================================

@immutable
class AuthUser {
  /// UUID (Supabase Auth ID)
  final String id;

  /// 이메일
  final String? email;

  /// 이름
  final String? name;

  /// 프로필 이미지
  final String? photoUrl;

  /// 닉네임
  final String? nickname;

  /// 휴대폰 번호
  final String? phone;

  /// 가족 ID
  final String? familyId;

  /// 관리자 여부
  final bool isAdmin;

  /// 최초 가입 여부
  final bool isProfileCompleted;

  /// 생성일
  final DateTime? createdAt;

  /// 수정일
  final DateTime? updatedAt;

  const AuthUser({
    required this.id,
    this.email,
    this.name,
    this.photoUrl,
    this.nickname,
    this.phone,
    this.familyId,
    this.isAdmin = false,
    this.isProfileCompleted = false,
    this.createdAt,
    this.updatedAt,
  });

  /// Guest User
  factory AuthUser.empty() {
    return const AuthUser(
      id: '',
      email: null,
      name: null,
      photoUrl: null,
      nickname: null,
      phone: null,
      familyId: null,
      isAdmin: false,
      isProfileCompleted: false,
      createdAt: null,
      updatedAt: null,
    );
  }

  /// JSON → Model
  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      email: json['email'] as String?,
      name: json['name'] as String?,
      photoUrl: json['photo_url'] as String?,
      nickname: json['nickname'] as String?,
      phone: json['phone'] as String?,
      familyId: json['family_id'] as String?,
      isAdmin: json['is_admin'] ?? false,
      isProfileCompleted:
          json['is_profile_completed'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  /// Model → JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photo_url': photoUrl,
      'nickname': nickname,
      'phone': phone,
      'family_id': familyId,
      'is_admin': isAdmin,
      'is_profile_completed': isProfileCompleted,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// 객체 복사
  AuthUser copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    String? nickname,
    String? phone,
    String? familyId,
    bool? isAdmin,
    bool? isProfileCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      nickname: nickname ?? this.nickname,
      phone: phone ?? this.phone,
      familyId: familyId ?? this.familyId,
      isAdmin: isAdmin ?? this.isAdmin,
      isProfileCompleted:
          isProfileCompleted ?? this.isProfileCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return '''
AuthUser(
  id: $id,
  email: $email,
  name: $name,
  nickname: $nickname,
  familyId: $familyId,
  admin: $isAdmin,
)
''';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AuthUser &&
            runtimeType == other.runtimeType &&
            id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}