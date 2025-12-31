import 'package:flutter/widgets.dart';

class BouncingDots extends StatefulWidget {
  const BouncingDots({super.key});

  @override
  State<BouncingDots> createState() => _BouncingDotsState();
}

class _BouncingDotsState extends State<BouncingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _animation = Tween(
      begin: 0.0,
      end: -6.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animation,
          builder: (_, child) {
            return Transform.translate(
              offset: Offset(0, _animation.value * (index == 1 ? 1.4 : 1)),
              child: child,
            );
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              ".",
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF0A3D62),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  }
}
