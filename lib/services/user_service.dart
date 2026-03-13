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

  Future<UserModel> saveUser(UserModel user) async {
    final ref = userDoc(user.id);
    final snap = await ref.get();

    if (snap.exists) {
      await ref.update(user.toUpdateJson());
    } else {
      await ref.set(user.toCreateJson());
    }

    final savedSnap = await ref.get();
    return UserModel.fromFirestore(savedSnap);
  }

  Future<UserModel?> getUser(String uid) async {
    final snap = await userDoc(uid).get();

    if (!snap.exists) return null;
    return UserModel.fromFirestore(snap);
  }

  Stream<UserModel?> watchUser(String uid) {
    return userDoc(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      return UserModel.fromFirestore(snap);
    });
  }
}
