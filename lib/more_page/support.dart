import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:n2u/const/widget/faq_and_contact.dart';
import 'package:n2u/more_page/more.dart';

class Support extends StatefulWidget{
  
  
  const Support ({super.key});
  
  @override
  State<Support> createState() => SupportPage();
  
  
}



class SupportPage extends State<Support>{
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
          title:   Text('Support', style: GoogleFonts.dmSans(fontSize: 18,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.w700,
          ),).tr(),
          leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                  MaterialPageRoute(builder: (_) => More()),
              );
            },
            icon: Icon(Icons.chevron_left, color: Colors.grey,),
          ),
        ),
      )),

      body: SingleChildScrollView(

        child: Column(

          children: [

            // In your build method:
            FaqSection(
              sectionLabel: 'Frequently Asked Questions (FAQ)'.tr(),
              items: faqItems,
            ),

            const SizedBox(height: 24),

            ContactSection(
              sectionLabel: 'Contact Us'.tr(),
              options: contactOptions,
            ),

          ],
        ),
      ),

    );
  }
  
  
}