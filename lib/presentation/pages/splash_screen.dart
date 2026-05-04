import 'package:flutter/material.dart';
import 'package:personal_expense_tracker_app/core/theme/app_colors.dart';
import 'package:personal_expense_tracker_app/presentation/pages/bottom_navbar_main.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _markFade;
  late Animation<double> _markScale;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _titleScale;
  late Animation<double> _titleLetterSpacing;
  late Animation<double> _subtitleFade;
  late Animation<Offset> _subtitleSlide;

  static const Duration _holdAfterAnimation = Duration(milliseconds: 400);
  static const Duration _crossFadeDuration = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1700));

    _markFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );
    _markScale = Tween<double>(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );
    _titleFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 0.92, curve: Curves.easeOut),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.92, curve: Curves.easeOutCubic),
      ),
    );
    _titleScale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.36, 0.84, curve: Curves.easeOutBack),
      ),
    );
    _titleLetterSpacing = Tween<double>(begin: 6.0, end: -0.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.34, 0.88, curve: Curves.easeOutCubic),
      ),
    );
    _subtitleFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.52, 0.96, curve: Curves.easeOut),
    );
    _subtitleSlide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.52, 0.96, curve: Curves.easeOutCubic),
      ),
    );

    _controller.addStatusListener(_onAnimationStatus);
    _controller.forward();
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    Future<void>.delayed(_holdAfterAnimation, () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          transitionDuration: _crossFadeDuration,
          pageBuilder: (_, _, _) => const BottomNavbarMain(),
          transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onAnimationStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _markScale,
                child: FadeTransition(
                  opacity: _markFade,
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 92,
                    color: AppColors.homeHeaderBlue,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SlideTransition(
                position: _titleSlide,
                child: FadeTransition(
                  opacity: _titleFade,
                  child: ScaleTransition(
                    scale: _titleScale,
                    alignment: Alignment.center,
                    child: AnimatedBuilder(
                      animation: _titleLetterSpacing,
                      builder: (context, child) {
                        return Text(
                          'Expense Tracker',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: const Color(0xFF1565C0),
                            fontWeight: FontWeight.bold,
                            letterSpacing: _titleLetterSpacing.value,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SlideTransition(
                position: _subtitleSlide,
                child: FadeTransition(
                  opacity: _subtitleFade,
                  child: Text(
                    'Know where it goes',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF546E7A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
