import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:n2u/more_page/more.dart';
import 'package:n2u/const/widget/info_and_license.dart';


class Info extends StatefulWidget{

  const Info ({super.key});

  @override
  State<Info> createState() => InfoPage();
}

class InfoPage extends State<Info>{
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
          title:   Text('Info', style: GoogleFonts.dmSans(fontSize: 18,
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

      body: Column(

        children: [

          SizedBox(height: 24,),
          CircleAvatar(

            radius: 50,
            
            child: Image.asset('n2u_logo.png'),
            
          ),

          SizedBox(height: 24,),

          AppInfoCard(
  items: [
    AppInfoItem(key: 'Application Name'.tr(), value: 'N2U'),
    AppInfoItem(key: 'Version'.tr(), value: '1.0.0 (Build 100)', isHighlighted: true),
    AppInfoItem(key: 'Platform'.tr(), value: 'Android & iOS'),
    AppInfoItem(key: 'Framework'.tr(), value: 'Flutter 3.x'),
    AppInfoItem(key: 'Developer'.tr(), value: 'CurrentTech Industries Sdn. Bhd.', isHighlighted: true),
  ],
),
        ],
      ),


    );
  }



}