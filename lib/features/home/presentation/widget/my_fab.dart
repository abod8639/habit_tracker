import 'package:flutter/material.dart';
import 'package:habit_tracker/generated/l10n.dart';

class MyfloatingActionButton extends StatefulWidget {
  final Function()? onPressed;
  const MyfloatingActionButton({this.onPressed, super.key});

  @override
  State<MyfloatingActionButton> createState() => _MyfloatingActionButtonState();
}

class _MyfloatingActionButtonState extends State<MyfloatingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _animationController.forward(),
      onExit: (_) => _animationController.reverse(),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: FloatingActionButton(
          tooltip: S.of(context).addNewHabit,
          autofocus: true,
          focusColor: Theme.of(
            context,
          ).colorScheme.secondary.withValues(alpha: 0.6),
          isExtended: true,
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
            if (widget.onPressed != null) {
              // Add tap animation
              _animationController.forward().then((_) {
                _animationController.reverse();
                widget.onPressed!();
              });
            }
          },
          splashColor: Theme.of(context).colorScheme.primary,
          child: Icon(
            size: 25,
            color: Theme.of(context).colorScheme.onPrimary,
            Icons.add,
          ),
        ),
      ),
    );
  }
}
