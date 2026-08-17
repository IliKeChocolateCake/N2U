import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:n2u/profile/profile.dart';
import 'package:n2u/const/constant.dart';
import 'package:n2u/const/button_style.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:n2u/const/controller/main_api.dart';
import 'package:easy_localization/easy_localization.dart';

class UserAcc extends StatefulWidget {
  const UserAcc({super.key});

  @override
  State<UserAcc> createState() => UserAccPage();
}

class UserAccPage extends State<UserAcc> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController uidController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _profileImageUrl;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  String? dob;
  String? fullPhoneNumber;
  String? dialCode;

  @override
  void initState() {
    super.initState();
    _fetchProfileDetails();
  }

  // ========================================
  // Fetch Profile Details (GET)
  // ========================================
  Future<void> _fetchProfileDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final stagingUrl = prefs.getString('staging_url');

      if (token == null || stagingUrl == null) {
        throw Exception('Not logged in');
      }

      final response = await http.get(
        Uri.parse(getProfile),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      debugPrint('📦 Profile Details: $data');

      if (response.statusCode == 200 && data['success'] == true) {
        setState(() {
          uidController.text = data['user']['uid'] ?? '';
          nameController.text = data['user']['name'] ?? '';
          emailController.text = data['user']['email'] ?? 'Not Set';

          // Handle phone number with dial code
          dialCode = data['user']['dial_code'] ?? '+60';
          String phoneNumber = data['user']['phone_number'] ?? '';



          if (phoneNumber.isNotEmpty) {
            // Remove dial code if it's already in the phone number
            if (phoneNumber.startsWith(dialCode!)) {
              phoneNumber = phoneNumber.substring(dialCode!.length);
            }
            // Also remove if it starts with dial code without +
            else if (phoneNumber.startsWith(dialCode!.replaceAll('+', ''))) {
              phoneNumber = phoneNumber.substring(dialCode!.replaceAll('+', '').length);
            }

            // Store full number with dial code
            fullPhoneNumber = '$dialCode$phoneNumber';

            // Set only the phone number (without dial code) in controller
            phoneController.text = phoneNumber;

            debugPrint('📱 Dial Code: $dialCode, Phone: $phoneNumber, Full: $fullPhoneNumber');
          } else {
            fullPhoneNumber = '';
            phoneController.text = '';
          }

          // Fix for DOB
          if (data['user']['dob'] != null && data['user']['dob'] != 'Not Set') {
            dob = data['user']['dob'];

            // Format for display
            try {
              final dateParts = dob!.split('-');
              if (dateParts.length == 3) {
                final year = dateParts[0];
                final month = int.parse(dateParts[1]);
                final day = dateParts[2];
                final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                dateController.text = "$day ${months[month - 1]} $year";
              } else {
                dateController.text = dob!;
              }
            } catch (e) {
              dateController.text = dob!;
            }
          } else {
            dateController.text = 'Not Set';
            dob = null;
          }

          _profileImageUrl = data['user']['profile_image'] ?? '';
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Failed to load profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error loading profile'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ========================================
  // Pick Image from Gallery
  // ========================================
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error selecting image'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ========================================
  // Update Profile (POST)
  // ========================================
  Future<void> _updateProfile() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final stagingUrl = prefs.getString('staging_url');

      if (token == null || stagingUrl == null) {
        throw Exception('Not logged in');
      }

      http.Response response;

      // If image is selected, use multipart/form-data
      if (_selectedImage != null) {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse(updateProfile),
        );

        request.headers['Authorization'] = 'Bearer $token';
        request.fields['name'] = nameController.text.trim();
        request.fields['email'] = emailController.text.trim();
        if (dob != null && dob != 'Not Set') {
          request.fields['dob'] = dob!;
        }
        request.fields['phone_number'] = phoneController.text.trim();
        if (dialCode != null) {
          request.fields['dial_code'] = dialCode!;
        }

        debugPrint('📤 Sending fields: ${request.fields}');

        // Add image file
        request.files.add(
          await http.MultipartFile.fromPath(
            'profile_image',
            _selectedImage!.path,
          ),
        );

        final streamedResponse = await request.send();
        response = await http.Response.fromStream(streamedResponse);
      } else {
        // No image, use regular JSON request
        final body = {
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'phone_number': phoneController.text.trim(),
        };

        // Only add dob if it's set
        if (dob != null && dob != 'Not Set') {
          body['dob'] = dob!;
        }

        // Add dial code if available
        if (dialCode != null) {
          body['dial_code'] = dialCode!;
        }

        debugPrint('📤 Final body being sent: ${jsonEncode(body)}');
        response = await http.post(
          Uri.parse(updateProfile),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        );
      }

      final data = jsonDecode(response.body);
      debugPrint('📦 Update Profile Response: $data');

      if (response.statusCode == 200 && data['success'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(

            content: AwesomeSnackbarContent(
              title: 'Profile Request.'.tr(),
              message:'Profile updated successfully!'.tr(),

              /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
              contentType: ContentType.success,
            ),


            backgroundColor: Colors.transparent,
          ),
        );

        // Refresh profile data
        _fetchProfileDetails();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(



              content: AwesomeSnackbarContent(
                title: 'Profile Request.'.tr(),
                message:data['message'] ?? 'Failed to update profile',

                /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
                contentType: ContentType.failure,
              ),


            backgroundColor: Colors.transparent,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(

          content: AwesomeSnackbarContent(
            title: 'Profile Request.'.tr(),
            message:'Error updating profile',

            /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
            contentType: ContentType.failure,
          ),

          backgroundColor: Colors.transparent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ========================================
  // Helper method to get country code from dial code
  // ========================================
  String _getCountryCodeFromDialCode(String dialCode) {
    // Remove + if present
    final code = dialCode.replaceAll('+', '');

    // Map dial codes to country codes (ISO 3166-1 alpha-2)
    switch (code) {
      case '60': return 'MY'; // Malaysia
      case '65': return 'SG'; // Singapore
      case '1': return 'US'; // US/Canada
      case '44': return 'GB'; // UK
      case '86': return 'CN'; // China
      case '61': return 'AU'; // Australia
      case '91': return 'IN'; // India
      case '62': return 'ID'; // Indonesia
      case '63': return 'PH'; // Philippines
      case '66': return 'TH'; // Thailand
      case '84': return 'VN'; // Vietnam
      case '82': return 'KR'; // South Korea
      case '81': return 'JP'; // Japan
      case '33': return 'FR'; // France
      case '49': return 'DE'; // Germany
      case '39': return 'IT'; // Italy
      case '34': return 'ES'; // Spain
      case '351': return 'PT'; // Portugal
      case '31': return 'NL'; // Netherlands
      case '32': return 'BE'; // Belgium
      case '41': return 'CH'; // Switzerland
      case '43': return 'AT'; // Austria
      case '45': return 'DK'; // Denmark
      case '46': return 'SE'; // Sweden
      case '47': return 'NO'; // Norway
      case '358': return 'FI'; // Finland
      case '48': return 'PL'; // Poland
      case '420': return 'CZ'; // Czech Republic
      case '36': return 'HU'; // Hungary
      case '30': return 'GR'; // Greece
      case '90': return 'TR'; // Turkey
      case '7': return 'RU'; // Russia
      case '380': return 'UA'; // Ukraine
      case '20': return 'EG'; // Egypt
      case '27': return 'ZA'; // South Africa
      case '234': return 'NG'; // Nigeria
      case '254': return 'KE'; // Kenya
      case '52': return 'MX'; // Mexico
      case '55': return 'BR'; // Brazil
      case '54': return 'AR'; // Argentina
      case '56': return 'CL'; // Chile
      case '57': return 'CO'; // Colombia
      case '51': return 'PE'; // Peru
      case '64': return 'NZ'; // New Zealand
    // Add more as needed
      default: return 'MY'; // Default to Malaysia
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
              'User Account',
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
                  MaterialPageRoute(builder: (_) => Profile()),
                );
              },
              icon: Icon(Icons.chevron_left, color: Colors.grey),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(color: primaryOrange),
      )
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // Profile icon
              Center(
                child: profileIconWithEdit(
                  context: context,
                  size: 100,
                  imageUrl: _profileImageUrl,
                  selectedImage: _selectedImage,
                  onEdit: _pickImage,
                ),
              ),

              const SizedBox(height: 24),

              // UID
              TextField(
                controller: uidController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "UID".tr(),
                  labelStyle: GoogleFonts.dmSans(color: primaryDark),
                  prefixIcon: const Icon(Icons.wallet_giftcard),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryOrange, width: 1),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Full Name
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Full Name".tr(),
                  labelStyle: GoogleFonts.dmSans(color: primaryDark),
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryOrange, width: 1),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Email
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email".tr(),
                  labelStyle: GoogleFonts.dmSans(color: primaryDark),
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryOrange, width: 1),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Phone with IntlPhoneField
              IntlPhoneField(
                dropdownIconPosition: IconPosition.trailing,
                disableLengthCheck: true,
                controller: phoneController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Only allow digits
                ],
                initialCountryCode: dialCode != null
                    ? _getCountryCodeFromDialCode(dialCode!)
                    : 'MY',
                decoration: InputDecoration(
                  labelText: "Phone Number".tr(),
                  labelStyle: GoogleFonts.dmSans(color: primaryDark),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryOrange, width: 1),
                  ),
                ),
                onChanged: (phone) {
                  fullPhoneNumber = phone.completeNumber;
                  dialCode = '+${phone.countryCode}';
                  debugPrint('📱 Dial: $dialCode, Phone: ${phone.number}, Full: $fullPhoneNumber');
                },
              ),
              const SizedBox(height: 24),

              // Date of Birth
              TextField(
                controller: dateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Date of Birth".tr(),
                  labelStyle: GoogleFonts.dmSans(color: primaryDark),
                  prefixIcon: const Icon(Icons.cake),
                  suffixIcon: InkWell(
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );

                      if (pickedDate != null) {
                        // Format: YYYY-MM-DD for backend
                        dob = "${pickedDate.year.toString().padLeft(4,'0')}-"
                            "${pickedDate.month.toString().padLeft(2,'0')}-"
                            "${pickedDate.day.toString().padLeft(2,'0')}";

                        // Display format: DD MMM YYYY (e.g., 15 Jan 2024)
                        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                        dateController.text = "${pickedDate.day.toString().padLeft(2,'0')} "
                            "${months[pickedDate.month - 1]} "
                            "${pickedDate.year}";
                      }
                    },
                    child: const Icon(Icons.calendar_today),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryOrange, width: 1),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Center(
                child: OrangeButtonTwo(
                  onPressed: _updateProfile,
                  text: _isSaving ? 'Saving...'.tr() : 'Save'.tr(),
                  height: 52,
                  width: MediaQuery.of(context).size.width * 0.9,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dateController.dispose();
    uidController.dispose();
    super.dispose();
  }
}

class ProfileField extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const ProfileField({
    super.key,
    required this.label,
    required this.value,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        leading: Icon(icon ?? Icons.info_outline, color: Colors.blue),
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}
Widget profileIconWithEdit({
  required BuildContext context,
  double size = 80,
  String? imageUrl,
  File? selectedImage,
  VoidCallback? onEdit,
}) {
  ImageProvider? avatarImage;

  if (selectedImage != null) {
    avatarImage = FileImage(selectedImage);
  } else if (imageUrl != null && imageUrl.trim().isNotEmpty) {
    avatarImage = NetworkImage(imageUrl);
  } else {
    avatarImage = null;
  }

  return GestureDetector(
    onTap: onEdit,
    child: Stack(
      children: [
        CircleAvatar(
          radius: size / 2,
          backgroundColor: const Color(0xFFFDD3A6),
          backgroundImage: avatarImage,
          child: avatarImage == null
              ? Icon(
            Icons.person,
            size: size * 0.6,
            color: Colors.white,
          )
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: onEdit,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Icon(
                Icons.edit,
                size: 24,
                color: primaryOrange,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
