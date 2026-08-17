import 'dart:convert';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:n2u/profile/profile.dart';
import 'package:n2u/const/constant.dart';
import 'package:n2u/const/button_style.dart';
import 'package:n2u/const/controller/main_api.dart';
import 'package:easy_localization/easy_localization.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});
  @override
  State<ChangePassword> createState() => ChangePasswordPage();
}

class ChangePasswordPage extends State<ChangePassword> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirm = TextEditingController();
  bool _isVisible = false;
  bool _validatePassword = false;
  bool _validateConfirm = false;
  bool isFormValid = false;
  bool isLoading = false;

  @override
  void dispose() {
    passwordController.dispose();
    passwordConfirm.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _validatePassword = passwordController.text.isEmpty;
      _validateConfirm = passwordConfirm.text.isEmpty || passwordController.text != passwordConfirm.text;
      isFormValid = !_validatePassword && !_validateConfirm;
    });
  }

  Future<void> _changePassword() async {
    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.post(
        Uri.parse(stageChangePassword), // 🔁 adjust endpoint if needed
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // 🔐 if your API requires auth
        },
        body: jsonEncode({
          'password': passwordController.text,
          'password_confirmation': passwordConfirm.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AwesomeSnackbarContent(
              title: 'Yay!',
              message:
              'Password changed successfully'.tr(),
              contentType: ContentType.success,
            ),
            backgroundColor: Colors.transparent,
          ),
        );


        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Profile(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: AwesomeSnackbarContent(
                title: 'Uh Oh!',
                message:
                data['message'] ?? 'Failed to change password',
                contentType: ContentType.failure,
              ),
          ),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: AwesomeSnackbarContent(
              title: 'Uh Oh!',
              message:
              'Network error',
              contentType: ContentType.failure,
            ),
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(preferredSize: Size.fromHeight(kToolbarHeight),
          child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              offset: Offset(0, 2),
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
        ),
        child: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text('Change Password', style: GoogleFonts.dmSans(fontSize: 18,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.w700,
          ),).tr(),
          leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => Profile()),
              );
            },
            icon: Icon(Icons.chevron_left, color: Colors.grey,),
          ),
        ),
      )
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Password', style: GoogleFonts.dmSans()).tr(),
            const SizedBox(height: 4),
            TextField(
              controller: passwordController,
              obscureText: !_isVisible,
              onChanged: (_) => _validateForm(),
              decoration: InputDecoration(
                hintText: 'Password'.tr(),
                filled: true,
                fillColor: Colors.white,
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
                  onPressed: () =>
                      setState(() => _isVisible = !_isVisible),
                  icon: Icon(
                    _isVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
                errorText:
                _validatePassword ? 'This field cannot be blank'.tr() : null,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 15,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Confirm Password', style: GoogleFonts.dmSans()).tr(),
            const SizedBox(height: 4),
            TextField(
              controller: passwordConfirm,
              obscureText: !_isVisible,
              onChanged: (_) => _validateForm(),
              decoration: InputDecoration(
                hintText: 'Confirm Password'.tr(),
                filled: true,
                fillColor: Colors.white,
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
                  onPressed: () =>
                      setState(() => _isVisible = !_isVisible),
                  icon: Icon(
                    _isVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
                errorText: _validateConfirm ? 'Passwords do not match'.tr() : null,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 15,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: NeoButton(
                onPressed: isFormValid && !isLoading ? _changePassword : null,
                text: isLoading ? 'Processing...'.tr() : 'Change Password'.tr(),
                width: MediaQuery.of(context).size.width * 0.9,
                height: 52,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
