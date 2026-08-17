import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:n2u/signup_login/tab_default.dart';
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';

/// 🔁 Toggle API vs Local Testing
const bool useApi = true; // true = API, false = local testing

// ============================================================================
// WebView Page (UNCHANGED - Keep as is)
// ============================================================================
class WebViewPage extends StatefulWidget {
  final String url;
  final String title;

  const WebViewPage({
    super.key,
    required this.url,
    this.title = 'App',
  });

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(false)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (url) async {
            await _controller.runJavaScript(
                '''
              var meta = document.querySelector('meta[name=viewport]');
              if (!meta) {
                meta = document.createElement('meta');
                meta.name = 'viewport';
                document.head.appendChild(meta);
              }
              meta.content =
                'width=device-width, initial-scale=1.0, maximum-scale=1.0';
              '''
            );

            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: WebViewWidget(controller: _controller),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// REDESIGNED Tenant Login Page with Persistent Login
// ============================================================================
class TenantLoginPage extends StatefulWidget {
  const TenantLoginPage({super.key});

  @override
  State<TenantLoginPage> createState() => _TenantLoginPageState();
}

class _TenantLoginPageState extends State<TenantLoginPage>
    with TickerProviderStateMixin {
  // ========================================
  // Controllers (KEEP ALL EXISTING)
  // ========================================
  final TextEditingController _uidController = TextEditingController();
  bool _isLoading = false;
  bool _isCheckingSession = true; // NEW: Check for existing session
  String? _errorMessage;

  // ========================================
  // Animation Controllers (NEW - For Design)
  // ========================================
  late AnimationController _floatController;
  late AnimationController _orbitController;
  late Animation<double> _floatAnimation;
  bool _animationsInitialized = false;

  @override
  void initState() {
    super.initState();

    // Initialize float animation for the main icon
    _floatController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0, end: -15).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Initialize orbit animation for floating bubbles
    _orbitController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    _animationsInitialized = true;

    // NEW: Check if user is already logged in
    _checkExistingSession();
  }

  @override
  void dispose() {
    _uidController.dispose();
    if (_animationsInitialized) {
      _floatController.dispose();
      _orbitController.dispose();
    }
    super.dispose();
  }

  // ========================================
  // NEW: Session Management
  // ========================================

  /// Check if user has previously logged in
  Future<void> _checkExistingSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUid = prefs.getString('user_uid');
      final savedUrl = prefs.getString('staging_url');

      // NEW: Also check for N2U auth token
      final authToken = prefs.getString('auth_token');
      final rememberMe = prefs.getBool('remember_me') ?? false;

      if (savedUid != null && savedUid.isNotEmpty) {
        // User was previously logged in to tenant app
        if (mounted) {
          _navigateToApp(savedUid, savedUrl ?? '');
        }
      }
      // NEW: Check if N2U user is logged in with remember me
      else if (savedUid == 'n2u' || (authToken != null && rememberMe)) {
        // N2U user is logged in, go directly to TabDefault
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => TabDefault()),
          );
        }
      }
      else {
        // No saved session, show login form
        if (mounted) {
          setState(() {
            _isCheckingSession = false;
          });
        }
      }
    } catch (e) {
      // Error reading preferences, show login form
      if (mounted) {
        setState(() {
          _isCheckingSession = false;
        });
      }
    }
  }

  /// Save login session after successful login
  Future<void> _saveSession(String uid, String stagingUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_uid', uid);
      await prefs.setString('staging_url', stagingUrl);
    } catch (e) {
      // Handle save error silently
      debugPrint('Error saving session: $e');
    }
  }

  /// Clear saved session (call this if you add a logout button)
  Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_uid');
      await prefs.remove('staging_url');
    } catch (e) {
      debugPrint('Error clearing session: $e');
    }
  }

  // ========================================
  // API Logic (UPDATED - Save session on success)
  // ========================================
  Future<void> _submitUID() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    final uid = _uidController.text.trim().toLowerCase();

    if (uid.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a UID';
        _isLoading = false;
      });
      return;
    }

    /// 🧪 LOCAL TEST MODE (NO API)
    if (!useApi) {
      await Future.delayed(const Duration(milliseconds: 300));
      await _saveSession(uid, ''); // NEW: Save session
      _navigateToApp(uid, '');
      return;
    }

    /// 🌐 REAL API MODE
    try {
      final response = await http.post(
        Uri.parse('https://fnb-management.testflight4u.com/api/login-tenant'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'uid': uid}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final stagingUrl = data['staging_url'] ?? '';
        await _saveSession(uid, stagingUrl); // NEW: Save session
        if (!mounted) return;
        _navigateToApp(uid, stagingUrl);
      } else {
        setState(() {
          _errorMessage = data['message'] ?? 'Invalid UID. Please try again.';
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        _errorMessage = 'Connection error. Please check your internet.';
        _isLoading = false;
      });
    }
  }

  // ========================================
  // Navigation Logic (KEEP UNCHANGED)
  // ========================================
  void _navigateToApp(String uid, String stagingUrl) {
    switch (uid) {
      case 'n2u':
        _saveSession('n2u', ''); // NEW: Save n2u session
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => TabDefault()),
        );
        break;

      case 'stoxpos':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => WebViewPage(
              url: useApi ? stagingUrl : 'https://app.stoxpos.com',
              title: 'StockPOS',
            ),
          ),
        );
        break;

      default:
        if (stagingUrl.isNotEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => WebViewPage(
                url: stagingUrl,
                title: uid.toUpperCase(),
              ),
            ),
          );
        } else {
          setState(() {
            _errorMessage = 'Unknown application. Please contact support.';
            _isLoading = false;
          });
        }
    }
  }

  // ========================================
  // UI BUILD (UPDATED - Show loading while checking session)
  // ========================================
  @override
  Widget build(BuildContext context) {
    // NEW: Show loading screen while checking for existing session
    if (_isCheckingSession) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFa8d8f0),
                Color(0xFFc8b8f0),
                Color(0xFFf0b8d8),
              ],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        // Main gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFa8d8f0), // Light blue
              Color(0xFFc8b8f0), // Light purple
              Color(0xFFf0b8d8), // Light pink
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ========================================
              // TOP SECTION: Illustration Area (45%)
              // ========================================
              Expanded(
                flex: 45,
                child: _buildIllustrationSection(),
              ),

              // ========================================
              // BOTTOM SECTION: Login Form (55%)
              // ========================================
              Expanded(
                flex: 55,
                child: _buildLoginSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========================================
  // Illustration Section (UNCHANGED)
  // ========================================
  Widget _buildIllustrationSection() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFe3f2fd), // Light blue
            Color(0xFFf3e5f5), // Light purple
            Color(0xFFfce4ec), // Light pink
          ],
        ),
      ),
      child: Stack(
        children: [
          // Wave effect at the bottom
          _buildWaveEffect(),

          // Floating bubbles with orbit animation
          _buildOrbitingBubble(
            color: Colors.yellow.shade600,
            size: 30,
            delay: 0,
            top: 0.2,
            left: 0.6,
          ),
          _buildOrbitingBubble(
            color: Colors.lightBlue.shade300,
            size: 20,
            delay: 5,
            top: 0.3,
            right: 0.15,
          ),
          _buildOrbitingBubble(
            color: Colors.purple.shade300,
            size: 15,
            delay: 10,
            top: 0.7,
            right: 0.2,
          ),

          // Main app icon in the center with float animation
          Center(
            child: _animationsInitialized
                ? AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatAnimation.value),
                  child: child,
                );
              },
              child: _buildMainAppIcon(),
            )
                : _buildMainAppIcon(),
          ),
        ],
      ),
    );
  }

  /// Builds the main app icon with gradient and mini icons
  Widget _buildMainAppIcon() {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        // Rainbow gradient background
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667eea),
            Color(0xFF764ba2),
            Color(0xFFf093fb),
            Color(0xFF4facfe),
            Color(0xFF00f2fe),
          ],
        ),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withValues(alpha: 0.4),
            blurRadius: 35,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      // Grid of 4 mini icons (2x2)
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildMiniIcon(
            icon: Icons.storefront,
            gradient: const LinearGradient(
              colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
            ),
          ),
          _buildMiniIcon(
            icon: Icons.shopping_cart,
            gradient: const LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
          ),
          _buildMiniIcon(
            icon: Icons.list_alt,
            gradient: const LinearGradient(
              colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
            ),
          ),
          _buildMiniIcon(
            icon: Icons.chat_bubble,
            gradient: const LinearGradient(
              colors: [Color(0xFFffd89b), Color(0xFF19547b)],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a single mini icon with gradient background
  Widget _buildMiniIcon({required IconData icon, required Gradient gradient}) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  /// Builds an orbiting bubble with circular motion animation
  Widget _buildOrbitingBubble({
    required Color color,
    required double size,
    required int delay,
    double? top,
    double? left,
    double? right,
  }) {
    return Positioned(
      top: top != null ? MediaQuery.of(context).size.height * top * 0.45 : null,
      left: left != null ? MediaQuery.of(context).size.width * left : null,
      right: right != null ? MediaQuery.of(context).size.width * right : null,
      child: _animationsInitialized
          ? AnimatedBuilder(
        animation: _orbitController,
        builder: (context, child) {
          final angle = (_orbitController.value * 2 * math.pi) -
              (delay * 2 * math.pi / 15);
          final radius = 60.0;

          return Transform.translate(
            offset: Offset(
              radius * math.cos(angle),
              radius * math.sin(angle),
            ),
            child: child,
          );
        },
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
      )
          : Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds animated wave effect
  Widget _buildWaveEffect() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: const Color(0xFF90caf9).withValues(alpha: 0.2),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.elliptical(200, 50),
            topRight: Radius.elliptical(200, 50),
          ),
        ),
      ),
    );
  }

  // ========================================
  // Login Form Section (UNCHANGED)
  // ========================================
  Widget _buildLoginSection() {
    return Container(
      // Dark navy background with rounded top corners
      decoration: const BoxDecoration(
        color: Color(0xFF2c3e5a),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      // Overlap the illustration section by moving up 30px
      transform: Matrix4.translationValues(0, -30, 0),
      padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 40),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // "WELCOME" heading
            Text(
              'WELCOME',
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),

            // "Enter your UID to continue" subtitle
            Text(
              'Enter your UID to continue',
              style: GoogleFonts.dmSans(
                color: const Color(0xFF9ca9c0),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 35),

            // UID Input Field (EXISTING LOGIC + NEW DESIGN)
            _buildInputField(
              label: 'UID',
              placeholder: 'Enter your UID here',
              controller: _uidController,
              enabled: !_isLoading,
              errorText: _errorMessage,
            ),
            const SizedBox(height: 30),

            // Continue/Login Button (EXISTING LOGIC + NEW DESIGN)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitUID,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFf5a3a3),
                  disabledBackgroundColor: const Color(0xFFf5a3a3).withValues(alpha: 0.6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                    : Text(
                  'CONTINUE',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Info text
            Center(
              child: Text(
                'Contact support if you need help',
                style: GoogleFonts.dmSans(
                  color: const Color(0xFF9ca9c0),
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a custom input field (UNCHANGED)
  Widget _buildInputField({
    required String label,
    required String placeholder,
    required TextEditingController controller,
    required bool enabled,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label text
        Text(
          label,
          style: GoogleFonts.dmSans(
            color: const Color(0xFF9ca9c0),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),

        // Input field with bottom border
        TextField(
          controller: controller,
          enabled: enabled,
          style: GoogleFonts.dmSans(
            color: Colors.white,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: GoogleFonts.dmSans(
              color: const Color(0xFF6b7a94),
            ),
            prefixIcon: const Icon(
              Icons.badge_outlined,
              color: Color(0xFF9ca9c0),
            ),
            suffixIcon: IconButton(
              onPressed: () async {
                // Show scanner as a modal bottom sheet
                final scannedValue = await showModalBottomSheet<String>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6, // scanner height
                    child: MobileScanner(

                      overlayBuilder: (context, constraints) => Center(
                        child: Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.blueAccent,
                              width: 8,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      onDetect: (capture) {
                        final List<Barcode> barcodes = capture.barcodes;
                        for (final barcode in barcodes) {
                          if (barcode.rawValue != null) {
                            final code = barcode.rawValue!;
                            Navigator.of(context).pop(code); // return scanned value
                            break;
                          }
                        }
                      },
                    ),
                  ),
                );

                // If a value was scanned, update the TextField
                if (scannedValue != null && scannedValue.isNotEmpty) {
                  controller
                    ..text = scannedValue
                    ..selection = TextSelection.collapsed(offset: scannedValue.length);
                  _submitUID();
                }
              },
              icon: const Icon(Icons.qr_code),
            ),

            suffixIconColor: Colors.white,
            errorText: errorText,
            errorStyle: GoogleFonts.dmSans(
              color: const Color(0xFFf5a3a3),
              fontSize: 12,
            ),
            border: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: Color(0xFF4a5f7f),
                width: 2,
              ),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: Color(0xFF4a5f7f),
                width: 2,
              ),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: Color(0xFFf5a3a3),
                width: 2,
              ),
            ),
            errorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: Color(0xFFf5a3a3),
                width: 2,
              ),
            ),
            disabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: Color(0xFF4a5f7f),
                width: 1,
              ),
            ),
          ),
          onSubmitted: (_) => _submitUID(),
        ),
      ],
    );
  }
}