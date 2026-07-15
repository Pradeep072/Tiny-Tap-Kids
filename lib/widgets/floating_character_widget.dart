import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/scheduler.dart';

class FloatingCharacterWidget extends StatefulWidget {
  final String character;
  final double startX;
  final double startY;
  final Color color;
  final bool isTapped;
  final Function(Offset) onTap;

  const FloatingCharacterWidget({
    super.key,
    required this.character,
    required this.startX,
    required this.startY,
    required this.color,
    required this.isTapped,
    required this.onTap,
  });

  @override
  State<FloatingCharacterWidget> createState() =>
      _FloatingCharacterWidgetState();
}

class _FloatingCharacterWidgetState extends State<FloatingCharacterWidget>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _tapController;
  late Ticker _physicsTicker;

  late Animation<Offset> _floatAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _flyUpAnimation;

  final GlobalKey _widgetKey = GlobalKey();

  Offset _position = Offset.infinite;
  Offset _velocity = Offset.zero;
  bool _isDragging = false;
  DateTime _lastTick = DateTime.now();

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      duration: Duration(seconds: 3 + Random().nextInt(3)),
      vsync: this,
    )..repeat(reverse: true);

    _tapController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _physicsTicker = createTicker(_onPhysicsTick);

    final random = Random();
    final offsetX = (random.nextDouble() - 0.5) * 0.3;
    final offsetY = (random.nextDouble() - 0.5) * 0.3;

    _floatAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(offsetX, offsetY),
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 2.5), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 2.5, end: 0.0), weight: 70),
    ]).animate(CurvedAnimation(parent: _tapController, curve: Curves.easeInOutCubic));

    // We initialize flyUpAnimation in build, as it depends on screen size
    _flyUpAnimation =
        Tween<double>(begin: 0.0, end: 0.0).animate(_tapController);

    _rotateAnimation = Tween<double>(begin: 0, end: 0.1).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(FloatingCharacterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isTapped && !oldWidget.isTapped) {
      _floatController.stop();
      _physicsTicker.stop();
      _tapController.forward(from: 0);
    } else if (!widget.isTapped && oldWidget.isTapped) {
      _tapController.reset();
      _physicsTicker.stop();
      _floatController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    _tapController.dispose();
    _physicsTicker.dispose();
    super.dispose();
  }

  void _onPhysicsTick(Duration elapsed) {
    if (!mounted) return;

    final now = DateTime.now();
    final delta = now.difference(_lastTick).inMilliseconds / 1000.0;
    _lastTick = now;

    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final baseSize = isMobile ? 90.0 : 140.0;

    setState(() {
      // Apply velocity
      _position += _velocity * delta;

      // Apply friction (exponential decay)
      _velocity *= pow(0.4, delta).toDouble();

      // Bounce off walls
      if (_position.dx <= 0 && _velocity.dx < 0) {
        _velocity = Offset(-_velocity.dx * 0.8, _velocity.dy);
      }
      if (_position.dx >= size.width - baseSize && _velocity.dx > 0) {
        _velocity = Offset(-_velocity.dx * 0.8, _velocity.dy);
      }
      if (_position.dy <= 0 && _velocity.dy < 0) {
        _velocity = Offset(_velocity.dx, -_velocity.dy * 0.8);
      }
      if (_position.dy >= size.height - baseSize && _velocity.dy > 0) {
        _velocity = Offset(_velocity.dx, -_velocity.dy * 0.8);
      }

      // Clamp position to be within bounds
      _position = Offset(
        _position.dx.clamp(0.0, size.width - baseSize),
        _position.dy.clamp(0.0, size.height - baseSize),
      );

      if (_velocity.distance < 1.0) {
        _physicsTicker.stop();
        _floatController.repeat(reverse: true);
      }
    });
  }

  Offset _getWidgetPosition() {
    final RenderBox? renderBox =
        _widgetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      return Offset(
        position.dx + renderBox.size.width / 2,
        position.dy + renderBox.size.height / 2,
      );
    }
    return Offset.zero;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final baseSize = isMobile ? 90.0 : 140.0;

    // Initialize position on first build
    if (_position.isInfinite) {
      _position = Offset(
        widget.startX * size.width - baseSize / 2,
        widget.startY * size.height - baseSize / 2,
      );
    }

    // Re-create animation if it's the first build or size changes
    if (_flyUpAnimation.value == 0.0 && _flyUpAnimation.status == AnimationStatus.dismissed) {
      _flyUpAnimation = Tween<double>(begin: 0.0, end: -size.height * 0.7).animate(
        CurvedAnimation(parent: _tapController, curve: Curves.easeIn),
      );
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_floatController, _tapController]), // Ticker updates via setState
      builder: (context, child) {
        final tapOffset = widget.isTapped ? _flyUpAnimation.value : 0.0;
        final currentScale = widget.isTapped ? _scaleAnimation.value : 1.0;

        final bool isPhysicsActive = _physicsTicker.isTicking || _isDragging;
        final floatOffsetX = isPhysicsActive ? 0.0 : _floatAnimation.value.dx * 100;
        final floatOffsetY = isPhysicsActive ? 0.0 : _floatAnimation.value.dy * 100;

        return Positioned(
          left: _position.dx + floatOffsetX,
          top: _position.dy + floatOffsetY + tapOffset,
          child: GestureDetector(
            onPanStart: (details) {
              if (widget.isTapped) return;
              setState(() {
                _isDragging = true;
                _floatController.stop();
                _physicsTicker.stop();
              });
            },
            onPanUpdate: (details) {
              if (widget.isTapped) return;
              setState(() {
                _position += details.delta;
                // Clamp position during drag
                _position = Offset(
                  _position.dx.clamp(0.0, size.width - baseSize),
                  _position.dy.clamp(0.0, size.height - baseSize),
                );
              });
            },
            onPanEnd: (details) {
              if (widget.isTapped) return;
              setState(() {
                _isDragging = false;
                _velocity = details.velocity.pixelsPerSecond;
                if (_velocity.distance > 10.0) {
                  _lastTick = DateTime.now();
                  _physicsTicker.start();
                } else {
                  _floatController.repeat(reverse: true);
                }
              });
            },
            onTap: () {
              if (_isDragging) return;
              widget.onTap(_getWidgetPosition());
            },
            child: Transform.scale(
              scale: currentScale,
              child: Transform.rotate(
                angle: isPhysicsActive ? 0.0 : _rotateAnimation.value,
                child: Container(
                  key: _widgetKey,
                  width: baseSize,
                  height: baseSize,
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      widget.character,
                      style: TextStyle(
                        fontSize: isMobile ? 50 : 80,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
