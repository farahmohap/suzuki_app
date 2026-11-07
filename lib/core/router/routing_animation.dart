
import 'package:flutter/material.dart';

enum RouteAnimation {
  none,
  fade,
  slideRight,
  slideLeft,
  slideUp,
  slideDown,
  scale,
  rotate,
  fadeSlide,
  fadeScale,
}

PageRouteBuilder buildRoute({
  required Widget page,
  RouteAnimation animation = RouteAnimation.none,
  Duration duration = const Duration(milliseconds: 300),
  RouteSettings? settings,
}) {
  return PageRouteBuilder(
    settings: settings,
    transitionDuration:
        animation == RouteAnimation.none ? Duration.zero : duration,
    reverseTransitionDuration:
        animation == RouteAnimation.none ? Duration.zero : duration,
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (_, animationValue, _, child) {
      if (animation == RouteAnimation.none) {
        return child;
      }

      final curvedAnimation = CurvedAnimation(
        parent: animationValue,
        curve: Curves.fastOutSlowIn,
      );

      switch (animation) {
        case RouteAnimation.fade:
          return FadeTransition(
            opacity: curvedAnimation,
            child: child,
          );

        case RouteAnimation.slideRight:
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          );

        case RouteAnimation.slideLeft:
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1, 0),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          );

        case RouteAnimation.slideUp:
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          );

        case RouteAnimation.slideDown:
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -1),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          );

        case RouteAnimation.scale:
          return ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1)
                .animate(curvedAnimation),
            child: child,
          );

        case RouteAnimation.rotate:
          return RotationTransition(
            turns: Tween<double>(begin: -0.02, end: 0)
                .animate(curvedAnimation),
            child: child,
          );

        case RouteAnimation.fadeSlide:
          return FadeTransition(
            opacity: curvedAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.1, 0), 
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            ),
          );

        case RouteAnimation.fadeScale:
          return FadeTransition(
            opacity: curvedAnimation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1)
                  .animate(curvedAnimation),
              child: child,
            ),
          );

        case RouteAnimation.none:
          return child;
      }
    },
  );
}
