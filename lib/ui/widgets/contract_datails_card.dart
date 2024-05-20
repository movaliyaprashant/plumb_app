import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plumbata/net/model/contract.dart';
import 'package:plumbata/net/model/timesheet.dart';
import 'package:plumbata/ui/home/contractor/timesheets_list.dart';
import 'dart:async';

import 'package:plumbata/ui/widgets/buttons.dart';
import 'package:plumbata/utils/colors.dart';
import 'package:plumbata/utils/fonts.dart';
import 'package:plumbata/utils/icons.dart';
import 'package:badges/badges.dart' as badges;

class ContractDetailsCard extends StatefulWidget {
  const ContractDetailsCard(
      {super.key, required this.contract, required this.pendingCount});
  final Contract? contract;
  final int pendingCount;
  @override
  State<ContractDetailsCard> createState() => _ContractDetailsCardState();
}

class _ContractDetailsCardState extends State<ContractDetailsCard> {
  @override
  void initState() {
    super.initState();
    // Set up a timer to update the time every minute
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                ),
                Icon(
                  Icons.schedule_outlined,
                  color: AppColors.lightAccentColor,
                  size: 30,
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  "Contract TimeSheets",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.lightBodyTextColor),
                ),
              ],
            ),
            Divider(),
            SizedBox(
              height: 8,
            ),
            InkWell(
              child: timeSheetItem("Approved timesheets",
                  leadingIcon: Icons.check),
              onTap: () {
                Navigator.of(context, rootNavigator: true)
                    .push(MaterialPageRoute(
                        builder: (ctx) => TimesheetList(
                              status: "approved",
                            )));
              },
            ),
            // InkWell(
            //   child:timeSheetItem("Submitted timesheets", leadingIcon: Icons.send),
            //   onTap: (){
            //     Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (ctx) => TimesheetList(status: '',)));
            //   },
            // ),
            InkWell(
              child: timeSheetItem("Pending timesheets",
                  leadingIcon: Icons.pending,
                  hasbadge: widget.pendingCount > 0 ? true : false),
              onTap: () {
                Navigator.of(context, rootNavigator: true)
                    .push(MaterialPageRoute(
                        builder: (ctx) => TimesheetList(
                              status: "pending",
                            )));
              },
            ),
            InkWell(
              child: timeSheetItem("Need changes Timesheets",
                  leadingIcon: Icons.auto_fix_high),
              onTap: () {
                Navigator.of(context, rootNavigator: true)
                    .push(MaterialPageRoute(
                        builder: (ctx) => TimesheetList(
                              status: 'need_changes',
                            )));
              },
            ),
            InkWell(
              child: timeSheetItem("Escalated Timesheets",
                  leadingIcon: Icons.no_backpack_outlined),
              onTap: () {
                Navigator.of(context, rootNavigator: true)
                    .push(MaterialPageRoute(
                    builder: (ctx) => TimesheetList(
                      status: 'escalated',
                    )));
              },
            ),
            SizedBox(
              height: 16,
            ),
          ],
        ),
      ),
    );
  }

  timeSheetItem(String title,
      {required IconData leadingIcon, bool hasbadge = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, right: 8, left: 8, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 8,
          ),
          Icon(
            leadingIcon,
            color: AppColors.lightPrimaryColor,
          ),
          SizedBox(
            width: 8,
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold, color: AppColors.filedBorder),
          ),
          Expanded(
              child: Align(
            alignment: Alignment.centerRight,
            child: hasbadge
                ? badges.Badge(
                    position: badges.BadgePosition.topEnd(top: -5, end: 20),
                    showBadge: true,
                    ignorePointer: false,
                    onTap: () {},
                    badgeContent: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Text(
                          "${widget.pendingCount}",
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
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 20.0,
                      color: AppColors.lightPrimaryColor,
                    ),
                  )
                : Icon(
                    Icons.arrow_forward_ios,
                    size: 20.0,
                    color: AppColors.lightPrimaryColor,
                  ),
          ))
        ],
      ),
    );
  }
}
