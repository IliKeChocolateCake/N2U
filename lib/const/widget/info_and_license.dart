import 'package:flutter/material.dart';
import 'package:n2u/const/constant.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
// ─────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────

class AppInfoItem {
  final String key;
  final String value;
  final bool isHighlighted; // shows value in gold

  const AppInfoItem({
    required this.key,
    required this.value,
    this.isHighlighted = false,
  });
}

class LicenseItem {
  final String name;
  final String licenseType; // e.g. MIT, BSD-3
  final String description;

  const LicenseItem({
    required this.name,
    required this.licenseType,
    required this.description,
  });
}

// ─────────────────────────────────────────────
// APP INFORMATION CARD
// ─────────────────────────────────────────────

class AppInfoCard extends StatelessWidget {
  final String sectionLabel;
  final List<AppInfoItem> items;

   AppInfoCard({
    super.key,
    this.sectionLabel = 'App Information',
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: sectionLabel.tr()),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;
              return _AppInfoRow(
                item: item,
                isLast: isLast,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _AppInfoRow extends StatelessWidget {
  final AppInfoItem item;
  final bool isLast;

  const _AppInfoRow({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: isLast
            ? null
            : Border(
          bottom: BorderSide(
            color: Colors.black.withValues(alpha: 0.05),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item.key,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w300,
              color: Colors.black.withValues(alpha: 0.6),
            ),
          ),
          Text(
            item.value,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: item.isHighlighted
                  ? const Color(0xFFD4AF37)
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// LICENSE LIST
// ─────────────────────────────────────────────

class LicenseList extends StatelessWidget {
  final String sectionLabel;
  final List<LicenseItem> licenses;

  const LicenseList({
    super.key,
    this.sectionLabel = 'Open Source Licenses',
    required this.licenses,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: sectionLabel.tr()),
        const SizedBox(height: 16),
        ...licenses.map((license) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _LicenseCard(item: license),
        )),
      ],
    );
  }
}

class _LicenseCard extends StatefulWidget {
  final LicenseItem item;
  const _LicenseCard({required this.item});

  @override
  State<_LicenseCard> createState() => _LicenseCardState();
}

class _LicenseCardState extends State<_LicenseCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _isHovered
              ? const Color(0xFFD4AF37).withValues(alpha: 0.05)
              : Colors.deepPurpleAccent.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? const Color(0xFFD4AF37).withValues(alpha: 0.2)
                : primaryDark.withValues(alpha: 0.06),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.item.name,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                _LicenseTag(label: widget.item.licenseType),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.item.description,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w300,
                color: Colors.black.withValues(alpha: 0.6),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LicenseTag extends StatelessWidget {
  final String label;
  const _LicenseTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.purpleAccent.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 10,
          color: Colors.pink,
          letterSpacing: 1,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SHARED: SECTION LABEL
// ─────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.dmSans(
            fontSize: 10,
            letterSpacing: 4,
            color: primaryDark,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryDark.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
