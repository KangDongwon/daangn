import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/providers/app_providers.dart';
import 'package:flutter_application_1/widgets/profile_image_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.userModel});

  final UserModel userModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '홈 화면 입니다.',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 24.w),
            Center(
              child: _HomeProfileImage(
                initialProfileImageUrl: userModel.profileImageUrl,
              ),
            ),
            SizedBox(height: 24.w),
            _InfoRow(label: 'uid', value: userModel.id),
            _InfoRow(label: 'nickname', value: userModel.nickname),
            _InfoRow(label: 'address', value: userModel.address),
            _InfoRow(
              label: 'marketingAgree',
              value: userModel.marketingAgree.toString(),
            ),
            _InfoRow(
              label: 'profileImageUrl',
              value: userModel.profileImageUrl.isEmpty
                  ? '(empty)'
                  : userModel.profileImageUrl,
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeProfileImage extends ConsumerWidget {
  const _HomeProfileImage({required this.initialProfileImageUrl});

  final String initialProfileImageUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileImageUrl = ref.watch(
      currentUserModelProvider.select(
        (asyncUser) => asyncUser.valueOrNull?.profileImageUrl,
      ),
    );

    return ProfileImageWidget(
      path: profileImageUrl ?? initialProfileImageUrl,
      size: 140.w,
      emptyChild: Icon(
        Icons.person_outline,
        size: 42.w,
        color: Colors.grey.shade600,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}
