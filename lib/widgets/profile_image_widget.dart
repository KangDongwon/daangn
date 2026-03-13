import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class ProfileImageWidget extends StatelessWidget {
  const ProfileImageWidget({
    super.key,
    required this.path,
    required this.size,
    this.emptyChild,
  });

  final String? path;
  final double size;
  final Widget? emptyChild;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(60),
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (path == null || path!.isEmpty) {
      return emptyChild ??
          Text(
            '+',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 36.sp,
              fontWeight: FontWeight.w100,
            ),
          );
    }

    if (path!.startsWith('http://') || path!.startsWith('https://')) {
      return _NetworkProfileImage(path: path!, size: size);
    }

    return Image.file(
      File(path!),
      fit: BoxFit.cover,
      width: size,
      height: size,
      errorBuilder: (context, error, stackTrace) {
        return const _ImageError();
      },
    );
  }
}

class _NetworkProfileImage extends StatefulWidget {
  const _NetworkProfileImage({required this.path, required this.size});

  final String path;
  final double size;

  @override
  State<_NetworkProfileImage> createState() => _NetworkProfileImageState();
}

class _NetworkProfileImageState extends State<_NetworkProfileImage> {
  bool _isLoaded = false;
  bool _hasError = false;

  @override
  void didUpdateWidget(covariant _NetworkProfileImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      _isLoaded = false;
      _hasError = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (!_isLoaded && !_hasError)
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(color: Colors.white),
          ),
        if (_hasError)
          const _ImageError()
        else
          Image.network(
            widget.path,
            fit: BoxFit.cover,
            width: widget.size,
            height: widget.size,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded || frame != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted || _isLoaded) return;
                  setState(() {
                    _isLoaded = true;
                  });
                });
              }

              return AnimatedOpacity(
                opacity: _isLoaded ? 1 : 0,
                duration: const Duration(milliseconds: 180),
                child: child,
              );
            },
            errorBuilder: (context, error, stackTrace) {
              if (!_hasError) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted || _hasError) return;
                  setState(() {
                    _hasError = true;
                  });
                });
              }

              return const SizedBox.shrink();
            },
          ),
      ],
    );
  }
}

class _ImageError extends StatelessWidget {
  const _ImageError();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.broken_image_outlined, color: Colors.grey, size: 28.w),
        SizedBox(height: 6.w),
        Text(
          '이미지 로드 실패',
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
