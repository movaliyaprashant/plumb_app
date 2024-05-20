import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:plumbata/net/model/contract.dart';
import 'package:plumbata/net/model/cost_code.dart';
import 'package:plumbata/net/model/shift.dart';
import 'package:plumbata/net/model/timesheet.dart';
import 'package:plumbata/providers/user.dart';
import 'package:plumbata/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:time_picker_sheet/widget/sheet.dart';
import 'package:time_picker_sheet/widget/time_picker.dart';

class SelectShift extends StatefulWidget {
  const SelectShift(
      {super.key,
      required this.timeSheet,
      required this.afterUpdate,
      this.isEdit = false,
      this.editShift,
      this.editTimesheet});

  final UiTimeSheet timeSheet;
  final Function afterUpdate;
  final bool? isEdit;
  final Shift? editShift;
  final TimeSheet? editTimesheet;

  @override
  State<SelectShift> createState() => _SelectShiftState();
}

class _SelectShiftState extends State<SelectShift> {
  DateTime datePerformedOn = DateTime.now();
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();
  late UserProvider repo;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit == false) {
      widget.timeSheet.datePerformedOn = datePerformedOn;
    } else {
      // widget.timeSheet.datePerformedOn = datePerformedOn;
      datePerformedOn = widget.timeSheet.datePerformedOn ?? DateTime.now();
      startTime = widget.timeSheet.startTime ?? DateTime.now();
      endTime = widget.timeSheet.endTime ?? DateTime.now();
    }
    repo = context.read<UserProvider>();
    getCostCodes();
  }

  getCostCodes() async {
    setState(() {
      isLoading = true;
    });
    //need to be the selected contract

    await repo.getCostCodes(contractId: repo.currentContract?.contractId ?? "");
    await repo.getContractShifts();

    if (widget.isEdit == false) {
      widget.timeSheet.contract = repo.contracts?[0];
      widget.timeSheet.costCode = repo.costcodes?[0];
      widget.timeSheet.shift = repo.shifts?[0];

      List<String>? startParts = widget.timeSheet.shift?.startTime?.split(":");
      int startHour = int.parse(startParts?[0] ?? "0");
      int startMins = int.parse(startParts?[1] ?? "0");

      widget.timeSheet.breakHrs =
          (widget.timeSheet.shift?.breaksMins ?? 0) ~/ 60;
      widget.timeSheet.breakMins =
          (widget.timeSheet.shift?.breaksMins ?? 0) % 60;

      widget.timeSheet.startTime = DateTime(datePerformedOn.year,
          datePerformedOn.month, datePerformedOn.day, startHour, startMins);

      List<String>? endParts = widget.timeSheet.shift?.endTime?.split(":");
      int endHour = int.parse(endParts?[0] ?? "0");
      int endMins = int.parse(endParts?[1] ?? "0");

      widget.timeSheet.endTime = DateTime(datePerformedOn.year,
          datePerformedOn.month, datePerformedOn.day, endHour, endMins);
    } else {
      var contractData = await widget.editTimesheet?.contract.get();
      if(contractData?.exists == true){
        Contract contract = Contract.fromJson(contractData?.data() as Map<String, dynamic>);
        widget.timeSheet.contract = contract;
      }

      var costCodeData = await widget.editTimesheet?.costCode.get();
      if(costCodeData?.exists == true){
        CostCode costCode = CostCode.fromJson(costCodeData?.data() as Map<String, dynamic>);
        widget.timeSheet.costCode = costCode;
      }

      var shiftData = await widget.editTimesheet?.shift.get();
      if(shiftData?.exists == true){
        Shift shift = Shift.fromJson(shiftData?.data() as Map<String, dynamic>);
          widget.timeSheet.shift = shift;
      }

      List<String>? startParts = widget.timeSheet.shift?.startTime?.split(":");
      int startHour = int.parse(startParts?[0] ?? "0");
      int startMins = int.parse(startParts?[1] ?? "0");

      widget.timeSheet.breakHrs =
          (widget.timeSheet.shift?.breaksMins ?? 0) ~/ 60;
      widget.timeSheet.breakMins =
          (widget.timeSheet.shift?.breaksMins ?? 0) % 60;

      widget.timeSheet.startTime = DateTime(datePerformedOn.year,
          datePerformedOn.month, datePerformedOn.day, startHour, startMins);

      List<String>? endParts = widget.timeSheet.shift?.endTime?.split(":");
      int endHour = int.parse(endParts?[0] ?? "0");
      int endMins = int.parse(endParts?[1] ?? "0");

      widget.timeSheet.endTime = DateTime(datePerformedOn.year,
          datePerformedOn.month, datePerformedOn.day, endHour, endMins);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: CircularProgressIndicator.adaptive(),
          )
        : Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  buildOption(
                    title: "Work Performed On",
                    hint:
                        "${datePerformedOn.day}/${datePerformedOn.month}/${datePerformedOn.year}",
                    icon: Icons.calendar_month_sharp,
                    onTap: () {
                      picker.DatePicker.showDatePicker(context,
                          showTitleActions: true,
                          maxTime: DateTime.now(),
                          onChanged: (date) {}, onConfirm: (date) {
                        datePerformedOn = date;
                        widget.timeSheet.datePerformedOn = datePerformedOn;
                        setState(() {});
                        widget.afterUpdate();
                      }, currentTime: datePerformedOn);
                    },
                  ),
                  Divider(
                    thickness: 1,
                  ),
                  buildOption(
                      title: "Contract",
                      hint: widget.timeSheet.contract?.title ?? "",
                      icon: Icons.navigate_next,
                      onTap: () {
                        showChooseContractSheet();
                      }),
                  Divider(
                    thickness: 1,
                  ),
                  buildOption(
                      title: "Shift",
                      hint: widget.timeSheet.shift?.shiftName ?? "",
                      icon: Icons.navigate_next,
                      onTap: () {
                        showChooseShiftSheet();
                      }),
                  Divider(
                    thickness: 1,
                  ),
                  buildOption(
                      title: "Start Time",
                      hint:
                          "${widget.timeSheet.startTime?.hour}:${widget.timeSheet.startTime?.minute.toString().padLeft(2, '0')}",
                      icon: Icons.timelapse_outlined,
                      onTap: () {
                        selectTimeDate(isStart: true);
                      }),
                  Divider(
                    thickness: 1,
                  ),
                  buildOption(
                      title: "End Time",
                      hint:
                          "${widget.timeSheet.endTime?.hour}:${widget.timeSheet.endTime?.minute.toString().padLeft(2, '0')}",
                      icon: Icons.timelapse_outlined,
                      onTap: () {
                        selectTimeDate(isStart: false);
                      }),
                  Divider(
                    thickness: 1,
                  ),
                  buildOption(
                      title: "Break",
                      hint:
                          "${widget.timeSheet.breakHrs}:${widget.timeSheet.breakMins}",
                      icon: Icons.timelapse_outlined,
                      onTap: () {
                        _openTimePickerSheet(context);
                      }),
                  Divider(
                    thickness: 1,
                  ),
                  buildOption(
                      title: "Cost code",
                      hint: widget.timeSheet.costCode?.code ?? "",
                      icon: Icons.code,
                      onTap: () {
                        showChooseCostCodeSheet();
                      }),
                  SizedBox(
                    height: 16.0,
                  ),
                  widget.timeSheet.startTime?.isAfter(
                              widget.timeSheet.endTime ?? DateTime.now()) ==
                          true
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            "End time can not be before start time, please fix the start and end times",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.errorColor),
                          ),
                        )
                      : SizedBox()
                ],
              ),
            ),
          );
  }

  buildOption(
      {required String title,
      required String hint,
      required IconData icon,
      required Function onTap}) {
    return ListTile(
      onTap: () {
        onTap();
      },
      title: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize
            .min, // Set the mainAxisSize to min to avoid occupying the entire ListTile width
        children: [
          Text(
            hint,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey),
          ),
          SizedBox(width: 8),
          Icon(icon),
        ],
      ),
    );
  }

  showChooseContractSheet() {
    showMaterialModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        context: context,
        builder: (context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setModalState) {
              return Container(
                height: 600,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios),
                            onPressed: () {
                              Navigator.pop(context);
                              widget.afterUpdate();
                            },
                          ),
                          Text(
                            "Select Contract",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    for (Contract? contract in repo.contracts ?? [])
                      ListTile(
                        title: Text(
                          contract?.title ?? "N/A",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        trailing: contract == repo.currentContract
                            ? Icon(
                                Icons.check,
                                color: Colors.green,
                              )
                            : SizedBox(),
                      ),
                  ],
                ),
              );
            }));
  }

  showChooseShiftSheet() {
    showMaterialModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        context: context,
        builder: (context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setModalState) {
              return Container(
                height: 600,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios),
                            onPressed: () {
                              Navigator.pop(context);
                              widget.afterUpdate();
                            },
                          ),
                          Text(
                            "Select Shift",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    for (Shift? shift in repo.shifts ?? [])
                      ListTile(
                        onTap: () {
                          widget.timeSheet.shift = shift;

                          List<String>? startParts =
                              widget.timeSheet.shift?.startTime?.split(":");
                          int startHour = int.parse(startParts?[0] ?? "0");
                          int startMins = int.parse(startParts?[1] ?? "0");

                          widget.timeSheet.startTime = DateTime(
                              datePerformedOn.year,
                              datePerformedOn.month,
                              datePerformedOn.day,
                              startHour,
                              startMins);

                          List<String>? endParts =
                              widget.timeSheet.shift?.endTime?.split(":");
                          int endHour = int.parse(endParts?[0] ?? "0");
                          int endMins = int.parse(endParts?[1] ?? "0");

                          widget.timeSheet.endTime = DateTime(
                              datePerformedOn.year,
                              datePerformedOn.month,
                              datePerformedOn.day,
                              endHour,
                              endMins);

                          widget.timeSheet.breakHrs =
                              (widget.timeSheet.shift?.breaksMins ?? 0) ~/ 60;
                          widget.timeSheet.breakMins =
                              (widget.timeSheet.shift?.breaksMins ?? 0) % 60;

                          setState(() {});
                          setModalState(() {});
                          Navigator.pop(context);
                          widget.afterUpdate();
                        },
                        title: Text(
                          shift?.shiftName ?? "N/A",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        trailing: widget.timeSheet.shift == shift
                            ? Icon(
                                Icons.check,
                                color: Colors.green,
                              )
                            : SizedBox(),
                      ),
                  ],
                ),
              );
            }));
  }

  showChooseCostCodeSheet() {
    showMaterialModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        context: context,
        builder: (context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setModalState) {
              return Container(
                height: 600,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          Text(
                            "Select Cost Code",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    for (CostCode? costCode in repo.costcodes ?? [])
                      ListTile(
                        onTap: () {
                          widget.timeSheet.costCode = costCode;
                          setState(() {});
                          setModalState(() {});
                          Navigator.pop(context);
                          widget.afterUpdate();
                        },
                        title: Text(
                          costCode?.code ?? "N/A",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        trailing: widget.timeSheet.costCode == costCode
                            ? Icon(
                                Icons.check,
                                color: Colors.green,
                              )
                            : SizedBox(),
                      ),
                  ],
                ),
              );
            }));
  }

  selectTimeDate({required bool isStart}) {
    picker.DatePicker.showTimePicker(context,
        showSecondsColumn: false,
        showTitleActions: true,
        onChanged: (date) {}, onConfirm: (date) {
      setState(() {
        if (isStart) {
          startTime = date;
          widget.timeSheet.startTime = startTime;
        } else {
          endTime = date;
          widget.timeSheet.endTime = endTime;
        }
      });
      widget.afterUpdate();
    }, currentTime: isStart ? startTime : endTime);
  }

  void _openTimePickerSheet(BuildContext context) async {
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
      repo.uiTimeSheet.breakHrs = result.hour;
      repo.uiTimeSheet.breakMins = result.minute;
      setState(() {});
      widget.afterUpdate();
    }
  }
}
