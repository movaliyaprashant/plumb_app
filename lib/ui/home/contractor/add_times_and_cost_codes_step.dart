import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:plumbata/net/model/cost_code.dart';
import 'package:plumbata/net/model/crew.dart';
import 'package:plumbata/net/model/crew_time_sheet.dart';
import 'package:plumbata/net/model/timesheet.dart';
import 'package:plumbata/net/model/worker.dart';
import 'package:plumbata/providers/user.dart';
import 'package:plumbata/ui/widgets/add_new_crew_sheet.dart';
import 'package:plumbata/ui/widgets/add_new_worker_sheet.dart';
import 'package:plumbata/ui/widgets/timesheet_crew_card.dart';
import 'package:plumbata/ui/widgets/timesheet_work_card.dart';
import 'package:provider/provider.dart';

class AddTimesAndCostCodesStep extends StatefulWidget {
  const AddTimesAndCostCodesStep({super.key, required this.costCodes});
  final List<CostCode> costCodes;

  @override
  State<AddTimesAndCostCodesStep> createState() =>
      _AddTimesAndCostCodesStepState();
}

class _AddTimesAndCostCodesStepState extends State<AddTimesAndCostCodesStep> {
  late UserProvider userProvider;
  bool preparedForAdjustStep = false;
  bool isLoading = false;
  late CostCode selectedCostCode;



  @override
  void initState() {
    super.initState();
    userProvider = context.read<UserProvider>();
    prepareDataForAdjustStep();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: CircularProgressIndicator.adaptive(),
          )
        : SingleChildScrollView(
            child: Column(
              children: [
                ListTile(
                  onTap: () {
                    picker.DatePicker.showDatePicker(context,
                        showTitleActions: true,
                        maxTime: DateTime.now(),
                        onChanged: (date) {}, onConfirm: (date) {
                      userProvider.uiTimeSheet.datePerformedOn = date;
                      setState(() {});
                    }, currentTime: userProvider.uiTimeSheet.datePerformedOn);
                  },
                  title: Text(
                    "Work Performed On",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  trailing: Icon(
                    Icons.date_range_outlined,
                    color: Color(0x68232121),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      formatDate(userProvider.uiTimeSheet.datePerformedOn ??
                          DateTime.now()),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Color(0x68232121),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Divider(
                  thickness: 2,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Workers",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold, fontSize: 18.0),
                      ),
                      IconButton(
                          onPressed: () {
                            showMaterialModalBottomSheet(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                context: context,
                                builder: (context) => StatefulBuilder(builder:
                                        (BuildContext context,
                                            StateSetter setModalState) {
                                      return AddNewWorkerToTimeSheet(
                                        afterDone: () {
                                          setState(() {});
                                        },
                                      );
                                    }));
                          },
                          icon: Icon(Icons.add))
                    ],
                  ),
                ),
                for (Worker w in userProvider.uiTimeSheet.workers ?? [])
                  TimesheetWorkCard(
                      worker: w,
                      costCodes: widget.costCodes,
                      afterDelete: () {
                        setState(() {});
                      }),
                Divider(
                  thickness: 2,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Crews",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      IconButton(
                          onPressed: () {
                            showMaterialModalBottomSheet(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                context: context,
                                builder: (context) => StatefulBuilder(builder:
                                        (BuildContext context,
                                            StateSetter setModalState) {
                                      return AddNewCrewToTimeSheet(
                                        afterDone: () async {
                                          await prepareDataForAdjustStep();
                                          setState(() {});
                                        },
                                      );
                                    }));
                          },
                          icon: Icon(Icons.add))
                    ],
                  ),
                ),
                for (CrewTimeSheet crewTimeSheet
                    in userProvider.uiTimeSheet.crewTimeSheet ?? [])
                  TimesheetCrewCard(
                    costCodes: widget.costCodes,
                    crewTimeSheet: crewTimeSheet,
                    afterDelete: () {
                      setState(() {});
                    },
                  ),
                SizedBox(
                  height: 64,
                )
              ],
            ),
          );
  }

  prepareDataForAdjustStep() async {
    setState(() {
      isLoading = true;
    });
    CostCodeShift defaultCostCodeShift = CostCodeShift(
      costCode: userProvider.uiTimeSheet.costCode,
      startTime: userProvider.uiTimeSheet.startTime,
      endTime: userProvider.uiTimeSheet.endTime,
      breakMins: (userProvider.uiTimeSheet.breakHrs * 60) +
          userProvider.uiTimeSheet.breakMins,
    );

    List<CrewTimeSheet> crewTimeSheets = [];
    for (Crew crew in userProvider.uiTimeSheet.crews) {
      int? index = userProvider.uiTimeSheet.crewTimeSheet?.indexWhere((
          element) => element.crew.crewId == crew.crewId);
      print(" crew index ${index}");
      if (index == null || index == -1) {
        Map<String, List<CostCodeShift>> crewWorkersCostCodeShifts = {};
        List<Worker> workers = [];
        for (DocumentReference ref in crew.workers ?? []) {
          var data = await ref.get();
          Worker worker = Worker.fromJson(data.data() as Map<String, dynamic>);
          workers.add(worker);
        }
        for (Worker worker in workers) {
          crewWorkersCostCodeShifts[worker.workerId ?? ""] = [
            defaultCostCodeShift
          ];
        }

        CrewTimeSheet crewTimeSheet = CrewTimeSheet(
            crewWorkers: workers,
            crew: crew,
            crewWorkersCostCodeShifts: crewWorkersCostCodeShifts);
        crewTimeSheets.add(crewTimeSheet);
      }else{
        if(index != -1) {
          //crewTimeSheets.add(userProvider.uiTimeSheet.crewTimeSheet![index]);
        }
      }
    }
    userProvider.uiTimeSheet.crewTimeSheet = [...?userProvider.uiTimeSheet.crewTimeSheet,...crewTimeSheets ];

    setState(() {
      isLoading = false;
    });
  }

  formatDate(DateTime dateTime) {
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }
}
