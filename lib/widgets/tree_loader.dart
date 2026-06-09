import 'package:flutter/material.dart';
import 'dart:math' as math;

class TreeLoader extends StatefulWidget {
  final double size;
  final Color? color;

  const TreeLoader({Key? key, this.size = 60.0, this.color}) : super(key: key);

  @override
  _TreeLoaderState createState() => _TreeLoaderState();
}

class _TreeLoaderState extends State<TreeLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.85 + (_controller.value * 0.3), // Pulse effect
          child: Transform.rotate(
            angle: math.sin(_controller.value * math.pi) * 0.15, // Sway effect
            child: Icon(
              Icons.park, // Tree icon
              size: widget.size,
              color: widget.color ?? Colors.green[700],
            ),
          ),
        );
      },
    );
  }
}
