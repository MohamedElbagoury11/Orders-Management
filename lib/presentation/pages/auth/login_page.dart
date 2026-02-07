import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projectmange/main.dart';
import 'package:projectmange/presentation/pages/home_page.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/utils/error_messages.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/auth_background.dart';
import '../../widgets/custom_error_dialog.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _googleSignInAvailable = true;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        SignInWithEmailAndPasswordEvent(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  void _signInWithGoogle() {
    context.read<AuthBloc>().add(SignInWithGoogleEvent());
  }

  void _navigateToSignUp() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SignUpPage()));
  }

  void _showErrorDialog(String error) {
    final title = ErrorMessages.getAuthErrorTitle(error, method: 'email');
    final message = ErrorMessages.getAuthErrorMessage(
      error,
      email: _emailController.text.trim(),
      method: 'email',
    );
    final actionText = ErrorMessages.getActionText(error, method: 'email');

    CustomErrorDialog.show(
      context: context,
      title: title,
      message: message,
      actionText: actionText,
      onActionPressed: () {
        Navigator.of(context).pop();
        if (error.toLowerCase().contains('user-not-found')) {
          _navigateToSignUp();
        }
      },
    );
  }

  void _showGoogleErrorDialog(String error) {
    final title = ErrorMessages.getAuthErrorTitle(error, method: 'google');
    final message = ErrorMessages.getAuthErrorMessage(error, method: 'google');
    final actionText = ErrorMessages.getActionText(error, method: 'google');

    CustomErrorDialog.show(
      context: context,
      title: title,
      message: message,
      actionText: actionText,
      onActionPressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return ValueListenableBuilder<Locale>(
      valueListenable: languageNotifier,
      builder: (context, locale, _) {
        AppStrings.setLocale(locale);

        return Scaffold(
          body: BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is Authenticated) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomePage()),
                  (route) => false,
                );
              } else if (state is AuthError) {
                final errorLower = state.message.toLowerCase();
                if (errorLower.contains('pigeonuserdetails') ||
                    errorLower.contains('google') ||
                    errorLower.contains('sign_in_failed') ||
                    errorLower.contains('developer_error') ||
                    errorLower.contains('invalid_account')) {
                  _showGoogleErrorDialog(state.message);
                } else {
                  _showErrorDialog(state.message);
                }
              }
            },
            child: AuthBackground(
              child: SafeArea(
                child: Stack(
                  children: [
                    // Main content (Moved before Top Bar to ensure Top Bar is on top)
                    Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Logo with glow effect
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary.withOpacity(0.2),
                                        blurRadius: 40,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Image.asset(
                                    'assets/icon/icon.png',
                                    height: size.height * 0.12,
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Brand name with gradient
                                ShaderMask(
                                  shaderCallback:
                                      (bounds) => LinearGradient(
                                        colors: [
                                          Theme.of(context).colorScheme.primary,
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                        ],
                                      ).createShader(bounds),
                                  child: Text(
                                    AppStrings.brandIdentity,
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize:
                                          28, // Slightly smaller to fit better
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 1.0,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),

                                const SizedBox(height: 48),

                                // Glass card container
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(32),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 10,
                                      sigmaY: 10,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(32),
                                      decoration: BoxDecoration(
                                        color:
                                            isDark
                                                ? Colors.black.withOpacity(0.3)
                                                : Colors.white.withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(32),
                                        border: Border.all(
                                          color:
                                              isDark
                                                  ? Colors.white.withOpacity(
                                                    0.1,
                                                  )
                                                  : Colors.white.withOpacity(
                                                    0.5,
                                                  ),
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 30,
                                            spreadRadius: 5,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: Form(
                                        key: _formKey,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Welcome text
                                            Text(
                                              AppStrings.welcomeBack,
                                              style: GoogleFonts.poppins(
                                                fontSize: 26,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    isDark
                                                        ? Colors.white
                                                        : Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              AppStrings.signInToContinue,
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color:
                                                    isDark
                                                        ? Colors.white70
                                                        : Colors.black54,
                                              ),
                                            ),

                                            const SizedBox(height: 32),

                                            // Email field
                                            _buildTextField(
                                              controller: _emailController,
                                              label: AppStrings.email,
                                              icon: Icons.email_rounded,
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return AppStrings
                                                      .pleaseEnterEmail;
                                                }
                                                if (!RegExp(
                                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                                ).hasMatch(value)) {
                                                  return AppStrings
                                                      .pleaseEnterValidEmail;
                                                }
                                                return null;
                                              },
                                            ),

                                            const SizedBox(height: 20),

                                            // Password field
                                            _buildTextField(
                                              controller: _passwordController,
                                              label: AppStrings.password,
                                              icon: Icons.lock_rounded,
                                              obscureText: _obscurePassword,
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _obscurePassword
                                                      ? Icons.visibility_rounded
                                                      : Icons
                                                          .visibility_off_rounded,
                                                  color:
                                                      Theme.of(
                                                        context,
                                                      ).colorScheme.primary,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _obscurePassword =
                                                        !_obscurePassword;
                                                  });
                                                },
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return AppStrings
                                                      .pleaseEnterPassword;
                                                }
                                                if (value.length < 6) {
                                                  return AppStrings
                                                      .passwordTooShort;
                                                }
                                                return null;
                                              },
                                            ),

                                            const SizedBox(height: 32),

                                            // Login button
                                            BlocBuilder<AuthBloc, AuthState>(
                                              builder: (context, state) {
                                                return Container(
                                                  width: double.infinity,
                                                  height: 56,
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Theme.of(
                                                          context,
                                                        ).colorScheme.primary,
                                                        Theme.of(
                                                          context,
                                                        ).colorScheme.secondary,
                                                      ],
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary
                                                            .withOpacity(0.4),
                                                        blurRadius: 20,
                                                        offset: const Offset(
                                                          0,
                                                          10,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  child: ElevatedButton(
                                                    onPressed:
                                                        state is AuthLoading
                                                            ? null
                                                            : _submitForm,
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      shadowColor:
                                                          Colors.transparent,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              16,
                                                            ),
                                                      ),
                                                    ),
                                                    child:
                                                        state is AuthLoading
                                                            ? const SizedBox(
                                                              height: 24,
                                                              width: 24,
                                                              child: CircularProgressIndicator(
                                                                strokeWidth:
                                                                    2.5,
                                                                valueColor:
                                                                    AlwaysStoppedAnimation<
                                                                      Color
                                                                    >(
                                                                      Colors
                                                                          .white,
                                                                    ),
                                                              ),
                                                            )
                                                            : Text(
                                                              AppStrings.login,
                                                              style: GoogleFonts.poppins(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                            ),
                                                  ),
                                                );
                                              },
                                            ),

                                            const SizedBox(height: 24),

                                            // Divider with "OR"
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Divider(
                                                    color:
                                                        isDark
                                                            ? Colors.white24
                                                            : Colors.black12,
                                                    thickness: 1,
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                      ),
                                                  child: Text(
                                                    AppStrings.or,
                                                    style: GoogleFonts.poppins(
                                                      color:
                                                          isDark
                                                              ? Colors.white70
                                                              : Colors.black54,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Divider(
                                                    color:
                                                        isDark
                                                            ? Colors.white24
                                                            : Colors.black12,
                                                    thickness: 1,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 24),

                                            // Google Sign-In button
                                            BlocBuilder<AuthBloc, AuthState>(
                                              builder: (context, state) {
                                                return Container(
                                                  width: double.infinity,
                                                  height: 56,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        isDark
                                                            ? Colors.white
                                                                .withOpacity(
                                                                  0.05,
                                                                )
                                                            : Colors
                                                                .transparent,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                    border: Border.all(
                                                      color:
                                                          isDark
                                                              ? Colors.white24
                                                              : Colors.grey
                                                                  .withOpacity(
                                                                    0.3,
                                                                  ),
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: OutlinedButton.icon(
                                                    onPressed:
                                                        (state is AuthLoading ||
                                                                !_googleSignInAvailable)
                                                            ? null
                                                            : _signInWithGoogle,
                                                    icon: Image.asset(
                                                      'assets/icon/icon.png',
                                                      height: 24,
                                                      width: 24,
                                                    ),
                                                    label: Text(
                                                      AppStrings
                                                          .signInWithGoogle,
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            isDark
                                                                ? Colors.white
                                                                : Colors
                                                                    .black87,
                                                      ),
                                                    ),
                                                    style: OutlinedButton.styleFrom(
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      side: BorderSide.none,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              16,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Sign up link
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      AppStrings.dontHaveAccount,
                                      style: GoogleFonts.poppins(
                                        color:
                                            isDark
                                                ? Colors.white70
                                                : Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    TextButton(
                                      onPressed: _navigateToSignUp,
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(0, 0),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        AppStrings.signUp,
                                        style: GoogleFonts.poppins(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // Debug button
                                if (const bool.fromEnvironment(
                                      'dart.vm.product',
                                    ) ==
                                    false)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: Center(
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.of(
                                            context,
                                          ).pushNamed('/debug-auth');
                                        },
                                        child: Text(
                                          AppStrings.debugAuth,
                                          style: GoogleFonts.poppins(
                                            color:
                                                isDark
                                                    ? Colors.white38
                                                    : Colors.black38,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                // Extra space at bottom
                                const SizedBox(height: 50),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Top bar with language and theme switchers (Now last in Stack to be on top)
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Language Switcher
                          _buildGlassButton(
                            child: PopupMenuButton<String>(
                              icon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.language,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    locale.languageCode == 'ar' ? 'ع' : 'EN',
                                    style: TextStyle(
                                      color:
                                          isDark
                                              ? Colors.white
                                              : Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              tooltip: AppStrings.language,
                              onSelected: (String value) {
                                if (value == 'en') {
                                  languageNotifier.setLanguage(
                                    const Locale('en', 'US'),
                                  );
                                } else if (value == 'ar') {
                                  languageNotifier.setLanguage(
                                    const Locale('ar', 'SA'),
                                  );
                                }
                              },
                              itemBuilder:
                                  (BuildContext context) => [
                                    PopupMenuItem<String>(
                                      value: 'en',
                                      child: Row(
                                        children: [
                                          const Text('🇺🇸 '),
                                          const SizedBox(width: 8),
                                          Text(AppStrings.englishLanguage),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'ar',
                                      child: Row(
                                        children: [
                                          const Text('🇸🇦 '),
                                          const SizedBox(width: 8),
                                          Text(AppStrings.arabicLanguage),
                                        ],
                                      ),
                                    ),
                                  ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Theme Switcher
                          ValueListenableBuilder<ThemeMode>(
                            valueListenable: themeNotifier,
                            builder: (context, mode, _) {
                              return _buildGlassButton(
                                child: IconButton(
                                  icon: Icon(
                                    mode == ThemeMode.dark
                                        ? Icons.dark_mode_rounded
                                        : Icons.light_mode_rounded,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                  tooltip:
                                      mode == ThemeMode.dark
                                          ? AppStrings.switchToLightMode
                                          : AppStrings.switchToDarkMode,
                                  onPressed: () => themeNotifier.toggleTheme(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlassButton({required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color:
                isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isDark
                      ? Colors.white.withOpacity(0.2)
                      : Colors.white.withOpacity(0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: GoogleFonts.poppins(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: isDark ? Colors.white60 : Colors.black54,
        ),
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor:
            isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? Colors.white12 : Colors.black12,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
      validator: validator,
    );
  }
}
