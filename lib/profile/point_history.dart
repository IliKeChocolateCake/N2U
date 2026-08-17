import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:n2u/profile/profile.dart';



class PointHistory extends StatefulWidget{

  const PointHistory ({super.key});


  @override
  State<PointHistory> createState() => PointHistoryPage();


}


class PointHistoryPage extends State<PointHistory>{
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
          title:   Text('Point History', style: GoogleFonts.dmSans(fontSize: 18,
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


      body: SingleChildScrollView(

        child: Padding(padding: EdgeInsets.all(16),

          child: Column(

            children: [


              _title(context, 'Award Points', '14/06/2023', '5000', true),
              _title(context, 'Grant Bonus', '22/07/2023', '100', true),
              _title(context, 'Deduct Points', '27/12/2023', '300', false),
              _title(context, 'Increase Score', '15/03/2024', '400', true),
              _title(context, 'Apply Penalty', '19/04/2024', '500', false),

              _title(context, 'Give Credit', '03/09/2024', '1200', true),
              _title(context, 'Add Reward', '05/10/2024', '100', true),
              _title(context, 'Reduce Score', '08/11/2024', '300', false),
              _title(context, 'Remove Credit', '31/01/2025', '200', false),
              _title(context, 'Subtract Reward', '11/02/2025', '300', false),



            ],
          ),

        ),
      ),


    );


  }

  ListTile _title(BuildContext context, String title, String subtitle, String point, bool add) {
    return ListTile(
      title: Text(
        title,
        style: GoogleFonts.dmSans(fontWeight: FontWeight.w500, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.dmSans(fontWeight: FontWeight.w500, fontSize: 12, color: Colors.grey),
      ),
      trailing: Text(
        add ? '+ $point pts' : '- $point pts',
        style: GoogleFonts.dmSans(
          fontWeight: FontWeight.w500,
          fontSize: 18,
          color: add ? Colors.green : Colors.red,
        ),
      ),
      onTap: () {

      },
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No Point History',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ).tr(),
          const SizedBox(height: 8),
          Text(
            "You don't have any point history right now",
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: Colors.grey[400],
            ),
            textAlign: TextAlign.center,
          ).tr(),
        ],
      ),
    );
  }
}

