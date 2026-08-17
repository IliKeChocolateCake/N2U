import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:n2u/const/constant.dart';
// ─────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────

class FaqItem {
  final String question;
  final String answer;

  const FaqItem({required this.question, required this.answer});
}

class ContactOption {
  final String name;
  final String description;
  final String imagePath;
  final Color iconColor;
  final Color borderColor;
  final Color backgroundColor;
  final VoidCallback onTap;

  const ContactOption({
    required this.name,
    required this.description,
    required this.imagePath,
    required this.iconColor,
    required this.borderColor,
    required this.backgroundColor,
    required this.onTap,
  });
}

// ─────────────────────────────────────────────
// EXPANDABLE FAQ WIDGET
// ─────────────────────────────────────────────

class FaqSection extends StatelessWidget {
  final List<FaqItem> items;
  final String? sectionLabel;

  const FaqSection({
    super.key,
    required this.items,
    this.sectionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24,),
        if (sectionLabel != null) ...[
          Text(
            sectionLabel!.toUpperCase(),
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: Colors.black.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 14),
        ],
        ...items.map((item) => _FaqTile(item: item)),
      ],
    );
  }
}

class _FaqTile extends StatefulWidget {
  final FaqItem item;

  const _FaqTile({required this.item});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _rotateAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isOpen = !_isOpen);
    _isOpen ? _controller.forward() : _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: _isOpen
              ? Colors.yellow.withValues(alpha: 0.4)
              : primaryOrange.withValues(alpha: 0.05),
          border: Border.all(
            color: _isOpen
                ? Colors.yellow.withValues(alpha: 0.4)
                : primaryOrange.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          children: [
            // Question row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.item.question,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  RotationTransition(
                    turns: _rotateAnimation,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: _isOpen
                          ? const Color(0xFF6B21A8)
                          : Colors.white.withValues(alpha: 0.4),
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),

            // Answer (animated)
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: Column(
                children: [
                  Divider(
                    color: Colors.white.withValues(alpha: 0.06),
                    height: 1,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                    child: Text(
                      widget.item.answer,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: Colors.black.withValues(alpha: 0.55),
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CONTACT OPTIONS WIDGET
// ─────────────────────────────────────────────

class ContactSection extends StatelessWidget {
  final List<ContactOption> options;
  final String? sectionLabel;

  const ContactSection({
    super.key,
    required this.options,
    this.sectionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sectionLabel != null) ...[
          Text(
            sectionLabel!.toUpperCase(),
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: Colors.black.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 14),
        ],
        ...options.map((option) => _ContactTile(option: option)),
      ],
    );
  }
}

class _ContactTile extends StatefulWidget {
  final ContactOption option;

  const _ContactTile({required this.option});

  @override
  State<_ContactTile> createState() => _ContactTileState();
}

class _ContactTileState extends State<_ContactTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.option.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: widget.option.backgroundColor,
            border: Border.all(color: widget.option.borderColor),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: widget.option.iconColor.withValues(alpha: 0.15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(
                    widget.option.imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.option.name,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.option.description,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: Colors.black.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.25),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}



final List<FaqItem> faqItems = [
  FaqItem(
    question: 'How can I update my user account?'.tr(),
    answer: 'Tap the profile image on homepage, at the top right side of the app.'.tr(),
  ),
  FaqItem(
    question: 'How do I Top-Up?'.tr(),
    answer: 'Tap Top-up button on the homepage, add or pick any value and tap top-up, there will be an alert dialog waiting for admin approval before money credited to your account.'.tr(),
  ),
];

final List<ContactOption> contactOptions = [
  ContactOption(
    name: 'WhatsApp',
    description: 'Fastest response. Take 1-3 business days.'.tr(),
    imagePath: 'asset/whatsapp.png', // 👈 your asset path
    iconColor: Color(0xFF25D366),
    borderColor: Color(0xFF25D366).withValues(alpha: 0.25),
    backgroundColor: Color(0xFF25D366).withValues(alpha: 0.06),
    onTap: () => launchUrl(Uri.parse('https://wa.me/60XXXXXXXXX')),
  ),
  ContactOption(
    name: 'Email Support',
    description: 'For detailed inquiries.'.tr(),
    imagePath: 'asset/mail.png',
    iconColor: Color(0xFFD4AF37),
    borderColor: Color(0xFFD4AF37).withValues(alpha: 0.25),
    backgroundColor: Color(0xFFD4AF37).withValues(alpha: 0.06),
    onTap: () => launchUrl(Uri.parse('mailto:support@n2u.com')),
  ),

];


