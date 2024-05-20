import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:plumbata/net/model/cost_code.dart';
import 'package:plumbata/net/model/timesheet.dart';
import 'package:plumbata/net/model/worker.dart';
import 'package:plumbata/providers/user.dart';
import 'package:plumbata/utils/app_utils.dart';
import 'package:plumbata/utils/colors.dart';
import 'package:plumbata/utils/error_utils.dart';
import 'package:provider/provider.dart';
import 'package:search_choices/search_choices.dart';
import 'package:time_picker_sheet/widget/sheet.dart';
import 'package:time_picker_sheet/widget/time_picker.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'buttons.dart';

class TimesheetWorkCard extends StatefulWidget {
  const TimesheetWorkCard(
      {super.key,
      required this.worker,
      required this.costCodes,
      required this.afterDelete});
  final Worker? worker;
  final Function afterDelete;
  final List<CostCode> costCodes;

  @override
  State<TimesheetWorkCard> createState() => _TimesheetWorkCardState();
}

class _TimesheetWorkCardState extends State<TimesheetWorkCard> {
  late List<DropdownMenuItem<CostCode>> costCodesItems;
  late CostCode selectedCostCode;
  late UserProvider repo;
  CostCodeShift costCodeShift = CostCodeShift();

  @override
  void initState() {
    super.initState();
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
            child: Column(
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
                      AppUtils.capitalize(widget.worker?.firstName) +
                          " " +
                          AppUtils.capitalize(widget.worker?.lastName),
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: [
                        Text(
                          "Worker",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        InkWell(
                            onTap: () {
                              print("Delete Worker ... ");
                              if (widget.worker != null) {
                                repo.addRemoveWorkerToTimesheet(widget.worker!);
                              }
                              widget.afterDelete();
                            },
                            child: Icon(
                              Icons.delete,
                              color: AppColors.errorColor.withOpacity(0.6),
                            ))
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Cost codes",
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    IconButton(
                        onPressed: () {
                          addNewCostCode();
                        },
                        icon: Icon(
                          Icons.add,
                          color: AppColors.lightAccentColor,
                        ))
                  ],
                ),
                buildCostCodeOption(
                  title: "Cost code",
                  start: "Start",
                  finish: "Finish",
                  endText: "Break",
                  icon: Icons.code,
                ),
                for (CostCodeShift costCodeShift in (repo.uiTimeSheet
                        .workersCostCodes[widget.worker?.workerId ?? ""] ??
                    []))
                  buildCostCodeOption(
                      title: costCodeShift.costCode?.code ?? "N/A",
                      start:
                          "${costCodeShift.startTime?.hour}:${costCodeShift.startTime?.minute.toString().padLeft(2, '0')}",
                      finish:
                          "${costCodeShift.endTime?.hour}:${costCodeShift.endTime?.minute.toString().padLeft(2, '0')}",
                      icon: Icons.code,
                      endText:
                          "${AppUtils.formatMinutesToHHMM(costCodeShift.breakMins ?? 0)}",
                      hasDelete: true,
                      onPressDelete: () {
                        String workerId = widget.worker?.workerId ?? "";
                        int index = repo.uiTimeSheet.workersCostCodes[workerId]
                                ?.indexOf(costCodeShift) ??
                            -1;
                        if (index != -1) {
                          // Update the specific item in the list
                          repo.uiTimeSheet.workersCostCodes[workerId]
                              ?.removeAt(index);
                        }
                        setState(() {});
                      }),
                SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Total: ${calculateTotalWorkingHours()} HR",
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  calculateTotalWorkingHours() {
    int totalMins = 0;
    for (CostCodeShift costCodeShift
        in (repo.uiTimeSheet.workersCostCodes[widget.worker?.workerId ?? ""] ??
            [])) {
      Duration? difference = costCodeShift.endTime
          ?.difference(costCodeShift.startTime ?? DateTime.now());
      if (difference != null) {
        totalMins =
            totalMins + difference.inMinutes - (costCodeShift.breakMins ?? 0);
      }
    }

    int hours = totalMins ~/ 60;
    int minutes = totalMins % 60;

    String formattedTime = '$hours:${minutes.toString().padLeft(2, '0')}';

    return formattedTime;
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

  buildCostCodeOption(
      {required String title,
      required String start,
      required String finish,
      String? endText,
      required IconData icon,
      bool? hasDelete,
      Function? onPressDelete,
      Widget? subTitle}) {
    return Column(
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
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  start,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey, fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: Text(
                  finish,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey, fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: Text(endText ?? "",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey, fontWeight: FontWeight.w600)),
              ),
              hasDelete == true
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          child: Icon(Icons.remove,
                              color: AppColors.errorColor.withOpacity(0.6)),
                          onTap: () {
                            if (onPressDelete != null) {
                              onPressDelete();
                            }
                          },
                        ),
                      ],
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

  addNewCostCode() {
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
                        }),
                    SizedBox(
                      height: 16.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: PrimaryButton(
                        'Add Cost Code',
                        onPressed: () {
                          // Assume costCodeShift is the new cost code to be added
                          bool hasOverlap = false;
                          var costCodes = repo.uiTimeSheet.workersCostCodes[widget.worker?.workerId??""];

                          if (costCodes != null) {
                            for (var existingCostCodeShift in costCodes) {
                              bool overlaps = doTimeRangesOverlap(
                                existingCostCodeShift.startTime ?? DateTime.now(),
                                existingCostCodeShift.endTime ?? DateTime.now(),
                                costCodeShift.startTime ?? DateTime.now(),
                                costCodeShift.endTime ?? DateTime.now(),
                              );

                              if (overlaps) {
                                hasOverlap = true;
                                break; // Exit the loop early if overlap is found
                              }
                            }
                          }

// Check if endTime is before startTime
                          bool? isEndTimeBeforeStartTime = costCodeShift.endTime
                              ?.isBefore(costCodeShift.startTime ?? DateTime.now());

                          if (hasOverlap == true) {
                            // Show overlap error message
                            ErrorUtils.showGeneralError(context,
                                "The new cost code overlaps with an existing cost code. Please choose a different time range.",
                                duration: Duration(seconds: 4));
                          } else if (isEndTimeBeforeStartTime == true) {
                            // Show time range error message
                            ErrorUtils.showGeneralError(context,
                                "End time must be after start time. Please choose a valid time range.",
                                duration: Duration(seconds: 4));
                          } else {
                            // No overlap or time range error, add the new cost code
                            repo.uiTimeSheet
                                .workersCostCodes[widget.worker?.workerId ?? ""]
                                ?.add(CostCodeShift(
                                    startTime: costCodeShift.startTime,
                                    endTime: costCodeShift.endTime,
                                    breakMins: costCodeShift.breakMins,
                                    costCode: costCodeShift.costCode));

                            setState(() {});
                            Navigator.pop(context);
                            widget.afterDelete();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            }));
  }

  bool doTimeRangesOverlap(
      DateTime start1, DateTime end1, DateTime start2, DateTime end2) {
    return start1.isBefore(end2) && end1.isAfter(start2);
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
}
