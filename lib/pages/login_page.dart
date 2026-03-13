import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/pages/agreement_page.dart';
import 'package:flutter_application_1/providers/app_providers.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/services/log.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool _isLoading = false;

  Future<void> _handleAnonymousLogin() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final AuthService authService = ref.read(authServiceProvider);
      final authUser = await authService.signInAnonymously();
      log(authUser.uid);
      final userModel = UserModel(
        id: authUser.uid,
        marketingAgree: false,
        nickname: '',
        profileImageUrl: '',
        address: '',
      );

      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => AgreementPage(userModel: userModel)),
      );
    } catch (e) {
      if (!mounted) return;
      print(e);
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('로그인 실패'),
          content: Text('익명 로그인에 실패했습니다.\n$e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 48.w),
              Text(
                '우리 동네 이웃 월리,\n내 반려동물의 친구가 되다.',
                style: TextStyle(
                  fontSize: 22.sp,
                  color: Colors.green,
                  fontWeight: FontWeight.w700,
                  height: 1.4.sp,
                ),
              ),
              const Spacer(),
              _buildBubbleMessage(),
              SizedBox(height: 16.w),
              _SocialLoginButton(
                text: 'Google 로그인',
                icon: Image.asset(
                  'assets/images/google.png',
                  width: 24.w,
                  height: 24.w,
                ),
                backgroundColor: Colors.white,
                borderColor: Colors.black,
                textColor: Colors.black,
                onPressed: _isLoading
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AgreementPage(
                              userModel: UserModel(
                                id: '',
                                marketingAgree: false,
                                nickname: '',
                                profileImageUrl: '',
                                address: '',
                              ),
                            ),
                          ),
                        );
                      },
              ),
              SizedBox(height: 12.w),
              _SocialLoginButton(
                text: 'Apple 로그인',
                icon: Icon(Icons.apple, color: Colors.white, size: 24.w),
                backgroundColor: Colors.black,
                textColor: Colors.white,
                onPressed: _isLoading
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AgreementPage(
                              userModel: UserModel(
                                id: '',
                                marketingAgree: false,
                                nickname: '',
                                profileImageUrl: '',
                                address: '',
                              ),
                            ),
                          ),
                        );
                      },
              ),
              SizedBox(height: 12.w),
              _SocialLoginButton(
                text: _isLoading ? '로그인 중...' : '익명 로그인',
                icon: _isLoading
                    ? SizedBox(
                        width: 24.w,
                        height: 24.w,
                        child: CircularProgressIndicator(strokeWidth: 2.w),
                      )
                    : Icon(
                        Icons.person_outline,
                        color: Colors.black,
                        size: 24.w,
                      ),
                backgroundColor: Colors.grey.shade100,
                borderColor: Colors.grey.shade400,
                textColor: Colors.black,
                onPressed: _isLoading ? null : _handleAnonymousLogin,
              ),
              SizedBox(height: 32.w),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBubbleMessage() {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 24.w),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Text(
            '우리 동네에는 어떤 월리가 있을까요?',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.green.shade800,
            ),
          ),
        ),
      ],
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  const _SocialLoginButton({
    required this.text,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
    required this.onPressed,
  });

  final String text;
  final Widget icon;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52.w,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: borderColor != null
              ? BorderSide(color: borderColor!)
              : BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            SizedBox(width: 12.w),
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
