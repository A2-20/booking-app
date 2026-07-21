import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/user_state.dart';
import '../../../services/auth_service.dart';
import '../../../services/hotel_service.dart';
import '../../../services/flight_service.dart';
import '../../../services/package_service.dart';
import '../../../core/utils/page_transitions.dart';
import '../auth/login_screen.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    _initializeApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    // Initialize services and load data
    await Future.wait([
      AuthService.initializeUsers(),
      HotelService.initializeHotels(),
      FlightService.initializeFlights(),
      PackageService.initializePackages(),
    ]);

    // Wait for animation to complete
    await Future.delayed(const Duration(seconds: 5));

    // Initialize user state
    final userState = Provider.of<UserState>(context, listen: false);
    await userState.initialize();

    // Navigate to appropriate screen
    if (mounted) {
      if (userState.isLoggedIn) {
        Navigator.of(context).pushReplacement(
          AppPageTransitions.fadeSlideRoute(const HomeScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          AppPageTransitions.fadeSlideRoute(const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
            stops: const [0.3, 1.5],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/logo.png',

                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
