import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:plumbata/net/model/cost_code.dart';
import 'package:plumbata/net/model/crew.dart';
import 'package:plumbata/net/model/crew_time_sheet.dart';
import 'package:plumbata/net/model/timesheet.dart';
import 'package:plumbata/net/model/worker.dart';
import 'package:plumbata/providers/user.dart';
import 'package:plumbata/ui/home/contractor/add_new_crew.dart';
import 'package:plumbata/ui/home/contractor/crews_manage.dart';
import 'package:plumbata/ui/home/contractor/select_worker_crew_step.dart';
import 'package:plumbata/ui/widgets/add_new_worker_to_timesheet_crew.dart';
import 'package:plumbata/ui/widgets/buttons.dart';
import 'package:plumbata/utils/app_utils.dart';
import 'package:plumbata/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:search_choices/search_choices.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:time_picker_sheet/widget/sheet.dart';
import 'package:time_picker_sheet/widget/time_picker.dart';

class TimesheetCrewCard extends StatefulWidget {
  const TimesheetCrewCard(
      {super.key,
      required this.crewTimeSheet,
      required this.afterDelete,
      required this.costCodes});
  final Function afterDelete;
  final CrewTimeSheet crewTimeSheet;
  final List<CostCode> costCodes;

  @override
  State<TimesheetCrewCard> createState() => _TimesheetCrewCardState();
}

class _TimesheetCrewCardState extends State<TimesheetCrewCard> {
  bool isLoading = false;
  late CrewTimeSheet? crewTimeSheet;
  late UserProvider repo;
  late List<DropdownMenuItem<CostCode>> costCodesItems;
  CostCodeShift costCodeShift = CostCodeShift();
  late CostCode selectedCostCode;

  @override
  void initState() {
    super.initState();
    crewTimeSheet = widget.crewTimeSheet;
    repo = context.read<UserProvider>();

    costCodesItems = widget.costCodes.map((exNum) {
      return (DropdownMenuItem(value: exNum, child: Text(exNum.code ?? "N/A")));
    }).toList();

    costCodeShift.costCode = (repo.uiTimeSheet.defaultCostCodeShift?.costCode);

    if (costCodeShift.costCode != null) {
      selectedCostCode = costCodeShift.costCode!;
    } else {
      selectedCostCode = widget.costCodes[0];
    }

    costCodeShift.breakMins =
        (repo.uiTimeSheet.defaultCostCodeShift?.breakMins ?? 0);
    costCodeShift.startTime =
        (repo.uiTimeSheet.defaultCostCodeShift?.startTime);
    costCodeShift.endTime = (repo.uiTimeSheet.defaultCostCodeShift?.endTime);
  }

  updateCrew() async {
    setState(() {
      isLoading = true;
    });
    crewTimeSheet?.crew =
        (await repo.getContractCrewById(crewTimeSheet?.crew.crewId ?? "N/A"))!;

    int? index = repo.uiTimeSheet.crewTimeSheet?.indexWhere(
        (CrewTimeSheet c) => c.crew.crewId == crewTimeSheet?.crew.crewId);

    if (index != null &&
        index != -1 &&
        crewTimeSheet != null &&
        crewTimeSheet?.crew != null) {
      repo.uiTimeSheet.crewTimeSheet?[index] = crewTimeSheet!;
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator.adaptive(),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppUtils.capitalize(crewTimeSheet?.crew.name ?? ""),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Row(
                            children: [
                              Text(
                                "Crew",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              SizedBox(
                                width: 16.0,
                              ),
                              InkWell(
                                  onTap: () {
                                    if (crewTimeSheet != null) {
                                      print("Removing crew...");

                                      repo.addRemoveCrewToTimesheet(
                                          crewTimeSheet!.crew);
                                    }
                                    widget.afterDelete();
                                    setState(() {

                                    });
                                  },
                                  child: Icon(
                                    Icons.delete,
                                    color:
                                        AppColors.errorColor.withOpacity(0.6),
                                  )),
                            ],
                          ),
                        ],
                      ),
                      //SizedBox(height: 8,),
                      //Divider(thickness: 1,),
                      //buildOption(title: "Shift", hint: "Morning", icon: Icons.schedule),
                      Divider(
                        thickness: 1,
                      ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     Text(
                      //       "Cost codes",
                      //       style: Theme.of(context)
                      //           .textTheme
                      //           .bodyMedium
                      //           ?.copyWith(fontWeight: FontWeight.w600),
                      //     ),
                      //     IconButton(
                      //         onPressed: () {
                      //           // addNewCostCode();
                      //         },
                      //         icon: Icon(
                      //           Icons.add,
                      //           color: AppColors.lightAccentColor,
                      //         ))
                      //   ],
                      // ),
                      // buildOption(
                      //   title: "T001",
                      //   hint: "8:30 - 4:30",
                      //   icon: Icons.code,
                      // ),
                      // SizedBox(
                      //   height: 8.0,
                      // ),
                      // Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Crew Workers",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            InkWell(
                              onTap: () async {

                                showMaterialModalBottomSheet(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    context: context,
                                    builder: (context) => StatefulBuilder(
                                            builder: (BuildContext context,
                                                StateSetter setModalState) {
                                          return AddNewWorkerToTimeSheetCrew(
                                            costCodeShift: costCodeShift,
                                            onAddWorker: onAddWorkerToCrew,
                                            onDeleteWorker: onDeleteWorkerFromCrew,
                                            afterDone: () {
                                              setModalState(() {});
                                              setState(() {});
                                            },
                                            crewTimeSheet: crewTimeSheet,
                                          );
                                        }));
                              },
                              child: Text(
                                "Manage Workers",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      for (Worker worker in crewTimeSheet?.crewWorkers ?? [])
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BuildWorkerName(
                                  key: UniqueKey(),
                                  worker: worker,
                                  hasRemove: true,
                                  onDelete: () {
                                    if (crewTimeSheet != null) {
                                      // Remove from the list
                                      crewTimeSheet?.crewWorkers
                                          ?.remove(worker);

                                      // Remove from the map
                                      crewTimeSheet?.crewWorkersCostCodeShifts
                                          .remove(worker?.workerId);
                                    }

                                    int? index = repo.uiTimeSheet.crewTimeSheet
                                        ?.indexWhere((ct) =>
                                            ct.crew.crewId ==
                                            crewTimeSheet?.crew.crewId);
                                    if (index != null && index != -1) {
                                      // If the crewTimeSheet is found, replace it with the newCrewTimeSheet
                                      repo.uiTimeSheet.crewTimeSheet?[index] =
                                          crewTimeSheet!;

                                      crewTimeSheet = repo
                                          .uiTimeSheet.crewTimeSheet?[index];
                                    }
                                    widget.afterDelete();
                                  }),
                              buildCostCodeOption(
                                title: "Cost code",
                                start: "Start",
                                finish: "Finish",
                                endText: "Break",
                                worker: worker,
                                hasAdd: true,
                                icon: Icons.code,
                              ),
                              for (CostCodeShift costCodeShift
                                  in crewTimeSheet!.crewWorkersCostCodeShifts[
                                          worker.workerId ?? ""] ??
                                      [])
                                buildCostCodeOption(
                                    worker: worker,
                                    title:
                                        costCodeShift.costCode?.code ?? "N/A",
                                    start:
                                        "${costCodeShift.startTime?.hour}:${costCodeShift.startTime?.minute.toString().padLeft(2, '0')}",
                                    finish:
                                        "${costCodeShift.endTime?.hour}:${costCodeShift.endTime?.minute.toString().padLeft(2, '0')}",
                                    icon: Icons.code,
                                    endText:
                                        "${AppUtils.formatMinutesToHHMM(costCodeShift.breakMins ?? 0)}",
                                    hasDelete: true,
                                    onPressDelete: () {
                                      int? index = crewTimeSheet!
                                          .crewWorkersCostCodeShifts[
                                              worker.workerId ?? ""]
                                          ?.indexOf(costCodeShift);
                                      if (index != null && index != -1) {
                                        crewTimeSheet!
                                            .crewWorkersCostCodeShifts[
                                                worker.workerId ?? ""]
                                            ?.removeAt(index);
                                      }
                                      setState(() {});
                                    }),
                            ],
                          ),
                        ),
                      SizedBox(height: 16,),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text("Total: ${calculateTotalWorkingHours()} HR", style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600
                            ),),
                          ],
                        ),
                      ),
                      SizedBox(height: 16,),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  calculateTotalWorkingHours(){
    Iterable<String> keys = crewTimeSheet?.crewWorkersCostCodeShifts.keys ?? [];
    int totalMins = 0;
    for(String key in keys){
      List<CostCodeShift>? costCodeShifts = crewTimeSheet?.crewWorkersCostCodeShifts[key];
      for(CostCodeShift costCodeShift in costCodeShifts??[]){
        Duration? difference = costCodeShift.endTime?.difference(costCodeShift!.startTime??DateTime.now());
        if(difference != null){
          totalMins = totalMins + difference.inMinutes - (costCodeShift.breakMins??0);
        }
      }
    }
    int hours = totalMins ~/ 60;
    int minutes = totalMins % 60;

    String formattedTime = '$hours:${minutes.toString().padLeft(2, '0')}';

    return formattedTime;
  }
  onDeleteWorkerFromCrew(worker) {
    ////////
    var newCrewTimeSheet = crewTimeSheet;
    if (newCrewTimeSheet != null) {
      int? wIndex = newCrewTimeSheet.crewWorkers
          ?.indexWhere((Worker element) => element.workerId == worker.workerId);

      if (wIndex != null && wIndex != -1) {
        // Remove from the list
        newCrewTimeSheet.crewWorkers?.removeAt(wIndex);
      }
      // Remove from the map
      newCrewTimeSheet.crewWorkersCostCodeShifts.remove(worker?.workerId);
    }

    int? index = repo.uiTimeSheet.crewTimeSheet
        ?.indexWhere((ct) => ct.crew.crewId == newCrewTimeSheet?.crew.crewId);

    if (index != null && index != -1) {
      // If the crewTimeSheet is found, replace it with the newCrewTimeSheet
      repo.uiTimeSheet.crewTimeSheet?[index] = newCrewTimeSheet!;

      crewTimeSheet = repo.uiTimeSheet.crewTimeSheet?[index];
    }
    widget.afterDelete();
    ////////
  }

  onAddWorkerToCrew(worker) {
    var newCrewTimeSheet = crewTimeSheet;
    if (newCrewTimeSheet != null) {
      // Remove from the list
      newCrewTimeSheet.crewWorkers?.add(worker);

      CostCodeShift defaultCostCodeShift = CostCodeShift(
        costCode: repo.uiTimeSheet.costCode,
        startTime: repo.uiTimeSheet.startTime,
        endTime: repo.uiTimeSheet.endTime,
        breakMins:
            (repo.uiTimeSheet.breakHrs * 60) + repo.uiTimeSheet.breakMins,
      );

      // Remove from the map
      newCrewTimeSheet.crewWorkersCostCodeShifts[worker?.workerId] = [
        defaultCostCodeShift
      ];
    }

    int? index = repo.uiTimeSheet.crewTimeSheet
        ?.indexWhere((ct) => ct.crew.crewId == newCrewTimeSheet?.crew.crewId);

    if (index != null && index != -1) {
      // If the crewTimeSheet is found, replace it with the newCrewTimeSheet
      repo.uiTimeSheet.crewTimeSheet?[index] = newCrewTimeSheet!;

      crewTimeSheet = repo.uiTimeSheet.crewTimeSheet?[index];
    }
    widget.afterDelete();
  }

  buildOption(
      {required String title,
      required String hint,
      String? endText,
      required Function onTap,
      Widget? subTitle}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          onTap();
        },
        child: Row(
          children: [
            SizedBox(
              width: 8.0,
            ),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(
              width: 8.0,
            ),
            subTitle ?? SizedBox(),
            Text(
              hint,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey, fontWeight: FontWeight.w600),
            )
          ],
        ),
      ),
    );
  }

  buildCostCodeOption(
      {required String title,
      required String start,
      required String finish,
      required Worker worker,
      String? endText,
      required IconData icon,
      bool? hasDelete,
      Function? onPressDelete,
      bool hasAdd = false,
      Widget? subTitle}) {
    return Column(
      key: UniqueKey(),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  start,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey, fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: Text(
                  finish,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey, fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: Text(endText ?? "",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey, fontWeight: FontWeight.w600)),
              ),
              hasAdd
                  ? InkWell(
                      child: Icon(
                        Icons.add,
                        color: AppColors.lightAccentColor,
                      ),
                      onTap: () {
                        addNewCostCode(worker);
                      },
                    )
                  : SizedBox(),
              hasDelete == true
                  ? InkWell(
                      onTap: () {
                        if (onPressDelete != null) {
                          onPressDelete();
                        }
                      },
                      child: Icon(
                        Icons.remove,
                        color: AppColors.errorColor.withOpacity(0.8),
                      ),
                    )
                  : SizedBox()
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(),
        )
      ],
    );
  }

  addNewCostCode(Worker worker) {
    showMaterialModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        context: context,
        builder: (context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setModalState) {
              return Container(
                height: 400,
                child: Column(
                  children: [
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.arrow_back_ios)),
                        Expanded(
                            child: Center(
                                child: Text(
                          "Add New Cost Code",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ))),
                        Expanded(
                          child: SizedBox(
                            width: 4,
                          ),
                        )
                      ],
                    ),
                    buildCostCodeColumOption(
                        title: "Cost code",
                        hint: "",
                        icon: Icons.navigate_next,
                        subTitle: Container(
                          height: 70,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: SearchChoices.single(
                                  items: costCodesItems,
                                  value: selectedCostCode,
                                  hint: "Select Cost Code",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  searchHint: "Select Cost Code",
                                  searchFn: (String keyword, items) {
                                    List<int> ret = [];
                                    if (items != null && keyword.isNotEmpty) {
                                      keyword.split(" ").forEach((k) {
                                        int i = 0;
                                        items.forEach((item) {
                                          print(item.value.code);
                                          if (k.isNotEmpty &&
                                              (item.value.code
                                                  .toString()
                                                  .toLowerCase()
                                                  .contains(k.toLowerCase()))) {
                                            ret.add(i);
                                          }
                                          i++;
                                        });
                                      });
                                    }
                                    if (keyword.isEmpty) {
                                      ret = Iterable<int>.generate(items.length)
                                          .toList();
                                    }
                                    return (ret);
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      selectedCostCode = value;
                                      costCodeShift.costCode = value;
                                    });
                                    setModalState(() {});
                                    setState(() {});
                                  },
                                  dialogBox: true,
                                  isExpanded: true,
                                ),
                              ),
                            ],
                          ),
                        )),
                    buildOption(
                        title: "Start Time",
                        hint:
                            "${costCodeShift?.startTime?.hour}:${costCodeShift?.startTime?.minute.toString().padLeft(2, '0')}",
                        onTap: () {
                          selectTimeDate(
                              isStart: true,
                              afterDone: () {
                                setState(() {});
                                setModalState(() {});
                              });
                        }),
                    Divider(),
                    buildOption(
                        title: "End Time",
                        hint:
                            "${costCodeShift?.endTime?.hour}:${costCodeShift?.endTime?.minute.toString().padLeft(2, '0')}",
                        onTap: () {
                          selectTimeDate(
                              isStart: false,
                              afterDone: () {
                                setState(() {});
                                setModalState(() {});
                              });
                          setModalState(() {});
                          setState(() {});
                        }),
                    Divider(),
                    buildOption(
                      title: "Break",
                      hint:
                          "${AppUtils.formatMinutesToHHMM(costCodeShift.breakMins ?? 0)}",
                      onTap: () {
                        _openTimePickerSheet(context, () {
                          setModalState(() {});
                        });
                        setModalState(() {});
                      },
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: PrimaryButton(
                        'Add Cost Code',
                        onPressed: () {
                          int? index = repo.uiTimeSheet.crewTimeSheet
                              ?.indexOf(widget.crewTimeSheet);
                          if (index != null && index != -1) {
                            repo
                                .uiTimeSheet
                                .crewTimeSheet?[index]
                                .crewWorkersCostCodeShifts[
                                    worker.workerId ?? ""]
                                ?.add(CostCodeShift(
                                    startTime: costCodeShift.startTime,
                                    endTime: costCodeShift.endTime,
                                    breakMins: costCodeShift.breakMins,
                                    costCode: costCodeShift.costCode));
                          }

                          print(
                              " ===> ${repo.uiTimeSheet.crewTimeSheet?[index ?? 0].crewWorkersCostCodeShifts["2FjoWxsvGZBlbnzxJEuF"]?.map((e) => e.costCode?.code).toString()}");
                          setState(() {});
                          Navigator.pop(context);
                          widget.afterDelete();
                        },
                      ),
                    ),
                  ],
                ),
              );
            }));
  }

  buildCostCodeColumOption(
      {required String title,
      required String hint,
      String? endText,
      required IconData icon,
      Widget? subTitle}) {
    return ListTile(
      subtitle: subTitle ?? SizedBox(),
      leading: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
      title: Text(
        hint,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: Colors.grey, fontWeight: FontWeight.w600),
      ),
      trailing: endText == null
          ? SizedBox()
          : Text(endText,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey, fontWeight: FontWeight.w600)),
    );
  }

  selectTimeDate({required bool isStart, required afterDone}) {
    picker.DatePicker.showTimePicker(context,
        showSecondsColumn: false,
        showTitleActions: true,
        onChanged: (date) {}, onConfirm: (date) {
      setState(() {
        if (isStart) {
          costCodeShift.startTime = date;
        } else {
          costCodeShift.endTime = date;
        }
      });
      afterDone();
      widget.afterDelete();
    }, currentTime: isStart ? costCodeShift.startTime : costCodeShift.endTime);
  }

  void _openTimePickerSheet(BuildContext context, afterDone) async {
    final result = await TimePicker.show<DateTime?>(
      context: context,
      sheet: TimePickerSheet(
        sheetTitle: 'Select Break Time',
        minuteTitle: 'Minute',
        hourTitle: 'Hour',
        saveButtonText: 'Set Break Time',
        saveButtonColor: AppColors.lightPrimaryColor,
      ),
    );

    if (result != null) {
      costCodeShift.breakMins = (result.hour * 60) + result.minute;
      setState(() {});
      afterDone();
      widget.afterDelete();
    }
  }
}
