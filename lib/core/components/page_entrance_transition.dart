import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A reusable, eye-friendly entrance animation widget (Fade + Subtle Vertical Slide).
/// Provides a consistent, smooth cascading entrance feel across app pages.
class PageEntranceTransition extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration duration;
  final Duration? delay;
  final Offset slideOffset;
  final Curve curve;
  final AnimationController? animationController;

  const PageEntranceTransition({
    super.key,
    required this.child,
    this.index = 0,
    this.duration = const Duration(milliseconds: 550),
    this.delay,
    this.slideOffset = const Offset(0, 0.08),
    this.curve = Curves.easeOutCubic,
    this.animationController,
  });

  @override
  State<PageEntranceTransition> createState() => _PageEntranceTransitionState();
}

class _PageEntranceTransitionState extends State<PageEntranceTransition>
    with SingleTickerProviderStateMixin {
  AnimationController? _internalController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  void _initAnimation() {
    if (widget.animationController != null) {
      final start = math.min(widget.index * 0.06, 0.4);
      final end = math.min(start + 0.6, 1.0);
      _animation = CurvedAnimation(
        parent: widget.animationController!,
        curve: Interval(start, end, curve: widget.curve),
      );
    } else {
      final controller = AnimationController(
        vsync: this,
        duration: widget.duration,
      );
      _internalController = controller;
      _animation = CurvedAnimation(
        parent: controller,
        curve: widget.curve,
      );

      final calculatedDelay =
          widget.delay ??
          Duration(milliseconds: math.min(widget.index * 50, 300));

      if (calculatedDelay == Duration.zero) {
        controller.forward();
      } else {
        Future.delayed(calculatedDelay, () {
          if (mounted) {
            controller.forward();
          }
        });
      }
    }
  }

  @override
  void didUpdateWidget(covariant PageEntranceTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animationController != null &&
        widget.animationController != oldWidget.animationController) {
      final start = math.min(widget.index * 0.06, 0.4);
      final end = math.min(start + 0.6, 1.0);
      _animation = CurvedAnimation(
        parent: widget.animationController!,
        curve: Interval(start, end, curve: widget.curve),
      );
    }
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: widget.slideOffset,
          end: Offset.zero,
        ).animate(_animation),
        child: widget.child,
      ),
    );
  }
}
