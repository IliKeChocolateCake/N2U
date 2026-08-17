import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:n2u/const/button_style.dart';
import 'package:n2u/const/constant.dart';
import 'package:n2u/const/text_style.dart';
import 'package:flutter_intl_phone_field/flutter_intl_phone_field.dart';
import 'package:n2u/const/controller/main_api.dart';
import 'package:http/http.dart' as http;
import 'package:n2u/signup_login/tab_default.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';


class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => SignUpPage();
}

class SignUpPage extends State<SignUp> {
  TextEditingController nameController = TextEditingController(); // FIXED: Changed from emailController to nameController
  TextEditingController passwordController = TextEditingController();
  TextEditingController referralController = TextEditingController(); // NEW: Separate controller for referral
  final TextEditingController _phoneController = TextEditingController();
  bool _isVisible = false;
  final bool _validateEmail = false;
  final bool _validatePassword = false;
  String _dialCode = '+60';
  final String phoneNumber = '';
  bool isFormValid = false;
  bool _isLoading = false; // NEW: Track loading state

  @override
  void initState() {
    super.initState();
    // Add listeners to all text controllers
    nameController.addListener(_updateButtonState);
    passwordController.addListener(_updateButtonState);
    _phoneController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {
      isFormValid = nameController.text.isNotEmpty &&
          passwordController.text.isNotEmpty &&
          _phoneController.text.isNotEmpty;
    });
  }

  // ========================================
  // NEW: API Sign Up Function
  // ========================================
  Future<void> _signUpWithAPI() async {
    setState(() {
      _isLoading = true;
    });

    final name = nameController.text.trim();
    final phone = _phoneController.text.trim();
    final password = passwordController.text.trim();
    final referralCode = referralController.text.trim();

    try {
      // final uid = 'n2u'; //n2u for n2u uid

      final body = {
        // 'uid': uid, // NEW: Add uid field
        'name': name,
        'dial_code': _dialCode,
        'phone': phone,
        'password': password,
      };

      // Add referral code if provided
      if (referralCode.isNotEmpty) {
        body['referral_code'] = referralCode;
      }

      final response = await http.post(
        Uri.parse(stageSignUp),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      debugPrint('📦 Sign Up Response: $data');

      if (response.statusCode == 200 && data['success'] == true) {
        if (!mounted) return;

        // Save UID in SharedPreferences (optional)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('uid', data['user']['uid']);

        // Show alert dialog with UID
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Center(

                child: Text('Sign Up Successful', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold),),

              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Your UID is:', style: GoogleFonts.dmSans(),).tr(),
                  const SizedBox(height: 8),
                  SelectableText(
                    data['user']['uid'],
                    style:GoogleFonts.dmSans(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Copy UID to clipboard
                    Clipboard.setData(ClipboardData(text: data['user']['uid']));
                    ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(

                       content: AwesomeSnackbarContent(
                         title: 'Copied.'.tr(),
                         message:
                         'UID copied to clipboard!'.tr(),
                         contentType: ContentType.success,
                       ),


                        backgroundColor: Colors.transparent,
                      ),
                    );
                  },
                  child:  Text('Copy UID', style: GoogleFonts.dmSans(),).tr(),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                    // Navigate to login page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TabDefault()),
                    );
                  },
                  child: Text('Go to Login', style: GoogleFonts.dmSans(),).tr(),
                ),
              ],
            );
          },
        );
      }
      else {
        // Failed - show error message from API
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AwesomeSnackbarContent(
              title: 'Error'.tr(),
              message:
              data['message'] ?? 'Sign up failed. Please try again.',
              contentType: ContentType.failure,
            ),


            backgroundColor: Colors.transparent,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      // Network or other error
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: AwesomeSnackbarContent(
            title: 'Error'.tr(),
            message:
            'Connection error. Please check your internet.'.tr(),
            contentType: ContentType.failure,
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
              const SizedBox(height: 10),
              Text(
                'Label',
                style: GoogleFonts.dmSans(color: Colors.black),
              ).tr(),
              const SizedBox(height: 4),
              TextField(
                controller: nameController, // FIXED: Using nameController
                onChanged: (value) {
                  //_updateButtonState();
                },
                decoration: InputDecoration(
                  hintText: 'eg. John Smith',
                  filled: true,
                  fillColor: Colors.white,
                  hintStyle: GoogleFonts.dmSans(),
                  errorText: _validateEmail ? 'This field cannot be blank' : null,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 5.0,
                    horizontal: 15.0,
                  ),
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
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Phone Number',
                style: GoogleFonts.dmSans(color: Colors.black),
              ).tr(),
              const SizedBox(height: 4),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: primaryDark.shade50),
                ),
                child: Row(
                  children: [
                    // Country Code Section
                    IntrinsicWidth(
                      child: IntlPhoneField(
                        dropdownIconPosition: IconPosition.trailing,
                        initialCountryCode: 'MY',
                        disableLengthCheck: true,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly, // Only allow digits
                        ],
                        showDropdownIcon: true,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        ),
                        onChanged: (phone) {
                          setState(() {
                            _dialCode = phone.countryCode;
                          });
                        },
                      ),
                    ),
                    // Divider
                    Container(
                      height: 40,
                      width: 1,
                      color: primaryDark.shade50,
                    ),
                    // Phone Number Field
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'Phone Number'.tr(),
                          hintStyle: GoogleFonts.dmSans(),
                          border: InputBorder.none,
                          contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We will send a verification code to this phone number.',
                style: GoogleFonts.dmSans(
                  color: primaryDark.shade200,
                  fontSize: 11,
                ),
              ).tr(),
              const SizedBox(height: 8),
              Text(
                'Referral Code',
                style: GoogleFonts.dmSans(color: Colors.black),
              ).tr(),
              const SizedBox(height: 4),
              TextField(
                controller: referralController, // FIXED: Using referralController
                onChanged: (value) {
                  //_updateButtonState();
                },
                decoration: InputDecoration(
                  hintText: 'REF1234',
                  filled: true,
                  fillColor: Colors.white,
                  hintStyle: GoogleFonts.dmSans(),
                  errorText: _validateEmail ? 'This field cannot be blank' : null,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 5.0,
                    horizontal: 15.0,
                  ),
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
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Password',
                style: GoogleFonts.dmSans(color: Colors.black),
              ).tr(),
              const SizedBox(height: 4),
              TextField(
                controller: passwordController,
                obscureText: !_isVisible,
                onChanged: (value) {
                  //_updateButtonState();
                },
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
              Text(
                'Must be at least 8 characters containing at least one alphabet letter, one number, and one special character.',
                style: GoogleFonts.dmSans(
                  color: primaryDark.shade200,
                  fontSize: 11,
                ),
              ).tr(),
              const SizedBox(height: 16),
              Center(
                child: NeoButton(
                  onPressed: (isFormValid && !_isLoading) ? _signUpWithAPI : null, // UPDATED: Call API
                  text: _isLoading ? 'Signing up...'.tr() : 'Sign Up'.tr(), // UPDATED: Show loading text
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

                        //todo: navigate to user agreement

                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'User Agreement',
                        style: GoogleFonts.dmSans(fontSize: 11, color: primaryOrange),
                      ).tr(),
                    ),
                    Text(
                      ' and ',
                      style: GoogleFonts.dmSans(fontSize: 11),
                    ).tr(),
                    TextButton(
                      onPressed: () {

                        //todo: navigate to user privacy policy

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
              const SizedBox(height: 16), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    passwordController.dispose();
    referralController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}