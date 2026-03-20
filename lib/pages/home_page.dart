import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/providers/app_providers.dart';
import 'package:flutter_application_1/widgets/profile_image_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userModelAsync = ref.watch(currentUserModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        automaticallyImplyLeading: false,
      ),
      body: userModelAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              '유저 정보를 불러오지 못했습니다.\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('유저 정보가 없습니다.'));
          }

          return Padding(
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
                  child: ProfileImageWidget(
                    path: user.profileImageUrl,
                    size: 140.w,
                    emptyChild: Icon(
                      Icons.person_outline,
                      size: 42.w,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                SizedBox(height: 24.w),
                _InfoRow(label: 'uid', value: user.id),
                _InfoRow(label: 'nickname', value: user.nickname),
                _InfoRow(label: 'address', value: user.address),
                _InfoRow(
                  label: 'marketingAgree',
                  value: user.marketingAgree.toString(),
                ),
                _InfoRow(
                  label: 'profileImageUrl',
                  value: user.profileImageUrl.isEmpty
                      ? '(empty)'
                      : user.profileImageUrl,
                ),
              ],
            ),
          );
        },
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
