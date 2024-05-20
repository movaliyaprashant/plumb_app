import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:plumbata/providers/user.dart';
import 'package:plumbata/repo/auth/auth_repo.dart';
import 'package:plumbata/ui/login/login_page.dart';
import 'package:plumbata/ui/reset/email_verification_page.dart';
import 'package:plumbata/ui/widgets/buttons.dart';
import 'package:plumbata/ui/widgets/main_layout.dart';
import 'package:plumbata/utils/colors.dart';
import 'package:plumbata/utils/device_utils.dart';
import 'package:plumbata/utils/icons.dart';
import 'package:plumbata/utils/validators.dart';
import 'package:provider/provider.dart';

import '../../utils/error_utils.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
  RegisterPage({this.isComplete = false});

  final bool isComplete;
}

class _RegisterPageState extends State<RegisterPage> {
  bool _agreedToTerms = false;
  var _canSignUp = false.obs;
  bool _isLoading = false;
  bool _isInvalidEmail = false;
  String? _passwordValidationError;
  bool _emailExists = false;
  late UserProvider userProvider;

  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  TextEditingController _companyController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String initialCountry = 'CA';
  PhoneNumber number = PhoneNumber(isoCode: 'CA');
  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    userProvider = context.read<UserProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MainLayout(
        showLogo: true,
        logoRadius: 62,
        showBackArrow: !widget.isComplete,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.isComplete ? 'Complete Sign up' : 'Sign Up',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
                const SizedBox(height: 14),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        onChanged: (value) {
                          _canSignUp.value = _validSignUp();
                        },
                        keyboardType: TextInputType.name,
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(16),
                          hintText: 'First Name',
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: SvgPicture.asset(kPersonOutlinedIcon),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        onChanged: (value) {
                          _canSignUp.value = _validSignUp();
                        },
                        controller: _lastNameController,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(16),
                          hintText: 'Last Name',
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: SvgPicture.asset(kPersonOutlinedIcon),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        validator: (value) {
                          if (value?.isEmpty == true) {
                            return "Company can not be empty";
                          }
                          return null;
                        },
                        onChanged: (value) {
                          _canSignUp.value = _validSignUp();
                        },
                        controller: _companyController,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(16),
                          hintText: 'Company',
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: SvgPicture.asset(kLockIcon),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        onChanged: (value) {
                          _canSignUp.value = _validSignUp();
                        },
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
                        visible: _isInvalidEmail,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          child: Text(
                            "Invalid email",
                            style: TextStyle(
                                color: Theme.of(context).errorColor,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: _emailExists,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          child: Text(
                            "Email exists",
                            style: TextStyle(
                                color: Theme.of(context).errorColor,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      widget.isComplete
                          ? SizedBox()
                          : const SizedBox(height: 12),
                      widget.isComplete
                          ? SizedBox()
                          : TextFormField(
                              validator: Validators.passwordValidator,
                              onChanged: (value) {
                                _canSignUp.value = _validSignUp();
                              },
                              controller: _passwordController,
                              keyboardType: TextInputType.visiblePassword,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(16),
                                hintText: 'Choose a password',
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: SvgPicture.asset(kLockIcon),
                                  ),
                                ),
                              ),
                            ),
                      Visibility(
                        visible: _passwordValidationError != null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          child: Text(
                            _passwordValidationError ?? '',
                            style: TextStyle(
                                color: Theme.of(context).errorColor,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      widget.isComplete
                          ? SizedBox()
                          : const SizedBox(height: 12),
                      widget.isComplete
                          ? SizedBox()
                          : TextFormField(
                              validator: (value) {
                                if (value != _passwordController.text) {
                                  return "Your password didn't match";
                                }
                                return null;
                              },
                              onChanged: (value) {
                                _canSignUp.value = _validSignUp();
                              },
                              controller: _confirmPasswordController,
                              keyboardType: TextInputType.visiblePassword,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(16),
                                hintText: 'Confirm your password',
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: SvgPicture.asset(kLockIcon),
                                  ),
                                ),
                              ),
                            ),
                      const SizedBox(height: 12),
                      Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: InternationalPhoneNumberInput(
                            onInputChanged: (PhoneNumber phone) {
                              print(phone.phoneNumber);
                              setState(() {
                                number = phone;
                              });
                            },
                            // onInputValidated: (bool value) {
                            //   print(value);
                            // },
                            selectorConfig: SelectorConfig(
                              selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                            ),
                            ignoreBlank: false,
                            autoValidateMode: AutovalidateMode.disabled,
                            selectorTextStyle: TextStyle(color: Colors.black),
                            initialValue: number,
                            textFieldController: _phoneController,
                            formatInput: true,
                            keyboardType: TextInputType.phone,
                            inputBorder: InputBorder.none,
                            onSaved: (PhoneNumber number) {
                              print('On Saved: $number');
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 23),
                      Row(
                        children: [
                          Checkbox(
                              value: _agreedToTerms,
                              onChanged: (v) {
                                setState(() {
                                  _agreedToTerms = v ?? false;
                                  _canSignUp.value = _validSignUp();
                                });
                              }),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle2
                                      ?.copyWith(
                                          color: kLightGreyBlue, fontSize: 12),
                                  text: 'By click check box you agree to our ',
                                  children: [
                                    TextSpan(
                                      text: 'community guidelines',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.lightBodyTextColor,
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline),
                                    ),
                                    TextSpan(text: ', terms of service and '),
                                    TextSpan(
                                      text: 'privacy policy.',
                                      style: TextStyle(
                                          color: AppColors.lightBodyTextColor,
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline),
                                    ),
                                  ]),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 17),
                      Obx(
                        () => PrimaryButton(
                          widget.isComplete ? 'Complete Sign up' : 'Sign up',
                          isLoading: _isLoading,
                          enabled: _canSignUp.value,
                          onPressed: () {
                            if (_formKey.currentState?.validate() == true) {
                              _signUp();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                widget.isComplete
                    ? SizedBox()
                    : RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                            style: Theme.of(context)
                                .textTheme
                                .subtitle2
                                ?.copyWith(
                                    color: kLightGreyBlue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                            text: 'Already have an account? ',
                            children: [
                              TextSpan(
                                text: 'Sign in',
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    _openSignInPage();
                                  },
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2
                                    ?.copyWith(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ]),
                      ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openSignInPage() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => LoginPage()));
  }

  bool _validSignUp() {
    if (_firstNameController.text.isEmpty) {
      return false;
    }
    if (_lastNameController.text.isEmpty) {
      return false;
    }
    if (_emailController.text.isEmpty) {
      return false;
    }
    if (_passwordController.text.isEmpty && !widget.isComplete) {
      return false;
    }
    if (_confirmPasswordController.text.isEmpty && !widget.isComplete) {
      return false;
    }
    if (_companyController.text.isEmpty) {
      return false;
    }
    if (!_agreedToTerms) {
      return false;
    }
    return true;
  }

  void _signUp() async {
    DeviceUtils.hideKB();

    String firstName = _firstNameController.text.trim();
    String lastName = _lastNameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    String company = _companyController.text.trim();
    String phone = number.phoneNumber ?? "";

    if (!EmailValidator.validate(email)) {
      setState(() {
        _isInvalidEmail = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _isInvalidEmail = false;
      _passwordValidationError = null;
      _emailExists = false;
    });

    try {
      await userProvider.signUp(
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName,
          company: company,
          phone: phone,
          countryCode: number.isoCode,
          isComplete: widget.isComplete);

      setState(() {
        _isLoading = false;
      });

      //open home page
     Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    } catch (e, s) {
      print(e);
      print(s);

      ErrorUtils.showGeneralError(context, e.toString(),
          duration: Duration(seconds: 3));
      setState(() {
        _isLoading = false;
      });
    }
  }
}
