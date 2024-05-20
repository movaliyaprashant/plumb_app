import 'package:flutter/material.dart';
import 'package:plumbata/net/model/app_user.dart';
import 'package:plumbata/net/model/contract.dart';
import 'package:plumbata/providers/user.dart';
import 'package:plumbata/ui/widgets/appbar.dart';
import 'package:plumbata/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class ContractDetails extends StatefulWidget {
  const ContractDetails({super.key, required this.contract});
  final Contract? contract;
  @override
  State<ContractDetails> createState() => _ContractDetailsState();
}

class _ContractDetailsState extends State<ContractDetails> {
  late Contract? contract;
  late UserProvider userProvider;
  bool isLoading = false;
  List<AppUser?> users = [];
  List<AppUser?> contractorUsers = [];
  List<AppUser?> superIntendentUsers = [];

  @override
  void initState() {
    super.initState();
    contract = widget.contract;
    userProvider = context.read<UserProvider>();
    getContractUsers();
  }

  getContractUsers() async {
    setState(() {
      isLoading = true;
    });

    users = await userProvider.getContractUsersData();
    for (AppUser? appUser in users) {
      if (appUser?.role == "contractor") {
        contractorUsers.add(appUser);
      } else {
        superIntendentUsers.add(appUser);
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GeneralAppBar(
        title: "Contract Details",
        backBtn: true,
      ),
      body: isLoading ? Center(
        child: CircularProgressIndicator(),
      ): ListView(
        children: [
          SizedBox(
            height: 16.0,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 32,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16.0,
                      ),
                      Text(
                        "Title: ",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                      Text(
                        contract?.title ?? "",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16.0,
                      ),
                      Text(
                        "Code: ",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                      Text(
                        contract?.code ?? "",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16.0,
                      ),
                      Text(
                        "Project Number: ",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                      Text(
                        contract?.projectNumber ?? "",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 4.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16.0,
                      ),
                      Text(
                        "Vendor: ",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                      Text(
                        contract?.vendor ?? "",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16.0,
                      ),
                      Text(
                        "Address: ",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                      Flexible(
                        child: Text(
                          "${contract?.address}",
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16.0,
                      ),
                      Text(
                        "Work Location: ",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                      Text(
                        "${contract?.workLocation}",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16.0,
                      ),
                      Text(
                        "Contract status: ",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                      Text(
                        "${contract?.contractStatus}",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 16,
          ),
          _buildStepsCounter(context),
          SizedBox(
            height: 16,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(
              thickness: 2,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Contract Superintendents",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ),
          ),
          for(AppUser? appUser in superIntendentUsers)
            userListTile(appUser),


          SizedBox(height: 32,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(
              thickness: 2,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Contract Contractors",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ),
          ),
          for(AppUser? appUser in contractorUsers)
            userListTile(appUser),
        ],
      ),
    );
  }

  userListTile(AppUser? appUser) {
    return ListTile(
      leading: Stack(
        children: [
          ClipRRect(child: Container(height: 60, width: 60, color: Colors.grey,),
            borderRadius: BorderRadius.circular(30.0),
          ),
          CircleAvatar(
            radius: 30.0,
            backgroundImage: NetworkImage(appUser?.profileImage ??
                "https://firebasestorage.googleapis.com/v0/b/plumbata-prod.appspot.com/o/profileImages%2Fapp_logo.png?alt=media&token=f306f551-cb70-4367-918e-02fccfb24c87"),
            backgroundColor: Colors.transparent,
          ),
        ],
      ),
      title: Text(
        "${appUser?.firstName} ${appUser?.lastName}",
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(fontWeight: FontWeight.bold, color: Colors.black),
      ),
      subtitle: Text(
        "${(appUser?.phone)??""}",
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  Widget _buildStepsCounter(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    var _pointerValue = contract?.approvedHours?.toDouble() ?? 0.0;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.68,
            child: SfLinearGauge(
              maximum: contract?.estimatedHours?.toDouble() ?? 100.0,
              interval: contract?.estimatedHours?.toDouble() ?? 100.0,
              animateAxis: true,
              minorTicksPerInterval: 0,
              axisTrackStyle: LinearAxisTrackStyle(
                thickness: 32,
                borderWidth: 1,
                borderColor: brightness == Brightness.dark
                    ? const Color(0xff898989)
                    : Colors.grey[350],
                color: brightness == Brightness.light
                    ? const Color(0xffE8EAEB)
                    : const Color(0xff62686A),
              ),
              barPointers: <LinearBarPointer>[
                LinearBarPointer(
                    value: _pointerValue,
                    animationDuration: 3000,
                    thickness: 32,
                    color: const Color(0xff0DC9AB)),
                LinearBarPointer(
                    value: contract?.estimatedHours?.toDouble() ?? 100.0,
                    enableAnimation: false,
                    thickness: 25,
                    offset: 10,
                    color: Colors.transparent,
                    position: LinearElementPosition.outside,
                    child: Text('Contract Progress',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold, color: Colors.grey))),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 65),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Approved Hours',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    _pointerValue.toStringAsFixed(0),
                    style: const TextStyle(
                        fontSize: 24,
                        color: Color(0xff0DC9AB),
                        fontWeight: FontWeight.bold),
                  )
                ]),
          )
        ],
      ),
    );
  }
}
