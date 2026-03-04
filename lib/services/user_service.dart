import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/model/user_model.dart';

class UserService {
  UserService({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _db.collection('users');

  DocumentReference<Map<String, dynamic>> userDoc(String uid) =>
      _usersRef.doc(uid);

  // -----------------------------
  // Create
  // -----------------------------
  /// 유저 문서가 없으면 생성 (최초 로그인/가입 시)
  /// - createdAt/updatedAt: serverTimestamp
  Future<UserModel> createUserIfNotExists({
    required String uid,
    bool marketingAgree = false,
    String nickname = '',
    String profileImageUrl = '',
    String address = '',
  }) async {
    final ref = userDoc(uid);

    return _db.runTransaction((tx) async {
      final snap = await tx.get(ref);

      if (!snap.exists) {
        final model = UserModel(
          id: uid,
          marketingAgree: marketingAgree,
          nickname: nickname,
          profileImageUrl: profileImageUrl,
          address: address,
        );

        tx.set(ref, model.toCreateJson());
        // 서버 타임스탬프는 즉시 DateTime으로 못 받으니, 생성 직후에는 null일 수 있음
        return model;
      } else {
        final data = snap.data() as Map<String, dynamic>;
        return UserModel.fromJson(data, uid);
      }
    });
  }
}
