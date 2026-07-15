import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:async';
import '../widgets/floating_character_widget.dart';
import '../widgets/background_bubbles.dart';

class MainScreen extends StatefulWidget {
  final String language;

  const MainScreen({super.key, required this.language});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final FocusNode _focusNode = FocusNode();
  int? _tappedCharacterId;
  bool _showBurst = false;
  Offset? _burstPosition;
  final Random _random = Random();

  List<String> get characters {
    const englishAlphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const numbers = '0123456789';
    final emojis = ['😊', '⭐', '❤️', '🌟', '😂', '😍', '🥳', '👍'];

    if (widget.language == 'english') {
      return [
        ...englishAlphabet.split(''),
        ...numbers.split(''),
        ...emojis,
      ];
    } else {
      const hindiVowels = 'अआइईउऊऋएऐओऔ';
      const hindiConsonants = 'कखगघङचछजझञटठडढणतथदधनपफबभमयरलवशषसह';
      return [
        ...hindiVowels.split(''),
        ...hindiConsonants.split(''),
        ...numbers.split(''),
        ...emojis,
      ];
    }
  }

  List<CharacterData> _characterDataList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize characters here because it needs the context (for MediaQuery),
    // which is not fully available in initState().
    if (_characterDataList.isEmpty) {
      _initializeCharacters();
    }
  }

  void _initializeCharacters() {
    final random = Random();
    final size = MediaQuery.of(context).size;
    final int numberOfCharacters = (size.width / 100).round().clamp(10, 15);
    final selectedChars = (characters..shuffle()).take(numberOfCharacters).toList();

    _characterDataList = selectedChars.asMap().entries.map((entry) {
      return CharacterData(
        character: entry.value,
        startX: _random.nextDouble(),
        startY: _random.nextDouble(),
        color: _getRandomColor(),
        id: entry.key,
      );
    }).toList();
  }

  Color _getRandomColor() {
    final colors = [
      Colors.red.shade400,
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.pink.shade400,
      Colors.yellow.shade700,
      Colors.teal.shade400,
    ];
    return colors[Random().nextInt(colors.length)];
  }

  void _handleCharacterTap(int id, Offset position) {
    setState(() {
      _tappedCharacterId = id;
      _showBurst = true;
      _burstPosition = position;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _replaceCharacter(id);
      }
    });
  }

  void _handleBackgroundTap() {
    // No longer needed, as characters fly away automatically
  }

  void _handleKeyPress(KeyEvent event) {
    if (event is KeyDownEvent) {
      final key = event.character?.toUpperCase() ?? '';

      for (var data in _characterDataList) {
        final char = data.character.toUpperCase();
        if (char == key || (char == 'अ' && key == 'A') ||
            (char == 'क' && key == 'K') || (char == 'म' && key == 'M') ||
            (char == 'न' && key == 'N') || (char == 'प' && key == 'P') ||
            (char == 'र' && key == 'R') || (char == 'स' && key == 'S') ||
            (char == 'ल' && key == 'L')) {

          final size = MediaQuery.of(context).size;
          final position = Offset(
            data.startX * size.width, // Approximate position for burst effect
            data.startY * size.height,
          );
          _handleCharacterTap(data.id, position);
          break;
        }
      }
    }
  }

  void _replaceCharacter(int idToReplace) {
    setState(() {
      final currentChars = _characterDataList.map((d) => d.character).toSet();
      final availableChars =
          characters.where((c) => !currentChars.contains(c)).toList();
      final newChar = availableChars.isNotEmpty
          ? (availableChars..shuffle()).first
          : (characters..shuffle()).first;

      final indexToReplace =
          _characterDataList.indexWhere((d) => d.id == idToReplace);

      if (indexToReplace != -1) {
        _characterDataList[indexToReplace] = CharacterData(
          character: newChar,
          startX: _random.nextDouble(),
          startY: _random.nextDouble(),
          color: _getRandomColor(),
          id: idToReplace,
        );
      }

      _tappedCharacterId = null;
      _showBurst = false;
    });
  }

    @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyPress,
      child: GestureDetector(
        onTap: _handleBackgroundTap,
        child: Scaffold(
          body: Stack(
            children: [
              const BackgroundBubbles(),

              ..._characterDataList.map((data) {
                final isTapped = _tappedCharacterId == data.id;
                return FloatingCharacterWidget(
                  character: data.character,
                  startX: data.startX,
                  startY: data.startY,
                  color: data.color,
                  isTapped: isTapped,
                  onTap: (position) => _handleCharacterTap(data.id, position),
                );
              }),

              if (_showBurst && _burstPosition != null)
                BurstEffect(position: _burstPosition!),

              Positioned(
                top: 40,
                left: 20,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, size: 32, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CharacterData {
  String character;
  double startX;
  double startY;
  Color color;
  int id;

  CharacterData({
    required this.character,
    required this.startX,
    required this.startY,
    required this.color,
    required this.id,
  });
}

class BurstEffect extends StatefulWidget {
  final Offset position;

  const BurstEffect({super.key, required this.position});

  @override
  State<BurstEffect> createState() => _BurstEffectState();
}

class _BurstEffectState extends State<BurstEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late List<ParticleData> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();

    _progressAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _particles = List.generate(12, (index) {
      final angle = (index / 12) * 2 * pi;
      return ParticleData(
        icon: [Icons.star, Icons.favorite, Icons.circle][index % 3],
        color: [Colors.yellow, Colors.pink, Colors.orange][index % 3],
        angle: angle,
      );
    });
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
        return Stack(
          children: _particles.map((particle) {
            final distance = _progressAnimation.value * 150;
            final x = widget.position.dx + cos(particle.angle) * distance;
            final y = widget.position.dy + sin(particle.angle) * distance +
                (200 * _controller.value * _controller.value); // Gravity
            final opacity = 1.0 - _progressAnimation.value;

            return Positioned(
              left: x - 15,
              top: y - 15,
              child: Opacity(
                opacity: opacity,
                child: Icon(
                  particle.icon,
                  size: 30,
                  color: particle.color,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class ParticleData {
  final IconData icon;
  final Color color;
  final double angle;

  ParticleData({
    required this.icon,
    required this.color,
    required this.angle,
  });
}
