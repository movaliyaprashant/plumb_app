import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:plumbata/providers/user.dart';
import 'package:plumbata/repo/auth/auth_repo.dart';
import 'package:plumbata/ui/home/bottom_navigation.dart';
import 'package:plumbata/ui/home/contractor/add_new_timesheet.dart';
import 'package:plumbata/ui/home/contractor/contractor_calender.dart';
import 'package:plumbata/ui/home/contractor/contractor_profile.dart';
import 'package:plumbata/ui/home/contractor/contracts_home.dart';
import 'package:plumbata/ui/home/contractor/notifications_page.dart';
import 'package:plumbata/ui/welcome/welcome_page.dart';
import 'package:plumbata/utils/colors.dart';
import 'package:plumbata/utils/icons.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late UserProvider userProvider;

  @override
  void initState() {
    super.initState();
    userProvider = context.read<UserProvider>();
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context, listen: true);

    return WillPopScope(
      onWillPop: () async {
        // TO DO
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: _getScreenForIndex(_selectedIndex),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: userProvider.isSuperIntendent() ? SizedBox() : GestureDetector(
          onTap: () async {
            // await GetIt.instance<AuthRepo>().signOut();
            // Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            if (userProvider.currentContract == null) {
              showNoActiveContractDialog(context);
            } else {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (ctx) => AddNewTimeSheet()));
            }
          },
          child: Card(
            elevation: 5,
            shape: CircleBorder(),
            child: Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xfff16075),
                    Color(0xfff16075),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                      offset: Offset(0, 17),
                      blurRadius: 30,
                      color: Color(0xfff16075).withOpacity(0.35))
                ],
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(16),
              child: SvgPicture.asset(
                kDocumentIcon,
                color: Colors.white,
              ),
            ),
          ),
        ),
        bottomNavigationBar: AppBottomNavigationBar(
          currentIndex: _selectedIndex,
          showGap: userProvider.isSuperIntendent() ? false : true,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: [
            NavigationBarItem(
              selectedIcon: SvgPicture.asset(
                kHomeIcon,
                color: AppColors.selectedColor,
              ),
              unSelectedIcon: SvgPicture.asset(
                kHomeIcon,
                color: AppColors.unselectedColor,
              ),
            ),
            NavigationBarItem(
              selectedIcon: SvgPicture.asset(
                kDocumentIcon,
                width: 25,
                height: 25,
                color: AppColors.selectedColor,
              ),
              unSelectedIcon: SvgPicture.asset(
                kDocumentIcon,
                color: Color(0xffCFDDF2),
                width: 25,
                height: 25,
              ),
            ),
            NavigationBarItem(
              selectedIcon: userProvider.notificationsCount > 0
                  ? badges.Badge(
                      position: badges.BadgePosition.topEnd(top: -12, end: -12),
                      showBadge: true,
                      ignorePointer: false,
                      onTap: () {},
                      badgeContent: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Text(
                            userProvider.notificationsCount.toString(),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      badgeAnimation: badges.BadgeAnimation.rotation(
                        animationDuration: Duration(seconds: 1),
                        colorChangeAnimationDuration: Duration(seconds: 1),
                        loopAnimation: false,
                        curve: Curves.fastOutSlowIn,
                        colorChangeAnimationCurve: Curves.easeInCubic,
                      ),
                      badgeStyle: badges.BadgeStyle(
                        shape: badges.BadgeShape.circle,
                        badgeColor: Colors.red,
                        padding: EdgeInsets.all(5),
                        borderRadius: BorderRadius.circular(4),
                        elevation: 0,
                      ),
                      child: SvgPicture.asset(
                        kNotificationIcon,
                        color: AppColors.selectedColor,
                      ),
                    )
                  : SvgPicture.asset(
                      kNotificationIcon,
                      color: AppColors.selectedColor,
                    ),
              unSelectedIcon: userProvider.notificationsCount > 0
                  ? badges.Badge(
                      position: badges.BadgePosition.topEnd(top: -12, end: -12),
                      showBadge: true,
                      ignorePointer: false,
                      onTap: () {},
                      badgeContent: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Text(
                            userProvider.notificationsCount.toString(),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      badgeAnimation: badges.BadgeAnimation.rotation(
                        animationDuration: Duration(seconds: 1),
                        colorChangeAnimationDuration: Duration(seconds: 1),
                        loopAnimation: false,
                        curve: Curves.fastOutSlowIn,
                        colorChangeAnimationCurve: Curves.easeInCubic,
                      ),
                      badgeStyle: badges.BadgeStyle(
                        shape: badges.BadgeShape.circle,
                        badgeColor: Colors.red,
                        padding: EdgeInsets.all(5),
                        borderRadius: BorderRadius.circular(4),
                        elevation: 0,
                      ),
                      child: SvgPicture.asset(
                        kNotificationIcon,
                      ),
                    )
                  : SvgPicture.asset(
                      kNotificationIcon,
                    ),
            ),
            NavigationBarItem(
              selectedIcon: SvgPicture.asset(
                kPersonIcon,
                color: AppColors.selectedColor,
              ),
              unSelectedIcon: SvgPicture.asset(kPersonIcon),
            ),
          ],
        ),
      ),
    );
  }

  _getScreenForIndex(int index) {
    switch (index) {
      case 0:
        return Navigator(
          onGenerateRoute: (settings) {
            return MaterialPageRoute(
              builder: (c) => ContractorHome(),
              settings: settings,
            );
          },
        );
      case 1:
        return ContractorCalender();
      case 2:
        return NotificationsPage();
      case 3:
        return ContractorProfile();
      default:
        return Container();
    }
  }

  void showNoActiveContractDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "No Active Contract",
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "You do not have an active contract. Please contact your superintendent.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
