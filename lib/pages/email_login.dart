import 'package:daily_drop/pages/login_page.dart';
import 'package:daily_drop/pages/home_page.dart';
import 'package:daily_drop/widget_tree.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:daily_drop/includes/constants.dart';
import 'package:daily_drop/pages/forgot_password.dart';
import 'package:daily_drop/pages/email_register.dart';
import 'package:daily_drop/auth/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailLoginPage extends StatefulWidget {
  const EmailLoginPage({super.key, this.verificationEmail});

  final String? verificationEmail;

  @override
  State<EmailLoginPage> createState() => _EmailLoginPageState();
}

class _EmailLoginPageState extends State<EmailLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = authService.value;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _showResendVerification = false;

  @override
  void initState() {
    super.initState();
    // Show verification message if coming from registration
    if (widget.verificationEmail != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSnackBar(
          'Verification email sent to ${widget.verificationEmail}. '
          'Please check your inbox before logging in.',
        );
        setState(() {
          _showResendVerification = true;
          _emailController.text = widget.verificationEmail ?? '';
        });
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
      action: isError && _showResendVerification
          ? SnackBarAction(
              label: 'Resend',
              textColor: Colors.white,
              onPressed: () {
                setState(() {}); // Ensure widget is ready
                _resendVerificationEmail();
              },
            )
          : null,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Please fill all fields', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // First sign out any existing session
      await _authService.signOut();

      String signInResult = await _authService.signInWithEmailPassword(
        _emailController.text,
        _passwordController.text,
      );

      if (signInResult == 'success') {
        // Check if email is verified
        if (!_authService.isEmailVerified) {
          _showResendVerification = true;
          _showSnackBar(
            'Please verify your email before logging in. Check your inbox.',
            isError: true,
          );
          // Sign out if email is not verified
          await _authService.signOut();
          return;
        }

        _showSnackBar('Login successful!');
        _showResendVerification = false;

        // Set the correct page index for HomePage
        selectedPageNotifier.value = 1;

        // Wait for snackbar to show, then navigate to WidgetTree (which shows HomePage with bottom nav)
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          // Replace entire stack with WidgetTree
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const WidgetTree()),
            (route) => false,
          );
        }
      } else {
        _showSnackBar('Login failed: $signInResult', isError: true);
      }
    } on FirebaseAuthException catch (e) {
      _showSnackBar('Login failed: ${e.message}', isError: true);
    } catch (e) {
      _showSnackBar('An unexpected error occurred: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Please enter your email and password', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String signInResult = await _authService.signInWithEmailPassword(
        _emailController.text,
        _passwordController.text,
      );

      if (signInResult == 'success') {
        final User? user = _authService.currentUser;
        if (user != null && !user.emailVerified) {
          await user.sendEmailVerification();
          await _authService.signOut();
          _showSnackBar('Verification email sent to ${_emailController.text}');
          setState(() {
            _showResendVerification = false;
          });
        } else if (user?.emailVerified ?? false) {
          await _authService.signOut();
          _showSnackBar('Email already verified. Please log in.');
          setState(() {
            _showResendVerification = false;
          });
        }
      } else {
        _showSnackBar('Failed: $signInResult', isError: true);
      }
    } on FirebaseAuthException catch (e) {
      _showSnackBar('Error: ${e.message}', isError: true);
    } catch (e) {
      _showSnackBar('An unexpected error occurred: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Login with Email',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              child: Lottie.asset(
                'assets/lotties/register_page_bg.json',
                fit: BoxFit.cover,
                repeat: true,
                reverse: true,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white70),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white70),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      prefixIcon: const Icon(
                        Icons.email,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white70),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white70),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: CommonStyles.primaryButtonStyle.copyWith(
                      foregroundColor: MaterialStateProperty.all<Color>(
                        Colors.blueAccent,
                      ),
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.white,
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.blueAccent,
                              ),
                            ),
                          )
                        : const Text('Login'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Back to Login',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgotPasswordPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.white70),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EmailRegisterPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Register',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
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
