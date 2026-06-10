import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../animations/notebook_3d_logo.dart';
import '../services/preferences_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _particleController;
  late final AnimationController _exitController;
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scheduleNavigation();
  }

  Future<void> _scheduleNavigation() async {
    await Future<void>.delayed(const Duration(milliseconds: 3200));
    if (!mounted || _navigating) return;
    _navigating = true;
    await _exitController.forward();
    if (!mounted) return;
    await PreferencesService.setSplashSeen();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 900),
        reverseTransitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _particleController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _exitController,
        builder: (context, child) {
          return Opacity(
            opacity: 1 - _exitController.value,
            child: Transform.scale(
              scale: 1 - _exitController.value * 0.05,
              child: child,
            ),
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            const _SplashBackground(),
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _ParticlePainter(_particleController.value),
                  size: Size.infinite,
                );
              },
            ),
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  const Notebook3DLogo(size: 180),
                  const SizedBox(height: 36),
                  Text(
                    'Notebooku',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                  )
                      .animate()
                      .fadeIn(delay: 800.ms, duration: 600.ms)
                      .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic),
                  const SizedBox(height: 10),
                  Text(
                    'Catatan cerdas, kapan saja',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withAlpha(180),
                          fontWeight: FontWeight.w500,
                        ),
                  )
                      .animate()
                      .fadeIn(delay: 1100.ms, duration: 500.ms)
                      .slideY(begin: 0.2, end: 0),
                  const Spacer(flex: 2),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 48),
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white.withAlpha(160),
                      ),
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat())
                      .fadeIn(delay: 1400.ms)
                      .then()
                      .shimmer(
                        duration: 1200.ms,
                        color: AppTheme.teal.withAlpha(100),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashBackground extends StatelessWidget {
  const _SplashBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A1614),
            Color(0xFF101E1C),
            Color(0xFF1A2F2B),
            Color(0xFF0F1A18),
          ],
          stops: [0.0, 0.35, 0.7, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.teal.withAlpha(30),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.plum.withAlpha(25),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;

  _ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(42);

    for (var i = 0; i < 40; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final radius = 1.0 + random.nextDouble() * 2.5;
      final speed = 0.3 + random.nextDouble() * 0.7;
      final phase = random.nextDouble() * math.pi * 2;

      final y = (baseY + math.sin(progress * math.pi * 2 * speed + phase) * 20) %
          size.height;
      final opacity = (0.15 + math.sin(progress * math.pi * 2 + phase).abs() * 0.35);

      paint.color = Color.lerp(
        AppTheme.teal,
        AppTheme.coral,
        random.nextDouble(),
      )!.withAlpha((opacity * 255).round());

      canvas.drawCircle(Offset(baseX, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
