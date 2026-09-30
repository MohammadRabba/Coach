import 'package:flutter/material.dart';
import 'package:coatch/ColoreApp/colors.dart';
import 'package:coatch/controller/loginController.dart';
import 'package:coatch/controller/resetPasswordController.dart';
import 'package:coatch/controller/signUpController.dart';
import 'package:coatch/view/auth/forgetPassword.dart';
import 'package:coatch/view/auth/signUp.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  final LoginController controller;

  const LoginScreen({super.key, required this.controller});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  ValueNotifier userCredential = ValueNotifier('');
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool rememberMe = false;
  bool auth = false;
  GlobalKey<FormState> formstate = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _logoAnimation;

  @override
  void initState() {
    super.initState();
    checkForSavedUser();
    widget.controller.addListener(_updateView);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animationController.reset();
    _animationController.forward();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutQuart),
      ),
    );

    _logoAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    widget.controller.removeListener(_updateView);
    super.dispose();
  }

  void _updateView() {
    setState(() {});
  }

  void checkForSavedUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? emaile = prefs.getString('email');
    String? passworde = prefs.getString('password');
    auth = prefs.getBool("auth") ?? false;

    if (emaile != null && passworde != null) {
      setState(() {
        emaile = emaile;
        passworde = passworde;
        emailController.text = emaile!;
        passwordController.text = passworde!;
        rememberMe = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 60),
            // Logo with elastic animation
            ScaleTransition(
              scale: _logoAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Image.asset(
                  'assets/images/logo-Photoroom.jpg',
                  height: 290,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Form fields with staggered animations
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildLoginForm(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        // Email Field
        _buildAnimatedField(
          controller: emailController,
          hintText: 'Email',
          index: 0,
          isPassword: false,
        ),
        const SizedBox(height: 20),

        // Password Field
        _buildAnimatedField(
          controller: passwordController,
          hintText: 'Password',
          index: 1,
          isPassword: true,
        ),
        const SizedBox(height: 10),

        // Remember Me & Forgot Password
        _buildOptionsRow(),
        const SizedBox(height: 80),

        // Login Button
        _buildLoginButton(),

        // Biometrics Option (if enabled)
        if (auth == true) _buildBiometricsOption(),
        const SizedBox(height: 20),

        // Social Login Divider
        _buildSocialLoginDivider(),
        const SizedBox(height: 10),

        // Sign Up Prompt
        _buildSignUpPrompt(),
      ],
    );
  }

  Widget _buildAnimatedField({
    required TextEditingController controller,
    required String hintText,
    required int index,
    bool isPassword = false,
  }) {
    final delay = 0.1 * index;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(delay, 1.0, curve: Curves.easeOut),
        ),
      ),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(delay, 1.0, curve: Curves.easeIn),
          ),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: AppColors.primary,
              selectionColor: Color.fromARGB(153, 255, 208, 0),
              selectionHandleColor: AppColors.primary,
            ),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.whiteC),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                color: AppColors.whiteC,
                fontSize: 13,
                fontFamily: "FFS",
                fontWeight: FontWeight.w100,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.9,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 13,
              ),
            ),
            onChanged: isPassword
                ? (value) => widget.controller.model.password = value
                : (value) => widget.controller.model.email = value,
          ),
        ),
      ),
    );
  }

  Widget _buildOptionsRow() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Remember Me Checkbox
          Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Checkbox(
                  key: ValueKey(rememberMe),
                  activeColor: AppColors.primary,
                  value: rememberMe,
                  onChanged: (bool? value) {
                    if (value != null) {
                      setState(() => rememberMe = value);
                      widget.controller.saveUserDataToPrefs(
                        emailController.text,
                        passwordController.text,
                        rememberMe,
                      );
                    }
                  },
                ),
              ),
              const Text(
                'Remember me',
                style: TextStyle(
                  color: AppColors.whiteC,
                  fontSize: 11,
                  fontFamily: "FFS",
                  fontWeight: FontWeight.w100,
                ),
              ),
            ],
          ),

          // Forgot Password
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ForgotPasswordScreen(
                          controller: ResetPasswordController()),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                ),
              );
            },
            child: const Text(
              'Forgot Password?',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontFamily: "FFS",
                fontWeight: FontWeight.w100,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.7, 1.0, curve: Curves.elasticOut),
      ),
      child: ElevatedButton(
        onPressed: () {
          // Button press animation

          widget.controller.signInWithEmailAndPassword(
            emailController.text,
            passwordController.text,
            context,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 4,
          shadowColor: AppColors.primary.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 90),
        ),
        child: const Text(
          'Login',
          style: TextStyle(
            color: AppColors.background,
            fontSize: 16,
            fontFamily: "FFS",
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricsOption() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.8, 1.0, curve: Curves.easeIn),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Sign In Using Biometrics',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.whiteC,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLoginDivider() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.8, 1.0, curve: Curves.easeIn),
        ),
      ),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppColors.garyC)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                const Text(
                  'Or sign in with',
                  style: TextStyle(
                    color: AppColors.whiteC,
                    fontFamily: "FFS",
                    fontWeight: FontWeight.w100,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () async {
                    await widget.controller.signInWithGoogle(context);
                  },
                  child: Image.asset(
                    'assets/images/google-icon.png',
                    height: 25,
                  ),
                ),
              ],
            ),
          ),
          const Expanded(child: Divider(color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _buildSignUpPrompt() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.9, 1.0, curve: Curves.easeIn),
        ),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  SignupScreen(controller: SignUpController()),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
            ),
          );
        },
        child: const Text.rich(
          TextSpan(
            text: 'Don\'t have an account? ',
            style: TextStyle(
              color: AppColors.whiteC,
              fontSize: 13,
              fontFamily: "FFS",
              fontWeight: FontWeight.w100,
            ),
            children: [
              TextSpan(
                text: 'Sign up now',
                style: TextStyle(
                  color: AppColors.primary,
                  fontFamily: "FFS",
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
