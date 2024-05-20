import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:plumbata/net/model/cost_code.dart';
import 'package:plumbata/net/model/crew.dart';
import 'package:plumbata/net/model/crew_time_sheet.dart';
import 'package:plumbata/net/model/time_table_item.dart';
import 'package:plumbata/net/model/timesheet.dart';
import 'package:plumbata/net/model/worker.dart';
import 'package:plumbata/providers/user.dart';
import 'package:plumbata/ui/widgets/dropdown_crew_worker.dart';
import 'package:plumbata/utils/app_utils.dart';
import 'package:plumbata/utils/colors.dart';
import 'package:provider/provider.dart';

class SelectWorkerOrCrew extends StatefulWidget {
  const SelectWorkerOrCrew(
      {super.key, this.isEdit = false, this.editTimesheet});
  final bool? isEdit;
  final TimeSheet? editTimesheet;

  @override
  State<SelectWorkerOrCrew> createState() => _SelectWorkerOrCrewState();
}

class _SelectWorkerOrCrewState extends State<SelectWorkerOrCrew> {
  int workerCrewIndex = 0;
  List<Worker> workers = [];
  List<Worker> filterWorkers = [];
  List<Crew> crews = [];
  List<Crew> filterCrews = [];
  late UserProvider userProvider;
  bool isLoading = false;
  final _controller = ValueNotifier<bool>(false);
  TextEditingController searchTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    userProvider = context.read<UserProvider>();
    _controller.value = true;
    _controller.addListener(() {
      setState(() {
        if (_controller.value) {
          workerCrewIndex = 0;
        } else {
          workerCrewIndex = 1;
        }
      });
    });
    getContractWorkers();
  }

  getContractWorkers() async {
    setState(() {
      isLoading = true;
    });
    workers = await userProvider.getContractWorkers(
        contractId: userProvider.currentContract?.contractId ?? "");

    crews = await userProvider.getContractCrews(
        contractId: userProvider.currentContract?.contractId ?? "");
    if (widget.isEdit == true) {
      for (DocumentReference? workerRef
          in widget.editTimesheet?.workers ?? []) {
        for (Worker worker in workers) {
          if (workerRef?.id.contains(worker.workerId ?? "N/A") == true) {
            List<CostCodeShift> costCodeShifts = [];
            for (DocumentReference costCodeRef
                in widget.editTimesheet?.workersCostCodes[worker.workerId] ??
                    []) {
              var costCodeShiftData = await costCodeRef.get();
              if (costCodeShiftData.exists) {
                var costCodeData =
                    costCodeShiftData.data() as Map<String, dynamic>;
                var costCodeDoc = await costCodeData['costCode'].get();
                CostCode costCode = CostCode.fromJson(
                    costCodeDoc.data() as Map<String, dynamic>);
                CostCodeShift costCodeShift = CostCodeShift(
                  costCode: costCode,
                  startTime: costCodeData['startTime'].toDate(),
                  endTime: costCodeData['endTime'].toDate(),
                  breakMins: costCodeData['breakMins'],
                );
                costCodeShifts.add(costCodeShift);
              }
            }
            userProvider.addRemoveWorkerToTimesheet(worker,
                costCodeShifts: costCodeShifts);
          }
        }
      }

      Map<String, CrewTimeSheet> crewTimesheets = {};
      for (DocumentReference crewTimesheetRef
          in widget.editTimesheet?.crewTimeSheet ?? []) {
        var crewTimesheetDoc = await crewTimesheetRef.get();
        if (crewTimesheetDoc.exists == true) {
          var crewTimeSheetdata = crewTimesheetDoc;
          CrewTimeSheet crewTimeSheet =
              await CrewTimeSheet.fromFirestore(crewTimesheetDoc);
          crewTimesheets.putIfAbsent(crewTimeSheetdata['crew'].id, () => crewTimeSheet);
        }
      }
      print("crewTimesheets ${crewTimesheets}");

      for (DocumentReference? crewRef in widget.editTimesheet?.crews ?? []) {
        for (Crew crew in crews) {
          if (crewRef?.id.contains(crew.crewId ?? "N/A") == true) {
            userProvider.addRemoveCrewToTimesheet(crew,
                crewTimeSheet: crewTimesheets[crew.crewId]);
          }
        }
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return selectWorkersOrCrews();
  }

  selectWorkersOrCrews() {
    return isLoading
        ? Center(
            child: CircularProgressIndicator.adaptive(),
          )
        : Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 16.0,
                  ),
                  Expanded(
                    child: Container(
                      height: 50,
                      // width: 200, // Set a finite width for the TextField
                      child: TextField(
                        decoration: const InputDecoration(hintText: 'Search'),
                        autofocus: false,
                        onChanged: (search) {
                          setState(() {
                            if (workerCrewIndex == 0) {
                              filterWorkers = workers
                                  .where((w) => (w.firstName
                                              .toString()
                                              .toLowerCase() +
                                          " " +
                                          w.lastName.toString().toLowerCase())
                                      .contains(search.toLowerCase()))
                                  .toList();
                            } else {
                              filterCrews = crews
                                  .where((e) =>
                                      e.name
                                          ?.toLowerCase()
                                          .contains(search.toLowerCase()) ==
                                      true)
                                  .toList();
                            }
                          });
                        },
                        controller: searchTextController,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 8.0,
                  ),
                  AdvancedSwitch(
                    controller: _controller,
                    activeColor: Colors.grey,
                    inactiveColor: Colors.grey,
                    borderRadius: BorderRadius.circular(5),
                    width: 76,
                    activeChild: Text('Worker'),
                    inactiveChild: Text('Crew'),
                    height: 30.0,
                    enabled: true,
                    disabledOpacity: 0.5,
                  ),
                  SizedBox(
                    width: 16.0,
                  )
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: workerCrewIndex == 0
                      ? (searchTextController.text.isEmpty
                          ? workers.length
                          : filterWorkers.length)
                      : (searchTextController.text.isEmpty
                          ? crews.length
                          : filterCrews.length),
                  itemBuilder: (ctx, index) {
                    var worker = workers[index];
                    if (workerCrewIndex == 0 &&
                        searchTextController.text.isNotEmpty) {
                      worker = filterWorkers[index];
                    }

                    if (workerCrewIndex == 0) {
                      return ListTile(
                        onTap: () {
                          userProvider.addRemoveWorkerToTimesheet(worker);
                          setState(() {});
                        },
                        title: Text(
                          (AppUtils.capitalize(worker.firstName) ?? "") +
                              " " +
                              (AppUtils.capitalize(worker.lastName) ?? ""),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          (AppUtils.capitalize(worker.classification)),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  fontWeight: FontWeight.bold, fontSize: 14.0),
                        ),
                        leading: Icon(Icons.person),
                        trailing: Checkbox(
                          activeColor: AppColors.lightAccentColor,
                          value: userProvider.timeSheetContainsWorker(worker),
                          onChanged: (bool? value) {
                            userProvider.addRemoveWorkerToTimesheet(worker);
                            setState(() {});
                          },
                        ),
                      );
                    }

                    var crew = crews[index];
                    if (workerCrewIndex == 1 &&
                        searchTextController.text.isNotEmpty) {
                      crew = filterCrews[index];
                    }
                    return ListTile(
                      onTap: () {
                        userProvider.addRemoveCrewToTimesheet(crew);
                        setState(() {});
                      },
                      title: Text(
                        (AppUtils.capitalize(crew.name)) + " ",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold, fontSize: 18.0),
                      ),
                      subtitle: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var worker in crew.workers ?? [])
                            BuildWorkerName(worker: worker),
                        ],
                      ),
                      leading: Icon(Icons.groups),
                      trailing: Checkbox(
                        activeColor: AppColors.lightAccentColor,
                        value: userProvider.timeSheetContainsCrew(crew),
                        onChanged: (bool? value) {
                          userProvider.addRemoveCrewToTimesheet(crew);
                          setState(() {});
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
  }
}

class BuildWorkerName extends StatefulWidget {
  const BuildWorkerName(
      {super.key, required this.worker, this.hasRemove = false, this.onDelete});
  final dynamic worker;
  final bool hasRemove;
  final Function? onDelete;
  @override
  State<BuildWorkerName> createState() => _BuildWorkerNameState();
}

class _BuildWorkerNameState extends State<BuildWorkerName> {
  Worker? worker;
  bool isLoading = false;
  late UserProvider userProvider;

  @override
  void initState() {
    super.initState();
    userProvider = context.read<UserProvider>();
    getWorkerData();
  }

  getWorkerData() async {
    setState(() {
      isLoading = true;
    });
    if (widget.worker is Worker) {
      worker = widget.worker;
    } else {
      worker = await userProvider.getWorkerByRef(widget.worker);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context, listen: true);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isLoading
              ? "..."
              : AppUtils.capitalize(worker?.firstName) +
                  " " +
                  AppUtils.capitalize(worker?.lastName),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            decoration: worker?.isActive != true ? TextDecoration.lineThrough: TextDecoration.none,
          ),
        ),
        widget.hasRemove
            ? IconButton(
                onPressed: () {
                  widget.onDelete!();
                },
                icon: Icon(
                  Icons.delete,
                  color: AppColors.errorColor.withOpacity(0.6),
                ))
            : SizedBox()
      ],
    );
  }
}
