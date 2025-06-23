import 'package:flutter/material.dart';
import 'dart:math' as math;

class PokeballProgressIndicator extends StatefulWidget {
  final double? size;
  final Color color;
  final Color backgroundColor;
  final Duration duration;
  final bool isLoading;
  final double minSize;
  final double maxSize;

  const PokeballProgressIndicator({
    super.key,
    this.size,
    this.color = Colors.red,
    this.backgroundColor = Colors.white,
    this.duration = const Duration(milliseconds: 1200),
    this.isLoading = true,
    this.minSize = 20.0,
    this.maxSize = 50.0,
  });

  @override
  State<PokeballProgressIndicator> createState() =>
      _PokeballProgressIndicatorState();
}

class _PokeballProgressIndicatorState extends State<PokeballProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    // Rotation animation
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Small bounce animation for added effect
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: -5), weight: 25),
      TweenSequenceItem(tween: Tween<double>(begin: -5, end: 0), weight: 25),
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: 5), weight: 25),
      TweenSequenceItem(tween: Tween<double>(begin: 5, end: 0), weight: 25),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Subtle pulsing effect
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.1), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.1, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isLoading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(PokeballProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double calculatedSize =
            widget.size ??
            math.min(
              math.min(constraints.maxWidth, constraints.maxHeight),
              widget.maxSize,
            );

        // Ensure size doesn't go below minimum
        final double finalSize = math.max(calculatedSize, widget.minSize);

        // Calculate shadow and bounce effects proportional to the size
        final double shadowBlur = finalSize * 0.2;
        final double shadowSpread = finalSize * 0.033;

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return SizedBox(
              width: finalSize,
              height: finalSize,
              child: Transform.translate(
                offset: Offset(0, _bounceAnimation.value),
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.color.withValues(alpha: 0.3),
                            blurRadius: shadowBlur,
                            spreadRadius: shadowSpread,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.catching_pokemon,
                        size: finalSize,
                        color: widget.color,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
