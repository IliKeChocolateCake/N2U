import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:n2u/signup_login/log_in.dart';
import 'package:n2u/const/constant.dart';
import 'package:n2u/const/button_style.dart';
import 'package:flutter_intl_phone_field/flutter_intl_phone_field.dart';
import 'package:n2u/signup_login/code_verify_password.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';


class ForgotPassword extends StatefulWidget{

  const ForgotPassword ({super.key});

  @override
  State<ForgotPassword> createState() => ForgotPasswordPage();

}


class ForgotPasswordPage extends State<ForgotPassword>{

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String _dialCode = '+60';
  final String phoneNumber = '';
  bool isFormValid =false;
  bool isToggled = false;

  @override
  void initState() {
    super.initState();



    _phoneController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {
      isFormValid =
          _phoneController.text.isNotEmpty;
    });
  }


 /* SnackBar(
  content: AwesomeSnackbarContent(
    title: 'Yay!',
  message:
  data['message'] ?? 'Successfully updated password.',

  contentType: ContentType.success,
  ),
  backgroundColor: Colors.transparent,
  ),

  SnackBar(
            content: AwesomeSnackbarContent(
              title: 'Uh Oh!',
              message:
              data['message'] ?? 'Failed to update password. Please try again.',


              contentType: ContentType.failure,
            ),
            backgroundColor: Colors.transparent,
          ),




  */


  @override
  Widget build(BuildContext context) {

    return Scaffold(

        backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,

        centerTitle: true,
        title:   Text('Forgot Password', style: GoogleFonts.dmSans(fontSize: 18,
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.w700,
        ),).tr(),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, LogIn());
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
                'For your security, enter your phone number to verify your identity and reset your password.',
                style: GoogleFonts.dmSans(
                  color: primaryDark.shade200,
                  fontSize: 14,
                ),
              ).tr(),

              // Text(
              //   widget.phoneNumber,
              //   style: GoogleFonts.dmSans(
              //       color: Colors.black,
              //       fontSize: 24,
              //       fontWeight:  FontWeight.bold
              //   ),
              // ),

              SizedBox(height: 16,),
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
                        showDropdownIcon: true,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Center(
                child: NeoButton(
                  onPressed: isFormValid ? () {
                    String fullPhoneNumber = '$_dialCode${_phoneController.text}';

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CodeVerifyPassword(

                          phoneNumber: fullPhoneNumber,
                        ),
                      ),
                    );
                  } : null,
                  text: 'Reset Password'.tr(),
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 52,
                ),
              ),
            ],
          )),
    );
  }
  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

}