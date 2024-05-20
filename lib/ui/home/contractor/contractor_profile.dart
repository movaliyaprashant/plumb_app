import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plumbata/net/model/app_user.dart';
import 'package:plumbata/net/model/help_and_support.dart';
import 'package:plumbata/providers/user.dart';
import 'package:plumbata/ui/home/contractor/change_password.dart';
import 'package:plumbata/ui/home/contractor/edit_profile.dart';
import 'package:plumbata/ui/home/contractor/privacy_policy.dart';
import 'package:plumbata/ui/home/contractor/terms_and_conditions.dart';
import 'package:plumbata/ui/welcome/welcome_page.dart';
import 'package:plumbata/ui/widgets/appbar.dart';
import 'package:plumbata/utils/colors.dart';
import 'package:plumbata/utils/error_utils.dart';
import 'package:plumbata/utils/icons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ContractorProfile extends StatefulWidget {
  const ContractorProfile({super.key});

  @override
  State<ContractorProfile> createState() => _ContractorProfileState();
}

class _ContractorProfileState extends State<ContractorProfile> {
  late UserProvider userProvider;
  AppUser? appUserData;
  late HelpAndSupport helpAndSupport;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    userProvider = context.read<UserProvider>();

    getHelpAndSupport();
  }

  getHelpAndSupport() async {
    setState(() {
      isLoading = true;
    });
    helpAndSupport = await userProvider.getHelpAndSupport();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context, listen: true);
    appUserData = userProvider.currUserData;
    return Scaffold(
      appBar: GeneralAppBar(
        title: "Profile",
      ),
      body: SafeArea(
        child: ListView(
          children: [
            SizedBox(
              height: 16,
            ),
            CircleAvatar(
              radius: 80.0,
              backgroundColor: AppColors.lightPrimaryColor,
              child: CircleAvatar(
                backgroundImage: appUserData?.profileImage != null &&
                        appUserData?.profileImage != ""
                    ? NetworkImage(appUserData?.profileImage ?? "")
                    : AssetImage('assets/images/app.jpg') as ImageProvider,
                radius: 78,
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "${appUserData?.firstName} ${appUserData?.lastName}",
                    style: Theme.of(context).textTheme.bodyLarge,
                  )
                ]),
            SizedBox(
              height: 4,
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "${userProvider.currentUser?.email}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                ]),
            SizedBox(
              height: 4,
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "${appUserData?.phone}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                ]),
            SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Divider(
                color: AppColors.lightPrimaryColor.withOpacity(0.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Column(
                  children: [
                    _pageOption(
                        title: "Edit Profile",
                        svgIcon: kSettingsIcon,
                        onTab: _editProfile),
                    _pageOption(
                        title: "Change Password",
                        svgIcon: kLockIcon,
                        onTab: _changePassword),
                    _pageOption(
                        title: "Terms & Conditions",
                        icon: Icons.privacy_tip_outlined,
                        onTab: _goToTermsAndConditions),
                    _pageOption(
                        title: "Privacy Policy",
                        icon: Icons.privacy_tip,
                        onTab: _goToPrivacyPolicy),
                    SizedBox(
                      height: 8.0,
                    ),
                    isLoading
                        ? CircularProgressIndicator.adaptive()
                        : ListTile(
                            trailing: Icon(Icons.navigate_next),
                            onTap: () async {
                              final String subject =
                                  'Support Email From Plumbata App';
                              final Uri _emailLaunchUri = Uri(
                                scheme: 'mailto',
                                path: 'admin@plumbata.com',
                                queryParameters: {
                                  'subject': Uri.encodeQueryComponent(subject),
                                  'body': Uri.encodeQueryComponent(
                                      '\n \n User email is ${userProvider.currUserData?.email}'),
                                },
                              );
                              try {
                                await launchUrl(_emailLaunchUri);
                              } catch (e) {
                                print('Error launching email: $e');
                                ErrorUtils.showGeneralError(
                                    context, "Error sending the support email",
                                    duration: Duration(seconds: 3));
                                // Handle error, e.g., show an error dialog
                              }
                            },
                            leading: Container(
                                width: 25,
                                height: 25,
                                child: Icon(
                                  Icons.help,
                                  color: AppColors.lightPrimaryColor,
                                )),
                            title: Text(
                              "${helpAndSupport.title}",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "${helpAndSupport.paragraph}",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                    SizedBox(
                      height: 8.0,
                    ),
                    _pageOption(
                        title: "Logout", icon: Icons.logout, onTab: _logout),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Center(
              child: Text(
                "V 1.0.0",
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey),
              ),
            )
          ],
        ),
      ),
    );
  }

  _pageOption(
      {required String title,
      String? svgIcon,
      IconData? icon,
      required Function onTab}) {
    return ListTile(
      onTap: () {
        onTab();
      },
      leading: svgIcon != null
          ? Container(
              width: 25,
              height: 25,
              child: SvgPicture.asset(
                svgIcon,
                color: AppColors.lightPrimaryColor,
              ))
          : Container(
              width: 25,
              height: 25,
              child: Icon(
                icon,
                color: AppColors.lightPrimaryColor,
              )),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      trailing: Container(
          width: 25,
          height: 25,
          child: Icon(
            Icons.navigate_next,
            color: AppColors.lightPrimaryColor,
          )),
    );
  }

  _editProfile() async {
    await Navigator.of(context, rootNavigator: true)
        .push(MaterialPageRoute(builder: (ctx) => EditProfile()));
    appUserData = userProvider.currUserData;
    setState(() {});
  }

  _changePassword() {
    Navigator.of(context, rootNavigator: true)
        .push(MaterialPageRoute(builder: (ctx) => ChangePassword()));
  }

  _logout() async {
    return showDialog<void>(
      context: context,
      barrierDismissible:
          false, // Prevent user from dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Are you sure you want to logout?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Logging out will require you to log in again.',
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child:
                  Text('Cancel', style: Theme.of(context).textTheme.bodyMedium),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child:
                  Text('Logout', style: Theme.of(context).textTheme.bodyMedium),
              onPressed: () async {
                await context.read<UserProvider>().signOut();
                Navigator.pop(context);

                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (c) => WelcomePage()),
                    (_) => false);
              },
            ),
          ],
        );
      },
    );
  }

  _goToPrivacyPolicy() {
    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
        builder: (ctx) => PrivacyPolicy(title: "Privacy Policy")));
  }

  _goToTermsAndConditions() {
    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
        builder: (ctx) => TermsAndConditions(title: "Terms And Conditions")));
  }
}
