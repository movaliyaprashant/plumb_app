import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plumbata/providers/user.dart';
import 'package:plumbata/ui/login/login_page.dart';
import 'package:plumbata/ui/register/register_page.dart';
import 'package:plumbata/ui/widgets/buttons.dart';
import 'package:plumbata/ui/widgets/main_layout.dart';
import 'package:plumbata/utils/colors.dart';
import 'package:plumbata/utils/error_utils.dart';
import 'package:plumbata/utils/icons.dart';
import 'package:provider/provider.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _isSigningIn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Color.fromARGB(255, 246, 245, 255),
        body: MainLayout(
          showLogo: true,
          showBackArrow: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Welcome to',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 38, fontWeight: FontWeight.w700)),
                Text(
                  'Plumbata',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w700,
                      color: Color(0xffff8d40)),
                ),
                Spacer(),
                PrimaryButton(
                  'Sign in',
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => LoginPage()));
                  },
                ),
                const SizedBox(height: 27),
                PrimaryButton(
                  'Sign up',
                  isLoading: false,
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => RegisterPage()));
                  },
                ),
                const SizedBox(height: 32),
                // SimpleOutlinedButton(
                //   'Continue as guest',
                //   onPressed: () {
                //     _openAsGuest();
                //   },
                // ),
                const SizedBox(height: 40),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: Color.fromARGB(125, 179, 179, 179),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text('Continue with',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.lightAccentColor)),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: Color.fromARGB(125, 179, 179, 179),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (!_isSigningIn) {
                          _googleSignIn();
                        }
                      },
                      child: Container(
                        height: 56,
                        width: 56,
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white),
                        child: SvgPicture.asset(kGoogleIcon),
                      ),
                    ),
                    const SizedBox(width: 18),
                    GestureDetector(
                      onTap: () {
                        if (!_isSigningIn) {
                          _appleSignIn();
                        }
                      },
                      child: Container(
                        height: 56,
                        width: 56,
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white),
                        child: SvgPicture.asset(kAppleIcon),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  _googleSignIn() async {
    setState(() {
      _isSigningIn = true;
    });
    try {
      var result = await context.read<UserProvider>().signInWithGoogle();
      if (result != false) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
      }
    } catch (e) {
      print(e);
      ErrorUtils.showGeneralError(context, 'Social media error',
          duration: Duration(seconds: 3));
    }

    setState(() {
      _isSigningIn = false;
    });
  }

  _appleSignIn() async {
    setState(() {
      _isSigningIn = true;
    });
    try {
      var result = await context.read<UserProvider>().signInWithApple();
      if (result != null) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
      }
    } catch (e, s) {
      print(e);
      ErrorUtils.showGeneralError(context, 'Social media error',
          duration: Duration(seconds: 3));
    }

    setState(() {
      _isSigningIn = false;
    });
  }
}
