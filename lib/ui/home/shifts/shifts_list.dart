import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:plumbata/net/model/shift.dart';
import 'package:plumbata/net/model/timesheet.dart';
import 'package:plumbata/providers/user.dart';
import 'package:plumbata/ui/widgets/appbar.dart';
import 'package:plumbata/ui/widgets/buttons.dart';
import 'package:plumbata/utils/app_utils.dart';
import 'package:plumbata/utils/colors.dart';
import 'package:plumbata/utils/error_utils.dart';
import 'package:plumbata/utils/fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:time_picker_sheet/widget/sheet.dart';
import 'package:time_picker_sheet/widget/time_picker.dart';

class ShiftsList extends StatefulWidget {
  const ShiftsList({super.key});

  @override
  State<ShiftsList> createState() => _ShiftsListState();
}

class _ShiftsListState extends State<ShiftsList> {
  late List<Shift> shifts;
  late UserProvider repo;
  bool isLoading = false;
  TextEditingController _shiftName = TextEditingController();

  @override
  void initState() {
    super.initState();
    repo = context.read<UserProvider>();
    getShifts();
  }

  getShifts() async {
    setState(() {
      isLoading = true;
    });

    shifts = await repo.getContractShifts();

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddNewShiftSheet();
        },
        backgroundColor: AppColors.lightPrimaryColor,
        child: Icon(Icons.add),
      ),
      appBar: GeneralAppBar(
        title: "Shifts",
        backBtn: true,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator.adaptive(),
            )
          : ListView.builder(
              itemCount: shifts.length,
              itemBuilder: (ctx, index) {
                DateTime now = DateTime.now();

                DateTime startTime = DateTime(
                    now.year,
                    now.month,
                    now.day,
                    int.parse(shifts[index]?.startTime?.split(":")[0] ?? "00"),
                    int.parse(shifts[index]?.startTime?.split(":")[1] ?? "00"));

                DateTime endTime = DateTime(
                    now.year,
                    now.month,
                    now.day,
                    int.parse(shifts[index]?.endTime?.split(":")[0] ?? "00"),
                    int.parse(shifts[index]?.endTime?.split(":")[1] ?? "00"));

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    child: Card(
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
                                (shifts[index].shiftName??"") +"${repo.currentContract?.defaultShiftId == shifts[index].shiftId ? " - Default" : ""}",
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
                                "Shift Time",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16.0),
                              ),
                              trailing: Text(
                                (shifts[index].startTime ?? "N/A") +
                                    " - " +
                                    (shifts[index].endTime ?? "N/A"),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16.0),
                              ),
                            ),
                            ListTile(
                              title: Text(
                                "Breaks",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16.0),
                              ),
                              trailing: Text(
                                (formatDuration(shifts[index].breaksMins)),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16.0),
                              ),
                            ),
                            ListTile(
                              title: Text(
                                "Total working hours",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16.0),
                              ),
                              trailing: Text(
                                AppUtils.calculateTotalDuration(
                                    startTime,
                                    endTime,
                                    (shifts[index]?.breaksMins ?? 0) ~/ 60,
                                    (shifts[index]?.breaksMins ?? 0) % 60),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16.0),
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
                                        "Edit",
                                        bgColor: AppColors.lightBorderColor
                                            .withOpacity(0.5),
                                        onPressed: () {
                                          showAddNewShiftSheet(
                                              isEdit: true,
                                              shift: shifts[index]);
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
                                        "Delete",
                                        bgColor: AppColors.lightBorderColor
                                            .withOpacity(0.5),
                                        onPressed: () {
                                          AppUtils.showYesNoDialog(
                                            context,
                                            onYes: () async {
                                              setState(() {
                                                isLoading = true;
                                              });

                                              await repo.deleteShift(
                                                  shifts[index].shiftId);

                                              await getShifts();

                                              setState(() {
                                                isLoading = false;
                                              });
                                            },
                                            onNo: () {
                                              //   Navigator.pop(context);
                                            },
                                            title: 'Are you sure?',
                                            message:
                                                "Are you sure you want to delete this shift?",
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
                                  repo.currentContract?.defaultShiftId ==
                                          shifts[index].shiftId
                                      ? SizedBox()
                                      : Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: SimpleOutlinedButton(
                                              "Presets",
                                              bgColor: AppColors
                                                  .lightBorderColor
                                                  .withOpacity(0.5),
                                              onPressed: () async {
                                                setState(() {
                                                  isLoading = true;
                                                });
                                                var result =
                                                    await repo.setShitAsDefault(
                                                        shifts[index]);
                                                if (result == true) {
                                                  ErrorUtils.showSuccessMessage(
                                                      context,
                                                      "Successfully set the shift as the default",);
                                                  repo.currentContract
                                                          ?.defaultShiftId =
                                                      shifts[index].shiftId;

                                                } else {
                                                  ErrorUtils.showGeneralError(
                                                      context,
                                                      "Unable to set the shift as the default",
                                                      duration:
                                                          Duration(seconds: 3));
                                                }

                                                setState(() {
                                                  isLoading = false;
                                                });
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
                    ),
                  ),
                );
              }),
    );
  }

  showAddNewShiftSheet({bool isEdit = false, Shift? shift}) {
    DateTime startTime = DateTime.now();
    startTime =
        DateTime(startTime.year, startTime.month, startTime.day, 0, 0, 0);

    DateTime endTime = DateTime.now();

    endTime = DateTime(endTime.year, endTime.month, endTime.day, 1, 0, 0);
    String errorMsg = '';

    int sheetBreakHrs = 0;
    int sheetBreakMins = 0;
    if (isEdit) {
      DateTime now = DateTime.now();
      startTime = DateTime(
          now.year,
          now.month,
          now.day,
          int.parse(shift?.startTime?.split(":")[0] ?? "00"),
          int.parse(shift?.startTime?.split(":")[1] ?? "00"));

      endTime = DateTime(
          now.year,
          now.month,
          now.day,
          int.parse(shift?.endTime?.split(":")[0] ?? "00"),
          int.parse(shift?.endTime?.split(":")[1] ?? "00"));

      sheetBreakHrs = (shift?.breaksMins ?? 0) ~/ 60;
      sheetBreakMins = (shift?.breaksMins ?? 0) % 60;

      _shiftName.text = shift?.shiftName ?? "";
    } else {
      _shiftName.clear();
    }
    showMaterialModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        context: context,
        builder: (context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setModalState) {
              String totalTime = AppUtils.calculateTotalDuration(
                  startTime, endTime, sheetBreakHrs, sheetBreakMins);
              return Container(
                  height: 600,
                  child: Column(children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 8, left: 16, right: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                              onPressed: () {
                                _shiftName.clear();
                                Navigator.pop(context);
                              },
                              icon: Icon(
                                Icons.arrow_back_ios,
                                color: AppColors.lightAccentColor,
                              )),
                          Text(
                            isEdit ? "Edit Shift" : "Add New Shift",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextFormField(
                        controller: _shiftName,
                        onChanged: (text) {
                          _shiftName.text = text.trimLeft();
                          setModalState(() {});
                        },
                        autocorrect: false,
                        maxLength: 40,
                        keyboardType: TextInputType.emailAddress,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            hintText: 'Shift Name',
                            prefixIcon: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Icon(Icons.schedule),
                            )),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Divider(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Container(
                        width: double.infinity,
                        child: InkWell(
                          onTap: () {
                            picker.DatePicker.showTimePicker(
                              context,
                              showSecondsColumn: false,
                              showTitleActions: true,
                              onChanged: (date) {
                                // Update the startTime if it's not after or equal to endTime
                                if (date.isAfter(endTime) ||
                                    date.isAtSameMomentAs(endTime)) {
                                  errorMsg =
                                      'Start time cannot be after or equal to finish time';
                                } else {
                                  errorMsg = '';
                                  startTime = date;
                                }
                                setState(() {});
                                setModalState(() {});
                              },
                              onConfirm: (date) {
                                // Handle the case when the user confirms the selected time
                                if (date.isAfter(endTime) ||
                                    date.isAtSameMomentAs(endTime)) {
                                  errorMsg =
                                      'Start time cannot be after or equal to finish time';
                                } else {
                                  errorMsg = '';
                                }
                                setState(() {});
                                startTime = date;
                                setModalState(() {});
                              },
                              currentTime: startTime,
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Start time",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  Text(
                                    "${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Icon(Icons.arrow_forward_ios)
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Divider(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Container(
                        width: double.infinity,
                        child: InkWell(
                          onTap: () {
                            picker.DatePicker.showTimePicker(
                              context,
                              showSecondsColumn: false,
                              showTitleActions: true,
                              onChanged: (date) {
                                // Update the endTime if it's not before or equal to startTime
                                if (date.isBefore(startTime) ||
                                    date.isAtSameMomentAs(startTime)) {
                                  errorMsg =
                                      'Finish time cannot be before or equal to start time';
                                } else {
                                  errorMsg = '';
                                }
                                endTime = date;
                                setState(() {});
                                setModalState(() {});
                              },
                              onConfirm: (date) {
                                // Handle the case when the user confirms the selected time
                                if (date.isBefore(startTime) ||
                                    date.isAtSameMomentAs(startTime)) {
                                  errorMsg =
                                      'Finish time cannot be before or equal to start time';
                                } else {
                                  errorMsg = '';
                                  endTime = date;
                                }
                                setState(() {});
                                setModalState(() {});
                              },
                              currentTime: endTime,
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Finish Time",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  Text(
                                    "${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Icon(Icons.arrow_forward_ios)
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Container(
                        width: double.infinity,
                        child: InkWell(
                          onTap: () {
                            _openTimePickerSheet(context, onSet: (result) {
                              sheetBreakHrs = result.hour;
                              sheetBreakMins = result.minute;
                              setState(() {});
                              setModalState(() {});
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Break Duration",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  Text(
                                    "${sheetBreakHrs.toString()}:${sheetBreakMins.toString().padLeft(2, '0')}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Icon(Icons.arrow_forward_ios)
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Text(
                            "Total working hours",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Spacer(),
                          Text(
                            "${totalTime} hrs",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: totalTime.startsWith("-")
                                        ? AppColors.errorColor
                                        : AppColors.lightPrimaryColor),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Icon(Icons.schedule)
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Divider(),
                    SizedBox(
                      height: 4,
                    ),
                    errorMsg == ''
                        ? SizedBox()
                        : ListTile(
                            title: Text(
                              errorMsg,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16.0,
                                    color: AppColors.errorColor,
                                  ),
                            ),
                            trailing: Icon(
                              Icons.error_outline,
                              color: AppColors.errorColor,
                            ),
                          ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: PrimaryButton(
                        isEdit ? "Edit Shift" : 'Add Shift',
                        enabled:
                            !(totalTime.startsWith("-") || errorMsg != '') &&
                                _shiftName.text.toString().trim().isNotEmpty,
                        isLoading: isLoading,
                        onPressed: () async {
                          if (isEdit) {
                            await repo.editShift(
                                shiftId: shift?.shiftId,
                                breakHrs: sheetBreakHrs,
                                breakMins: sheetBreakMins,
                                startTime: startTime,
                                endTime: endTime,
                                shiftName: _shiftName.text.trim());
                          } else {
                            await repo.addNewShift(
                                breakHrs: sheetBreakHrs,
                                breakMins: sheetBreakMins,
                                startTime: startTime,
                                endTime: endTime,
                                shiftName: _shiftName.text.trim());
                          }
                          Navigator.pop(context);
                          _shiftName.clear();
                          getShifts();
                        },
                      ),
                    ),
                    SizedBox(
                      height: 32.0,
                    )
                  ]));
            }));
  }

  void _openTimePickerSheet(BuildContext context, {Function? onSet}) async {
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
      if (onSet != null) {
        onSet(result);
      }
    }
  }

  String formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes mins';
    } else {
      int hours = minutes ~/ 60;
      int remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours hour${hours > 1 ? 's' : ''}';
      } else {
        return '$hours hour${hours > 1 ? 's' : ''} $remainingMinutes mins';
      }
    }
  }
}
