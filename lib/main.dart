import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/my_app.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  //각종 sdk 초기화

  // 화면 세로 고정
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    ScreenUtilInit(
      splitScreenMode: true, // 폴드 펼쳤을 때 화면 사이즈 다시 계산
      minTextAdapt: true, // 텍스트 최소 크기 보정
      designSize: Size(360, 800),
      builder: (context, child) => const MyApp(),
    ),
  );
}
