import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/pages/agreement_page.dart';
import 'package:flutter_application_1/pages/home_page.dart';
import 'package:flutter_application_1/pages/login_page.dart';
import 'package:flutter_application_1/services/user_service.dart';

class UserGateOldst extends StatelessWidget {
  const UserGateOldst({super.key});

  @override
  Widget build(BuildContext context) {
    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser == null) {
      return const LoginPage();
    }

    return StreamBuilder<UserModel?>(
      stream: UserService().watchUser(authUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingPage();
        }

        if (snapshot.hasError) {
          return _ErrorPage(
            onRetry: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const UserGateOldst()),
              );
            },
          );
        }

        final userModel = snapshot.data;
        if (userModel != null) {
          return const HomePage();
        }

        return AgreementPage(
          userModel: UserModel(
            id: authUser.uid,
            marketingAgree: false,
            nickname: '',
            profileImageUrl: '',
            address: '',
          ),
        );
      },
    );
  }
}

class _LoadingPage extends StatelessWidget {
  const _LoadingPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _ErrorPage extends StatelessWidget {
  const _ErrorPage({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '유저 정보를 불러오지 못했어요.\n네트워크 상태를 확인한 뒤 다시 시도해 주세요.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: onRetry, child: const Text('다시 시도')),
            ],
          ),
        ),
      ),
    );
  }
}
