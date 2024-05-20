import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:plumbata/net/model/cost_code.dart';
import 'package:plumbata/net/model/crew.dart';
import 'package:plumbata/net/model/time_table_item.dart';
import 'package:plumbata/net/model/timesheet.dart';
import 'package:plumbata/net/model/worker.dart';
import 'package:plumbata/providers/user.dart';
import 'package:plumbata/ui/home/contractor/contract_workers.dart';
import 'package:plumbata/ui/home/contractor/crews_manage.dart';
import 'package:plumbata/ui/home/contractor/add_timesheet_by_step.dart';
import 'package:plumbata/ui/widgets/appbar.dart';
import 'package:plumbata/ui/widgets/buttons.dart';
import 'package:plumbata/ui/widgets/video_player.dart';
import 'package:plumbata/utils/app_utils.dart';
import 'package:plumbata/utils/colors.dart';
import 'package:plumbata/utils/error_utils.dart';
import 'package:plumbata/utils/icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:time_picker_sheet/widget/sheet.dart';
import 'package:time_picker_sheet/widget/time_picker.dart';

class AddNewTimeSheet extends StatefulWidget {
  const AddNewTimeSheet({super.key, this.isEdit = false, this.timesheet});
  final bool isEdit;
  final TimeSheet? timesheet;
  @override
  State<AddNewTimeSheet> createState() => _AddNewTimeSheetState();
}

class _AddNewTimeSheetState extends State<AddNewTimeSheet> {
  List<XFile> files = [];
  List<TextEditingController> filesControllers = [];
  bool isLoading = false;
  late UserProvider userProvider;
  List<Worker> workers = [];
  List<Crew> crews = [];
  List<CostCode> costCodes = [];
  List<TimeTableItem> timeTableItems = [];
  DateTime datePerformedOn = DateTime.now();



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

  @override
  void initState() {
    super.initState();
    userProvider = context.read<UserProvider>();
    getContractWorkers();
  }

  @override
  Widget build(BuildContext context) {
    return FirstScreen(isEdit: widget.isEdit, timesheet: widget.timesheet,);
  }

  validData() {
    for (TimeTableItem timeTableItem in timeTableItems) {
      if (timeTableItem.calculateTotalDuration() < 0 ||
          timeTableItem.costCodeId == null) {
        return false;
      }
    }
    return true;
  }


  showAddNewTimeSlot() {
    showMaterialModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      context: context,
      builder: (context) => SizedBox(
        height: 400,
        child: Column(
          children: [
            const SizedBox(
              height: 16,
            ),
            ListTile(
              onTap: () {
                Navigator.pop(context);
                showWorkersOrCrewsModal();
              },
              title: Text(
                "Worker",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Select individual worker",
                  style: Theme.of(context).textTheme.bodyMedium),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            const Divider(),
            ListTile(
              onTap: () {
                Navigator.pop(context);
                showWorkersOrCrewsModal(isWorkers: false);
              },
              title: Text(
                "Crew",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Select a Crew",
                  style: Theme.of(context).textTheme.bodyMedium),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            const Divider(),
            ListTile(
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(context,
                    MaterialPageRoute(builder: (ctx) => ContractWorkers()));
                getContractWorkers();
              },
              title: Text(
                "Manage The Workers",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Manage Contract workers",
                  style: Theme.of(context).textTheme.bodyMedium),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            const Divider(),
            ListTile(
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(context,
                    MaterialPageRoute(builder: (ctx) => ContractCrews()));
                getContractWorkers();
              },
              title: Text(
                "Manage The Crews",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Manage Contract Crews",
                  style: Theme.of(context).textTheme.bodyMedium),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
          ],
        ),
      ),
    );
  }

  showAssignCostCode(TimeTableItem timeTableItem) {
    showMaterialModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        context: context,
        builder: (context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setModalState) {
              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: Column(
                  children: [
                    SizedBox(
                      height: 16.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Choose Costcode",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  fontSize: 18.0, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    Divider(
                      thickness: 2,
                    ),
                    for (CostCode code in costCodes)
                      Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: ListTile(
                              onTap: () {
                                timeTableItem.costCodeId = code.costCodeId;
                                Navigator.pop(context);
                                setState(() {});
                              },
                              title: Text(
                                code.code ?? "",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontSize: 18.0),
                              ),
                              trailing: Icon(Icons.done),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Divider(
                              thickness: 2,
                            ),
                          ),
                        ],
                      )
                  ],
                ),
              );
            }));
  }

  showWorkersOrCrewsModal({bool isWorkers = true}) {
    showMaterialModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        context: context,
        builder: (context) {
          return SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.close)),
                      Flexible(
                        child: Center(
                          child: Text(
                            isWorkers ? "Contract Workers" : "Contract Crews",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Flexible(child: Text(" ")),
                    ],
                  ),
                ),
                Divider(),
                Expanded(
                  child: ListView.builder(
                      itemCount: isWorkers ? workers.length : crews.length,
                      itemBuilder: (ctx, index) {
                        return ListTile(
                          onTap: () {
                            if (isWorkers) {
                              timeTableItems.add(TimeTableItem(
                                  worker: workers[index],
                                  startTime: datePerformedOn,
                                  endTime: datePerformedOn));
                            } else {
                              timeTableItems.add(TimeTableItem(
                                  crew: crews[index],
                                  startTime: datePerformedOn,
                                  endTime: datePerformedOn));
                            }
                            Navigator.pop(context);
                            setState(() {});
                          },
                          title: Text(
                            isWorkers
                                ? "${workers[index].firstName} ${workers[index].lastName}"
                                : "${crews[index].name}",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                              isWorkers
                                  ? "${workers[index].classification}"
                                  : "${crews[index].workers?.length} Worker",
                              style: Theme.of(context).textTheme.bodyMedium),
                          trailing: Icon(Icons.arrow_forward_ios),
                        );
                      }),
                ),
              ],
            ),
          );
        });
  }

  formatDate(DateTime dateTime) {
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }

  void _openTimePickerSheet(BuildContext context, int timeSlotIndex) async {
    TimeTableItem item = timeTableItems[timeSlotIndex];

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
      item.breakHrs = result.hour;
      item.breakMins = result.minute;
      setState(() {
        timeTableItems[timeSlotIndex] = item;
      });
    }
  }

  calculateOverallTime(List<TimeTableItem> items) {
    double total = 0.0;
    for (TimeTableItem item in items) {
      total += item.calculateTotalDuration();
    }
    return total;
  }

}
