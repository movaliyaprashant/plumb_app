import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plumbata/providers/user.dart';
import 'package:plumbata/ui/widgets/appbar.dart';
import 'package:plumbata/ui/widgets/buttons.dart';
import 'package:plumbata/utils/colors.dart';
import 'package:plumbata/utils/error_utils.dart';
import 'package:plumbata/utils/icons.dart';
import 'package:plumbata/utils/validators.dart';
import 'package:provider/provider.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  TextEditingController oldPass = TextEditingController();
  TextEditingController newPass = TextEditingController();
  TextEditingController confirmPass = TextEditingController();
  String? validateError;
  bool _isLoading = false;
  late UserProvider userProvider;

  bool _visibleOldPass = false;
  bool _visibleNewPass = false;
  bool _visibleConfirmPass = false;

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context, listen: true);

    return Scaffold(
      appBar: GeneralAppBar(title: "Change Password", backBtn: true),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                SizedBox(
                  height: 32,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Form(
                      child: Column(
                    children: [
                      SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        onChanged: (text){
                          _validateForm();
                          setState(() {});
                        },
                        controller: oldPass,
                        autocorrect: false,
                        obscureText: !_visibleOldPass,
                        keyboardType: TextInputType.emailAddress,
                        autovalidateMode: AutovalidateMode.always,
                        decoration: InputDecoration(
                          labelText: 'Old Password', // Add this line
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.lightAccentColor, width: 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.errorColor, width: 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          floatingLabelStyle: MaterialStateTextStyle.resolveWith(
                                (Set<MaterialState> states) {
                              final Color color = states.contains(MaterialState.error)
                                  ? AppColors.errorColor
                                  : Colors.black;
                              return TextStyle(color: color, letterSpacing: 1.3);
                            },
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          hintText: 'Old Password',
                          suffixIcon: IconButton(
                            icon: _visibleOldPass
                                ? Icon(Icons.visibility_off)
                                : Icon(Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _validateForm();
                                _visibleOldPass = !_visibleOldPass;
                              });
                            },
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: SvgPicture.asset(kLockIcon),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        onChanged: (text){
                          _validateForm();
                          setState(() {});
                        },
                        controller: newPass,
                        autocorrect: false,
                        obscureText: !_visibleNewPass,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'New Password', // Add this line
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.lightAccentColor, width: 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.errorColor, width: 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          floatingLabelStyle: MaterialStateTextStyle.resolveWith(
                                (Set<MaterialState> states) {
                              final Color color = states.contains(MaterialState.error)
                                  ? AppColors.errorColor
                                  : Colors.black;
                              return TextStyle(color: color, letterSpacing: 1.3);
                            },
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          hintText: 'New Password',
                          suffixIcon: IconButton(
                            icon: _visibleNewPass
                                ? Icon(Icons.visibility_off)
                                : Icon(Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _validateForm();
                                _visibleNewPass = !_visibleNewPass;
                              });
                            },
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: SvgPicture.asset(kLockIcon),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        onChanged: (text){
                          _validateForm();
                          setState(() {});
                        },
                        controller: confirmPass,
                        autocorrect: false,
                        obscureText: !_visibleConfirmPass,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Confirm New Password', // Add this line
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.lightAccentColor, width: 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.errorColor, width: 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          floatingLabelStyle: MaterialStateTextStyle.resolveWith(
                                (Set<MaterialState> states) {
                              final Color color = states.contains(MaterialState.error)
                                  ? AppColors.errorColor
                                  : Colors.black;
                              return TextStyle(color: color, letterSpacing: 1.3);
                            },
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          hintText: 'Confirm New Password',
                          suffixIcon: IconButton(
                            icon: _visibleConfirmPass
                                ? Icon(Icons.visibility_off)
                                : Icon(Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _validateForm();
                                _visibleConfirmPass = !_visibleConfirmPass;
                              });
                            },
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: SvgPicture.asset(kLockIcon),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          validateError ?? "",
                          textAlign: TextAlign.start,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.errorColor),
                        ),
                      )
                    ],
                  )),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 32,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: PrimaryButton(
              'Update the password',
              isLoading: _isLoading,
              enabled: _isEnabled(),
              onPressed: () async {
                bool isValid = _validateForm();
                if (isValid) {
                  setState(() {
                    _isLoading = true;
                  });
                  String? result = await userProvider.changePassword(
                      currentPassword: oldPass.text, newPassword: newPass.text);
                  if (result != null) {
                    setState(() {
                      if(result?.toLowerCase().contains("wrong-password") == true){
                        result = "Wrong Password";
                      }

                      validateError = result;
                    });
                  } else {
                    ErrorUtils.showSuccessMessage(
                        context, "Password updated successfully");
                    oldPass.clear();
                    newPass.clear();
                    confirmPass.clear();
                    Future.delayed(
                        const Duration(seconds: 4),
                            () => Navigator.pop(context));
                  }
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
            ),
          ),
          SizedBox(
            height: 32,
          )
        ],
      ),
    );
  }

  _isEnabled(){
    bool val =  _validateForm();
    if(val == false){
      return false;
    }
    if(validateError == "Wrong Password"){
      return false;
    }
    if (oldPass.text.isEmpty == true) {
      return false;
    }
    if (newPass.text.isEmpty == true) {
      return false;
    }
    if (confirmPass.text != newPass.text) {
      return false;
    }
    validateError = Validators.passwordValidator(newPass.text);
    setState(() {});
    return validateError == null;
  }
  _validateForm() {
    if (oldPass.text.isEmpty == true) {
      validateError = "Please Enter your current Password";
      return false;
    }
    if (newPass.text.isEmpty == true) {
      validateError = "Please Enter your new Password";
      return false;
    }
    if (confirmPass.text != newPass.text) {
      validateError = "Confirm Password should match the new password";
      return false;
    }
    if(oldPass.text == newPass.text){
      validateError = "The new password is same as old password";
      return false;
    }
    validateError = Validators.passwordValidator(newPass.text);
    setState(() {});
    return validateError == null;
  }
}
