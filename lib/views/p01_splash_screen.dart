import 'package:flutter/material.dart';
import 'dart:async';
import '../core/app_theme.dart';
import 'p03_onboarding_view.dart';

class P01SplashScreen extends StatefulWidget {
  const P01SplashScreen({super.key});

  @override
  State<P01SplashScreen> createState() => _P01SplashScreenState();
}

class _P01SplashScreenState extends State<P01SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _controller.forward();

    Timer(const Duration(milliseconds: 3000), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const P03OnboardingView()),
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.cieOrange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.bolt_rounded, size: 100, color: AppTheme.cieOrange),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        "CourantInfo CI",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "VOTRE ÉNERGIE, NOTRE PRIORITÉ",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.cieOrange,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 60,
            left: 50,
            right: 50,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: const LinearProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.cieOrange),
                      backgroundColor: Color(0xFFF5F5F5),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
