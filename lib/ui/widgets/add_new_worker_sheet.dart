import 'package:flutter/material.dart';
import 'package:plumbata/net/model/worker.dart';
import 'package:plumbata/providers/user.dart';
import 'package:plumbata/ui/widgets/buttons.dart';
import 'package:plumbata/utils/app_utils.dart';
import 'package:plumbata/utils/colors.dart';
import 'package:provider/provider.dart';

class AddNewWorkerToTimeSheet extends StatefulWidget {
  const AddNewWorkerToTimeSheet({super.key, required this.afterDone});
  final Function afterDone;
  @override
  State<AddNewWorkerToTimeSheet> createState() =>
      _AddNewWorkerToTimeSheetState();
}

class _AddNewWorkerToTimeSheetState extends State<AddNewWorkerToTimeSheet> {
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
                    repo.addRemoveWorkerToTimesheet(worker!);
                    setState(() {});
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
                    value: repo.timeSheetContainsWorker(worker!),
                    onChanged: (bool? value) {
                      repo.addRemoveWorkerToTimesheet(worker!);
                      setState(() {});
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



}
