import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/native_image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';

class SelectProfilePage extends StatefulWidget {
  const SelectProfilePage({super.key});

  @override
  State<SelectProfilePage> createState() => _SelectProfilePageState();
}

class _SelectProfilePageState extends State<SelectProfilePage> {
  late final double _size;
  Offset? _tapPosition;
  String? _profilePath;

  @override
  void initState() {
    super.initState();

    _size = ScreenUtil().screenWidth / 2;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _storeTapPosition(TapDownDetails details) {
    _tapPosition = details.globalPosition; // ⭐ 화면 전체 기준 좌표
  }

  Future<void> _showProfileMenu() async {
    final pos = _tapPosition;
    if (pos == null) return;

    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(pos.dx, pos.dy, 1, 1),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(value: 'camera', child: Text('사진 찍기')),
        PopupMenuItem(value: 'gallery', child: Text('앨범에서 가져오기')),
      ],
    );

    if (!mounted) return;

    switch (selected) {
      case 'camera':
        final ok = await _ensureCameraPermission();
        if (!ok) return;
        print('camera allowed');
        break;

      case 'gallery':
        final ok = await _ensureGalleryPermission();
        if (!ok) return;
        print('gallery allowed');
        final path = await NativeImagePicker.pickFromGallery();
        print(path);
        setState(() {
          _profilePath = path;
        });
        break;

      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('회원가입'), backgroundColor: Colors.white),
      bottomNavigationBar: _buildNextButton(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 30.w),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '얼굴이 잘 보이는 사진을 업로드해 주세요!\n',
                      style: TextStyle(color: Colors.black, fontSize: 16.sp),
                    ),
                    TextSpan(
                      text: '반려동물과 함께 찍은 사진도 괜찮아요!',
                      style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.w),
              _buildProfile(),
              SizedBox(height: 30.w),
              Text(
                '예시',
                style: TextStyle(color: Colors.black, fontSize: 16.sp),
              ),
              SizedBox(height: 30.w),
              _buildExampleProfile(),
              SizedBox(height: 30.w),
              _buildTextBox(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextBox() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(20),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14.sp, // 원 크기에 비례해서 자동
              fontWeight: FontWeight.w500,
              height: 1.4.sp,
            ),
          ),
          Expanded(
            child: Text(
              '해당 사진은 프로필 사진으로 사용됩니다. 다른 사람도 볼 수 있으니 유의해 주세요.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14.sp, // 원 크기에 비례해서 자동
                fontWeight: FontWeight.w500,
                height: 1.4.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleProfile() {
    return Row(children: []);
  }

  Widget _buildProfile() {
    return GestureDetector(
      onTapDown: _storeTapPosition, // ⭐ 좌표 저장
      onTap: _showProfileMenu,
      child: Container(
        width: _size,
        height: _size,
        decoration: BoxDecoration(
          color: Colors.grey.withAlpha(60),
          shape: BoxShape.circle,
          image: (_profilePath != null && _profilePath!.isNotEmpty)
              ? DecorationImage(
                  image: FileImage(File(_profilePath!)),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        alignment: Alignment.center,
        child: (_profilePath == null || _profilePath!.isEmpty)
            ? Text(
                '+',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 36.sp,
                  fontWeight: FontWeight.w100,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildNextButton() {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 52.w,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            elevation: 0,
          ),
          onPressed: () {},
          child: Text(
            '다음',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _ensureCameraPermission() async {
    // iOS/Android 공통
    var status = await Permission.camera.status;
    if (status.isGranted) return true;

    status = await Permission.camera.request();
    if (status.isGranted) return true;

    print(status.toString());

    // 영구 거절(다시 묻지 않음) or 제한됨(iOS)
    if (status.isPermanentlyDenied || status.isRestricted) {
      if (!mounted) return false;
      await _showPermissionDialog(
        title: '카메라 권한 필요',
        message: '사진 촬영을 위해 카메라 권한이 필요합니다.\n설정에서 권한을 허용해 주세요.',
      );
      return false;
    }

    // 그냥 거절
    return false;
  }

  Future<bool> _ensureGalleryPermission() async {
    // Android 13+ : photos, 구형 : storage
    // iOS : photos
    Permission permission;

    if (Theme.of(context).platform == TargetPlatform.android) {
      permission =
          Permission.photos; // permission_handler가 Android에서 사진 권한으로 매핑
      // 만약 특정 기기/버전에서 photos가 애매하면 아래처럼 fallback도 가능:
      // permission = Permission.storage;
    } else {
      permission = Permission.photos;
    }

    var status = await permission.status;
    if (status.isGranted) return true;

    status = await permission.request();
    if (status.isGranted) return true;

    // iOS에서 "limited"면 사실상 선택은 가능(제한 접근) → 허용으로 처리하고 싶으면:
    if (status.isLimited) return true;

    print(status.toString());

    if (status.isPermanentlyDenied || status.isRestricted) {
      if (!mounted) return false;
      await _showPermissionDialog(
        title: '사진 권한 필요',
        message: '앨범에서 사진을 가져오려면 사진 접근 권한이 필요합니다.\n설정에서 권한을 허용해 주세요.',
      );
      return false;
    }

    return false;
  }

  Future<void> _showPermissionDialog({
    required String title,
    required String message,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: const Text('설정으로 이동'),
          ),
        ],
      ),
    );
  }
}
