import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fine_stepper/fine_stepper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:plumbata/net/model/cost_code.dart';
import 'package:plumbata/net/model/crew.dart';
import 'package:plumbata/net/model/crew_time_sheet.dart';
import 'package:plumbata/net/model/time_table_item.dart';
import 'package:plumbata/net/model/timesheet.dart';
import 'package:plumbata/net/model/worker.dart';
import 'package:plumbata/providers/user.dart';
import 'package:plumbata/services/files/types.dart';
import 'package:plumbata/ui/home/contractor/add_times_and_cost_codes_step.dart';
import 'package:plumbata/ui/home/contractor/create_timesheet/add_commet_to_timesheet.dart';
import 'package:plumbata/ui/home/contractor/select_shift.dart';
import 'package:plumbata/ui/home/contractor/select_worker_crew_step.dart';
import 'package:plumbata/ui/widgets/add_new_crew_sheet.dart';
import 'package:plumbata/ui/widgets/add_new_worker_sheet.dart';
import 'package:plumbata/ui/widgets/appbar.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:plumbata/ui/widgets/dropdown_crew_worker.dart';
import 'package:plumbata/ui/widgets/timesheet_crew_card.dart';
import 'package:plumbata/ui/widgets/timesheet_work_card.dart';
import 'package:plumbata/utils/app_utils.dart';
import 'package:plumbata/utils/colors.dart';
import 'package:plumbata/utils/error_utils.dart';
import 'package:provider/provider.dart';
import 'package:time_picker_sheet/widget/sheet.dart';
import 'package:time_picker_sheet/widget/time_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({Key? key, this.isEdit = false, this.timesheet})
      : super(key: key);
  final bool isEdit;
  final TimeSheet? timesheet;

  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  late UserProvider userProvider;
  int currentPageIndex = 0;
  DateTime datePerformedOn = DateTime.now();

  bool preparedForAdjustStep = false;
  bool isLoading = false;
  List<XFile> files = [];

  List<TimeTableItem> timeTableItems = [];
  List<Worker> workers = [];
  List<Crew> crews = [];
  List<CostCode> costCodes = [];

  int workerCrewIndex = 0;

  getContractWorkers() async {
    setState(() {
      isLoading = true;
    });
    workers = await userProvider.getContractWorkers(
        contractId: userProvider.currentContract?.contractId ?? "");

    crews = await userProvider.getContractCrews(
        contractId: userProvider.currentContract?.contractId ?? "");

    costCodes = await userProvider.getCostCodes(
        contractId: userProvider.currentContract?.contractId ?? "");

    setState(() {
      isLoading = false;
    });
  }

  prepareForEdit() async {
    if (widget.isEdit == true) {
      datePerformedOn = widget.timesheet?.datePerformedOn ?? DateTime.now();
      userProvider.uiTimeSheet.datePerformedOn =
          widget.timesheet?.datePerformedOn ?? DateTime.now();

      var costCodeData = await widget.timesheet!.costCode.get();
      CostCode code =
          CostCode.fromJson(costCodeData.data() as Map<String, dynamic>);

      CostCodeShift defaultCostCodeShift = CostCodeShift(
        costCode: code,
        startTime: widget.timesheet?.startTime,
        endTime: widget.timesheet?.endTime,
        breakMins: (widget.timesheet?.breakHrs ?? 0 * 60) +
            (widget.timesheet?.breakMins ?? 0),
      );
      // create uiTimeSheet
      userProvider.uiTimeSheet.defaultCostCodeShift = defaultCostCodeShift;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    userProvider = context.read<UserProvider>();
    prepareForEdit();
    getContractWorkers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: GeneralAppBar(
          title: 'Add New Timesheet',
          backBtn: true,
          onBack: () {
            userProvider.cleanUiTimesheet();
          },
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator.adaptive(),
              )
            : SafeArea(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 16,
                      ),
                      Expanded(
                        child: FineStepper.linear(
                          indicatorOptions: IndicatorOptions(
                              activeStepColor: AppColors.lightAccentColor,
                              completedStepColor: AppColors.lightPrimaryColor),
                          steps: [
                            StepItem.linear(
                              builder: buildFormStep,
                              title: 'Select Shifts',
                            ),
                            StepItem.linear(
                              builder: buildFormStep,
                              title: 'Select Workers or Crews',
                            ),
                            StepItem.linear(
                              builder: buildFormStep,
                              title: 'Adjust Timesheet',
                            ),
                            StepItem.linear(
                              builder: buildFormStep,
                              title: 'Add Files',
                            ),
                            StepItem.linear(
                              builder: buildFormStep,
                              title: 'Add Comments',
                            ),
                          ],
                        ),
                      ),
                      //Get all fields of form
                    ]),
              ));
  }

  Widget buildFormStep(BuildContext context) {
    Widget child = SizedBox();
    if (FineStepper.of(context).stepIndex == 0) {
      child = SelectShift(
        editTimesheet: widget.timesheet,
        isEdit: widget.isEdit,
        timeSheet: userProvider.uiTimeSheet,
        editShift: userProvider.uiTimeSheet.shift,
        afterUpdate: () {
          setState(() {});
        },
      );
    }
    if (FineStepper.of(context).stepIndex == 1) {
      child = SelectWorkerOrCrew(
        isEdit: widget.isEdit,
        editTimesheet: widget.timesheet,
      );
    } else if (FineStepper.of(context).stepIndex == 2) {
      child = addTimesAndCostCodes(isTime: true);
    } else if (FineStepper.of(context).stepIndex == 3) {
      child = addFiles();
    } else if (FineStepper.of(context).stepIndex == 4) {
      child = AddCommentToTimeSheet(
        previousComment: widget.timesheet?.comment ?? "",
      );
    }

    return Column(
      children: [
        Expanded(child: child),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FineStepper.of(context).isFirstStep
                  ? SizedBox()
                  : ElevatedButton(
                      onPressed: () {
                        // Add your button click logic here
                        if (FineStepper.of(context).isFirstStep) {
                          Navigator.of(context).pop();
                        }
                        if (!FineStepper.of(context).isFirstStep) {
                          FineStepper.of(context).stepBack();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor:
                            AppColors.lightPrimaryColor, // Text color
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(20.0), // Rounded corners
                        ),
                      ),
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        child: Text(
                          'Back',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
              ElevatedButton(
                onPressed: () {
                  // Add your button click logic here
                  if (!FineStepper.of(context).isLastStep) {
                    bool valid = validateStep(context);
                    if (valid) {
                      FineStepper.of(context).stepForward();
                    }
                  } else {
                    submitTimeSheet(isEdit: widget.isEdit);
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.lightPrimaryColor, // Text color
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(20.0), // Rounded corners
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Text(
                    FineStepper.of(context).isLastStep
                        ? widget.isEdit
                            ? "Resubmit Timesheet"
                            : "Submit Timesheet"
                        : 'Next',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  addTimesAndCostCodes({required bool isTime}) {
    return AddTimesAndCostCodesStep(
      costCodes: costCodes,
    );
  }

  showTimeSheetBottomSheet({Worker? worker, Crew? crew}) {
    DateTime sheetStartTime = DateTime.now();
    DateTime sheetEndTime = DateTime.now();
    int sheetBreakHrs = 0;
    int sheetBreakMins = 0;

    showMaterialModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        context: context,
        builder: (context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setModalState) {
              return Container(
                height: 600,
                child: ListView(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.arrow_back_ios)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            "Add Times",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Select Start Time",
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 60,
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.grey,
                          ),
                          child: InkWell(
                            onTap: () {
                              picker.DatePicker.showTimePicker(context,
                                  showSecondsColumn: false,
                                  showTitleActions: true,
                                  onChanged: (date) {}, onConfirm: (date) {
                                sheetStartTime = date;
                                setState(() {});
                                setModalState(() {});
                              }, currentTime: datePerformedOn);
                            },
                            child: Center(
                              child: Text(
                                "${sheetStartTime.hour}:${sheetStartTime.minute}",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Select End Time",
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 60,
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.grey,
                          ),
                          child: InkWell(
                            onTap: () {
                              picker.DatePicker.showTimePicker(context,
                                  showSecondsColumn: false,
                                  showTitleActions: true,
                                  onChanged: (date) {}, onConfirm: (date) {
                                sheetEndTime = date;
                                setState(() {});
                                setModalState(() {});
                              }, currentTime: datePerformedOn);
                            },
                            child: Center(
                              child: Text(
                                "${sheetEndTime.hour}:${sheetEndTime.minute}",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
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
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Select Break Duration",
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 60,
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.grey,
                          ),
                          child: InkWell(
                            onTap: () {
                              _openTimePickerSheet(context, onSet: (result) {
                                sheetBreakHrs = result.hour;
                                sheetBreakMins = result.minute;
                                setState(() {});
                                setModalState(() {});
                              });
                            },
                            child: Center(
                              child: Text(
                                "${sheetBreakHrs}:${sheetBreakMins}",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 32,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Total Duration ${AppUtils.calculateTotalDuration(sheetStartTime, sheetEndTime, sheetBreakHrs, sheetBreakMins)} hr",
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          // Add your button click logic here
                          Navigator.pop(context);
                          if (worker != null) {
                            timeTableItems
                                .where((element) => element.worker == worker)
                                .forEach((element) {
                              element.startTime = sheetStartTime;
                              element.endTime = sheetEndTime;
                              element.breakMins = sheetBreakMins;
                              element.breakHrs = sheetBreakHrs;
                            });
                          }
                          if (crew != null) {
                            timeTableItems
                                .where((element) => element.crew == crew)
                                .forEach((element) {
                              element.startTime = sheetStartTime;
                              element.endTime = sheetEndTime;
                              element.breakMins = sheetBreakMins;
                              element.breakHrs = sheetBreakHrs;
                            });
                          }
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor:
                              AppColors.lightPrimaryColor, // Text color
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(20.0), // Rounded corners
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          child: Text(
                            "Set Time",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
              ;
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

  addFiles() {
    return Column(
      children: [
        OutlinedButton(
          onPressed: () {
            // Add your button click logic here
            _addNewFile();
          },
          style: OutlinedButton.styleFrom(
            side:
                BorderSide(color: AppColors.lightPrimaryColor), // Border color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  8.0), // Rectangle shape with rounded corners
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Text('Add new File',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightAccentColor)),
          ),
        ),
        SizedBox(
          height: 16,
        ),
        editFiles(),
        Divider(),
        for (var file in files)
          ListTile(
            title: Text(
              file.name,
              maxLines: 2,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            leading: Icon(Icons.file_copy),
            trailing: InkWell(
                onTap: () {
                  files.remove(file);
                  setState(() {});
                },
                child: Icon(
                  Icons.delete,
                  color: AppColors.errorColor,
                )),
          )
      ],
    );
  }

  editFiles() {
    if (widget.isEdit == true) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          for (int i = 0; i < (widget.timesheet?.files ?? []).length; i++)
            ListTile(
              leading: Icon(Icons.open_in_new),
              trailing: InkWell(
                onTap: () async {
                  AppUtils.showConfirmationDialog(context,
                      'Are you sure you want to delete this file from the Timesheet?',
                      () async {
                    print("Delete ...");
                    await userProvider.deleteFileFromTimesheet(
                        widget.timesheet?.timeSheetId,
                        widget.timesheet?.files[i]);
                    widget.timesheet?.files.removeAt(i);
                    setState(() {});
                  });
                },
                child: Icon(
                  Icons.delete,
                  color: AppColors.errorColor,
                ),
              ),
              title: InkWell(
                onTap: () async {
                  await AppUtils.utilLaunchUrl(
                      widget.timesheet?.files[i], "", context);
                },
                child: Text(
                  "File $i",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600, fontSize: 18.0),
                ),
              ),
            ),
        ],
      );
    }
    return SizedBox();
  }

  showSetCodeSheet({Worker? worker, Crew? crew}) {
    showMaterialModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        context: context,
        builder: (context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setModalState) {
              return Container(
                height: 400,
                child: ListView.builder(
                    itemCount: costCodes.length,
                    itemBuilder: (ctx, index) {
                      return ListTile(
                        onTap: () {
                          if (worker != null) {
                            timeTableItems
                                .where((element) => element.worker == worker)
                                .forEach((element) {
                              // Update the matching elements
                              element.costCodeId = costCodes[index].costCodeId;
                              element.costCode = costCodes[index];
                            });
                          }
                          if (crew != null) {
                            timeTableItems
                                .where((element) =>
                                    element.crew?.crewId == crew.crewId)
                                .forEach((element) {
                              // Update the matching elements
                              element.costCodeId = costCodes[index].costCodeId;
                              element.costCode = costCodes[index];
                            });
                          }
                          Navigator.pop(context);
                          setState(() {});
                        },
                        title: Text(
                          (costCodes[index].code ?? "") + " ",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        leading: Icon(Icons.abc),
                        subtitle: Text(
                          (costCodes[index].description ?? "") + " ",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  fontWeight: FontWeight.bold, fontSize: 16.0),
                        ),
                      );
                    }),
              );
            }));
  }

  bool validateStep(context) {
    if (isLoading) {
      return false;
    }
    if (FineStepper.of(context).stepIndex == 0) {
      if (userProvider.uiTimeSheet.startTime
              ?.isAfter(userProvider.uiTimeSheet.endTime ?? DateTime.now()) ==
          true) {
        ErrorUtils.showGeneralError(context, "Please fix the errors",
            duration: Duration(seconds: 3));
        return false;
      }
    }
    CostCodeShift defaultCostCodeShift = CostCodeShift(
      costCode: userProvider.uiTimeSheet.costCode,
      startTime: userProvider.uiTimeSheet.startTime,
      endTime: userProvider.uiTimeSheet.endTime,
      breakMins: (userProvider.uiTimeSheet.breakHrs * 60) +
          userProvider.uiTimeSheet.breakMins,
    );
    // create uiTimeSheet
    userProvider.uiTimeSheet.defaultCostCodeShift = defaultCostCodeShift;

    if (FineStepper.of(context).stepIndex == 1) {
      bool valid = true;
      for (TimeTableItem timeTableItem in timeTableItems) {
        if (timeTableItem.crew != null) {
          double time = timeTableItem.calculateCrewTotalDuration(
              timeTableItem.startTime,
              timeTableItem.endTime,
              timeTableItem.crew?.workers?.length ?? 0);

          if (time <= 0.0) {
            ErrorUtils.showGeneralError(context, "Please Select correct times",
                duration: Duration(seconds: 3));
            return false;
          }
        }
        if (timeTableItem.calculateTotalDuration() <= 0.0) {
          ErrorUtils.showGeneralError(context, "Please Select correct times",
              duration: Duration(seconds: 3));
          return false;
        }
      }
    }

    if (FineStepper.of(context).stepIndex == 2) {
      bool valid = true;
      for (TimeTableItem timeTableItem in timeTableItems) {
        if (timeTableItem.costCode == null ||
            timeTableItem.costCodeId == null) {
          print("timeTableItem.costCodeId ${timeTableItem.costCodeId}");
          print("timeTableItem.costCode ${timeTableItem.costCode?.costCodeId}");
          ErrorUtils.showGeneralError(
              context, "Please select correct cost codes",
              duration: Duration(seconds: 3));
          return false;
        }
      }
    }

    return true;
  }

  formatDate(DateTime dateTime) {
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }

  formatTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  _addNewFile() {
    AppUtils.showPickFileSource(context, ({isCamera, isVideo, source}) async {
      XFile? file;
      if (source == PickSource.FILE) {
        file = await AppUtils.pickGeneralFile();
      } else if (!isCamera && !isVideo) {
        file = await AppUtils.pickGalleryPhoto();
      } else if (isCamera && !isVideo) {
        file = await AppUtils.pickCameraPhoto();
      } else if (!isCamera && isVideo) {
        file = await AppUtils.pickGalleryVideo();
      } else if (isCamera && isVideo) {
        file = await AppUtils.pickCameraVideo();
      }
      if (file != null) {
        files.add(file);
      }
      Navigator.pop(context);
      setState(() {});
    });
  }

  submitTimeSheet({isEdit = false}) async {
    setState(() {
      isLoading = true;
    });

    bool result = true;
    User? user = FirebaseAuth.instance.currentUser;
    List crewTimeSheets = await userProvider
        .createCrewTimeSheets(userProvider.uiTimeSheet.crewTimeSheet);
    Map createWorkersCostCodes = await userProvider
        .createWorkersCostCodes(userProvider.uiTimeSheet.workersCostCodes);
    List<String?>? filesUrls = await userProvider.createFiles(files);

    var data;
    if(isEdit){
      ///////////removing old data
      for(DocumentReference ref in  widget.timesheet?.crewTimeSheet ?? []){
        await ref.delete();
      }
        for (var key in widget.timesheet!.workersCostCodes.keys) {
          var documentReferences = widget.timesheet!.workersCostCodes[key];
          // Iterate over each DocumentReference in the list
          for (var documentReference in documentReferences) {
            // Check if the document exists before deleting
            var snapshot = await documentReference.get();
            if (snapshot.exists) {
              await documentReference.delete();
              print('DocumentReference deleted successfully: $documentReference');
            } else {
              print('DocumentReference does not exist: $documentReference');
            }
          }
        }
      ////////////done removing old data

       data = {
        "added_by": FirebaseFirestore.instance.collection("users").doc(user?.uid),
        "breakHrs": userProvider.uiTimeSheet.breakHrs,
        "breakMins": userProvider.uiTimeSheet.breakMins,
        "comment": userProvider.uiTimeSheet.comment,
        "contract": FirebaseFirestore.instance
            .collection("contracts")
            .doc(userProvider.currentContract?.contractId),
        "cost_code": FirebaseFirestore.instance
            .collection("costcodes")
            .doc(userProvider.uiTimeSheet.costCode?.costCodeId),
        "crewIds": userProvider.uiTimeSheet.crewIds,
        "crews": [
          for (Crew crew in userProvider.uiTimeSheet.crews)
            FirebaseFirestore.instance.collection("crews").doc(crew.crewId),
        ],
        "date_performed_on": userProvider.uiTimeSheet.datePerformedOn,
        "default_cost_code_shift": "/cost_code_with_shift/xx",
        "end_time": userProvider.uiTimeSheet.endTime,
        "shift": FirebaseFirestore.instance.collection("shifts").doc(
          userProvider.uiTimeSheet.shift?.shiftId,
        ),
        "start_time": AppUtils.parseTimeStringToTimeStamp(
            userProvider.uiTimeSheet.shift?.startTime ?? "00:00"),
        "status": "pending",
        "resubmitted": true,
        "updated_at": Timestamp.now(),
        "workerIds": userProvider.uiTimeSheet.workerIds,
        "workers": [
          for (Worker worker in userProvider.uiTimeSheet.workers)
            FirebaseFirestore.instance.collection("workers").doc(worker.workerId)
        ],
        "files": filesUrls,
         "workers_cost_codes": createWorkersCostCodes,
         "crew_time_sheet": crewTimeSheets,
      };
    }else {
      data = {
        "added_by": FirebaseFirestore.instance.collection("users").doc(
            user?.uid),
        "breakHrs": userProvider.uiTimeSheet.breakHrs,
        "breakMins": userProvider.uiTimeSheet.breakMins,
        "comment": userProvider.uiTimeSheet.comment,
        "contract": FirebaseFirestore.instance
            .collection("contracts")
            .doc(userProvider.currentContract?.contractId),
        "cost_code": FirebaseFirestore.instance
            .collection("costcodes")
            .doc(userProvider.uiTimeSheet.costCode?.costCodeId),
        "created_at": Timestamp.now(),
        "crewIds": userProvider.uiTimeSheet.crewIds,
        "crew_time_sheet": crewTimeSheets, //["/crew_timesheet/xxx"],
        "crews": [
          for (Crew crew in userProvider.uiTimeSheet.crews)
            FirebaseFirestore.instance.collection("crews").doc(crew.crewId),
        ],
        "date_performed_on": userProvider.uiTimeSheet.datePerformedOn,
        "default_cost_code_shift": "/cost_code_with_shift/xx",
        "end_time": userProvider.uiTimeSheet.endTime,
        "shift": FirebaseFirestore.instance.collection("shifts").doc(
          userProvider.uiTimeSheet.shift?.shiftId,
        ),
        "start_time": AppUtils.parseTimeStringToTimeStamp(
            userProvider.uiTimeSheet.shift?.startTime ?? "00:00"),
        "status": "pending",
        "timesheet_id": "idid",
        "updated_at": Timestamp.now(),
        "workerIds": userProvider.uiTimeSheet.workerIds,
        "workers": [
          for (Worker worker in userProvider.uiTimeSheet.workers)
            FirebaseFirestore.instance.collection("workers").doc(
                worker.workerId)
        ],
        "workers_cost_codes": createWorkersCostCodes,
        "files": filesUrls,
        "resubmitted": false,

      };
    }
    if (isEdit == true) {
      result = await userProvider.updateTimesheet(
          data: data, timesheetId: widget.timesheet?.timeSheetId);
    } else {
      result = await userProvider.addNewTimeSheet(data: data);
    }
    if (result == true) {
      files = [];
      timeTableItems = [];
      datePerformedOn = DateTime.now();
      Navigator.pop(context);
      userProvider.cleanUiTimesheet();
      ErrorUtils.showSuccessMessage(context, "Timesheet added successfully");
    } else {
      ErrorUtils.showGeneralError(
        context,
        isEdit
            ? "Could not update the timesheet"
            : "Could not add new timesheet",
        duration: Duration(seconds: 3),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  calculateOverallTime(List<TimeTableItem> items) {
    double total = 0.0;
    for (TimeTableItem item in items) {
      total += item.calculateTotalDuration();
    }
    print("calculateOverallTime ${total}");
    return total;
  }

  calculateWorkerTime(Worker worker) {
    String time = '00:00';
    for (TimeTableItem timeTable in timeTableItems) {
      if (timeTable.worker?.workerId == worker.workerId) {
        time = AppUtils.convertToHHMM(timeTable.calculateTotalDuration());
        return time;
      }
    }
    return time;
  }

  calculateCrewTime(Crew crew) {
    String time = '00:00';
    for (TimeTableItem timeTable in timeTableItems) {
      if (timeTable.crew?.crewId == crew.crewId) {
        time = AppUtils.convertToHHMM(
            timeTable.calculateTotalDuration() * (crew.workers?.length ?? 0));
        return time;
      }
    }
    return time;
  }
}
