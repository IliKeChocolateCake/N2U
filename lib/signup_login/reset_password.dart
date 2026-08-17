import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:n2u/signup_login/forgot_password.dart';
import 'package:n2u/const/constant.dart';
import 'package:n2u/const/text_style.dart';
import 'package:n2u/const/button_style.dart';





class ResetPassword extends StatefulWidget{

  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => ResetPasswordPage();

}



class ResetPasswordPage extends State<ResetPassword>{

  TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirm = TextEditingController();
  bool _isVisible = false;
  final bool _validatePassword = false;


  bool isToggled = false;
  bool isFormValid = false;


  @override
  Widget build(BuildContext context) {

    return Scaffold(


      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,

        centerTitle: true,
        title:   Text('Reset Password', style: GoogleFonts.dmSans(fontSize: 18,
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.w700,
        ),),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, ForgotPassword());
          },
          icon: Icon(Icons.chevron_left, color: Colors.grey,),
        ),


      ),

      body: Padding(padding: const EdgeInsets.all(16),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [


              Text(
                'Password',
                style: GoogleFonts.dmSans(color: Colors.black),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: passwordController,
                obscureText: !_isVisible,
                decoration: InputDecoration(
                  hintText: 'Password',
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
              const SizedBox(height: 16),
              Text(
                ' Confirm Password',
                style: GoogleFonts.dmSans(color: Colors.black),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: passwordConfirm,
                obscureText: !_isVisible,
                decoration: InputDecoration(
                  hintText: 'Confirm Password',
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
              const SizedBox(height: 24),
              Center(
                child: NeoButton(
                  onPressed: isFormValid ? () {

                    //todo: reset password

                  } : null,
                  text: 'Reset Password',
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 52,
                ),
              ),




            ],
          )),








    );
  }



}
