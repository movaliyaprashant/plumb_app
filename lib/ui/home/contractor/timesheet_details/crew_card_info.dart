import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:plumbata/net/model/cost_code.dart';
import 'package:plumbata/net/model/crew.dart';
import 'package:plumbata/net/model/crew_time_sheet.dart';
import 'package:plumbata/net/model/timesheet.dart';
import 'package:plumbata/net/model/worker.dart';
import 'package:plumbata/providers/user.dart';
import 'package:plumbata/ui/home/contractor/timesheet_details/worker_in_crew_data.dart';
import 'package:plumbata/utils/app_utils.dart';
import 'package:plumbata/utils/colors.dart';
import 'package:provider/provider.dart';

class CrewCardInfo extends StatefulWidget {
  const CrewCardInfo(
      {super.key, required this.crewTimesheetDoc});
  final DocumentReference? crewTimesheetDoc;

  @override
  State<CrewCardInfo> createState() => _CrewCardInfoState();
}

class _CrewCardInfoState extends State<CrewCardInfo>  with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  List<CostCodeShift> codeShifts = [];
  CrewTimeSheet? crewTimeSheet;
  bool isLoading = false;
  late UserProvider repo;
  late Crew crew;
  Map<Worker, List<CostCodeShift>> workersCostCodeShifts = {};

  @override
  void initState() {
    super.initState();
    repo = context.read<UserProvider>();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    var crewTimesheetData = await widget.crewTimesheetDoc?.get();
    Map<String, dynamic>? data = crewTimesheetData?.data() as Map<String, dynamic>?;

    var crewDoc = await data?['crew'].get();
    print("crewDoc ${crewDoc.data()}");

    crew = Crew.fromJson(crewDoc.data());
    Map CrewWorkersWithCostCodeShifts = data?['crew_workers_cost_code_shifts'];

    for(String key in CrewWorkersWithCostCodeShifts.keys){
      var workerDoc = await FirebaseFirestore.instance
          .collection("workers")
          .doc(key)
          .get();

      if (workerDoc.exists) {
        Worker worker = Worker.fromJson(
            workerDoc.data() as Map<String, dynamic>);
        workersCostCodeShifts[worker] = [];

        List<CostCodeShift> workerCostCodeShifts = [];
        for (DocumentReference costCodeShiftRef in CrewWorkersWithCostCodeShifts[key]) {
          var costCodeShiftDoc = await costCodeShiftRef.get();
          Map<String, dynamic> costCodeShiftData = costCodeShiftDoc.data() as Map<String, dynamic>;
          DocumentReference costCodeRef = costCodeShiftData['costCode'];
          var costCodeData = await costCodeRef.get();
          CostCode costCode = CostCode.fromJson(costCodeData.data() as Map<String, dynamic>);

          CostCodeShift costCodeShift = CostCodeShift(
            costCode: costCode,
            startTime: costCodeShiftData['startTime'].toDate(),
            endTime: costCodeShiftData['endTime'].toDate(),
            breakMins: costCodeShiftData['breakMins'],
          );
          workerCostCodeShifts.add(costCodeShift);
        }
        workersCostCodeShifts[worker] = workerCostCodeShifts;
      }
    }

    crewTimeSheet = CrewTimeSheet(
        crewWorkers: [],
        crewWorkersCostCodeShifts: {},
        crew: crew);

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
      child: CircularProgressIndicator.adaptive(),
    ),
        )
        : Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 8.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      crew.name ?? "N/A",
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      "Crew",
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.lightPrimaryColor),
                    )
                  ],
                ),
                SizedBox(
                  height: 16.0,
                ),
                buildWorkersRows(),
                SizedBox(
                  height: 8.0,
                ),
                SizedBox(height: 16,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text("Crew Total: ${calculateCrewTotalTime()} HR", style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.0
                      ),),
                    ],
                  ),
                ),
                SizedBox(height: 16,),
              ],
            ),
          )),
    );
  }
  buildWorkersRows(){
    List<Widget> widgets = [];
    for(Worker worker in workersCostCodeShifts.keys){
      Widget widget = WorkerInCrewData(worker: worker,
        costCodeShifts: workersCostCodeShifts[worker],
        );
      widgets.add(widget);
      widgets.add(Divider());
    }
    return Column(
      children: widgets,
    );
  }

  calculateCrewTotalTime(){
    int totalMins = 0;
    for(Worker worker in workersCostCodeShifts.keys){
      List<CostCodeShift>? costCodeShifts = workersCostCodeShifts[worker];
      for(var costCodeShift in costCodeShifts??[]) {
        Duration? difference = costCodeShift.endTime
            ?.difference(costCodeShift.startTime ?? DateTime.now());
        if (difference != null) {
          totalMins =
              (totalMins + difference.inMinutes - (costCodeShift.breakMins ?? 0)).toInt();
        }
      }
    }

    int hours = totalMins ~/ 60;
    int minutes = totalMins % 60;
    String formattedTime = '$hours:${minutes.toString().padLeft(2, '0')}';
    return formattedTime;
  }


}
