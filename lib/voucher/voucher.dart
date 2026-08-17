import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:n2u/profile/profile.dart';
import 'package:n2u/const/constant.dart';
import 'package:n2u/voucher/my_voucher.dart';
import 'package:n2u/voucher/n2u_voucher.dart';






class VoucherTab extends StatefulWidget{

  const VoucherTab ({super.key});

  @override
  State<VoucherTab> createState() => VoucherTabPage();

}


class VoucherTabPage extends State<VoucherTab>{
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
          title:   Text('Vouchers', style: GoogleFonts.dmSans(fontSize: 18,
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

      body: DefaultTabController(
        length: 2,
        child: Column(
          children: <Widget>[
            TabBar(
              labelColor: primaryOrange,
              unselectedLabelColor: Colors.black,
              indicatorColor: primaryOrange,
              labelStyle: GoogleFonts.dmSans(),
              tabs:  [
                Tab(text: 'N2U Vouchers'.tr()),
                Tab(text: 'My Vouchers'.tr()),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: const [
                  Center(child: N2uVoucher()),
                  Center(child: MyVoucher()),
                ],
              ),
            ),
          ],
        ),
      ),

    );
  }



}