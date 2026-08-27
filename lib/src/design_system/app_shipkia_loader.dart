import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/shipkia_colors.dart';
import 'shipkia_tokens.dart';

class AppShipKiaLoader extends StatefulWidget {
  const AppShipKiaLoader({
    this.size = 96,
    this.showLabel = true,
    this.message,
    super.key,
  });

  final double size;
  final bool showLabel;
  final String? message;

  @override
  State<AppShipKiaLoader> createState() => _AppShipKiaLoaderState();
}

class _AppShipKiaLoaderState extends State<AppShipKiaLoader>
    with SingleTickerProviderStateMixin {
  static const _messages = [
    'Packing the fastest route.',
    'Sorting parcels with care.',
    'Checking pincode promises.',
    'Calling the nearest courier.',
    'Balancing speed with precision.',
    'Finding the cleanest lane.',
    'Labeling your next shipment.',
    'Syncing pickup windows.',
    'Routing around traffic.',
    'Sealing the manifest.',
  ];

  late final AnimationController _controller;
  int _messageIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    )..repeat();
    _messageIndex = DateTime.now().millisecond % _messages.length;
    _controller.addListener(_updateMessage);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_updateMessage)
      ..dispose();
    super.dispose();
  }

  void _updateMessage() {
    if (widget.message != null) return;
    final nextIndex =
        (_controller.lastElapsedDuration?.inMilliseconds ?? 0) ~/
        800 %
        _messages.length;
    if (nextIndex != _messageIndex && mounted) {
      setState(() => _messageIndex = nextIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final message = widget.message ?? _messages[_messageIndex];

    return Semantics(
      label: 'Loading',
      liveRegion: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: isDark ? 0.2 : 0.16,
                  child: SvgPicture.asset(
                    'assets/icons/shipkia_fav.svg',
                    width: widget.size * 0.78,
                    height: widget.size * 0.78,
                    colorFilter: ColorFilter.mode(
                      isDark ? ShipKiaColors.paper : ShipKiaColors.mutedInk,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size.square(widget.size),
                      painter: _ShipKiaParticlePainter(
                        progress: _controller.value,
                        isDark: isDark,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          if (widget.showLabel) ...[
            const SizedBox(height: 8),
            Text(
              'ShipKia',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedSwitcher(
              duration: ShipKiaMotion.duration(context, ShipKiaMotion.normal),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: Text(
                message,
                key: ValueKey(message),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ShipKiaColors.mutedInk,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class AppLoadingScreen extends StatelessWidget {
  const AppLoadingScreen({this.message, super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Center(child: AppShipKiaLoader(message: message)),
    );
  }
}

class _ShipKiaParticlePainter extends CustomPainter {
  const _ShipKiaParticlePainter({required this.progress, required this.isDark});

  static const _particleCount = 72;
  static const _trailSpan = 0.58;
  static const _tau = math.pi * 2;

  final double progress;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final visualSize = size.shortestSide;
    final pathScale = visualSize / 96;
    final accent = ShipKiaColors.shipkiaBlue;
    final base = Paint()
      ..color = (isDark ? ShipKiaColors.paper : ShipKiaColors.mutedInk)
          .withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6 * pathScale
      ..strokeCap = StrokeCap.round;

    final path = _buildPath(center, visualSize * 0.34, visualSize * 0.42);
    canvas.drawPath(path, base);

    final chase = _normalize(
      progress +
          math.sin(progress * _tau) * 0.045 +
          math.sin(progress * _tau * 2 + 0.75) * 0.012,
    );

    for (var index = 0; index < _particleCount; index += 1) {
      final tailOffset = index / (_particleCount - 1);
      final particleProgress = _normalize(
        chase - math.pow(tailOffset, 1.32) * _trailSpan,
      );
      final fade =
          math.pow(1 - tailOffset, 0.56) *
          (0.92 + 0.08 * math.sin((chase - tailOffset * 0.36) * _tau * 2));
      final point = _pointAt(particleProgress, center, visualSize);
      final radius = (0.55 + math.pow(fade, 0.75) * 1.85) * pathScale;
      final paint = Paint()
        ..color = accent.withValues(
          alpha: (0.05 + fade * 0.86).clamp(0.0, 0.95),
        );
      canvas.drawCircle(point, radius, paint);
    }
  }

  Path _buildPath(Offset center, double rx, double ry) {
    final path = Path();
    for (var index = 0; index <= 96; index += 1) {
      final point = _pointAt(index / 96, center, math.max(rx, ry) * 2.38);
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    return path..close();
  }

  Offset _pointAt(double value, Offset center, double visualSize) {
    final t = value * _tau;
    final x =
        center.dx +
        visualSize * 0.28 * math.cos(t) +
        visualSize * 0.09 * math.cos(3 * t + 0.6) +
        visualSize * 0.05 * math.sin(5 * t - 0.4);
    final y =
        center.dy +
        visualSize * 0.36 * math.sin(t) +
        visualSize * 0.08 * math.sin(2 * t + 0.25) +
        visualSize * 0.04 * math.cos(4 * t - 0.5);
    return Offset(x, y);
  }

  double _normalize(double value) => ((value % 1) + 1) % 1;

  @override
  bool shouldRepaint(covariant _ShipKiaParticlePainter oldDelegate) {
    return progress != oldDelegate.progress || isDark != oldDelegate.isDark;
  }
}
