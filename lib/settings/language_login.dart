import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:n2u/const/constant.dart';
import 'package:n2u/signup_login/tab_default.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageLogin extends StatefulWidget {
  const LanguageLogin({super.key});

  @override
  State<LanguageLogin> createState() => LanguagePage();
}

class LanguagePage extends State<LanguageLogin> {
  bool isChangingLanguage = false;
  String currentLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
  }

  Future<void> _loadCurrentLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentLanguage = prefs.getString('selected_language') ?? 'en';
    });
  }

  Future<void> setLanguage(String localeCode) async {
    setState(() => isChangingLanguage = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_language', localeCode);

      if (mounted) {
        await context.setLocale(Locale(localeCode));
      }

      setState(() {
        currentLanguage = localeCode;
      });
    } catch (e) {
      debugPrint('Error changing language: $e');
    } finally {
      if (mounted) {
        setState(() => isChangingLanguage = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
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
          child: AppBar(
            backgroundColor: Colors.white,
            centerTitle: true,
            title: Text(
              'Language',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w700,
              ),
            ).tr(),
            leading: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TabDefault()),
                );
              },
              icon: Icon(Icons.chevron_left, color: Colors.grey),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            RadioGroup<String>(
              groupValue: currentLanguage,
              onChanged: isChangingLanguage
                  ? (_) {}
                  : (value) => setLanguage(value as String),
              child: Column(
                children: [
                  RadioListTile<String>(
                    value: 'en',
                    title: Text(
                      'English',
                      style: GoogleFonts.dmSans(fontWeight: FontWeight.w500),
                    ),
                    activeColor: primaryOrange,
                    controlAffinity: ListTileControlAffinity.trailing,
                  ),
                  Divider(height: 0.5, thickness: 1, color: Colors.grey[300]),
                  RadioListTile<String>(
                    value: 'zh',
                    title: Text(
                      'Chinese',
                      style: GoogleFonts.dmSans(fontWeight: FontWeight.w500),
                    ).tr(),
                    activeColor: primaryOrange,
                    controlAffinity: ListTileControlAffinity.trailing,
                  ),
                  Divider(height: 0.5, thickness: 1, color: Colors.grey[300]),
                  RadioListTile<String>(
                    value: 'ms',
                    title: Text(
                      'Bahasa Melayu',
                      style: GoogleFonts.dmSans(fontWeight: FontWeight.w500),
                    ),
                    activeColor: primaryOrange,
                    controlAffinity: ListTileControlAffinity.trailing,
                  ),
                ],
              ),
            ),
            if (isChangingLanguage)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: CircularProgressIndicator(color: primaryOrange),
              ),
          ],
        ),
      ),
    );
  }
}