import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:n2u/signup_login/reset_password.dart';
import 'package:n2u/signup_login/sign_up.dart';
import 'package:n2u/const/constant.dart';
import 'package:n2u/const/button_style.dart';
import 'package:pin_code_fields/pin_code_fields.dart';





class CodeVerifyPassword extends StatefulWidget{

  final String phoneNumber;

  const  CodeVerifyPassword({super.key, required this.phoneNumber,});
  
  @override 
  State< CodeVerifyPassword> createState() => CodeVerifyPage();

}


class CodeVerifyPage extends State<CodeVerifyPassword>{
  static const String testPin= '123456';
  String otpCode ="";

  bool isFormValid = false;

  final TextEditingController pinController = TextEditingController();

  @override
  void initState() {
    super.initState();



    pinController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {
      isFormValid =
          pinController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,

        centerTitle: true,
        title:   Text('Code Verification', style: GoogleFonts.dmSans(fontSize: 18,
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.w700,
        ),),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, SignUp());
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
        'Enter the code we’ve sent to your phone number.',
        style: GoogleFonts.dmSans(
          color: primaryDark.shade200,
          fontSize: 14,
        ),
        ),

          Text(
           widget.phoneNumber,
            style: GoogleFonts.dmSans(
              color: Colors.black,
              fontSize: 24,
              fontWeight:  FontWeight.bold
            ),
          ),

          SizedBox(height: 16,),



          PinCodeTextField(
            appContext: context,
            length: 6,
            controller: pinController,
            onChanged: (value) {
              setState(() {
                otpCode = value;
                isFormValid = value.length == 6;
              });

            },
            keyboardType: TextInputType.number,
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(8),
              borderWidth: 1,
              fieldHeight: 62,
              fieldWidth: 48,
              activeColor: Color(0xFFE4E4E7),
              selectedColor: primaryOrange,
              inactiveColor: Color(0xFFE4E4E7),
            ),


          ),
          
          Row(

            children: [

              Text(
                'Didn’t receive the code?',
                style: GoogleFonts.dmSans(
                  color: primaryDark.shade800,
                  fontSize: 12,
                ),
              ),

              Spacer(),
              TextButton(
                onPressed: () {
                  // TODO: navigate to forgot password
                },
                child: Text(
                  'Resend',
                  style: GoogleFonts.dmSans(
                    color: primaryOrange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),

          const SizedBox(height: 24),
          Center(
            child: NeoButton(
              onPressed: isFormValid ? () {

                if (pinController.text == testPin) {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResetPassword(),

                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Invalid PIN code'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }

              } : null,
              text: 'Continue',
              width: MediaQuery.of(context).size.width * 0.9,
              height: 52,
            ),
          ),


        ],
      )),

    );
  }
  
  
}