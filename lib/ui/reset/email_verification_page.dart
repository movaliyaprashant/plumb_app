import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:plumbata/repo/auth/auth_repo.dart';
import 'package:plumbata/ui/widgets/buttons.dart';
import 'package:plumbata/ui/widgets/main_layout.dart';
import 'package:plumbata/utils/colors.dart';
import 'package:plumbata/utils/fonts.dart';
import 'package:plumbata/utils/icons.dart';

import 'new_password_page.dart';

class EmailVerificationPage extends StatefulWidget {
  final String email;
  final bool isForSignUp;

  EmailVerificationPage({required this.email, this.isForSignUp = false});

  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool _isWrongCode = false;
  bool _isActivating = false;
  bool _isEmailResent = false;
  var _canActivate = false.obs;

  final TextEditingController _codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MainLayout(
        title: 'Verification',
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: SvgPicture.asset(kRecentIcon)),
              Text(
                'Email Verification',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                "We have sent a 6 digits code to",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kLightGreyBlue),
              ),
              const SizedBox(height: 4),
              Text(
                widget.email,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kPurpleBlue),
              ),
              const SizedBox(height: 24),
              Text(
                "Enter or paste the code to Activate now",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kLightGreyBlue),
              ),
              const SizedBox(height: 16),
              Container(
                height: 63,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Theme.of(context).primaryColor),
                  color: Colors.white,
                ),
                padding:
                    EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 0),
                child: PinCodeTextField(
                  length: 6,
                  obscureText: false,
                  controller: _codeController,
                  animationType: AnimationType.fade,
                  textStyle: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      fontFamily: kOpenSansFont),
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.underline,
                    fieldHeight: 50,
                    fieldWidth: 30,
                    borderWidth: 1.5,
                    selectedColor: kPurpleBlue,
                    activeColor: kPurpleBlue,
                    disabledColor: Color(0xffEEEEEE),
                    inactiveColor: Color(0xffEEEEEE),
                  ),
                  animationDuration: Duration(milliseconds: 300),
                  onCompleted: (v) {
                    print("Completed");
                  },
                  onChanged: (value) {
                    print(value);
                    _canActivate.value = value.length == 6;
                  },
                  beforeTextPaste: (text) {
                    return true;
                  },
                  appContext: context,
                ),
              ),
              const SizedBox(height: 12),
              Visibility(
                visible: _isWrongCode,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    "Wrong code, please try Again OR click resend Code",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).errorColor),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Obx(
              //   () => PrimaryButton(
              //     'Activate',
              //     enabled: _canActivate.value,
              //     isLoading: _isActivating,
              //     onPressed: () {
              //       if (widget.isForSignUp) {
              //         _confirmSignUp();
              //       } else {
              //         _confirmPassword();
              //       }
              //     },
              //   ),
              // ),
              const SizedBox(height: 22),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2
                        ?.copyWith(color: kLightGreyBlue, fontSize: 12),
                    text: "Didn't receive code? ",
                    children: [
                      TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            if (widget.isForSignUp) {
                              _resendSignUpCode();
                            } else {
                              //TODO
                            }
                          },
                        text: 'Resend Code',
                        style: Theme.of(context).textTheme.subtitle2?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    ]),
              ),
              const SizedBox(height: 12),
              if (_isEmailResent)
                Text(
                  'Email has been resent successfully',
                  style: Theme.of(context).textTheme.subtitle2?.copyWith(
                        color: Color.fromARGB(255, 92, 166, 91),
                        fontSize: 12,
                      ),
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  _confirmPassword() async {
    String email = widget.email;
    String code = _codeController.text;
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (c) => NewPasswordPage(
                  email: email,
                  code: code,
                )));

    if (result != null && result == false) {
      setState(() {
        _isWrongCode = true;
      });
    }
  }

  void _resendSignUpCode() async {
    try {
      setState(() {
        _isEmailResent = false;
      });
      await GetIt.instance<AuthRepo>().resetPassword(
        widget.email,
      );

      setState(() {
        _isEmailResent = true;
      });
    } catch (e, s) {
      print(e);
      print(s);
    }
  }
}
