import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:n2u/const/button_style.dart';
import 'package:n2u/profile/profile.dart';
import 'package:n2u/const/constant.dart';
import 'package:n2u/profile/request_top_up.dart';
import 'package:easy_localization/easy_localization.dart';






class TopUp extends StatefulWidget{

  const TopUp ({super.key});

  @override
  State<TopUp> createState() => TopUpPage();

}


class TopUpPage extends State<TopUp>{

  TextEditingController topUpController = TextEditingController();
  bool validateTopUp = false;

  String? selectedAmount; // Track which button is selected

  @override
  void dispose() {
    topUpController.dispose();
    super.dispose();
  }

  void _setAmount(String amount) {
    setState(() {
      selectedAmount = amount; // Update selected state
      topUpController.text = amount;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.white,


      appBar: PreferredSize(preferredSize: Size.fromHeight(kToolbarHeight), child: Container(

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
        child:    AppBar(
          backgroundColor: Colors.white,


          centerTitle: true,
          title:   Text('N2U Balance Top Up', style: GoogleFonts.dmSans(fontSize: 18,
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
      )),


      body: Padding(

        padding: const EdgeInsets.all(16),
        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,

          children: [



            const SizedBox(height: 16),
            Text(
              'Top Up Amount',
              style: GoogleFonts.dmSans(color: Colors.black),
            ).tr(),
            const SizedBox(height: 4),
            TextField(
              controller: topUpController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')), // Allows 10.50
              ],
              onChanged: (value) {
                if (value != selectedAmount) {
                  setState(() => selectedAmount = null);
                }
              },
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    widthFactor: 0,
                    child: Text(
                      'RM',
                      style: GoogleFonts.dmSans(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 0),
                // prefixStyle: GoogleFonts.dmSans(
                //   color: Colors.black,
                //   fontSize: 16,
                //   fontWeight: FontWeight.w500,
                // ),
                hintText: '10',
                filled: true,
                fillColor: Colors.white,
                hintStyle: GoogleFonts.dmSans(),
                errorText: validateTopUp ? 'This field cannot be blank'.tr() : null,
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


            const SizedBox(height: 16),

            // First Row: 10, 50, 100
            Row(
              children: [
                Expanded(
                  child: _amountButton('10'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _amountButton('50'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _amountButton('100'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Second Row: 300, 500
            Row(
              children: [
                Expanded(
                  child: _amountButton('300'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _amountButton('500'),
                ),
              ],
            ),

            Spacer(flex: 3,),

            ZincButton(
              onPressed: () {
                // Validate that user entered/selected an amount
                if (topUpController.text.isEmpty) {
                  setState(() {
                    validateTopUp = true;
                  });
                  return;
                }

                // Navigate with the amount from text field
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RequestTopUp(
                      amount: topUpController.text,  // 👈 Pass the text field value
                    ),
                  ),
                );
              },
              text: 'Top Up'.tr(),
              height: 52,
              width: MediaQuery.of(context).size.width * 0.9,
            ),
          ],
        ),),



    );
  }

  Widget _amountButton(String amount) {
    final isSelected = selectedAmount == amount;
    return OutlinedButton(
      onPressed: () => _setAmount(amount),

      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? Colors.orange.shade50 : Colors.white,
        side: BorderSide(
          color: isSelected ? primaryOrange : Colors.grey.shade300,
          width: isSelected ? 2 : 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Text(
        amount,
        style: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isSelected? primaryOrange: Colors.black87,
        ),
      ),
    );
  }




}