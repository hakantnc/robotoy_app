import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'main_screen.dart';

class SavingScreen extends StatefulWidget {
  const SavingScreen({super.key});

  @override
  State<SavingScreen> createState() => _SavingScreenState();
}

class _SavingScreenState extends State<SavingScreen>
    with TickerProviderStateMixin {
  static const Color _pink = Color(0xFFFFC5D3);
  static const Color _lavender = Color(0xFFC8B6E2);
  static const Color _cream = Color(0xFFFFF8F0);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _textDark = Color(0xFF5B4B6E);

  Timer? _navigationTimer;

  late final AnimationController _entryController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  late final AnimationController _bounceController;
  late final Animation<double> _bounceAnimation;

  late final AnimationController _spinController;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );
    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
        );

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _bounceAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _entryController.forward();

    _navigationTimer = Timer(const Duration(seconds: 15), _goToMainScreen);
  }

  void _goToMainScreen() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, _, _) => const MainScreen(),
        transitionsBuilder: (_, animation, _, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _entryController.dispose();
    _bounceController.dispose();
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: Stack(
        children: [
          const Positioned(
            top: -80,
            right: -60,
            child: _PastelBlob(size: 240, color: _pink),
          ),
          const Positioned(
            bottom: -100,
            left: -70,
            child: _PastelBlob(size: 280, color: _lavender),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedBuilder(
                          animation: _bounceAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _bounceAnimation.value),
                              child: child,
                            );
                          },
                          child: const _CuteRobot(),
                        ),
                        const SizedBox(height: 48),
                        const Text(
                          'Ayarlarınız kaydediliyor...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: _textDark,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Robotoy küçük dostunu hazırlıyor,\nlütfen biraz bekle.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: _textDark.withValues(alpha: 0.65),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 40),
                        _OrbitingDotsIndicator(
                          controller: _spinController,
                          primary: _pink,
                          secondary: _lavender,
                          background: _white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PastelBlob extends StatelessWidget {
  const _PastelBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.55), color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}

class _CuteRobot extends StatelessWidget {
  const _CuteRobot();

  static const Color _pink = Color(0xFFFFC5D3);
  static const Color _lavender = Color(0xFFC8B6E2);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _eye = Color(0xFF5B4B6E);
  static const Color _cheek = Color(0xFFFFA8BD);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0,
            child: Container(
              width: 6,
              height: 28,
              decoration: BoxDecoration(
                color: _lavender,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: _pink,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 24,
            child: Container(
              width: 170,
              height: 150,
              decoration: BoxDecoration(
                color: _white,
                borderRadius: BorderRadius.circular(38),
                boxShadow: [
                  BoxShadow(
                    color: _lavender.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
                border: Border.all(color: _pink.withValues(alpha: 0.45), width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        _RobotEye(),
                        _RobotEye(),
                      ],
                    ),
                    Container(
                      width: 38,
                      height: 14,
                      decoration: BoxDecoration(
                        color: _pink,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 96,
            left: 18,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: _cheek.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 96,
            right: 18,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: _cheek.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 178,
            child: Container(
              width: 130,
              height: 60,
              decoration: BoxDecoration(
                color: _lavender,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Center(
                child: Container(
                  width: 60,
                  height: 22,
                  decoration: BoxDecoration(
                    color: _white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 70,
            left: 0,
            child: Container(
              width: 22,
              height: 70,
              decoration: BoxDecoration(
                color: _pink,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Positioned(
            top: 70,
            right: 0,
            child: Container(
              width: 22,
              height: 70,
              decoration: BoxDecoration(
                color: _pink,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RobotEye extends StatelessWidget {
  const _RobotEye();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: const BoxDecoration(
        color: _CuteRobot._eye,
        shape: BoxShape.circle,
      ),
      child: Align(
        alignment: const Alignment(-0.4, -0.4),
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFFFFFFFF),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _OrbitingDotsIndicator extends StatelessWidget {
  const _OrbitingDotsIndicator({
    required this.controller,
    required this.primary,
    required this.secondary,
    required this.background,
  });

  final AnimationController controller;
  final Color primary;
  final Color secondary;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: secondary.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final t = controller.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              for (int i = 0; i < 3; i++)
                _buildDot(
                  index: i,
                  progress: t,
                  color: i.isEven ? primary : secondary,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDot({
    required int index,
    required double progress,
    required Color color,
  }) {
    const radius = 26.0;
    final phase = (progress + index / 3) % 1.0;
    final angle = phase * 2 * math.pi;
    final dx = radius * math.cos(angle);
    final dy = radius * math.sin(angle);
    final scale = 0.8 + 0.4 * ((math.sin(phase * 2 * math.pi) + 1) / 2);

    return Transform.translate(
      offset: Offset(dx, dy),
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.45),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
