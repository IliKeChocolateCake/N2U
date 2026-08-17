import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:n2u/profile/profile.dart';
import 'package:n2u/const/constant.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:n2u/const/controller/main_api.dart';
import 'package:easy_localization/easy_localization.dart';





class Subscription extends StatefulWidget{
  
  const Subscription ({super.key});
  
  @override
  State<Subscription> createState() => SubscriptionPage();
  
}


class SubscriptionPage extends State<Subscription>{

  List<dynamic> subscriptionPlans = [];
  dynamic userSubscription;
  bool _isLoading = true;

  final Map<String, String> planImages = { //image icons
    'MEMBERS': 'asset/member.png',
    'FANS CLUB': 'asset/fans.png',
    'VIP CLUB': 'asset/vip.png',
    'VVIP CLUB' : 'asset/crown.png'
  };

  final Map<String, List<Color>> planGradients = { //background color for card
    'MEMBERS': [Colors.grey, Colors.black],
    'FANS CLUB': [Color(0xFFFFD6BA), Color(0xFFFFE8D6)],
    'VIP CLUB': [Color(0xFF1A0033), Color(0xFF3D0000)], // purple for VIP
    'VVIP CLUB': [Color(0xFF0D0030), Color(0xFF5A189A)], // deep purple to rose gold
  };

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  Future<void> _loadSubscriptions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final stagingUrl = prefs.getString('staging_url');

      if (token == null || stagingUrl == null) {
        throw Exception('Not logged in');
      }

      final response = await http.get(
        Uri.parse(getSubscription),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final data = jsonDecode(response.body);
      debugPrint('📦 Subscription Response: $data');

      if (response.statusCode == 200 && data['success'] == true) {
        setState(() {
          subscriptionPlans = data['data'] ?? [];
          userSubscription = data['user_subscription'];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading subscriptions: $e');
      setState(() {
        _isLoading = false;
      });
    }
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
          title:   Text('N2U Subscription', style: GoogleFonts.dmSans(fontSize: 18,
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


      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : subscriptionPlans.isEmpty
          ? buildEmptyState()
          : SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Show current subscription status if exists
              if (userSubscription != null)
                Container(
                  margin: EdgeInsets.only(bottom: 16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Active Subscription',
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Build subscription cards dynamically
              ...subscriptionPlans.map((plan) {
                return _buildSubscriptionCard(plan);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(dynamic plan) {
    final isMemberPlan = plan['name'].toString().toUpperCase().contains('MEMBER');
    final isVvipPlan = plan['name'].toString().toUpperCase().contains('VVIP'); // add this first!
    final isVipPlan = plan['name'].toString().toUpperCase().contains('VIP') && !isVvipPlan; // exclude VVIP
    final isCurrentPlan = userSubscription != null &&
        userSubscription['subscription_plan_id'] == plan['id']; //KIV because im not sure which the API points to this.
    debugPrint(userSubscription.toString());

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: planGradients[plan['name'].toString().toUpperCase()]
                  ?? [Color(0xFFFFD6BA), Color(0xFFFFE8D6)],
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // Show "Current Plan" badge
              if (isCurrentPlan)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'ACTIVE',
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),

              SizedBox(height: isCurrentPlan ? 16 : 0),

              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 40,
                child: Image.asset(
                  planImages[plan['name'].toString().toUpperCase()] ?? 'asset/member.png',
                  width: 100,
                  height: 100,
                ),
              ),


              const SizedBox(height: 16),

              // Price
              Text(
                'RM ${plan['amount']}',
                style: GoogleFonts.dmSans(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..shader = (isMemberPlan
                        ? metallicGold
                        : isVvipPlan
                        ? royalGold
                        : isVipPlan
                        ? pearlWhite       // 💎 rose gold for VIP
                        : bluePinkGradient).createShader(
                      isVvipPlan
                          ? Rect.fromLTWH(0.0, 0.0, 400.0, 150.0) // 👑 wide & tall = more dramatic gold sweep
                          : Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                    ),
                ),
              ),

              const SizedBox(height: 8),

              Divider(
                color: isMemberPlan || isVvipPlan
                    ? Colors.white.withValues(alpha: 0.3)
                    : Colors.pinkAccent.withValues(alpha: 0.6),
                thickness: 1,
              ),

              const SizedBox(height: 16),

              // Plan name
              Text(
                plan['name'].toString().toUpperCase(), //Buddy , Family
                style: GoogleFonts.dmSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..shader = (isMemberPlan
                        ? metallicGold
                        : isVvipPlan
                        ? royalGold
                        : isVipPlan
                        ? pearlWhite       // 💎 rose gold for VIP
                        : bluePinkGradient).createShader(
                      isVvipPlan
                          ? Rect.fromLTWH(0.0, 0.0, 400.0, 150.0) // 👑 wide & tall = more dramatic gold sweep
                          : Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                    ),
                ),
              ),

              const SizedBox(height: 16),

              // Benefits list
              ...((plan['subscription_item'] as List?)?.map((item) {
                return ListTile(
                  leading: Icon(
                    _getIconForBenefit(item['name']),
                    color: isMemberPlan
                        ? Color(0xFFFFD700)
                        : isVvipPlan
                        ? Color(0xFFD4AF37)
                        : isVipPlan
                        ? Color(0xFFF5F0FF)
                        : Colors.pinkAccent,
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'] ?? '',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          foreground: Paint()
                            ..shader = (isMemberPlan
                                ? metallicGold
                                : isVvipPlan
                                ? royalGold
                                : isVipPlan
                                ? pearlWhite       // 💎 rose gold for VIP
                                : bluePinkGradient).createShader(
                              isVvipPlan
                                  ? Rect.fromLTWH(0.0, 0.0, 400.0, 150.0) // 👑 wide & tall = more dramatic gold sweep
                                  : Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                            ),
                        ),
                      ),
                      if (item['event_type'] != null || item['validity_type'] != null)
                        SizedBox(height: 4),
                      Row(
                        children: [
                          if (item['event_type'] != null)
                            _buildBadge(item['event_type'], isMemberPlan),
                          if (item['event_type'] != null && item['validity_type'] != null)
                            SizedBox(width: 4),
                          if (item['validity_type'] != null)
                            _buildBadge(item['validity_type'], isMemberPlan),
                        ],
                      ),
                    ],
                  ),
                  subtitle: item['description'] != null
                      ? Text(
                    item['description'],
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: isMemberPlan
                          ? Color(0xFFFFD700)
                          : isVvipPlan
                          ? Color(0xFFD4AF37)
                          : isVipPlan
                          ? Color(0xFFF5F0FF)
                          : Colors.pinkAccent,
                    ),
                  )

                      : null,
                );
              }).toList() ?? []),

              const SizedBox(height: 16),

              // // Subscribe button (only show if not current plan)
              // if (!isCurrentPlan)
              //   Padding(
              //     padding: const EdgeInsets.symmetric(horizontal: 16),
              //     child: OutlinedButton(
              //       onPressed: () {},
              //       style: OutlinedButton.styleFrom(
              //         backgroundColor: isMemberPlan || isVipPlan ? Colors.white : primaryDark,
              //         minimumSize: Size(double.infinity, 50),
              //         side: BorderSide.none,
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(12),
              //         ),
              //       ),
              //       child: Text(
              //         'Subscribe Now',
              //         style: GoogleFonts.dmSans(
              //           fontSize: 16,
              //           fontWeight: FontWeight.w600,
              //           color: isMemberPlan
              //               ? Colors.black
              //               : isVipPlan
              //               ? primaryDark
              //               : Colors.white,
              //         ),
              //       ),
              //     ),
              //   ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String label, bool isMemberPlan) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isMemberPlan
            ? Colors.white.withValues(alpha: 0.15)
            : Colors.pinkAccent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isMemberPlan ? Colors.amber : Colors.pinkAccent,
          width: 0.8,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isMemberPlan ? Colors.amber : Colors.pinkAccent,
        ),
      ),
    );
  }

// Helper to get appropriate icons
  IconData _getIconForBenefit(String? benefitName) {
    if (benefitName == null) return Icons.check_circle;

    final name = benefitName.toLowerCase();
    if (name.contains('voucher')) return Icons.confirmation_number;
    if (name.contains('samgyeopsal') || name.contains('pork')) return Icons.local_fire_department;
    if (name.contains('point')) return Icons.stars;
    if (name.contains('birthday')) return Icons.cake;
    if (name.contains('rsvp') || name.contains('priority')) return Icons.event_available;
    if (name.contains('dining') || name.contains('private')) return Icons.meeting_room;
    if (name.contains('gainer') || name.contains('prize')) return Icons.emoji_events;
    if (name.contains('cashback') || name.contains('refund')) return Icons.currency_exchange;

    return Icons.check_circle;
  }

  void showSubscribeDialog(dynamic plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(
          child: Text('Subscribe to ${plan['name']}?', style: GoogleFonts.dmSans()),
        ),
        content: Text(
          'You will be charged RM ${plan['amount']}',
          style: GoogleFonts.dmSans(),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.dmSans()),
          ),
          ElevatedButton(
            onPressed: () {
              // Navigator.pop(context);
              // // TODO: Call subscription API
              // _subscribeToplan(plan['id']);
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryDark),
            child: Text('Confirm', style: GoogleFonts.dmSans(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> subscribeToPlan(int planId) async {
    // TODO: Implement subscription API call
    debugPrint('Subscribing to plan: $planId');
  }

  Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.subscriptions,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No Subscription Plans available',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ).tr(),
          const SizedBox(height: 8),
          Text(
            "No subscription plans right now",
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