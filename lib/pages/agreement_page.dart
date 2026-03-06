import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/pages/check_adult_page.dart';
import 'package:flutter_application_1/services/log.dart';
import 'package:flutter_application_1/widgets/circle_checkbox_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AgreementPage extends StatefulWidget {
  const AgreementPage({super.key, required this.userModel});

  final UserModel userModel;

  @override
  State<AgreementPage> createState() => _AgreementPageState();
}

class _AgreementPageState extends State<AgreementPage> {
  bool _serviceAgree = false;
  bool _privacyAgree = false;
  bool _marketingAgree = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
              SizedBox(height: 40.w),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '만나서 반가워요 🐶😸\n',
                      style: TextStyle(color: Colors.black, fontSize: 16.sp),
                    ),
                    TextSpan(
                      text: '이용약관',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: '에 동의해 주세요!',
                      style: TextStyle(color: Colors.black, fontSize: 16.sp),
                    ),
                  ],
                ),
              ),
              Spacer(),
              _buildAgreeCustom('모두 동의합니다'),
              Divider(height: 10.w, color: Colors.grey.withValues(alpha: .4)),
              Row(
                children: [
                  Expanded(
                    child: _buildAgree('서비스 이용 약관(필수)', _serviceAgree, (v) {
                      setState(() {
                        _serviceAgree = v;
                      });
                    }),
                  ),
                  Icon(Icons.chevron_right, color: Colors.black),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildAgree('개인정보처리방침(필수)', _privacyAgree, (v) {
                      setState(() {
                        _privacyAgree = v;
                      });
                    }),
                  ),
                  Icon(Icons.chevron_right, color: Colors.black),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildAgree('마케팅활용방침(선택)', _marketingAgree, (v) {
                      setState(() {
                        _marketingAgree = v;
                      });
                    }),
                  ),
                  Icon(Icons.chevron_right, color: Colors.black),
                ],
              ),
              SizedBox(height: 30.w),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    final enable = _serviceAgree && _privacyAgree;
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 52.w,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: enable ? Colors.green : Colors.grey.withAlpha(90),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            elevation: 0,
          ),
          onPressed: enable
              ? () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CheckAdultPage(
                        userModel: widget.userModel.copyWith(
                          marketingAgree: _marketingAgree,
                        ),
                      ),
                    ),
                  );
                }
              : null,
          child: Text(
            '다음',
            style: TextStyle(
              color: enable ? Colors.white : Colors.black.withAlpha(70),
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAgree(String label, bool value, ValueChanged onChanged) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(value: value, onChanged: onChanged, shape: CircleBorder()),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildAgreeCustom(String label) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: 12.w),
        CircleCheckBox(
          initialValue: _serviceAgree && _privacyAgree && _marketingAgree,
          size: 18.w,
          onChanged: (v) {
            setState(() {
              _serviceAgree = v;
              _privacyAgree = v;
              _marketingAgree = v;
            });
          },
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
