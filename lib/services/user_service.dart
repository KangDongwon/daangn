import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/user_model.dart';

class UserService {
  UserService({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _db.collection('users');

  DocumentReference<Map<String, dynamic>> userDoc(String uid) =>
      _usersRef.doc(uid);

  Future<UserModel> createUserIfNotExists({
    required String uid,
    bool marketingAgree = false,
    String nickname = '',
    String profileImageUrl = '',
    String address = '',
  }) async {
    final ref = userDoc(uid);
    final snap = await ref.get();

    if (snap.exists) {
      return UserModel.fromFirestore(snap);
    }

    final model = UserModel(
      id: uid,
      marketingAgree: marketingAgree,
      nickname: nickname,
      profileImageUrl: profileImageUrl,
      address: address,
    );

    await ref.set(model.toCreateJson());

    return model;
  }

  Future<UserModel?> getUser(String uid) async {
    final snap = await userDoc(uid).get();

    if (!snap.exists) return null;
    return UserModel.fromFirestore(snap);
  }
}
