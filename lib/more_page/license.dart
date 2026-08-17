import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:n2u/more_page/more.dart';
import 'package:n2u/const/widget/info_and_license.dart';


class License extends StatefulWidget{

  const License ({super.key});

  State<License> createState() => LicensePage();

}

class LicensePage extends State<License>{
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
          title:   Text('License', style: GoogleFonts.dmSans(fontSize: 18,
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

      body: SafeArea(child: SingleChildScrollView(
        child: Column(


          children: [

            SizedBox(height: 24,),

            LicenseList(
              licenses: [
                LicenseItem(
                  name: 'Flutter SDK',
                  licenseType: 'BSD-3',
                  description: 'Google\'s UI toolkit for building natively compiled applications.',
                ),
                LicenseItem(
                  name: 'google_fonts',
                  licenseType: 'MIT',
                  description: 'A Flutter package to use fonts from fonts.google.com.',
                ),
                LicenseItem(
                  name: 'http',
                  licenseType: 'BSD-3',
                  description: 'A composable, Future-based API for HTTP requests.',
                ),
                LicenseItem(
                  name: 'shared_preferences',
                  licenseType: 'BSD-3',
                  description: 'Persistent storage for simple key-value data.',
                ),
                LicenseItem(
                  name: 'easy_localization',
                  licenseType: 'MIT',
                  description: 'Easy and fast internationalization for Flutter apps.',
                ),
              ],
            ),

            SizedBox(height: 24,),
            LicenseList(
              sectionLabel: 'Icon Attribution'.tr(),
              licenses: [
                LicenseItem(
                  name: 'Crown Icon — Freepik',
                  licenseType: 'Flaticon',
                  description: 'Used in VVIP Club tier. Icons made by Freepik from www.flaticon.com',
                ),
                LicenseItem(
                  name: 'VIP Diamond Icon — Freepik',
                  licenseType: 'Flaticon',
                  description: 'Used in VIP Club tier. Icons made by Freepik from www.flaticon.com',
                ),
                LicenseItem(
                  name: 'Member Icon — Freepik',
                  licenseType: 'Flaticon',
                  description: 'Used in Members tier. Icons made by Freepik from www.flaticon.com',
                ),
              ],
            ),
          ],
        ),

      ) ),
    );
  }



}