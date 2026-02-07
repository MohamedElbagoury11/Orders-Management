import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projectmange/main.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/utils/error_messages.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/auth_background.dart';
import '../../widgets/custom_error_dialog.dart';
import '../home_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        SignUpWithEmailAndPasswordEvent(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
        ),
      );
    }
  }

  void _signInWithGoogle() {
    context.read<AuthBloc>().add(SignInWithGoogleEvent());
  }

  void _showErrorDialog(String error) {
    final title = ErrorMessages.getAuthErrorTitle(error, method: 'signup');
    final message = ErrorMessages.getAuthErrorMessage(
      error,
      email: _emailController.text.trim(),
      method: 'signup',
    );
    final actionText = ErrorMessages.getActionText(error, method: 'signup');

    CustomErrorDialog.show(
      context: context,
      title: title,
      message: message,
      actionText: actionText,
      onActionPressed: () {
        Navigator.of(context).pop(); // Close dialog

        // Handle specific actions
        if (error.toLowerCase().contains('email-already-in-use')) {
          // Navigate back to login page
          Navigator.of(context).pop();
        } else if (error.toLowerCase().contains('pigeonuserdetails')) {
          // User can try email/password login
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
        Navigator.of(context).pop(); // Close dialog

        // Handle specific actions for Google Sign-In
        if (error.toLowerCase().contains('pigeonuserdetails')) {
          // User can try email/password signup
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder<Locale>(
      valueListenable: languageNotifier,
      builder: (context, locale, _) {
        // Update AppStrings locale
        AppStrings.setLocale(locale);

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: isDark ? Colors.white : Colors.black87,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is Authenticated) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomePage()),
                  (route) => false,
                );
              } else if (state is AuthError) {
                // Determine if this is a Google Sign-In error
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
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            // Logo
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.2),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.person_add_rounded,
                                size: 50,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              AppStrings.createAccount,
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              AppStrings.pleaseFillDetails,
                              style: GoogleFonts.poppins(
                                color:
                                    isDark
                                        ? Colors.white70
                                        : Colors.grey.shade600,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 40),

                            // Glass morphism form container
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
                                              ? Colors.white.withOpacity(0.1)
                                              : Colors.white.withOpacity(0.5),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
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
                                        _buildTextField(
                                          controller: _nameController,
                                          label: AppStrings.fullName,
                                          icon: Icons.person_outline_rounded,
                                          keyboardType: TextInputType.name,
                                          textCapitalization:
                                              TextCapitalization.words,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return AppStrings
                                                  .pleaseEnterFullName;
                                            }
                                            if (value.trim().length < 2) {
                                              return 'Name must be at least 2 characters';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 20),
                                        _buildTextField(
                                          controller: _emailController,
                                          label: AppStrings.email,
                                          icon: Icons.email_outlined,
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
                                        _buildTextField(
                                          controller: _passwordController,
                                          label: AppStrings.password,
                                          icon: Icons.lock_outline_rounded,
                                          obscureText: _obscurePassword,
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons.visibility_outlined
                                                  : Icons
                                                      .visibility_off_outlined,
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
                                              return 'Password must be at least 6 characters';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 20),
                                        _buildTextField(
                                          controller:
                                              _confirmPasswordController,
                                          label: AppStrings.confirmPassword,
                                          icon: Icons.lock_reset_rounded,
                                          obscureText: _obscureConfirmPassword,
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscureConfirmPassword
                                                  ? Icons.visibility_outlined
                                                  : Icons
                                                      .visibility_off_outlined,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _obscureConfirmPassword =
                                                    !_obscureConfirmPassword;
                                              });
                                            },
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return AppStrings
                                                  .pleaseConfirmPassword;
                                            }
                                            if (value !=
                                                _passwordController.text) {
                                              return AppStrings
                                                  .passwordsDoNotMatch;
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 30),
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
                                                    BorderRadius.circular(16),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                        .withOpacity(0.4),
                                                    blurRadius: 20,
                                                    offset: const Offset(0, 10),
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
                                                            strokeWidth: 2.5,
                                                            valueColor:
                                                                AlwaysStoppedAnimation<
                                                                  Color
                                                                >(Colors.white),
                                                          ),
                                                        )
                                                        : Text(
                                                          AppStrings
                                                              .createAccount,
                                                          style:
                                                              GoogleFonts.poppins(
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
                                        const SizedBox(height: 20),
                                        Center(
                                          child: Text(
                                            AppStrings.or,
                                            style: GoogleFonts.poppins(
                                              color:
                                                  isDark
                                                      ? Colors.white70
                                                      : Colors.black54,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        BlocBuilder<AuthBloc, AuthState>(
                                          builder: (context, state) {
                                            return Container(
                                              width: double.infinity,
                                              height: 56,
                                              decoration: BoxDecoration(
                                                color:
                                                    isDark
                                                        ? Colors.white
                                                            .withOpacity(0.05)
                                                        : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: Border.all(
                                                  color:
                                                      isDark
                                                          ? Colors.white24
                                                          : Colors.grey
                                                              .withOpacity(0.3),
                                                  width: 1,
                                                ),
                                              ),
                                              child: OutlinedButton.icon(
                                                onPressed:
                                                    state is AuthLoading
                                                        ? null
                                                        : _signInWithGoogle,
                                                icon: const Icon(
                                                  Icons.g_mobiledata,
                                                ),
                                                label: Text(
                                                  AppStrings.signInWithGoogle,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        isDark
                                                            ? Colors.white
                                                            : Colors.black87,
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
                                        const SizedBox(height: 30),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Already have an account? ',
                                              style: GoogleFonts.poppins(
                                                color:
                                                    isDark
                                                        ? Colors.white70
                                                        : Colors.black54,
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text(
                                                AppStrings.signIn,
                                                style: GoogleFonts.poppins(
                                                  color:
                                                      Theme.of(
                                                        context,
                                                      ).colorScheme.primary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      style: GoogleFonts.poppins(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: isDark ? Colors.white60 : Colors.black54,
        ),
        prefixIcon: Icon(icon, color: isDark ? Colors.white60 : Colors.black54),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? Colors.white24 : Colors.black12,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? Colors.white24 : Colors.black12,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      validator: validator,
    );
  }
}
