import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ProfileImageConversionException implements Exception {
  const ProfileImageConversionException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ProfileImageUploadException implements Exception {
  const ProfileImageUploadException(this.message);

  final String message;

  @override
  String toString() => message;
}

class StorageService {
  StorageService({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;
  static const int _profileImageQuality = 82;
  static const int _maxWidth = 1080;
  static const int _maxHeight = 1080;

  Future<String> uploadProfileImage({
    required String uid,
    required String localPath,
  }) async {
    final sourceFile = File(localPath);

    if (!sourceFile.existsSync()) {
      throw Exception('업로드할 프로필 이미지 파일을 찾을 수 없습니다.');
    }

    final ref = _storage.ref().child(
      'users/$uid/profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    final uploadFile = await _compressToJpg(sourceFile);

    try {
      await ref.putFile(uploadFile, SettableMetadata(contentType: 'image/jpg'));
      return ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw ProfileImageUploadException(e.message ?? '프로필 이미지를 업로드하지 못했습니다.');
    } catch (_) {
      throw const ProfileImageUploadException('프로필 이미지를 업로드하지 못했습니다.');
    }
  }

  Future<File> _compressToJpg(File sourceFile) async {
    final targetPath =
        '${Directory.systemTemp.path}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      sourceFile.absolute.path,
      targetPath,
      format: CompressFormat.jpeg,
      quality: _profileImageQuality,
      minWidth: _maxWidth,
      minHeight: _maxHeight,
    );

    if (compressedFile == null) {
      throw const ProfileImageConversionException('프로필 이미지를 JPG로 변환하지 못했습니다.');
    }

    return File(compressedFile.path);
  }
}
