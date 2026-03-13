import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/services/storage_service.dart';
import 'package:flutter_application_1/services/user_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges();
});

final currentAuthUserProvider = Provider<User?>((ref) {
  return ref.watch(authServiceProvider).currentUser;
});

final currentUserModelProvider = StreamProvider<UserModel?>((ref) {
  final authUser = ref.watch(currentAuthUserProvider);
  if (authUser == null) {
    return Stream.value(null);
  }

  return ref.watch(userServiceProvider).watchUser(authUser.uid);
});

final currentUserBootstrapProvider = FutureProvider<UserModel?>((ref) async {
  final authUser = ref.watch(currentAuthUserProvider);
  if (authUser == null) return null;

  return ref.read(userServiceProvider).getUser(authUser.uid);
});
