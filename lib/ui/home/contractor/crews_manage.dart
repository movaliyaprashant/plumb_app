import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:plumbata/net/model/crew.dart';
import 'package:plumbata/net/model/worker.dart';
import 'package:plumbata/providers/user.dart';
import 'package:plumbata/ui/home/contractor/add_new_crew.dart';
import 'package:plumbata/ui/home/contractor/crew_details.dart';
import 'package:plumbata/ui/home/contractor/select_worker_crew_step.dart';
import 'package:plumbata/ui/widgets/appbar.dart';
import 'package:plumbata/ui/widgets/buttons.dart';
import 'package:plumbata/utils/app_utils.dart';
import 'package:plumbata/utils/colors.dart';
import 'package:plumbata/utils/fonts.dart';
import 'package:plumbata/utils/icons.dart';
import 'package:provider/provider.dart';

class ContractCrews extends StatefulWidget {
  const ContractCrews({super.key});

  @override
  State<ContractCrews> createState() => _ContractCrewsState();
}

class _ContractCrewsState extends State<ContractCrews> {
  late UserProvider userProvider;

  TextEditingController _fname = TextEditingController();
  TextEditingController _lname = TextEditingController();
  TextEditingController _classification = TextEditingController();
  bool _isLoading = false;

  List<Crew> crews = [];
  bool isLoading = false;

  String? validateError;

  @override
  void initState() {
    super.initState();
    userProvider = context.read<UserProvider>();
    getContractWorkers();
  }

  getContractWorkers() async {
    setState(() {
      isLoading = true;
    });
    crews = await userProvider.getContractCrews(
        contractId: userProvider.currentContract?.contractId ?? "");

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context, listen: true);

    return Scaffold(
        appBar: GeneralAppBar(title: "Contract Crews", backBtn: true),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            var data = await Navigator.push(
                context, MaterialPageRoute(builder: (ctx) => AddNewCrew()));
            getContractWorkers();
          },
          backgroundColor: AppColors.lightAccentColor,
          child: Icon(Icons.add),
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : crews.isEmpty
                ? Center(
                    child: Text(
                      "There's no crews yet",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: crews.length,
                    itemBuilder: (ctx, index) {
                      return CrewCard(crews[index]);
                    }));
  }

  CrewCard(Crew crew) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          CrewCardItem(crew),
        ],
      ),
    );
  }
  CrewCardItem(Crew crew){
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                crew.name ?? "N/A",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 18.0),
              ),
            ),
            Divider(),
            ListTile(
              title: Text(
                ((crew.workers?.length.toString()??"0") +" "+
                    "${crew.workers?.length == 1 || crew.workers?.length == 0 ? 'Worker':'Workers'}"),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.0),
              ),
            ),
            for(var worker in crew.workers??[])
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8,),
                    BuildWorkerName(worker: worker),
                  ],
                ),
              ),
            Container(
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SimpleOutlinedButton(
                        "Crew Details",
                        bgColor: AppColors.lightBorderColor
                            .withOpacity(0.5),
                        onPressed: () async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (ctx) => CrewDetails(
                                    crew: crew,
                                  )));
                          getContractWorkers();
                        },
                        textStyle: TextStyle(
                          color: Color(0xfff16075),
                          fontSize: 14,
                          fontFamily: kOpenSansFont,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SimpleOutlinedButton(
                        "Delete Crew",
                        bgColor: AppColors.lightBorderColor
                            .withOpacity(0.5),
                        onPressed: () {
                          AppUtils.showYesNoDialog(
                            context,
                            onYes: () async {
                              await userProvider.deleteCrew(crew.crewId);
                              getContractWorkers();
                            },
                          onNo: (){},
                              title: 'Delete Crew',
                              message: 'Are you sure you want to delete this crew?'
                          );
                        },
                        textStyle: TextStyle(
                          color: Color(0xfff16075),
                          fontSize: 14,
                          fontFamily: kOpenSansFont,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
