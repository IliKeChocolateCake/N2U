import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:n2u/const/constant.dart';
import 'package:n2u/voucher/type/active.dart';
import 'package:n2u/voucher/type/expired.dart';
import 'package:n2u/voucher/type/redeemed.dart';
import 'package:easy_localization/easy_localization.dart';



class MyVoucher extends StatefulWidget{

  const MyVoucher({super.key});

  @override
  State<MyVoucher> createState() => MyVoucherPage();

}


class MyVoucherPage extends State<MyVoucher>{
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,

      body: DefaultTabController(
        length: 3,
        child: Column(
          children: <Widget>[
            TabBar(
              labelColor: primaryOrange,
              unselectedLabelColor: Colors.black,
              indicatorColor: primaryOrange,
              labelStyle: GoogleFonts.dmSans(),
              tabs:  [
                Tab(text: 'Active'.tr()),
                Tab(text: 'Used'.tr()),
                Tab(text: 'Expired'.tr()),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: const [
                  Center(child: Active()),
                  Center(child: Used()),
                  Center(child: Expired()),
                ],
              ),
            ),
          ],
        ),
      ),


    );
  }

  
}