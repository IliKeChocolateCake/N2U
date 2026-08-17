import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:n2u/const/constant.dart';
import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:n2u/settings/language_login.dart';
import 'package:n2u/signup_login/log_in.dart';
import 'package:n2u/signup_login/sign_up.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:n2u/profile/profile.dart';
import 'package:easy_localization/easy_localization.dart';

class TabDefault extends StatefulWidget {
  const TabDefault({super.key});

  @override
  State<TabDefault> createState() => TabDefaultPage();
}

class TabDefaultPage extends State<TabDefault> with WidgetsBindingObserver {
  bool _wasInBackground = false;

  @override
  void initState() {
    super.initState();
    // Register lifecycle observer
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Unregister lifecycle observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // App went to background
      _wasInBackground = true;
      debugPrint('📱 App went to background');
    } else if (state == AppLifecycleState.resumed && _wasInBackground) {
      // App came back from background
      _wasInBackground = false;
      debugPrint('📱 App resumed from background');
      _navigateToProfileIfLoggedIn();
    }
  }

  Future<void> _navigateToProfileIfLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');
      final rememberMe = prefs.getBool('remember_me') ?? false;

      debugPrint('🔍 Checking session: token=${authToken != null}, rememberMe=$rememberMe');

      // If user is logged in with remember me, navigate to profile
      if (authToken != null && authToken.isNotEmpty && rememberMe) {
        if (mounted) {
          debugPrint('✅ Navigating to Profile');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => Profile()),
          );
        }
      } else {
        debugPrint('❌ No valid session, staying on login');
      }
    } catch (e) {
      debugPrint('❌ Error checking session on resume: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Member Account',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.w700,
          ),
        ).tr(),
        automaticallyImplyLeading: false,
        // leading: IconButton(
        //   onPressed: () {
        //     // Optional: Add navigation back or close action
        //     null;
        //   },
        //   icon: Icon(
        //     Icons.close,
        //     color: Colors.grey,
        //   ),
        // ),
        actions: [
          IconButton(onPressed: (){

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LanguageLogin()),
            );

          }, icon: Icon(Icons.language)),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        initialIndex: 1,
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(50),
              ),
              child: ButtonsTabBar(
                backgroundColor: primaryOrange,
                unselectedBackgroundColor: Colors.grey[300],
                unselectedLabelStyle: GoogleFonts.dmSans(
                  color: primaryDark,
                  fontWeight: FontWeight.bold,
                ),
                labelStyle: GoogleFonts.dmSans(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 30),
                radius: 50,
                height: 45,
                buttonMargin: const EdgeInsets.symmetric(horizontal: 0),
                tabs:  [
                  Tab(
                    text: "Sign Up".tr(),
                  ),
                  Tab(
                    text: "Log In".tr(),
                  ),
                ],
              ),
            ),
            // Add TabBarView here to show content
            Expanded(
              child: TabBarView(
                children: [
                  // Sign Up content
                  Center(child: SignUp()),
                  // Log In content
                  Center(child: LogIn()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}