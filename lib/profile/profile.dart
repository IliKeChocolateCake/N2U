import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:n2u/const/constant.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:n2u/more_page/more.dart';
import 'package:n2u/profile/change_password.dart';
import 'package:n2u/profile/order_history.dart';
import 'package:n2u/profile/point_history.dart';
import 'package:n2u/profile/referral_page.dart';
import 'package:n2u/profile/subscription.dart';
import 'package:n2u/profile/top_up.dart';
import 'package:n2u/profile/user_acc.dart';
import 'package:n2u/profile/withdraw.dart';
import 'package:n2u/settings/language.dart';
import 'package:n2u/signup_login/tab_default.dart';
import 'package:n2u/voucher/voucher.dart';
import 'package:n2u/wallet/wallet_transaction.dart';
import 'package:n2u/notification/notification.dart';
import 'package:n2u/const/controller/auth_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:n2u/const/controller/main_api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';



class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => ProfilePage();
}

class ProfilePage extends State<Profile> {
  final secureStorage = const FlutterSecureStorage();


  TutorialCoachMark? tutorialCoachMark;
  List<TargetFocus> targets = [];

  GlobalKey topUpKey=GlobalKey(); //top up icon button
  GlobalKey voucherKey = GlobalKey(); //voucher gesture dectector
  GlobalKey pointKey = GlobalKey(); //point
  GlobalKey withdrawKey = GlobalKey(); //icon button for withdraw


  double creditBalance = 0.0;
  double cashBalance = 0.0;
  double pointBalance = 0.0;
  bool isLoadingBalances = true;
  bool isOffline = false; // NEW: Track offline state
  String name = '';
  String titleCredit = "";
  String titleCash = '';
  String titlePoint = '';
  String profileImage = '';
  int notificationBadgeCount = 0;
  int voucherCount = 0;
  String? lastUpdateTime; // NEW: Track last cache time

  @override
  void initState() {
    super.initState();
    _loadBalances();
    _loadNotificationCount();

    Future.delayed(const Duration(milliseconds: 300), () {
      _checkAndShowTutorial();
    });
  }

  Future<void> _checkAndShowTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenTutorial = prefs.getBool('has_seen_profile_tutorial') ?? false;

    if (!hasSeenTutorial && mounted) {
      _createTutorial();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          tutorialCoachMark?.show(context: context);
        }
      });
    }
  }

  void _createTutorial() {
    targets = [
      TargetFocus(
        identify: "top-up-key",
        keyTarget: topUpKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      'Top Up',
                      style: GoogleFonts.dmSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryOrange,
                      ),
                    ).tr(),
                    const SizedBox(height: 12),
                    Text(
                      'Add funds to your wallet instantly! Choose the value and enjoy seamless transactions.',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ).tr(),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "voucher-key",
        keyTarget: voucherKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Vouchers',
                      style: GoogleFonts.dmSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryOrange,
                      ),
                    ).tr(),
                    const SizedBox(height: 12),
                    Text(
                      'Save more with exclusive vouchers! View all your available discounts and special offers here.',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ).tr(),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "point-key",
        keyTarget: pointKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Points History',
                      style: GoogleFonts.dmSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryOrange,
                      ),
                    ).tr(),
                    const SizedBox(height: 12),
                    Text(
                      'Track your rewards journey! See how you earned points and redeem them for amazing benefits.',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ).tr(),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "withdraw-key",
        keyTarget: withdrawKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Withdraw',
                      style: GoogleFonts.dmSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryOrange,
                      ),
                    ).tr(),
                    const SizedBox(height: 12),
                    Text(
                      'Cash out your earnings anytime! Transfer your balance directly to you.',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ).tr(),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        controller.next();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Got it!',
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ).tr(),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ];

    tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      textSkip: "SKIP".tr(),
      paddingFocus: 10,
      opacityShadow: 0.8,
      textStyleSkip: GoogleFonts.dmSans(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      onFinish: () async {
        // Mark tutorial as seen
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('has_seen_profile_tutorial', true);
        debugPrint('✅ Tutorial completed and marked as seen');
      },
      onSkip: () {
        // Mark tutorial as seen even if skipped (do it asynchronously without blocking)
        SharedPreferences.getInstance().then((prefs) {
          prefs.setBool('has_seen_profile_tutorial', true);
          debugPrint('⏭️ Tutorial skipped and marked as seen');
        });
        return true;
      },
    );
  }


  Future<void> _loadNotificationCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationBadgeCount = prefs.getInt('unread_notification_count') ?? 0;
    });
  }

  // NEW: Load cached data first for instant display
  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedProfile = prefs.getString('cached_profile');

      if (cachedProfile != null) {
        final data = jsonDecode(cachedProfile);

        setState(() {
          name = data['name'] ?? '';
          profileImage = data['profile_image'] ?? '';
          creditBalance = data['credit_balance'] ?? 0.0;
          cashBalance = data['cash_balance'] ?? 0.0;
          pointBalance = data['point_balance'] ?? 0.0;
          titleCredit = data['title_credit'] ?? '';
          titleCash = data['title_cash'] ?? '';
          titlePoint = data['title_point'] ?? '';
          voucherCount = data['voucher_count'] ?? 0;
          lastUpdateTime = data['last_update'] ?? '';
        });

        debugPrint('✅ Loaded cached data from $lastUpdateTime');
      }
    } catch (e) {
      debugPrint('Error loading cached data: $e');
    }
  }

  // NEW: Save fresh data to cache
  Future<void> _cacheData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();

      final cacheData = {
        'name': name,
        'profile_image': profileImage,
        'credit_balance': creditBalance,
        'cash_balance': cashBalance,
        'point_balance': pointBalance,
        'title_credit': titleCredit,
        'title_cash': titleCash,
        'title_point': titlePoint,
        'voucher_count': voucherCount,
        'last_update': now.toIso8601String(),
      };

      await prefs.setString('cached_profile', jsonEncode(cacheData));
      debugPrint('💾 Data cached at ${now.toIso8601String()}');
    } catch (e) {
      debugPrint('Error caching data: $e');
    }
  }

  // UPDATED: Offline-first approach
  Future<void> _loadBalances() async {
    // Step 1: Load cached data first (instant)
    await _loadCachedData();

    // Step 2: Try to fetch fresh data
    try {
      final token = await AuthStorage.getToken();
      final headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      // Add timeout to detect offline faster
      final responses = await Future.wait([
        http.get(Uri.parse(stageGetProfile), headers: headers).timeout(Duration(seconds: 10)),
        http.get(Uri.parse(stageCreditBalance), headers: headers).timeout(Duration(seconds: 10)),
        http.get(Uri.parse(stageCashBalance), headers: headers).timeout(Duration(seconds: 10)),
        http.get(Uri.parse(stagePointBalance), headers: headers).timeout(Duration(seconds: 10)),
        http.get(Uri.parse(stageGetMyVoucher), headers: headers).timeout(Duration(seconds: 10)),
      ]);

      // Profile
      final profileData = jsonDecode(responses[0].body);
      name = profileData['user']?['name'] ?? '';
      profileImage = profileData['user']?['profile_image']?.toString().trim() ?? '';

      // Credit
      final creditData = jsonDecode(responses[1].body);
      titleCredit = creditData['wallet'] ?? '';
      creditBalance = double.tryParse(creditData['credit_balance']?.toString() ?? '0') ?? 0.0;

      // Cash
      final cashData = jsonDecode(responses[2].body);
      titleCash = cashData['wallet'] ?? '';
      cashBalance = double.tryParse(cashData['cash_balance']?.toString() ?? '0') ?? 0.0;

      // Points
      final pointData = jsonDecode(responses[3].body);
      titlePoint = pointData['points'] ?? '';
      pointBalance = double.tryParse(pointData['balance']?.toString() ?? '0') ?? 0.0;

      // Voucher count
      final voucherSum = jsonDecode(responses[4].body) as List;
      final now = DateTime.now();

      voucherCount = voucherSum.where((voucher) {
        final expiredAt = DateTime.parse(voucher['expired_at']);
        return expiredAt.isAfter(now);
      }).length;

      // Save fresh data to cache
      await _cacheData();

      setState(() {
        isOffline = false;
        lastUpdateTime = DateTime.now().toIso8601String();
      });

      debugPrint('🌐 Fresh data loaded successfully');
    } catch (e) {
      debugPrint('❌ Network error, using cached data: $e');
      setState(() {
        isOffline = true;
      });

      // Show offline indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AwesomeSnackbarContent(

                title: 'Offline',
                message: lastUpdateTime != null
                    ? 'Showing cached data'.tr()
                    : 'No cached data available'.tr(),
                contentType: ContentType.warning, // orange/warning theme
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
            )
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoadingBalances = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryOrange,
        automaticallyImplyLeading: false,
        // leading: Padding(
        //   padding: const EdgeInsets.all(12.0),
        //   child: Container(
        //     decoration: BoxDecoration(
        //       color: Colors.white,
        //       borderRadius: BorderRadius.circular(50),
        //     ),
        //     child: IconButton(
        //       padding: EdgeInsets.zero,
        //       constraints: BoxConstraints(),
        //       onPressed: () {
        //         // Navigator.pop(context);
        //       },
        //       icon: Icon(Icons.close, color: Colors.black, size: 24),
        //     ),
        //   ),
        // ),
        // NEW: Add offline indicator in AppBar
        actions: [
          if (isOffline)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Icon(
                Icons.cloud_off,
                color: Colors.white70,
                size: 20,
              ),
            ),
          // NEW: Add refresh button
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: isLoadingBalances ? null : _loadBalances,
              icon: Icon(
                Icons.refresh,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Orange background header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: _getHeaderHeight(context),
            child: Container(
              color: primaryOrange,
            ),
          ),

          // Scrollable content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome to N2U Malaysia,',
                              style: GoogleFonts.dmSans(fontSize: 14, color: Colors.white),
                            ).tr(),
                            Text(
                              name,
                              style: GoogleFonts.dmSans(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        profileIconWithEdit(
                          context: context,
                          profileImage: profileImage,
                          size: 55,
                          onEdit: () {
                            debugPrint('edit');
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Wallet Card
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 20,
                          spreadRadius: 0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Card(
                      color: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.transparent, width: 1),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // NEW: Offline indicator inside card
                            if (isOffline && lastUpdateTime != null)
                              Container(
                                margin: EdgeInsets.only(bottom: 12),
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.info_outline, color: Colors.orange, size: 16),
                                    SizedBox(width: 6),
                                    Wrap(

                                      children: [

                                        Text(
                                          'Offline mode - Last updated ',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 11,
                                            color: Colors.orange,
                                          ),
                                        ).tr(),

                                        Text(
                                          _formatTime(lastUpdateTime!),
                                          style: GoogleFonts.dmSans(
                                            fontSize: 11,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ],
                                    ),

                                  ],
                                ),
                              ),

                            // CREDIT BALANCE ROW
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$titleCredit (RM)',
                                        style: GoogleFonts.dmSans(
                                          color: Colors.grey[600],
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        creditBalance.toStringAsFixed(2),
                                        style: GoogleFonts.dmSans(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                OutlinedButton.icon(
                                  key: topUpKey,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => TopUp()),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    side: const BorderSide(color: Colors.white, width: 2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                  icon: const Icon(Icons.add_circle_outline, color: Colors.black, size: 18),
                                  label: Text(
                                    'Top Up',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ).tr(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            const Divider(color: Colors.grey, thickness: 1),

                            // CASH WALLET ROW
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$titleCash (RM)',
                                        style: GoogleFonts.dmSans(
                                          color: Colors.grey[600],
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        cashBalance.toStringAsFixed(2),
                                        style: GoogleFonts.dmSans(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                OutlinedButton.icon(
                                  key: withdrawKey,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => Withdraw()),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    side: const BorderSide(color: Colors.white, width: 2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                  icon: const Icon(Icons.remove_circle_outline, color: Colors.black, size: 18),
                                  label: Text(
                                    'Withdraw',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ).tr(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            const Divider(color: Colors.grey, thickness: 1),

                            // POINTS & VOUCHERS ROW
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        titlePoint,
                                        style: GoogleFonts.dmSans(
                                          color: Colors.grey[600],
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        key: pointKey,
                                        pointBalance.toStringAsFixed(0),
                                        style: GoogleFonts.dmSans(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Vouchers',
                                        style: GoogleFonts.dmSans(
                                          color: Colors.grey[600],
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ).tr(),
                                      const SizedBox(height: 4),
                                      GestureDetector(
                                        key: voucherKey,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (_) => VoucherTab()),
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Icon(
                                                Icons.card_giftcard,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              voucherCount.toString(),
                                              style: GoogleFonts.dmSans(
                                                fontSize: 28,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const Spacer(),
                                            IconButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (_) => VoucherTab()),
                                                );
                                              },
                                              icon: const Icon(Icons.chevron_right, color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Menu Items (rest of your code stays the same)
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _title(context, 'Subscription'.tr(), Icons.diamond, onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => Subscription()),
                          );
                        }),
                        Divider(height: 0.5, thickness: 1, color: Colors.grey[300]),
                        _title(context, 'Wallet Transactions'.tr(), Icons.wallet, onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => WalletTransaction()),
                          );
                        }),
                        Divider(height: 0.5, thickness: 1, color: Colors.grey[300]),
                        _title(context, 'Order History'.tr(), Icons.assignment, onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => OrderHistory()),
                          );
                        }),
                        Divider(height: 0.5, thickness: 1, color: Colors.grey[300]),
                        _titleNotification(context, 'Notification'.tr(), Icons.notifications,
                            badgeCount: notificationBadgeCount,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => Noti()),
                              );
                            }),
                        Divider(height: 0.5, thickness: 1, color: Colors.grey[300]),
                        _title(context, 'Invite your friend'.tr(), Icons.qr_code_scanner, onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ReferralPage()),
                          );
                        }),
                        Divider(height: 0.5, thickness: 1, color: Colors.grey[300]),
                        _title(context, 'Points History'.tr(), Icons.history, onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => PointHistory()),
                          );
                        }),
                        Divider(height: 0.5, thickness: 1, color: Colors.grey[300]),
                        _title(context, 'Language'.tr(), Icons.language_outlined, onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => Language()),
                          );
                        }),
                        Divider(height: 0.5, thickness: 1, color: Colors.grey[300]),
                        _title(context, 'Change Password'.tr(), Icons.key, onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ChangePassword()),
                          );
                        }),
                        Divider(height: 0.5, thickness: 1, color: Colors.grey[300]),
                        _title(context, 'More'.tr(), Icons.more, onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => More()),
                          );
                        }),
                        Divider(height: 0.5, thickness: 1, color: Colors.grey[300]),
                        _titleLog(
                          'Log Out'.tr(),
                          Icons.logout,
                          onTap: () async {
                            final result = await showDialog<String>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  title:  Text('Log Out',style: GoogleFonts.dmSans(),).tr(),
                                  content:  Text('Do you want to stay logged in next time?',style: GoogleFonts.dmSans(),).tr(),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, 'no'),
                                      child: Text('No',style: GoogleFonts.dmSans(),).tr(),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, 'yes'),
                                      child: Text('Yes',style: GoogleFonts.dmSans(),).tr(),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (result == 'no') {
                              await AuthStorage.clearSession();
                              debugPrint('🗑️ Full logout - all credentials cleared');
                            } else if (result == 'yes') {
                              await AuthStorage.clearSessionKeepCredentials();
                              debugPrint('✅ Session cleared - credentials preserved for next login');
                            }

                            if (!mounted) return;

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => TabDefault()),
                            );
                          },
                        ),
                        Divider(height: 0.5, thickness: 1, color: Colors.grey[300]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // NEW: Format time helper
  String _formatTime(String isoTime) {
    try {
      final time = DateTime.parse(isoTime);
      final now = DateTime.now();
      final diff = now.difference(time);

      if (diff.inMinutes < 1) return 'just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (e) {
      return 'recently';
    }
  }

  ListTile _title(BuildContext context, String title, IconData icon, {VoidCallback? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 1),
      minLeadingWidth: 40,
      title: Text(
        title,
        style: GoogleFonts.dmSans(fontWeight: FontWeight.w500, fontSize: 14),
      ),
      leading: Icon(
        icon,
        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF3F3F46),
        size: 24,
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.red),
      onTap: onTap,
    );
  }

  ListTile _titleNotification(BuildContext context, String title, IconData icon,
      {int badgeCount = 0, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 1),
      minLeadingWidth: 40,
      title: Text(
        title,
        style: GoogleFonts.dmSans(fontWeight: FontWeight.w500, fontSize: 14),
      ),
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            icon,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : const Color(0xFF3F3F46),
            size: 24,
          ),
          if (badgeCount > 0)
            Positioned(
              right: -6,
              top: -6,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Center(
                  child: Text(
                    badgeCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.red),
      onTap: onTap,
    );
  }

  ListTile _titleLog(String title, IconData icon, {VoidCallback? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 1),
      minLeadingWidth: 40,
      title: Text(
        title,
        style: GoogleFonts.dmSans(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.red),
      ),
      leading: Icon(icon, color: Colors.red, size: 24),
      onTap: onTap,
    );
  }

  Widget profileIconWithEdit({
    required BuildContext context,
    double size = 80,
    String? profileImage,
    VoidCallback? onEdit,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => UserAcc()),
        );
      },
      borderRadius: BorderRadius.circular(size / 2),
      child: (profileImage != null && profileImage.isNotEmpty)
          ? CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(profileImage),
      )
          : CircleAvatar(
        radius: size / 2,
        backgroundColor: Color(0xFFFDD3A6),
        child: Icon(
          Icons.person,
          color: Colors.white,
          size: size / 2,
        ),
      ),
    );
  }

  double _getHeaderHeight(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 600) {
      return 280;
    } else if (screenWidth < 1200) {
      return 320;
    } else {
      return 340;
    }
  }
}