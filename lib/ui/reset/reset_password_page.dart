import 'package:another_flushbar/flushbar.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:plumbata/repo/auth/auth_repo.dart';
import 'package:plumbata/ui/login/login_page.dart';
import 'package:plumbata/ui/widgets/buttons.dart';
import 'package:plumbata/ui/widgets/main_layout.dart';
import 'package:plumbata/utils/colors.dart';
import 'package:plumbata/utils/error_utils.dart';
import 'package:plumbata/utils/icons.dart';

import 'email_verification_page.dart';

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  bool _isLoading = false;
  bool _isInvalidEmail = false;
  bool _isEmptyEmail = false;

  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MainLayout(
        title: 'Forgot Password',
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 46),
                Text(
                  'Reset Password',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  "Please enter your email address to request a password reset email.",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kLightGreyBlue),
                ),
                const SizedBox(height: 32.0),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(16),
                    hintText: 'Enter your email',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: SvgPicture.asset(kMailIcon),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: _isInvalidEmail || _isEmptyEmail,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: Text(
                      "Invalid email",
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).errorColor,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 64),
                PrimaryButton(
                  'Send Reset Email',
                  isLoading: _isLoading,
                  onPressed: () {
                    _sendCode();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _sendCode() async {
    String email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _isEmptyEmail = true;
      });
      return;
    }

    if (!EmailValidator.validate(email)) {
      setState(() {
        _isInvalidEmail = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _isInvalidEmail = false;
      _isEmptyEmail = false;
    });

    try {
      await GetIt.instance<AuthRepo>().resetPassword(email);

      setState(() {
        _isLoading = false;
      });
      ErrorUtils.showSuccessMessage(context, "Rest email was sent to ${email}");

      Future.delayed(const Duration(seconds: 3), () {
        Navigator.pushAndRemoveUntil(
            context, MaterialPageRoute(builder: (c) => LoginPage()), (
            _) => false);
      });

    } catch (e, s) {
      print(e);
      print(s);

      setState(() {
        _isLoading = false;
      });
    }
  }
}
