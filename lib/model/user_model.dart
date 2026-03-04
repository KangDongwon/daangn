import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final bool marketingAgree;
  final String nickname;
  final String profileImageUrl;
  final String address;

  UserModel({
    required this.id,
    this.createdAt,
    this.updatedAt,
    required this.marketingAgree,
    required this.nickname,
    required this.profileImageUrl,
    required this.address,
  });

  /// Firestore → Model
  factory UserModel.fromJson(Map<String, dynamic> json, String id) {
    return UserModel(
      id: id,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
      marketingAgree: json['marketingAgree'] ?? false,
      nickname: json['nickname'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
      address: json['address'] ?? '',
    );
  }

  /// 신규 생성용 (createdAt 서버타임스탬프)
  Map<String, dynamic> toCreateJson() {
    return {
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'marketingAgree': marketingAgree,
      'nickname': nickname,
      'profileImageUrl': profileImageUrl,
      'address': address,
    };
  }

  /// 수정용 (updatedAt만 갱신)
  Map<String, dynamic> toUpdateJson() {
    return {
      'updatedAt': FieldValue.serverTimestamp(),
      'marketingAgree': marketingAgree,
      'nickname': nickname,
      'profileImageUrl': profileImageUrl,
      'address': address,
    };
  }

  UserModel copyWith({
    bool? marketingAgree,
    String? nickname,
    String? profileImageUrl,
    String? address,
  }) {
    return UserModel(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      marketingAgree: marketingAgree ?? this.marketingAgree,
      nickname: nickname ?? this.nickname,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      address: address ?? this.address,
    );
  }
}
