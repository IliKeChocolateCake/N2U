import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:n2u/more_page/info.dart';
import 'package:n2u/more_page/license.dart';
import 'package:n2u/more_page/support.dart';
import 'package:n2u/profile/profile.dart';




class More extends StatelessWidget{

  const More({super.key});

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
          title:   Text('More', style: GoogleFonts.dmSans(fontSize: 18,
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


      body: Column(

        children: [

          _title(context, 'Support'.tr(), Icons.support,

              onTap: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => Support()),
            );
          }

          ),

          Divider(height: 0.5, thickness: 1, color: Colors.grey[300]),

          _title(context, 'Info'.tr(), Icons.info, onTap: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => Info()),
            );
          }),

          Divider(height: 0.5, thickness: 1, color: Colors.grey[300],),

          _title(context, 'License'.tr(), Icons.list, onTap: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => License()),
            );
          })

        ],
      ),
    );
  }

  ListTile _title(BuildContext context, String title, IconData icon, {VoidCallback? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
      minLeadingWidth: 20,
      title: Text(
        title,
        style: GoogleFonts.dmSans(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black),
      ),
      leading: Icon(
        icon,
        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.grey,
        size: 24,
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[300]),
      onTap: onTap,
    );
  }



}