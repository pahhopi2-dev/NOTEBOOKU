import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Animated 3D notebook logo with page-flip and depth perspective.
class Notebook3DLogo extends StatefulWidget {
  final double size;
  final bool animate;

  const Notebook3DLogo({
    super.key,
    this.size = 160,
    this.animate = true,
  });

  @override
  State<Notebook3DLogo> createState() => _Notebook3DLogoState();
}

class _Notebook3DLogoState extends State<Notebook3DLogo>
    with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final AnimationController _glowController;
  late final Animation<double> _rotateY;
  late final Animation<double> _rotateX;
  late final Animation<double> _scale;
  late final Animation<double> _pageFlip;
  late final Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _rotateY = Tween<double>(begin: -0.6, end: 0.15).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _rotateX = Tween<double>(begin: 0.35, end: -0.08).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _scale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );
    _pageFlip = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.35, 0.85, curve: Curves.easeInOutCubic),
      ),
    );
    _float = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeInOutSine),
      ),
    );

    if (widget.animate) {
      _mainController.forward();
    } else {
      _mainController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;

    return AnimatedBuilder(
      animation: Listenable.merge([_mainController, _glowController]),
      builder: (context, _) {
        final floatOffset = math.sin(_float.value * math.pi) * 6;
        final glow = 0.4 + _glowController.value * 0.6;

        return Transform.translate(
          offset: Offset(0, floatOffset),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012)
              ..rotateY(_rotateY.value)
              ..rotateX(_rotateX.value)
              ..multiply(
                Matrix4.diagonal3Values(
                  _scale.value,
                  _scale.value,
                  _scale.value,
                ),
              ),
            child: SizedBox(
              width: s,
              height: s * 1.15,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Ambient glow
                  Container(
                    width: s * 1.4,
                    height: s * 1.4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6FC9BE).withAlpha(
                            (80 * glow).round(),
                          ),
                          blurRadius: 60,
                          spreadRadius: 10,
                        ),
                        BoxShadow(
                          color: const Color(0xFF7359A6).withAlpha(
                            (50 * glow).round(),
                          ),
                          blurRadius: 40,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                  // Back cover
                  _NotebookCover(
                    width: s * 0.88,
                    height: s * 1.05,
                    color: const Color(0xFF1A3D38),
                    spineColor: const Color(0xFF0F2824),
                    isBack: true,
                  ),
                  // Pages stack
                  ...List.generate(4, (i) {
                    final offset = i * 2.0;
                    final flipAngle = i == 3 ? _pageFlip.value * 0.8 : 0.0;
                    return Positioned(
                      left: s * 0.08 + offset,
                      top: s * 0.06 + offset * 0.5,
                      child: Transform(
                        alignment: Alignment.centerLeft,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(-flipAngle),
                        child: Container(
                          width: s * 0.76 - offset,
                          height: s * 0.92 - offset,
                          decoration: BoxDecoration(
                            color: Color.lerp(
                              const Color(0xFFFFFDF8),
                              const Color(0xFFF0EDE6),
                              i / 4,
                            ),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(4),
                              bottomRight: Radius.circular(4),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(20),
                                blurRadius: 4,
                                offset: const Offset(1, 2),
                              ),
                            ],
                          ),
                          child: i == 2
                              ? Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 6,
                                        width: s * 0.4,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1F7A70)
                                              .withAlpha(180),
                                          borderRadius:
                                              BorderRadius.circular(3),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ...List.generate(
                                        3,
                                        (j) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 6,
                                          ),
                                          child: Container(
                                            height: 3,
                                            width: s * (0.5 - j * 0.08),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF66736F)
                                                  .withAlpha(60 + j * 20),
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : null,
                        ),
                      ),
                    );
                  }),
                  // Front cover
                  _NotebookCover(
                    width: s * 0.88,
                    height: s * 1.05,
                    color: const Color(0xFF1F7A70),
                    spineColor: const Color(0xFF155A52),
                    isBack: false,
                    logoSize: s * 0.28,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NotebookCover extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final Color spineColor;
  final bool isBack;
  final double logoSize;

  const _NotebookCover({
    required this.width,
    required this.height,
    required this.color,
    required this.spineColor,
    required this.isBack,
    this.logoSize = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (isBack) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(60),
              blurRadius: 20,
              offset: const Offset(4, 8),
            ),
          ],
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, Color.lerp(color, Colors.black, 0.15)!],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(100),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 16,
            offset: const Offset(4, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Spine
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 10,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: spineColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
            ),
          ),
          // Elastic band
          Positioned(
            right: width * 0.15,
            top: 0,
            bottom: 0,
            width: 8,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFE56B5D).withAlpha(200),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          // Logo icon
          if (logoSize > 0)
            Center(
              child: Icon(
                Icons.auto_stories_rounded,
                size: logoSize,
                color: Colors.white.withAlpha(220),
              ),
            ),
        ],
      ),
    );
  }
}
