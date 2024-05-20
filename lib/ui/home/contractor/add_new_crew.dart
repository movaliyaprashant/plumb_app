import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:plumbata/net/model/crew.dart';
import 'package:plumbata/net/model/worker.dart';
import 'package:plumbata/providers/user.dart';
import 'package:plumbata/ui/widgets/appbar.dart';
import 'package:plumbata/ui/widgets/buttons.dart';
import 'package:plumbata/utils/app_utils.dart';
import 'package:plumbata/utils/colors.dart';
import 'package:plumbata/utils/error_utils.dart';
import 'package:plumbata/utils/icons.dart';
import 'package:provider/provider.dart';

class AddNewCrew extends StatefulWidget {
  const AddNewCrew({super.key, this.isEdit = false, this.editCrew});
  final bool isEdit;
  final Crew? editCrew;

  @override
  State<AddNewCrew> createState() => _AddNewCrewState();
}

class _AddNewCrewState extends State<AddNewCrew> {
  TextEditingController _crewName = TextEditingController();
  TextEditingController _search = TextEditingController();
  List<Worker> workers = [];
  List<Worker> tempWorkers = [];
  List<Worker> allWorkers = [];
  List<Worker> filterWorkers = [];
  bool isLoading = false;
  late UserProvider userProvider;
  String originalCrewName = '';
  List<Worker> originalCrewWorkers = [];
  @override
  void initState() {
    super.initState();
    userProvider = context.read<UserProvider>();
    if (widget.editCrew != null) {
      _crewName.text = widget.editCrew?.name ?? "";
      getCrewWorkers();
    }
    originalCrewName = _crewName.text;
    getContractWorkers();
  }

  getCrewWorkers() async {
    setState(() {
      isLoading = true;
    });

    List<DocumentReference> ids = [];
    for (DocumentReference d in widget.editCrew?.workers ?? []) {
      ids.add(d);
    }

    workers = await userProvider.getWorkerListByIds(ids: ids);
    tempWorkers = workers;
    originalCrewWorkers = List.from(tempWorkers);

    setState(() {
      isLoading = false;
    });
  }

  getContractWorkers() async {
    setState(() {
      isLoading = true;
    });
    allWorkers = await userProvider.getContractWorkers(
        contractId: userProvider.currentContract?.contractId ?? "");

    setState(() {
      isLoading = false;
    });
  }

  filterListView(String text, onFilter) {
    filterWorkers = allWorkers
        .where((element) => "${element.firstName} ${element.lastName}"
            .toLowerCase()
            .contains(text.toLowerCase()))
        .toList();
    setState(() {});
    onFilter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GeneralAppBar(
          title: widget.isEdit ? "Edit Crew" : "Add New Crew", backBtn: true),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Write Crew name and select workers for the crew",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                    ],
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextFormField(
                      controller: _crewName,
                      textCapitalization: TextCapitalization.words,
                      keyboardType: TextInputType.name,
                      onChanged: (value) {
                        _crewName.text = value.trimLeft();
                        // Capitalize the first letter
                        setState(() {});
                      },
                      maxLength: 30,
                      decoration: AppUtils.getInputDecoration("Crew Name", Icons.person),
                      validator: (String? value) {
                        if (value == null || value == '') {
                          return 'Enter crew name';
                        }
                        if (value.trim().length < 2) {
                          return "The name can not be less than 2 chars";
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.always,
                    )),
                SizedBox(
                  height: 16,
                ),

                InkWell(
                  onTap: () {
                    showWorkersSheet();
                  },
                  child: Text("Select Worker(s)",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.blueAccent,
                          )),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        "Crew Workers",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Expanded(
                    child: ListView.builder(
                  itemCount: workers.length,
                  itemBuilder: (ctx, index) {
                    Worker worker = workers[index];
                    return ListTile(
                      title: Text("${worker.firstName} ${worker.lastName}",
                          style: Theme.of(context).textTheme.bodyMedium),
                      subtitle: Text("${worker.classification}}",
                          style: Theme.of(context).textTheme.bodySmall),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          AppUtils.showYesNoDialog(context, onYes: () async {
                            setState(() {
                              workers.remove(worker);
                            });
                          },
                              onNo: () {},
                              title: 'Remove Worker',
                              message:
                                  'Are you sure you want to remove the worker ${(AppUtils.capitalize(worker.firstName ?? "")) + " " + (AppUtils.capitalize(worker.lastName ?? ""))} from the crew?');
                        },
                      ),
                    );
                  },
                )),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: PrimaryButton(
                    widget.isEdit ? "Update & Save" : 'Create Crew',
                    enabled: !isLoading && widget.isEdit
                        ? (_crewName.text.isNotEmpty &&
                            _crewName.text.trim().length >= 2 &&
                            workers.isNotEmpty &&
                            (_crewName.text != originalCrewName ||
                                !doesCrewEquals(originalCrewWorkers, workers)))
                        : _crewName.text.isNotEmpty &&
                            _crewName.text.trim().length >= 2 &&
                            workers.isNotEmpty,
                    isLoading: isLoading,
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      try {
                        await userProvider.createCrew(
                            isEdit: widget.isEdit,
                            crewId: widget.editCrew?.crewId,
                            workers: workers.map((e) => e.workerId).toList(),
                            name: _crewName.text.trim(),
                            contractId:
                                userProvider.currentContract?.contractId ?? "");

                        ErrorUtils.showSuccessMessage(
                            context,
                            widget.isEdit
                                ? "Crew Updated Successfully"
                                : "Crew Created Successfully");
                        if(widget.isEdit){
                           originalCrewName = _crewName.text;
                           originalCrewWorkers = List.from(tempWorkers);
                        }else {
                          _crewName.clear();
                          tempWorkers = [];
                          workers = [];
                        }
                        Future.delayed(Duration(seconds: 4)).then((value) {
                          Navigator.pop(context);
                          _crewName.clear();
                        });
                      } catch (e) {
                        ErrorUtils.showGeneralError(
                            context,
                            widget.isEdit
                                ? "Could not edit the Crew ${e.toString()}"
                                : "Could not create the Crew ${e.toString()}",
                            duration: Duration(seconds: 3));
                      }
                      setState(() {
                        isLoading = false;
                      });
                    },
                  ),
                ),
                SizedBox(
                  height: 32,
                )
              ],
            ),
    );
  }

  bool doesCrewEquals(List<Worker>? workers1, List<Worker>? workers2) {

    if (workers1 == null || workers2 == null || workers1.length != workers2.length) {
      return false;
    }

    workers1.sort((a, b) => (a.workerId ?? '').compareTo(b.workerId ?? ''));
    workers2.sort((a, b) => (a.workerId ?? '').compareTo(b.workerId ?? ''));

    for (int i = 0; i < workers1.length; i++) {
      if ((workers1[i].workerId ?? '') != (workers2[i].workerId ?? '')) {
        return false;
      }
    }
    return true;
  }
  showWorkersSheet() {
    showMaterialModalBottomSheet(
        isDismissible: false,
        enableDrag: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        context: context,
        builder: (context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setModalState) {
              return SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 8, left: 16, right: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                              onPressed: () {
                                workers = tempWorkers;
                                Navigator.pop(context);
                                Future.delayed(Duration(milliseconds: 800), () {
                                  // Code inside this block will be executed after a delay of 2 seconds
                                  setState(() {
                                    // Your setState logic here
                                  });
                                });
                              },
                              icon: Icon(
                                Icons.arrow_back_ios,
                                color: AppColors.lightAccentColor,
                              ))
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextFormField(
                          controller: _search,
                          onChanged: (text) {
                            filterListView(text, () {
                              setModalState(() {});
                            });
                          },
                          autocorrect: false,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              hintText: 'Search',
                              prefixIcon: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: SvgPicture.asset(kSearchIcon),
                              )),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Expanded(
                        child: ListView.builder(
                            itemCount: _search.text.isNotEmpty
                                ? filterWorkers.length
                                : allWorkers.length,
                            itemBuilder: (ctx, index) {
                              if (_search.text.isNotEmpty == true) {
                                return workerCard(
                                    filterWorkers[index], setModalState);
                              }
                              return workerCard(
                                  allWorkers[index], setModalState);
                            })),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: PrimaryButton(
                        widget.isEdit ? 'Update & Save' : "Update & Save",
                        isLoading: isLoading,
                        enabled: tempWorkers.length > 0,
                        onPressed: () {
                          workers = tempWorkers;
                          Navigator.pop(context);
                          Future.delayed(Duration(milliseconds: 800), () {
                            // Code inside this block will be executed after a delay of 2 seconds
                            setState(() {
                              // Your setState logic here
                            });
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      height: 32.0,
                    )
                  ],
                ),
              );
            }));
  }

  workerCard(Worker worker, setModalState) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: InkWell(
          onTap: () {
            setState(() {
              if (tempWorkers
                  .map((e) => e.workerId)
                  .toList()
                  .contains(worker.workerId)) {
                tempWorkers.remove(worker);
              } else {
                tempWorkers.add(worker);
              }
              setModalState(() {});
              setState(() {});
            });
            setModalState(() {});
          },
          child: Card(
            elevation: 4.0,
            child: ListTile(
              onTap: () {
                if (tempWorkers
                    .map((e) => e.workerId)
                    .toList()
                    .contains(worker.workerId)) {
                  tempWorkers.removeWhere((e) => e.workerId == worker.workerId);
                } else {
                  tempWorkers.add(worker);
                }
                print("tempWorkers ${tempWorkers.toString()}");
                setModalState(() {});
                setState(() {});
              },
              title: Text(
                "${worker.firstName} ${worker.lastName}",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              subtitle: Text(
                "${worker.classification}",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              trailing: Checkbox(
                checkColor: Colors.white,
                activeColor: AppColors.lightAccentColor,
                value: tempWorkers
                    .map((e) => e.workerId)
                    .toList()
                    .contains(worker.workerId),
                onChanged: (bool? value) {
                  setState(() {
                    if (tempWorkers
                        .map((e) => e.workerId)
                        .toList()
                        .contains(worker.workerId)) {
                      tempWorkers
                          .removeWhere((e) => e.workerId == worker.workerId);
                    } else {
                      tempWorkers.add(worker);
                    }
                  });
                  setModalState(() {});
                },
              ),
            ),
          ),
        ));
  }
}
