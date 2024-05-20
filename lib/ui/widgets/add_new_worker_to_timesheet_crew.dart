import 'package:flutter/material.dart';
import 'package:plumbata/net/model/crew_time_sheet.dart';
import 'package:plumbata/net/model/timesheet.dart';
import 'package:plumbata/net/model/worker.dart';
import 'package:plumbata/providers/user.dart';
import 'package:plumbata/ui/widgets/buttons.dart';
import 'package:plumbata/utils/app_utils.dart';
import 'package:plumbata/utils/colors.dart';
import 'package:provider/provider.dart';

class AddNewWorkerToTimeSheetCrew extends StatefulWidget {
  const AddNewWorkerToTimeSheetCrew({super.key,
    required this.afterDone,
    required this.crewTimeSheet,
    required this.costCodeShift,
    required this.onDeleteWorker,
    required this.onAddWorker,
  });

  final Function afterDone;
  final Function onDeleteWorker;
  final Function onAddWorker;
  final CrewTimeSheet? crewTimeSheet;
  final CostCodeShift costCodeShift;

  @override
  State<AddNewWorkerToTimeSheetCrew> createState() =>
      _AddNewWorkerToTimeSheetCrewState();
}

class _AddNewWorkerToTimeSheetCrewState extends State<AddNewWorkerToTimeSheetCrew> {
  TextEditingController searchTextController = TextEditingController();
  late UserProvider repo;
  List<Worker?> filterWorkers = [];

  @override
  void initState() {
    super.initState();
    repo = context.read<UserProvider>();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 700,
      child: Column(
        children: [
          SizedBox(
            height: 16.0,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              height: 50,
              child: TextField(
                decoration: const InputDecoration(hintText: 'Search'),
                autofocus: false,
                onChanged: (search) {
                  setState(() {
                    filterWorkers = repo.workers!
                        .where((w) => (w?.firstName
                        .toString()
                        .toLowerCase() ??
                        "" +
                            " " +
                            (w?.lastName.toString().toLowerCase() ??
                                ""))
                        .contains(search.toLowerCase()))
                        .toList();
                  });
                },
                controller: searchTextController,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: (searchTextController.text.isEmpty
                  ? repo.workers?.length
                  : filterWorkers.length),
              itemBuilder: (ctx, index) {
                var worker = repo.workers?[index];
                if (searchTextController.text.isNotEmpty) {
                  worker = filterWorkers[index];
                }
                if (worker == null) {
                  return SizedBox();
                }
                return ListTile(
                  onTap: () {
                    if(selectedWorkersHasWorker(worker) == true){
                      widget.onDeleteWorker(worker);
                    }else{
                      widget.onAddWorker(worker);
                    }
                    setState(() {});
                    widget.afterDone();
                  },
                  title: Text(
                    (AppUtils.capitalize(worker?.firstName) ?? "") +
                        " " +
                        (AppUtils.capitalize(worker?.lastName) ?? ""),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    (AppUtils.capitalize(worker?.classification)),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                        fontWeight: FontWeight.bold, fontSize: 14.0),
                  ),
                  leading: Icon(Icons.person),
                  trailing: Checkbox(
                    activeColor: AppColors.lightAccentColor,
                    value: selectedWorkersHasWorker(worker),
                    onChanged: (bool? value) {
                      if(selectedWorkersHasWorker(worker) == true){
                        widget.onDeleteWorker(worker);
                      }else{
                        widget.onAddWorker(worker);
                      }
                      setState(() {});
                      widget.afterDone();
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: PrimaryButton("Done", onPressed: () {
              Navigator.pop(context);
              widget.afterDone();
            }),
          ),
          SizedBox(height: 32,)
        ],
      ),
    );
  }

  selectedWorkersHasWorker(listWorkers){
    for(Worker? worker in  widget.crewTimeSheet?.crewWorkers??[]){
      if(worker?.workerId == listWorkers?.workerId){
        return true;
      }
    }
    return false;
  }

}
