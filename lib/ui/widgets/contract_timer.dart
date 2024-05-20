import 'package:flutter/material.dart';
import 'package:plumbata/providers/user.dart';
import 'package:plumbata/ui/home/contractor/contract_details.dart';
import 'package:plumbata/ui/home/super_intenedent/create_contract.dart';
import 'dart:async';

import 'package:plumbata/ui/widgets/buttons.dart';
import 'package:plumbata/utils/colors.dart';
import 'package:plumbata/utils/fonts.dart';
import 'package:provider/provider.dart';

class ContractTimer extends StatefulWidget {
  const ContractTimer({super.key, required this.contractLocation});
  final String contractLocation;
  @override
  State<ContractTimer> createState() => _ContractTimerState();
}

class _ContractTimerState extends State<ContractTimer> {
  DateTime time = DateTime.now();
  late Timer timer;
  late UserProvider userProvider;

  @override
  void initState() {
    super.initState();
    userProvider = context.read<UserProvider>();

    timer = Timer.periodic(Duration(minutes: 1), (timer) {
      setState(() {
        time = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    // Dispose of the timer when the widget is removed
    timer.cancel();
    super.dispose();
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
            SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "${time.hour}:${time.minute.toString().padLeft(2, '0')}",
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Center(
                      child: Text(
                        "${widget.contractLocation}",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.lightBorderColor),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SimpleOutlinedButton(
                "Contract Details",
                bgColor: AppColors.lightBorderColor.withOpacity(0.5),
                onPressed: onPressed,
                textStyle: TextStyle(
                  color: Color(0xfff16075),
                  fontSize: 16,
                  fontFamily: kOpenSansFont,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            userProvider.isSuperIntendent() ? Row(
              children: [
                // Expanded(
                //   child: Padding(
                //     padding: const EdgeInsets.all(8.0),
                //     child: SimpleOutlinedButton(
                //       "Edit Contract",
                //       bgColor: AppColors.lightBorderColor.withOpacity(0.5),
                //       onPressed: editContract,
                //       textStyle: TextStyle(
                //         color: Color(0xfff16075),
                //         fontSize: 14,
                //         fontFamily: kOpenSansFont,
                //         fontWeight: FontWeight.w800,
                //       ),
                //     ),
                //   ),
                // ),
                // SizedBox(width: 16,),
                // Expanded(
                //   child: Padding(
                //     padding: const EdgeInsets.all(8.0),
                //     child: SimpleOutlinedButton(
                //       "New Contract",
                //       bgColor: AppColors.lightBorderColor.withOpacity(0.5),
                //       onPressed: (){
                //         Navigator.of(context, rootNavigator: true)
                //             .push(MaterialPageRoute(builder: (ctx) => CreateContract()));
                //       },
                //       textStyle: TextStyle(
                //         color: Color(0xfff16075),
                //         fontSize: 16,
                //         fontFamily: kOpenSansFont,
                //         fontWeight: FontWeight.w800,
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ):SizedBox(),
          ],
        ),
      ),
    );
  }

  void editContract(){

    if (userProvider.currentContract == null) {
      showNoActiveContractDialog(context);
    } else {
      Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
          builder: (ctx) => CreateContract(
            isEdit: true,
            contract: userProvider.currentContract,
          )));
    }
  }
  void onPressed() {

    if (userProvider.currentContract == null) {
      showNoActiveContractDialog(context);
    } else {
      Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
          builder: (ctx) => ContractDetails(
                contract: userProvider.currentContract,
              )));
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
