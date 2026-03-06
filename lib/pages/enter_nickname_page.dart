import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/pages/home_page.dart';
import 'package:flutter_application_1/services/log.dart';
import 'package:flutter_application_1/services/user_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EnterNicknamePage extends StatefulWidget {
  const EnterNicknamePage({super.key, required this.userModel});

  final UserModel userModel;

  @override
  State<EnterNicknamePage> createState() => _EnterNicknamePageState();
}

class _EnterNicknamePageState extends State<EnterNicknamePage> {
  final TextEditingController _nicknameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String get _nickname => _nicknameController.text.trim();

  bool get _canNext => _isValidNickname(_nickname);

  final UserService _userService = UserService();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _nicknameController.addListener(() {
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool _isValidNickname(String value) {
    if (value.isEmpty) return false;
    if (value.length < 2) return false;
    if (value.length > 10) return false;
    return true;
  }

  Future<void> _onNext() async {
    if (!_canNext) return;
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userModel = widget.userModel.copyWith(
        nickname: _nicknameController.text.trim(),
      );

      log(userModel, name: 'USER');

      final savedUser = await _userService.createUserIfNotExists(
        uid: userModel.id,
        marketingAgree: userModel.marketingAgree,
        nickname: userModel.nickname,
        profileImageUrl: userModel.profileImageUrl,
        address: userModel.address,
      );

      log(savedUser, name: 'USER');

      if (!mounted) return;

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => HomePage()));
    } on FirebaseException catch (e, s) {
      log(e.toString(), name: 'ERROR');
      log(s.toString(), name: 'ERROR');

      if (!mounted) return;

      String message = '유저 정보를 저장하지 못했습니다.';

      switch (e.code) {
        case 'permission-denied':
          message = '권한이 없습니다. 다시 로그인 후 시도해 주세요.';
          break;
        case 'unavailable':
          message = '일시적인 네트워크 오류입니다. 잠시 후 다시 시도해 주세요.';
          break;
        default:
          message = '저장 중 오류가 발생했습니다.\n${e.message ?? e.code}';
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
      bottomNavigationBar: AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.only(bottom: bottomInset),
        child: _buildNextButton(),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 30.w),
              Text(
                '닉네임을 생성해 주세요!',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.w),
              Text(
                '이웃들과 소통할 새로운 닉네임을 생성해 주세요!',
                style: TextStyle(color: Colors.grey, fontSize: 14.sp),
              ),
              SizedBox(height: 24.w),
              _buildNicknameField(),
              SizedBox(height: 12.w),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNicknameField() {
    return TextField(
      controller: _nicknameController,
      focusNode: _focusNode,
      maxLength: 10,
      cursorColor: Colors.green, // 커서 색
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => _onNext(),
      decoration: InputDecoration(
        hintText: '닉네임',
        hintStyle: TextStyle(color: Colors.grey, fontSize: 15.sp),
        counterText: '',

        // 기본 밑줄
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),

        // 포커스 시 밑줄
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
            backgroundColor: (_canNext && !_isLoading)
                ? Colors.green
                : Colors.grey.shade300,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            elevation: 0,
          ),
          onPressed: (_canNext && !_isLoading) ? _onNext : null,
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
                  '다음',
                  style: TextStyle(
                    color: (_canNext && !_isLoading)
                        ? Colors.white
                        : Colors.grey.shade400,
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
