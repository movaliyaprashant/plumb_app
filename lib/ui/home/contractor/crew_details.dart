import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:plumbata/net/model/app_user.dart';
import 'package:plumbata/net/model/crew.dart';
import 'package:plumbata/net/model/worker.dart';
import 'package:plumbata/providers/user.dart';
import 'package:plumbata/ui/home/contractor/add_new_crew.dart';
import 'package:plumbata/ui/widgets/appbar.dart';
import 'package:plumbata/utils/colors.dart';
import 'package:provider/provider.dart';

class CrewDetails extends StatefulWidget {
  const CrewDetails({super.key, required this.crew});
  final Crew crew;

  @override
  State<CrewDetails> createState() => _CrewDetailsState();
}

class _CrewDetailsState extends State<CrewDetails> {
  bool isLoading = false;
  late UserProvider userProvider;
  AppUser? createdByUser;
  List<Worker> workers = [];

  @override
  void initState() {
    super.initState();
    userProvider = context.read<UserProvider>();
    getUserCreatedBy();
  }

  getUserCreatedBy() async {
    setState(() {
      isLoading = true;
    });
    createdByUser =
        await userProvider.getUserDataById(id: widget.crew.createdBy?.path.replaceAll("users/", "") ?? "");
    workers =
        await userProvider.getWorkerListByIds(ids: widget.crew.workers ?? []);
    setState(() {
      isLoading = false;
    });
  }
  // getWorkerListByIds

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: GeneralAppBar(title: "Crew Details", backBtn: true),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.lightAccentColor,
          onPressed: () async {
            var res = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (ctx) => AddNewCrew(
                          isEdit: true,
                          editCrew: widget.crew,
                        )));
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.edit,
              color: Colors.white,
            ),
          ),
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                children: [
                  SizedBox(
                    height: 32,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Center(
                      child: Text(
                        "${widget.crew.name}",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Created By ${createdByUser?.firstName} ${createdByUser?.lastName}",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Last update ${getTime(widget.crew.updatedAt)}",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Crew Workers",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  for (Worker worker in workers) workerData(worker)
                ],
              ));
  }

  getTime(Timestamp? time) {
    if (time == null) time = Timestamp.now();

    DateTime date = time.toDate();
    return "${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute}";
  }

  workerData(Worker worker) {
    return ListTile(
      title: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
          child: Text(
            "${worker.firstName} ${worker.lastName}",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}
