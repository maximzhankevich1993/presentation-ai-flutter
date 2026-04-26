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
    // Бесплатные
    const TransitionType(id: 'fade', name: 'Плавное появление', icon: Icons.opacity, isFree: true),
    const TransitionType(id: 'slide', name: 'Сдвиг', icon: Icons.swap_horiz, isFree: true),
    
    // Premium
    const TransitionType(id: 'cube', name: '3D Куб', icon: Icons.view_in_ar, isFree: false),
    const TransitionType(id: 'flip', name: 'Переворот', icon: Icons.flip, isFree: false),
    const TransitionType(id: 'wave', name: 'Волна', icon: Icons.waves, isFree: false),
    const TransitionType(id: 'zoom', name: 'Зум с размытием', icon: Icons.zoom_in, isFree: false),
    const TransitionType(id: 'particles', name: 'Частицы', icon: Icons.auto_awesome, isFree: false),
    const TransitionType(id: 'page_curl', name: 'Перелистывание', icon: Icons.book, isFree: false),
    const TransitionType(id: 'dissolve', name: 'Растворение', icon: Icons.blur_on, isFree: false),
    const TransitionType(id: 'glitch', name: 'Глитч-эффект', icon: Icons.broken_image, isFree: false),
  ];

  /// Возвращает PageRouteBuilder с выбранной анимацией перехода
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
      default:
        return _fadeTransition(page);
    }
  }

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
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
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
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }

  static PageRouteBuilder _flipTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(animation.value * 3.14159),
              child: animation.value < 0.5 ? child : page,
            );
          },
        );
      },
      transitionDuration: const Duration(milliseconds: 600),
    );
  }
}