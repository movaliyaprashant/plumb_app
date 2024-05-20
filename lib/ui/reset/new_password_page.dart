import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:plumbata/repo/auth/auth_repo.dart';
import 'package:plumbata/ui/widgets/buttons.dart';
import 'package:plumbata/ui/widgets/main_layout.dart';
import 'package:plumbata/utils/colors.dart';
import 'package:plumbata/utils/error_utils.dart';
import 'package:plumbata/utils/icons.dart';
import 'package:plumbata/utils/validators.dart';

class NewPasswordPage extends StatefulWidget {
  final String email;
  final String code;

  NewPasswordPage({required this.email, required this.code});

  @override
  _NewPasswordPageState createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  bool _isActivating = false;

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MainLayout(
        title: 'New Password',
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 32, right: 32, top: 46),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'New Password',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Please enter your new password.",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: kLightGreyBlue),
                  ),
                  const SizedBox(height: 32.0),
                  TextFormField(
                    validator: Validators.passwordValidator,
                    controller: _passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(16),
                        hintText: 'Choose a password',
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SvgPicture.asset(kLockIcon),
                        )),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    validator: (password) {
                      if (password != _passwordController.text) {
                        return "Your password didn't match";
                      }
                      return null;
                    },
                    controller: _confirmPasswordController,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(16),
                        hintText: 'Confirm your password',
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SvgPicture.asset(kLockIcon),
                        )),
                  ),
                  const SizedBox(height: 32.0),
                  PrimaryButton(
                    'Confirm',
                    isLoading: _isActivating,
                    onPressed: () {
                      if (_formKey.currentState?.validate() == true) {
                        _confirmPassword();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _confirmPassword() async {
    String email = widget.email;
    String code = widget.code;
    String password = _passwordController.text;

    setState(() {
      _isActivating = true;
    });

    try {
      await GetIt.instance<AuthRepo>().confirmPassword(
        email,
        password,
        code,
      );

      setState(() {
        _isActivating = false;
      });

      Navigator.pushNamedAndRemoveUntil(context, '/welcome', (_) => false);
      ErrorUtils.showSuccessMessage(context, 'Password reset successfully');
    } catch (e, s) {
      print(e);
      print(s);

      ErrorUtils.showGeneralError(context, e, duration: Duration(seconds: 3));
      setState(() {
        _isActivating = false;
      });
    }
  }
}
