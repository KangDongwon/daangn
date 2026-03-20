import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/pages/agreement_page.dart';
import 'package:flutter_application_1/pages/home_page.dart';
import 'package:flutter_application_1/pages/login_page.dart';
import 'package:flutter_application_1/providers/app_providers.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/services/user_service.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  static const int _maxAutoRetries = 2;

  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  int _retryCount = 0;
  bool _isResolving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1,
          end: 1.12,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.12,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _controller.forward();
    _bootstrapAndNavigate(showResolvingMessage: false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _bootstrapAndNavigate({
    required bool showResolvingMessage,
  }) async {
    if (mounted) {
      setState(() {
        _isResolving = showResolvingMessage;
        _errorMessage = null;
      });
    }

    try {
      final destinationFuture = _resolveDestination();
      await Future.wait<void>([
        Future<void>.delayed(const Duration(milliseconds: 1200)),
        destinationFuture.then((_) {}),
      ]);

      if (!mounted) return;

      final destination = await destinationFuture;
      _controller.stop();

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 250),
          pageBuilder: (_, __, ___) => destination,
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } catch (error) {
      if (!mounted) return;

      if (_isRetryableError(error) && _retryCount < _maxAutoRetries) {
        _retryCount += 1;
        await Future<void>.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        await _bootstrapAndNavigate(showResolvingMessage: true);
        return;
      }

      setState(() {
        _isResolving = false;
        _errorMessage = '네트워크 상태를 확인한 뒤 다시 시도해 주세요.';
      });
    }
  }

  Future<Widget> _resolveDestination() async {
    final AuthService authService = ref.read(authServiceProvider);
    final UserService userService = ref.read(userServiceProvider);
    final authUser = authService.currentUser;

    if (authUser == null) {
      return const LoginPage();
    }

    final userModel = await userService.getUser(authUser.uid);
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
  }

  bool _isRetryableError(Object error) {
    if (error is FirebaseException) {
      return error.code == 'unavailable' || error.code == 'deadline-exceeded';
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Image.asset(
                'assets/images/daangn_study_logo.png',
                width: 138,
                height: 138,
              ),
            ),
            if (_isResolving) ...[
              SizedBox(height: 28),
              AnimatedOpacity(
                opacity: _isResolving ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  '앱을 준비하고 있어요...',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _retryCount = 0;
                  _bootstrapAndNavigate(showResolvingMessage: true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6F0F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                child: const Text('다시 시도'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
