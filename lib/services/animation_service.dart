import 'package:flutter/material.dart';

class TransitionType {
  final String id;
  final String name;
  final IconData icon;
  final bool isFree;

  const TransitionType({
    required this.id,
    required this.name,
    required this.icon,
    this.isFree = true,
  });
}

class AnimationService {
  static List<TransitionType> getTransitions({bool? freeOnly}) {
    final transitions = _allTransitions;

    if (freeOnly == true) {
      return transitions.where((t) => t.isFree).toList();
    }

    return transitions;
  }

  static final List<TransitionType> _allTransitions = [
    // Free
    const TransitionType(
      id: 'fade',
      name: 'Плавное появление',
      icon: Icons.opacity,
      isFree: true,
    ),
    const TransitionType(
      id: 'slide',
      name: 'Сдвиг',
      icon: Icons.swap_horiz,
      isFree: true,
    ),

    // Premium
    const TransitionType(
      id: 'cube',
      name: '3D Куб',
      icon: Icons.view_in_ar,
      isFree: false,
    ),
    const TransitionType(
      id: 'flip',
      name: 'Переворот',
      icon: Icons.flip,
      isFree: false,
    ),
    const TransitionType(
      id: 'wave',
      name: 'Волна',
      icon: Icons.waves,
      isFree: false,
    ),
    const TransitionType(
      id: 'zoom',
      name: 'Зум с размытием',
      icon: Icons.zoom_in,
      isFree: false,
    ),
    const TransitionType(
      id: 'particles',
      name: 'Частицы',
      icon: Icons.auto_awesome,
      isFree: false,
    ),
    const TransitionType(
      id: 'page_curl',
      name: 'Перелистывание',
      icon: Icons.book,
      isFree: false,
    ),
    const TransitionType(
      id: 'dissolve',
      name: 'Растворение',
      icon: Icons.blur_on,
      isFree: false,
    ),
    const TransitionType(
      id: 'glitch',
      name: 'Глитч-эффект',
      icon: Icons.broken_image,
      isFree: false,
    ),

    // ⭐ NEW
    const TransitionType(
      id: 'slow_motion',
      name: 'Slow Motion',
      icon: Icons.slow_motion_video,
      isFree: true,
    ),
  ];

  /// MAIN ROUTE BUILDER
  static PageRouteBuilder buildAnimatedRoute({
    required Widget page,
    required String transitionId,
  }) {
    switch (transitionId) {
      case 'fade':
        return _fadeTransition(page);

      case 'slide':
        return _slideTransition(page);

      case 'zoom':
        return _zoomTransition(page);

      case 'flip':
        return _flipTransition(page);

      case 'slow_motion':
        return _slowMotionTransition(page);

      default:
        return _fadeTransition(page);
    }
  }

  // -------------------------
  // BASIC TRANSITIONS
  // -------------------------

  static PageRouteBuilder _fadeTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  static PageRouteBuilder _slideTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  static PageRouteBuilder _zoomTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return ScaleTransition(
          scale: Tween<double>(begin: 0.85, end: 1.0).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }

  static PageRouteBuilder _flipTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        );

        return AnimatedBuilder(
          animation: curved,
          child: child,
          builder: (context, child) {
            final value = curved.value;

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(value * 3.14159),
              child: value < 0.5 ? child : page,
            );
          },
        );
      },
      transitionDuration: const Duration(milliseconds: 600),
    );
  }

  // -------------------------
  // ⭐ SLOW MOTION (NEW)
  // -------------------------

  static PageRouteBuilder _slowMotionTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,

      transitionDuration: const Duration(milliseconds: 1200),

      transitionsBuilder: (_, animation, __, child) {
        /// Делает эффект "замедленного времени"
        final slowCurve = CurvedAnimation(
          parent: animation,
          curve: const Interval(
            0.0,
            1.0,
            curve: Curves.fastOutSlowIn,
          ),
        );

        return Stack(
          children: [
            // fade in
            FadeTransition(
              opacity: slowCurve,
              child: child,
            ),

            // slow zoom-in (эффект "погружения")
            ScaleTransition(
              scale: Tween<double>(
                begin: 1.05,
                end: 1.0,
              ).animate(slowCurve),
              child: child,
            ),
          ],
        );
      },
    );
  }
}