part of 'widgets.dart';

class CustomLoadingAnimation extends StatefulWidget {
  final bool isLoading;
  final Widget child;

  final Color? barrierColor;

  const CustomLoadingAnimation({
    super.key,
    required this.isLoading,
    required this.child,
    this.barrierColor,
  });

  @override
  State<CustomLoadingAnimation> createState() => _CustomLoadingAnimationState();
}

class _CustomLoadingAnimationState extends State<CustomLoadingAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void initState() {
    super.initState();
    if (widget.isLoading) _controller.repeat();
  }

  @override
  void didUpdateWidget(CustomLoadingAnimation old) {
    super.didUpdateWidget(old);
    if (widget.isLoading == old.isLoading) return;
    widget.isLoading ? _controller.repeat() : _controller.stop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.isLoading,
      child: Stack(
        children: [
          widget.child,
          if (widget.isLoading) ...[
            ModalBarrier(
              dismissible: false,
              color: widget.barrierColor ?? blackColor.withValues(alpha: 0.6),
            ),
            Center(
              child: RepaintBoundary(
                child: CustomPaint(
                  size: const Size.square(72),
                  painter: LoadingPainter(_controller, primaryColor),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class LoadingPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;
  static const _dots = 12;

  LoadingPainter(this.animation, this.color) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final ringRadius = size.shortestSide / 2 - 6;
    final paint = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < _dots; i++) {
      final t = ((animation.value - i / _dots) % 1.0 + 1.0) % 1.0;
      final strength = 1.0 - t;
      final angle = 2 * math.pi * i / _dots - math.pi / 2;
      paint.color = color.withValues(alpha: 0.15 + 0.85 * strength);
      canvas.drawCircle(
        center + Offset(math.cos(angle), math.sin(angle)) * ringRadius,
        2 + 4 * strength,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(LoadingPainter old) => old.color != color;
}
