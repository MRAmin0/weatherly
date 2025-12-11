import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:weatherly_app/presentation/widgets/animations/icon/svg_assets.dart';

class RainDropAnimator extends StatefulWidget {
  final double width;
  final double height;

  const RainDropAnimator({
    super.key,
    required this.width,
    required this.height,
  });

  @override
  State<RainDropAnimator> createState() => _RainDropAnimatorState();
}

class _RainDropAnimatorState extends State<RainDropAnimator>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;

  @override
  void initState() {
    super.initState();
    // Three drops with different speeds/offsets
    _controller1 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _controller2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _controller3 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // Stagger start
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _controller2.repeat();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _controller3.repeat();
    });
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  Widget _buildDrop(
    AnimationController controller,
    double leftOffset,
    double scale,
  ) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        // Fall from top (0) to bottom (height)
        final double y = controller.value * (widget.height * 1.5);
        final double opacity = 1.0 - controller.value; // Fade out as it falls

        // Reset check is automatic via repeat()

        return Positioned(
          top: y,
          left: leftOffset,
          child: Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              child: SvgPicture.string(dropSvg, width: 24, height: 24),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // We render drops in a container of size width x height
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          // Left Drop
          _buildDrop(_controller1, widget.width * 0.25, 0.7),
          // Center Drop
          _buildDrop(_controller2, widget.width * 0.45, 0.9),
          // Right Drop
          _buildDrop(_controller3, widget.width * 0.65, 0.8),
        ],
      ),
    );
  }
}
