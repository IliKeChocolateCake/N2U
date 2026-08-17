import 'package:flutter/material.dart';
import 'package:n2u/const/constant.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:n2u/const/text_style.dart';
import 'package:n2u/const/button_style.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:n2u/profile/profile.dart';
import 'package:n2u/signup_login/forgot_password.dart';
import 'package:n2u/const/controller/main_api.dart';
import 'package:n2u/const/controller/auth_storage.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => LogInPage();
}

class LogInPage extends State<LogIn> {
  TextEditingController passwordController = TextEditingController();
  final TextEditingController uidController = TextEditingController();

  bool _isVisible = false;
  final bool validateUid = false;
  final bool _validatePassword = false;
  final String uidNumber = '';
  bool isToggled = false;
  bool isFormValid = false;
  bool _isLoading = false;

  // ========================================
  // NEW: Initialize secure storage
  // ========================================
  final _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    passwordController.addListener(_updateButtonState);
    uidController.addListener(_updateButtonState);
    _checkRememberedLogin();
  }

  // ========================================
  // UPDATED: Check if user was remembered and auto-login or load credentials
  // ========================================
  Future<void> _checkRememberedLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('remember_me') ?? false;
    final token = prefs.getString('auth_token');

    // If user has valid token and remember me is on, go to Profile
    if (rememberMe && token != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Profile()),
      );
      return;
    }

    // If no valid token but remember me is on, try to auto-login with saved credentials
    if (rememberMe) {
      final rememberedUid = await _secureStorage.read(key: 'remembered_uid');
      final rememberedPassword = await _secureStorage.read(key: 'remembered_password');

      if (rememberedUid != null && rememberedPassword != null) {
        // Fill in the credentials
        setState(() {
          isToggled = true;
          uidController.text = rememberedUid;
          passwordController.text = rememberedPassword;
        });

        // Auto-login after a short delay to ensure UI is ready
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _loginWithAPI();
          }
        });
      } else if (rememberedUid != null) {
        // Only UID is saved, just fill it in
        setState(() {
          isToggled = true;
          uidController.text = rememberedUid;
        });
      }
    }
  }

  void _updateButtonState() {
    setState(() {
      isFormValid = passwordController.text.isNotEmpty &&
          uidController.text.isNotEmpty;
    });
  }

  // ========================================
  // UPDATED: Save password securely when Remember Me is checked
  // ========================================
  Future<void> _loginWithAPI() async {
    setState(() {
      _isLoading = true;
    });

    final uid = uidController.text.trim();
    final password = passwordController.text.trim();

    try {
      final response = await http.post(
        Uri.parse(stageLogIn),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'uid': uid,
          'password': password,
        }),
      );

      debugPrint('Full login response: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['data'] != null) {
        final token = data['data']?['token'];
        final user = data['data']?['user'];

        debugPrint('🔑 Token received: $token');

        await AuthStorage.saveSession(
          token: token,
          rememberMe: isToggled,
          user: user,
        );

        // Save UID and password securely if Remember Me is toggled
        if (isToggled) {
          final prefs = await SharedPreferences.getInstance();
          await _secureStorage.write(key: 'remembered_uid', value: uid);
          await _secureStorage.write(key: 'remembered_password', value: password);
          await prefs.setBool('remember_me', true);
          debugPrint('✅ Credentials saved securely');
        } else {
          // Clear saved credentials if Remember Me is off
          final prefs = await SharedPreferences.getInstance();
          await _secureStorage.delete(key: 'remembered_uid');
          await _secureStorage.delete(key: 'remembered_password');
          await prefs.setBool('remember_me', false);
          debugPrint('🗑️ Credentials cleared');
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(

            content: AwesomeSnackbarContent(
              title: 'Log In'.tr(),
              message:
              'Login successful!'.tr(),
              contentType: ContentType.success,
            ),

            backgroundColor: Colors.transparent,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Profile()),
        );
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AwesomeSnackbarContent(
              title: 'Uh Oh!'.tr(),
              message:
              data['message'] ?? 'Invalid phone number or password',
              contentType: ContentType.failure,
            ),


            backgroundColor: Colors.transparent,
          ),
        );
      }
    } catch (e) {
      debugPrint('Login error: $e');
      debugPrint('Logging in with $uid / $password');
      debugPrint('POST $stageLogIn');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(

         content:  SnackBar(
            content: AwesomeSnackbarContent(
              title: 'Uh Oh!',
              message:
              'Connection error. Please try again later.',
              contentType: ContentType.failure,
            ),
         ),



          backgroundColor: Colors.transparent,
        ),
      );
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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                'Enter UID',
                style: GoogleFonts.dmSans(color: Colors.black),
              ).tr(),
              const SizedBox(height: 4),
              TextField(
                controller: uidController,
                decoration: InputDecoration(
                  hintText: 'UID',
                  filled: true,
                  fillColor: Colors.white,
                  hintStyle: GoogleFonts.dmSans(),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: primaryDark.shade50),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: primaryDark.shade200),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  labelStyle: heading4Regular,
                  errorText: validateUid ? 'This field cannot be blank' : null,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 5.0,
                    horizontal: 15.0,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Password',
                style: GoogleFonts.dmSans(color: Colors.black),
              ).tr(),
              const SizedBox(height: 4),
              TextField(
                controller: passwordController,
                obscureText: !_isVisible,
                decoration: InputDecoration(
                  hintText: 'Password'.tr(),
                  filled: true,
                  fillColor: Colors.white,
                  hintStyle: GoogleFonts.dmSans(),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: primaryDark.shade50),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: primaryDark.shade200),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _isVisible = !_isVisible;
                      });
                    },
                    icon: _isVisible
                        ? const Icon(Icons.visibility_outlined)
                        : const Icon(Icons.visibility_off_outlined),
                  ),
                  labelStyle: heading4Regular,
                  errorText: _validatePassword ? 'This field cannot be blank' : null,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 5.0,
                    horizontal: 15.0,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Switch(
                        value: isToggled,
                        onChanged: (value) {
                          setState(() {
                            isToggled = value;
                          });
                        },
                        activeThumbColor: Colors.white,
                        activeTrackColor: primaryOrange,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.grey.shade300,
                        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                      ),
                      Text('Remember Me', style: GoogleFonts.dmSans()).tr(),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ForgotPassword(),
                        ),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: GoogleFonts.dmSans(
                        color: primaryOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ).tr(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: NeoButton(
                  onPressed: (isFormValid && !_isLoading) ? _loginWithAPI : null,
                  text: _isLoading ? 'Logging in...'.tr() : 'Log In'.tr(),
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 52,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'By continuing, you agree to our ',
                      style: GoogleFonts.dmSans(fontSize: 11),
                    ).tr(),
                    TextButton(
                      onPressed: () {
                        //todo: user agreement
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'User Agreement'.tr(),
                        style: GoogleFonts.dmSans(fontSize: 11, color: primaryOrange),
                      ),
                    ),
                    Text(
                      ' and ',
                      style: GoogleFonts.dmSans(fontSize: 11),
                    ).tr(),
                    TextButton(
                      onPressed: () {
                        //todo: privacy policy
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Privacy Policy',
                        style: GoogleFonts.dmSans(fontSize: 11, color: primaryOrange),
                      ).tr(),
                    ),
                    Text(
                      ' applies.',
                      style: GoogleFonts.dmSans(fontSize: 11),
                    ).tr(),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    passwordController.dispose();
    uidController.dispose();
    super.dispose();
  }
}