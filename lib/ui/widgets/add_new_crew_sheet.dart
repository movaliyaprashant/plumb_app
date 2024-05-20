import 'package:flutter/material.dart';
import 'package:plumbata/net/model/crew.dart';
import 'package:plumbata/net/model/worker.dart';
import 'package:plumbata/providers/user.dart';
import 'package:plumbata/ui/home/contractor/select_worker_crew_step.dart';
import 'package:plumbata/ui/widgets/buttons.dart';
import 'package:plumbata/utils/app_utils.dart';
import 'package:plumbata/utils/colors.dart';
import 'package:provider/provider.dart';

class AddNewCrewToTimeSheet extends StatefulWidget {
  const AddNewCrewToTimeSheet({super.key, required this.afterDone});
  final Function afterDone;
  @override
  State<AddNewCrewToTimeSheet> createState() =>
      _AddNewCrewToTimeSheetState();
}

class _AddNewCrewToTimeSheetState extends State<AddNewCrewToTimeSheet> {
  TextEditingController searchTextController = TextEditingController();
  late UserProvider repo;
  List<Crew?> filterCrews = [];

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
                    filterCrews = repo.crews!
                        .where((w) => (w?.name
                        .toString()
                        .toLowerCase())
                        ?.contains(search.toLowerCase()) == true)
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
                  ? repo.crews?.length
                  : filterCrews.length),
              itemBuilder: (ctx, index) {
                var crew = repo.crews?[index];
                if (searchTextController.text.isNotEmpty) {
                  crew = filterCrews[index];
                }
                if (crew == null) {
                  return SizedBox();
                }
                return ListTile(
                  onTap: () {
                    repo.addRemoveCrewToTimesheet(crew!);
                    setState(() {});
                  },
                  title: Text(
                    (AppUtils.capitalize(crew.name) ?? ""),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var worker in crew.workers ?? [])
                        BuildWorkerName(worker: worker),
                    ],
                  ),
                  leading: Icon(Icons.person),
                  trailing: Checkbox(
                    activeColor: AppColors.lightAccentColor,
                    value: repo.timeSheetContainsCrew(crew!),
                    onChanged: (bool? value) {
                      repo.addRemoveCrewToTimesheet(crew!);
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
