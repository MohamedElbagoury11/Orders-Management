import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme_helper.dart';
import '../blocs/auth/auth_bloc.dart';
import 'auth/login_page.dart';
import 'home_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _fadeController.forward();
    _scaleController.forward();
    
    // Check authentication state after animation
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.read<AuthBloc>().add(CheckAuthStateEvent());
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          } else if (state is Unauthenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          }
        },
        child: Container(
          decoration: AppThemeHelper.getBackgroundGradientDecoration(context),
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: AppThemeHelper.getCardPadding(context),
                  decoration: AppThemeHelper.getCardDecoration(context),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // App Icon
                      Center(
                    child: Image.asset(
                      'assets/icon/icon.png',
                      height: MediaQuery.of(context).size.height * 0.2,
                    ),
                  ),
                      
                      const SizedBox(height: AppThemeHelper.standardSpacing),
                      
                      // App Name
                      Text(
                        'Project Management',
                        style: AppThemeHelper.getHeadlineStyle(context).copyWith(
                          fontSize: 28,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: AppThemeHelper.smallSpacing),
                      
                      // App Description
                      Text(
                        'Manage your business efficiently',
                        style: AppThemeHelper.getBodyStyle(context).copyWith(
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: AppThemeHelper.standardSpacing),
                      
                      // Loading Indicator
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 