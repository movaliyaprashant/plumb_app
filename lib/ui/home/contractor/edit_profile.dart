import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:plumbata/net/model/app_user.dart';
import 'package:plumbata/providers/user.dart';
import 'package:plumbata/services/files/types.dart';
import 'package:plumbata/ui/widgets/appbar.dart';
import 'package:plumbata/ui/widgets/buttons.dart';
import 'package:plumbata/utils/app_utils.dart';
import 'package:plumbata/utils/colors.dart';
import 'package:plumbata/utils/error_utils.dart';
import 'package:plumbata/utils/icons.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController _fname = TextEditingController();
  TextEditingController _lname = TextEditingController();
  TextEditingController _company = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  late UserProvider userProvider;
  AppUser? appUserData;

  bool _isLoading = false;
  String originalFname = '';
  String originalLname = '';
  String originalCompanyname = '';
  String originalEmail = '';
  bool isInit = false;
  PhoneNumber number = PhoneNumber(isoCode: 'CA');
  PhoneNumber originalNumber = PhoneNumber(isoCode: 'CA');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context, listen: true);
    appUserData = userProvider.currUserData;
    if (!isInit) {
      _fname.text = appUserData?.firstName ?? "";
      _lname.text = appUserData?.lastName ?? "";
      _company.text = appUserData?.company ?? "";
      _phoneController.text = appUserData?.phone ?? "";

      originalFname = appUserData?.firstName ?? "";
      originalLname = appUserData?.lastName ?? "";
      originalCompanyname = appUserData?.company ?? "";
      originalEmail = appUserData?.email ?? "";

      originalNumber = PhoneNumber(
          isoCode: appUserData?.countryCode ?? '+1',
          phoneNumber: appUserData?.phone
              ?.replaceAll(appUserData?.countryCode ?? "", ""));

      String? phoneNumberWithoutCode =
          appUserData?.phone?.replaceAll(appUserData?.countryCode ?? "", "");
      _phoneController.text = phoneNumberWithoutCode ?? "";

      number = originalNumber;

      isInit = true;
    }

    return Scaffold(
      appBar: GeneralAppBar(title: "Update Profile", backBtn: true),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                SizedBox(
                  height: 32,
                ),
                Stack(
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 80.0,
                        backgroundColor: AppColors.lightPrimaryColor,
                        child: CircleAvatar(
                          backgroundImage: appUserData?.profileImage != null &&
                                  appUserData?.profileImage != ""
                              ? NetworkImage(appUserData?.profileImage ?? "")
                              : AssetImage('assets/images/app.jpg')
                                  as ImageProvider,
                          radius: 78,
                        ),
                      ),
                    ),
                    Positioned(
                        top: 120,
                        right: 120,
                        child: Container(
                          height: 40.0,
                          width: 40.0,
                          child: FloatingActionButton(
                            onPressed: () {
                              _editProfilePic();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.edit,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )),
                  ],
                ),
                SizedBox(
                  height: 32,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Form(
                      child: Column(
                    children: [
                      TextFormField(
                        controller: _fname,
                        autocorrect: false,
                        onChanged: (text) {
                          _fname.text = text.trimLeft();
                          setState(() {});
                        },
                        keyboardType: TextInputType.emailAddress,
                        decoration: AppUtils.getInputDecoration("First Name", Icons.person),
                        validator: (String? value) {
                          if (value == null || value == '') {
                            return 'Enter first name';
                          }
                          if (value.trim().length < 2) {
                            return "The name can not be less than 2 chars";
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.always,
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        controller: _lname,
                        autocorrect: false,
                        onChanged: (text) {
                          _lname.text = text.trimLeft();

                          setState(() {});
                        },
                        keyboardType: TextInputType.name,
                        decoration: AppUtils.getInputDecoration("Last Name", Icons.person),
                        validator: (String? value) {
                          if (value == null || value == '') {
                            return 'Enter last name';
                          }
                          if (value.trim().length < 2) {
                            return "The name can not be less than 2 chars";
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.always,
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        controller: _company,
                        autocorrect: false,
                        onChanged: (text) {
                          _company.text = text.trimLeft();

                          setState(() {});
                        },
                        keyboardType: TextInputType.name,
                        decoration: AppUtils.getInputDecoration("Company", Icons.home_work_outlined),
                        autovalidateMode: AutovalidateMode.always,
                        validator: (value) {
                          if (value == null || value == '') {
                            return 'Please enter your company.';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Divider(),
                      SizedBox(
                        height: 16,
                      ),
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
                      // TextFormField(
                      //   controller: _email,
                      //   autocorrect: false,
                      //   onChanged: (text) {
                      //     setState(() {});
                      //   },
                      //   keyboardType: TextInputType.name,
                      //   decoration: AppUtils.getInputDecoration("Email"),
                      //   autovalidateMode: AutovalidateMode.always,
                      //   validator: (value) {
                      //     if (value == null || value == '') {
                      //       return 'Please enter your email.';
                      //     }
                      //     // Regular expression for a simple email validation
                      //     final emailRegex =
                      //         RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
                      //
                      //     if (!emailRegex.hasMatch(value)) {
                      //       return 'Please enter a valid email address.';
                      //     }
                      //
                      //     return null;
                      //   },
                      // ),
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
              'Save & Update',
              isLoading: _isLoading,
              enabled: isEnable(),
              onPressed: () async {
                bool isValid = _validateForm();
                if (isValid) {
                  setState(() {
                    _isLoading = true;
                  });
                  var result = await userProvider.updateUserData({
                    "firstName": _fname.text.trim(),
                    "lastName": _lname.text.trim(),
                    "company": _company.text.trim(),
                    "countryCode": number.dialCode,
                    "phone": number.phoneNumber,
                  });

                  originalFname = _fname.text.trim();
                  originalLname = _lname.text.trim();
                  originalCompanyname = _company.text.trim();
                  originalNumber = number;

                  appUserData?.phone ?? "";

                  if (result == true) {
                    ErrorUtils.showSuccessMessage(
                        context, "User data updated successfully");
                  } else {
                    ErrorUtils.showGeneralError(
                        context, "could not update user data",
                        duration: Duration(seconds: 2));
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

  _editProfilePic() {
    AppUtils.showPickSource(context, _pickFile);
  }

  _pickFile({required bool isCamera}) async {
    setState(() {
      _isLoading = true;
    });

    XFile? file;
    if (isCamera) {
      file = await AppUtils.pickCameraPhoto();
    } else {
      file = await AppUtils.pickGalleryPhoto();
    }

    Navigator.pop(context);

    await userProvider.updateUserPhoto(file);

    setState(() {
      _isLoading = false;
    });
  }

  isEnable() {
    if ((_company.text != originalCompanyname ||
            _fname.text != originalFname ||
            _lname.text != originalLname ||
            number.phoneNumber != originalNumber?.phoneNumber ||
            number.isoCode != originalNumber?.isoCode) &&
        _fname.text.length >= 2 &&
        _lname.text.length >= 2 &&
        _company.text.length > 1) {
      return true;
    }
    return false;
  }

  _validateForm() {
    return true;
  }
}
