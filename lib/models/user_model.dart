import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final bool marketingAgree;
  final String nickname;
  final String profileImageUrl;
  final String address;

  const UserModel({
    required this.id,
    this.createdAt,
    this.updatedAt,
    required this.marketingAgree,
    required this.nickname,
    required this.profileImageUrl,
    required this.address,
  });

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final json = doc.data() ?? {};

    return UserModel(
      id: doc.id,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
      marketingAgree: json['marketingAgree'] as bool? ?? false,
      nickname: json['nickname'] as String? ?? '',
      profileImageUrl: json['profileImageUrl'] as String? ?? '',
      address: json['address'] as String? ?? '',
    );
  }

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'marketingAgree': marketingAgree,
      'nickname': nickname,
      'profileImageUrl': profileImageUrl,
      'address': address,
    };
  }

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
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? marketingAgree,
    String? nickname,
    String? profileImageUrl,
    String? address,
  }) {
    return UserModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      marketingAgree: marketingAgree ?? this.marketingAgree,
      nickname: nickname ?? this.nickname,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      address: address ?? this.address,
    );
  }
}
