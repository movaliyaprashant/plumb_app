import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plumbata/net/model/contract.dart';
import 'package:plumbata/providers/user.dart';
import 'package:plumbata/ui/home/contractor/cost_codes.dart';
import 'package:plumbata/ui/home/shifts/shifts_list.dart';
import 'dart:async';

import 'package:plumbata/ui/widgets/buttons.dart';
import 'package:plumbata/utils/colors.dart';
import 'package:plumbata/utils/fonts.dart';
import 'package:plumbata/utils/icons.dart';
import 'package:provider/provider.dart';

class CostCodeCard extends StatefulWidget {
  const CostCodeCard({super.key, required this.contract});
  final Contract? contract;
  @override
  State<CostCodeCard> createState() => _CostCodeCardState();
}

class _CostCodeCardState extends State<CostCodeCard> {
  late UserProvider userProvider;

  @override
  void initState() {
    super.initState();
    userProvider = context.read<UserProvider>();
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
                  Icons.price_change_outlined,
                  color: AppColors.lightAccentColor,
                  size: 30,
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  "Cost Code",
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
              onTap: () {
                if (userProvider.currentContract == null) {
                  showNoActiveContractDialog(context);
                } else {
                  Navigator.of(context, rootNavigator: true)
                      .push(MaterialPageRoute(builder: (ctx) {
                    return CostCodes();
                  }));
                }
              },
              child: contractItem( userProvider.isSuperIntendent() ?
              "Manage Cost Codes" : "Cost codes",
                  leadingIcon: Icons.price_change),
            ),
            Divider(),
            InkWell(
              onTap: () {
                if (userProvider.currentContract == null) {
                  showNoActiveContractDialog(context);
                } else {
                  Navigator.of(context, rootNavigator: true)
                      .push(MaterialPageRoute(builder: (ctx) {
                    return ShiftsList();
                  }));
                }
              },
              child: contractItem("Manage Shifts",
                  leadingIcon: Icons.work_history_outlined),
            ),
            // contractItem("Contract crews",
            //     leadingIcon: Icons.groups_sharp),
            SizedBox(
              height: 16,
            ),
          ],
        ),
      ),
    );
  }

  contractItem(String title, {required IconData leadingIcon}) {
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
            child: Icon(
              Icons.arrow_forward_ios,
              size: 20.0,
              color: AppColors.lightPrimaryColor,
            ),
          ))
        ],
      ),
    );
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
