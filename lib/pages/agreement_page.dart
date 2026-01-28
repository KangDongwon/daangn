import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/circle_checkbox_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AgreementPage extends StatefulWidget {
  const AgreementPage({super.key});

  @override
  State<AgreementPage> createState() => _AgreementPageState();
}

class _AgreementPageState extends State<AgreementPage> {
  bool _agree1 = false;
  bool _agree2 = false;

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
    print('build call!');
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
                  Expanded(child: _buildAgree()),
                  Icon(Icons.chevron_right, color: Colors.black),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _buildAgreeCustom('동의합니다2')),
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

  Widget _buildAgree() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
          value: _agree1,
          onChanged: (value) {
            setState(() {});
            _agree1 = value ?? false;
          },
          shape: CircleBorder(),
        ),

        Expanded(
          child: Text(
            '동의합니다1',
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
          initialValue: _agree2,
          size: 18.w,
          onChanged: (v) {
            _agree2 = v;
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
