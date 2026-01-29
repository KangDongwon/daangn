import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/login_page.dart';
import 'package:flutter_application_1/pages/select_profile_page.dart';
import 'package:flutter_application_1/widgets/circle_checkbox_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CheckAdultPage extends StatefulWidget {
  const CheckAdultPage({super.key});

  @override
  State<CheckAdultPage> createState() => _CheckAdultPagePageState();
}

class _CheckAdultPagePageState extends State<CheckAdultPage> {
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
                      text: '월리 서비스는 만 19세 이상 이용이 가능해요!\n',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: '현재 만19세 이상이신가요?',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: '*',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 50.w),
              _buildNextButton(),
              Spacer(),
              _buildPrevButton(),
              SizedBox(height: 30.w),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => SelectProfilePage()));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          '네, 만19세 이상이에요!',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildPrevButton() {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => LoginPage()),
          (route) => false,
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '만 19세 이상이 아니신가요?',
            style: TextStyle(
              color: Colors.red,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2), // 텍스트-밑줄 간격
          Container(
            height: 1,
            width: 140.w, // 텍스트 길이에 맞게 조절 가능
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}
