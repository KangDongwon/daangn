import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daum_postcode_view/daum_postcode_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/pages/home_page.dart';
import 'package:flutter_application_1/providers/app_providers.dart';
import 'package:flutter_application_1/services/log.dart';
import 'package:flutter_application_1/services/storage_service.dart';
import 'package:flutter_application_1/services/user_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EnterAddressPage extends ConsumerStatefulWidget {
  const EnterAddressPage({super.key, required this.userModel});

  final UserModel userModel;

  @override
  ConsumerState<EnterAddressPage> createState() => _EnterAddressPageState();
}

class _EnterAddressPageState extends ConsumerState<EnterAddressPage> {
  final TextEditingController _detailAddressController =
      TextEditingController();
  final FocusNode _detailFocusNode = FocusNode();

  String _selectedAddress = '';
  String _zonecode = '';
  bool _isLoading = false;

  bool get _hasSelectedAddress => _selectedAddress.trim().isNotEmpty;
  bool get _canNext =>
      _hasSelectedAddress &&
      _detailAddressController.text.trim().isNotEmpty &&
      !_isLoading;

  @override
  void initState() {
    super.initState();
    _detailAddressController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _detailAddressController.dispose();
    _detailFocusNode.dispose();
    super.dispose();
  }

  Future<void> _openAddressSearch() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _detailFocusNode.requestFocus();
    });
  }

  Future<void> _onNext() async {
    if (!_canNext || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final UserService userService = ref.read(userServiceProvider);
      final StorageService storageService = ref.read(storageServiceProvider);
      var userModel = widget.userModel.copyWith(address: _buildFullAddress());

      final profileImageUrl = userModel.profileImageUrl.trim();
      if (_shouldUploadProfileImage(profileImageUrl)) {
        final uploadedUrl = await storageService.uploadProfileImage(
          uid: userModel.id,
          localPath: profileImageUrl,
        );

        userModel = userModel.copyWith(profileImageUrl: uploadedUrl);
      }

      log(userModel, name: 'USER');

      final savedUser = await userService.saveUser(userModel);

      log(savedUser, name: 'USER');

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => HomePage(userModel: savedUser)),
        (route) => false,
      );
    } on ProfileImageConversionException catch (e, s) {
      log(e.toString(), name: 'ERROR');
      log(s.toString(), name: 'ERROR');

      if (!mounted) return;
      await _showErrorDialog('프로필 사진을 JPG로 변환하지 못했어요.\n다른 사진으로 다시 시도해 주세요.');
    } on ProfileImageUploadException catch (e, s) {
      log(e.toString(), name: 'ERROR');
      log(s.toString(), name: 'ERROR');

      if (!mounted) return;
      await _showErrorDialog('프로필 사진 업로드에 실패했어요.\n네트워크 상태를 확인한 뒤 다시 시도해 주세요.');
    } on FirebaseException catch (e, s) {
      log(e.toString(), name: 'ERROR');
      log(s.toString(), name: 'ERROR');

      if (!mounted) return;

      String message = '회원정보를 저장하지 못했습니다.';

      switch (e.code) {
        case 'permission-denied':
          message = '회원정보 저장 권한이 없습니다. 다시 로그인 후 시도해 주세요.';
          break;
        case 'unavailable':
          message = '회원정보 저장 중 네트워크 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.';
          break;
        default:
          message = '회원정보 저장 중 오류가 발생했습니다.\n${e.message ?? e.code}';
      }

      await _showErrorDialog(message);
    } catch (e, s) {
      log(e.toString(), name: 'ERROR');
      log(s.toString(), name: 'ERROR');

      if (!mounted) return;
      await _showErrorDialog('알 수 없는 오류가 발생했습니다.\n$e');
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  String _buildFullAddress() {
    final detail = _detailAddressController.text.trim();
    final parts = <String>[
      if (_zonecode.isNotEmpty) '($_zonecode)',
      _selectedAddress.trim(),
      detail,
    ];
    return parts.join(' ');
  }

  bool _shouldUploadProfileImage(String path) {
    if (path.isEmpty) return false;
    return !_isRemoteProfileImage(path);
  }

  bool _isRemoteProfileImage(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('회원가입'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBar: _hasSelectedAddress
          ? AnimatedPadding(
              duration: const Duration(milliseconds: 150),
              padding: EdgeInsets.only(bottom: bottomInset),
              child: _buildNextButton(),
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 30.w),
              Text(
                '주소를 입력해 주세요!',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.w),
              Text(
                '우리 동네 이웃을 찾기 위해 주소가 필요해요.',
                style: TextStyle(color: Colors.grey, fontSize: 14.sp),
              ),
              SizedBox(height: 24.w),
              Expanded(
                child: _hasSelectedAddress
                    ? _buildSelectedAddressSection()
                    : _buildAddressSearchPanel(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressSearchPanel() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
            color: Colors.grey.withAlpha(18),
            child: Text(
              _selectedAddress.isEmpty
                  ? '아래 검색창에서 도로명 또는 지번 주소를 검색해 주세요.'
                  : '선택한 주소: $_selectedAddress',
              style: TextStyle(
                color: _selectedAddress.isEmpty
                    ? Colors.grey.shade700
                    : Colors.black,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: IgnorePointer(
              ignoring: _isLoading,
              child: DaumPostcodeView(
                onComplete: (model) {
                  final roadAddress = '${model.roadAddress ?? ''}'.trim();
                  final jibunAddress = '${model.jibunAddress ?? ''}'.trim();
                  final zonecode = '${model.zonecode ?? ''}'.trim();
                  final address = roadAddress.isNotEmpty
                      ? roadAddress
                      : jibunAddress;

                  setState(() {
                    _selectedAddress = address;
                    _zonecode = zonecode;
                  });

                  _openAddressSearch();
                },
                options: const DaumPostcodeOptions(
                  animation: true,
                  hideEngBtn: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.w),
          decoration: BoxDecoration(
            color: Colors.grey.withAlpha(18),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  _zonecode.isEmpty
                      ? _selectedAddress
                      : '($_zonecode) $_selectedAddress',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              InkWell(
                onTap: _isLoading
                    ? null
                    : () {
                        setState(() {
                          _selectedAddress = '';
                          _zonecode = '';
                          _detailAddressController.clear();
                        });
                      },
                borderRadius: BorderRadius.circular(999),
                child: Padding(
                  padding: EdgeInsets.all(2.w),
                  child: Icon(
                    Icons.close,
                    color: Colors.grey.shade700,
                    size: 18.w,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.w),
        _buildDetailAddressField(),
      ],
    );
  }

  Widget _buildDetailAddressField() {
    return TextField(
      controller: _detailAddressController,
      focusNode: _detailFocusNode,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => _onNext(),
      decoration: InputDecoration(
        hintText: '상세 주소',
        hintStyle: TextStyle(color: Colors.grey, fontSize: 15.sp),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.green, width: 2),
        ),
      ),
      style: TextStyle(
        color: Colors.black,
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
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
            backgroundColor: _canNext ? Colors.green : Colors.grey.shade300,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            elevation: 0,
          ),
          onPressed: _canNext ? _onNext : null,
          child: _isLoading
              ? SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.w,
                    color: Colors.white,
                  ),
                )
              : Text(
                  '회원가입 완료',
                  style: TextStyle(
                    color: _canNext ? Colors.white : Colors.grey.shade400,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _showErrorDialog(String message) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
