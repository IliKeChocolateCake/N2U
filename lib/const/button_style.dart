import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:n2u/const/constant.dart';

class OrangeButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final double? height;
  final double? width;

  const OrangeButton({super.key,
  required this.onPressed,
  required this.text,
  required this.height,
  required this.width
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateColor.resolveWith((states) => Color(0xFFFDD3A6)),
        fixedSize: WidgetStateProperty.all<Size>(
            Size(width ?? double.infinity, height ?? 40)
        ),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)
        ),),
      ),
      
      child: Text(text, 
        style: GoogleFonts.dmSans(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.white,
          height: 1.0,
          ),
        ),
    );
  }
}


class OrangeButtonTwo extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final double? height;
  final double? width;

  const OrangeButtonTwo({super.key,
    required this.onPressed,
    required this.text,
    required this.height,
    required this.width
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateColor.resolveWith((states) => primaryOrange),
        fixedSize: WidgetStateProperty.all<Size>(
            Size(width ?? double.infinity, height ?? 40)
        ),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)
        ),),
      ),

      child: Text(text,
        style: TextStyle(
          fontFamily: GoogleFonts.dmSans().fontFamily,
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.white,
          height: 1.0,
        ),
      ),
    );
  }
}


class ZincButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final double? height;
  final double? width;

  const ZincButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateColor.resolveWith((states) => primaryDark.shade900),
        fixedSize: WidgetStateProperty.all<Size>(
          Size(width ?? double.infinity, height ?? 40),
        ),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        padding: WidgetStateProperty.all<EdgeInsets>(
          EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.dmSans(  // Changed from .fontFamily
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.white,
          height: 1.0,  // THIS IS KEY - fixes vertical spacing
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class ZincButtonTwo extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final double? height;
  final double? width;

  const ZincButtonTwo({super.key,
    required this.onPressed,
    required this.text,
    required this.height,
    required this.width
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateColor.resolveWith((states) => primaryDark.shade900),
        fixedSize: WidgetStateProperty.all<Size>(
            Size(width ?? double.infinity, height ?? 40)
        ),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50)
        ),),
      ),

      child: Text(text,
        style: TextStyle(
          fontFamily: GoogleFonts.dmSans().fontFamily,
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.white,
          height: 1.0,
        ),
      ),
    );
  }
}


class NeoButton extends StatelessWidget {
  final VoidCallback? onPressed; // Change to nullable
  final String text;
  final double? height;
  final double? width;

  const NeoButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.height,
    required this.width
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return Color(0xFFFDD3A6); // Disabled color
          }
          return primaryOrange; // Active color
        }),
        fixedSize: WidgetStateProperty.all<Size>(
            Size(width ?? double.infinity, height ?? 40)
        ),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)
          ),
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.dmSans(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: onPressed != null ? Colors.white : Colors.white,

        ),
      ),
    );
  }
}


class OrangeOutlineButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final double? height;
  final double? width;
  
  const OrangeOutlineButton({super.key,
  required this.onPressed,
  required this.text,
  required this.width,
  required this.height
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        fixedSize: WidgetStateProperty.all<Size>(
            Size(width ?? double.infinity, height ?? 40)
        ),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15)
        ),),
        side: WidgetStateProperty.all<BorderSide>(
          BorderSide(color: primaryOrange.shade900),
        ),
      ),
      child: Text(text,
        style: TextStyle(
        fontFamily: GoogleFonts.poppins().fontFamily,
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: primaryOrange.shade900,
          height: 1.0,
        ),
      ),
    );
  }
}

class WhiteOutlineButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final double? height;
  final double? width;

  const WhiteOutlineButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.white),
        fixedSize: WidgetStateProperty.all<Size>(
          Size(width ?? double.infinity, height ?? 40),
        ),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        side: WidgetStateProperty.all<BorderSide>(
          BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: GoogleFonts.poppins().fontFamily,
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.black,
          height: 1.0,
        ),
      ),
    );
  }
}


class CustomOutlineButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color borderColor;
  final Color textColor;

  const CustomOutlineButton({super.key,
  required this.onPressed,
  required this.text,
  required this.borderColor,
  required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        fixedSize: WidgetStateProperty.all<Size>(const Size.fromHeight(40)),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5)
        ),),
        side: WidgetStateProperty.all<BorderSide>(
          BorderSide(color: borderColor),
        ),
      ),
      child: Text(text,
        style: TextStyle(
        fontFamily: GoogleFonts.poppins().fontFamily,
        fontWeight: FontWeight.bold,
        fontSize: 10,
        color: textColor,
          height: 1.0,
        ),
      ),
    );
  }
}

class ZincIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData icon;

  const ZincIconButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateColor.resolveWith((states) => primaryDark),
        foregroundColor: WidgetStateColor.resolveWith((states) => Colors.white),
        fixedSize: WidgetStateProperty.all<Size>(const Size.fromHeight(40)),
        padding: WidgetStateProperty.all<EdgeInsets>(
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      icon: Icon(icon, size: 18),
      label: Text(
        text,
        style: TextStyle(
          fontFamily: GoogleFonts.dmSans().fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: Colors.white,
          height: 1.0,
        ),
      ),
    );
  }
}

class LightOrangeIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData icon;

  const LightOrangeIconButton({super.key,
  required this.onPressed,
  required this.text,
  required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateColor.resolveWith((states) => primaryOrange.shade300),
        fixedSize: WidgetStateProperty.all<Size>(const Size.fromHeight(50)),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5)
        ),),
      ),
      
      icon: Icon(icon), 
      label: Text(
        text, style:TextStyle(
          fontFamily: GoogleFonts.poppins().fontFamily,
          fontWeight: FontWeight.bold,
          fontSize: 11,
          color: Colors.white,
        height: 1.0,
          ),
        ),
    );
  }
}


