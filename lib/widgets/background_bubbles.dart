import 'package:flutter/material.dart';
import 'dart:math';

class BackgroundBubbles extends StatefulWidget {
  const BackgroundBubbles({super.key});

  @override
  State<BackgroundBubbles> createState() => _BackgroundBubblesState();
}

class _BackgroundBubblesState extends State<BackgroundBubbles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Bubble> _bubbles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    final random = Random();
    for (int i = 0; i < 8; i++) {
      _bubbles.add(Bubble(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: 50 + random.nextDouble() * 150,
        speed: 0.3 + random.nextDouble() * 0.5,
        color: _getRandomColor(),
      ));
    }
  }

  Color _getRandomColor() {
    final colors = [
      Colors.blue.shade200.withOpacity(0.3),
      Colors.pink.shade200.withOpacity(0.3),
      Colors.green.shade200.withOpacity(0.3),
      Colors.yellow.shade200.withOpacity(0.3),
      Colors.orange.shade200.withOpacity(0.3),
    ];
    return colors[Random().nextInt(colors.length)];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade300,
            Colors.cyan.shade200,
            Colors.green.shade300,
            Colors.yellow.shade200,
          ],
        ),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: _bubbles.map((bubble) {
              final progress = (_controller.value * bubble.speed) % 1.0;
              final yPos = progress * size.height;
              final xOffset = sin(progress * 2 * pi * 2) * 50;

              return Positioned(
                left: bubble.x * size.width + xOffset - bubble.size / 2,
                top: yPos - bubble.size / 2,
                child: Container(
                  width: bubble.size,
                  height: bubble.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: bubble.color,
                    boxShadow: [
                      BoxShadow(
                        color: bubble.color.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class Bubble {
  final double x;
  final double y;
  final double size;
  final double speed;
  final Color color;

  Bubble({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.color,
  });
}
