import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SelectProfilePage extends StatefulWidget {
  const SelectProfilePage({super.key});

  @override
  State<SelectProfilePage> createState() => _SelectProfilePageState();
}

class _SelectProfilePageState extends State<SelectProfilePage> {
  late final double _size;
  Offset? _tapPosition;

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
        print('camera');
        break;
      case 'gallery':
        print('gallery');
        break;
      default:
        break; // 취소(바깥 클릭)
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
      onTapDown: _storeTapPosition, // ⭐ 좌표 먼저 저장
      onTap: _showProfileMenu, //
      child: Container(
        width: _size,
        height: _size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.withAlpha(60),
          shape: BoxShape.circle, // ⭐ 핵심
        ),
        child: Text(
          '+',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 36.sp, // 원 크기에 비례해서 자동
            fontWeight: FontWeight.w100,
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
}
