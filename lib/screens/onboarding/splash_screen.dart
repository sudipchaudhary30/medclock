import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/routes.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const Color _backgroundColor = Color(0xFFF8F9FF);
  static const Color _primaryColor = Color(0xFF0E5F97);
  static const Color _badgeTextColor = Color(0xFF4B5F7A);
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;
  bool _canNavigate = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _slideAnim = Tween<double>(
      begin: 30,
      end: 0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      _canNavigate = true;
      _tryNavigate();
    });
  }

  void _navigateToNextScreen() {
    final isInitialized = ref.read(authInitializedProvider);
    if (!isInitialized) return;

    final user = ref.read(authProvider);
    final nextRoute = user != null
        ? (user.role == UserRole.caregiver
              ? AppRoutes.caregiverDashboard
              : AppRoutes.home)
        : AppRoutes.onboarding;

    if (mounted && !_hasNavigated) {
      _hasNavigated = true;
      Navigator.of(context).pushReplacementNamed(nextRoute);
    }
  }

  void _tryNavigate() {
    if (_canNavigate) {
      _navigateToNextScreen();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isInitialized = ref.watch(authInitializedProvider);
    if (isInitialized && _canNavigate && !_hasNavigated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToNextScreen();
      });
    }

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFFE7F5FF), Color(0xFFF8F9FF), Color(0xFFEAF6FF)],
            stops: [0.0, 0.52, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              children: [
                const Spacer(flex: 1),

                // Logo
                AnimatedBuilder(
                  animation: _slideAnim,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(0, _slideAnim.value),
                    child: child,
                  ),
                  child: SizedBox(
                    width: 320,
                    height: 280,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _primaryColor.withOpacity(0.18),
                                blurRadius: 35,
                                spreadRadius: 6,
                              ),
                            ],
                          ),
                        ),
                        Image.asset(
                          'assets/medclocklogo.png',
                          width: 320,
                          height: 280,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Tagline
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    '"Precision monitoring for your\nmedical journey."',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF5F6772),
                      height: 1.7,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // Page Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: index == 0 ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: index == 0
                            ? _primaryColor
                            : _primaryColor.withOpacity(0.28),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 38),

                // Trusted Badge
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.78),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFE2EAF6),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _primaryColor.withOpacity(0.06),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.verified_user_rounded,
                        color: _primaryColor,
                        size: 16,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'TRUSTED BY CLINICAL\nPROFESSIONALS',
                        style: const TextStyle(
                          color: _badgeTextColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.2,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  width: 42,
                  height: 1.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8E2EF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
