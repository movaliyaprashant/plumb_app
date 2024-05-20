import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:plumbata/providers/user.dart';
import 'package:plumbata/ui/register/register_page.dart';
import 'package:plumbata/ui/reset/reset_password_page.dart';
import 'package:plumbata/ui/widgets/buttons.dart';
import 'package:plumbata/ui/widgets/main_layout.dart';
import 'package:plumbata/utils/colors.dart';
import 'package:plumbata/utils/icons.dart';
import 'package:plumbata/utils/validators.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isSigningIn = false;

  String? _emailValidation;
  String? _passwordValidation;
  bool visiblePass = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MainLayout(
        logoRadius: 62,
        showLogo: true,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Welcome back',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
                const SizedBox(height: 55),
                Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _emailController,
                        autocorrect: false,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            hintText: 'Email',
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: SvgPicture.asset(kMailIcon),
                            )),
                      ),
                      if (_emailValidation != null)
                        _validationText(_emailValidation),
                      const SizedBox(height: 12),
                      TextFormField(
                        obscureText: !visiblePass,
                        controller: _passwordController,
                        validator: (text) => Validators.emptyValidator(
                            text, 'Enter your password'),
                        keyboardType: TextInputType.visiblePassword,
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: visiblePass
                                  ? Icon(Icons.visibility_off)
                                  : Icon(Icons.visibility),
                              onPressed: () {
                                setState(() {
                                  visiblePass = !visiblePass;
                                });
                              },
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            hintText: 'Password',
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: SvgPicture.asset(kLockIcon),
                            )),
                      ),
                      if (_passwordValidation != null)
                        _validationText(_passwordValidation),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (cc) => ResetPasswordPage())),
                        child: Text(
                          'Forget password?',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  'Sign in',
                  isLoading: _isSigningIn,
                  onPressed: () {
                    bool isValid = _validateForm();
                    if (isValid) {
                      String email = _emailController.text.trim();
                      String password = _passwordController.text.trim();
                      _login(email, password);
                    }
                  },
                ),
                const SizedBox(height: 32),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      style: Theme.of(context)
                          .textTheme
                          .subtitle2
                          ?.copyWith(color: Colors.black, fontSize: 14),
                      text: 'Don’t have an account yet? \n',
                      children: [
                        TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => RegisterPage()));
                            },
                          text: 'Sign up',
                          style: Theme.of(context)
                              .textTheme
                              .subtitle2
                              ?.copyWith(color: Theme.of(context).primaryColor),
                        ),
                        TextSpan(text: ' or...'),
                      ]),
                ),
                const SizedBox(height: 22),
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
                          style: Theme.of(context)
                              .textTheme
                              .subtitle2
                              ?.copyWith(
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
                      onTap: _isSigningIn ? null : () => _googleSignIn(),
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
                      onTap: _isSigningIn ? null : () => _appleSignIn(),
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
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _validationText(text) => Padding(
        padding: EdgeInsets.only(top: 4, left: 8),
        child: Text(
          text,
          style: TextStyle(
            color: Theme.of(context).errorColor,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      );

  _appleSignIn() async {
    setState(() {
      _isSigningIn = true;
    });
    try {
      var result = await context.read<UserProvider>().signInWithApple();
      if (result != null) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
      }
    } catch (e, s) {
      print(e);
      _handleLoginError(e);
    }

    setState(() {
      _isSigningIn = false;
    });
  }

  _login(String username, String password) async {
    setState(() {
      _isSigningIn = true;
    });
    try {
      await context
          .read<UserProvider>()
          .signIn(username: username, password: password);
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    } catch (e, s) {
      print(e);
      print(s);
      _handleLoginError(e);
    }

    setState(() {
      _isSigningIn = false;
    });
  }

  _googleSignIn() async {
    setState(() {
      _isSigningIn = true;
    });
    try {
      var result = await context.read<UserProvider>().signInWithGoogle();
      if (result != false) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
      }
    } catch (e) {
      print(e);
      _handleLoginError(e);
    }

    setState(() {
      _isSigningIn = false;
    });
  }

  _handleLoginError(exception) {
    setState(() {
      _emailValidation = 'Incorrect email or password';
    });
  }

  bool _validateForm() {
    _emailValidation = null;
    _passwordValidation = null;
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    if (email.isEmpty) {
      _emailValidation = 'Enter your email';
    }
    if (password.isEmpty) {
      _passwordValidation = 'Enter your password';
    }

    setState(() {
      //
    });

    return _emailValidation == null && _passwordValidation == null;
  }
}
