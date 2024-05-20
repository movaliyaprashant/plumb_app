import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:plumbata/net/model/cost_code.dart';
import 'package:plumbata/net/model/timesheet.dart';
import 'package:plumbata/net/model/worker.dart';
import 'package:plumbata/providers/user.dart';
import 'package:plumbata/utils/app_utils.dart';
import 'package:plumbata/utils/colors.dart';
import 'package:provider/provider.dart';

class WorkerCardInfo extends StatefulWidget {
  const WorkerCardInfo(
      {super.key, required this.workerId, required this.workerCostCodes});
  final String workerId;
  final List workerCostCodes;

  @override
  State<WorkerCardInfo> createState() => _WorkerCardInfoState();
}

class _WorkerCardInfoState extends State<WorkerCardInfo> with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  List<CostCodeShift> codeShifts = [];
  late Worker? worker;
  bool isLoading = false;
  late UserProvider repo;

  @override
  void initState() {
    super.initState();
    repo = context.read<UserProvider>();

    getCodeShift();
  }

  getCodeShift() async {
    setState(() {
      isLoading = true;
    });

    for (DocumentReference ref in widget.workerCostCodes) {
      var data = await ref.get();
      var workerCostCodeData = data.data() as Map<String, dynamic> ?? {};
      var costCodeData = await workerCostCodeData['costCode'].get();
      CostCode costCode = CostCode.fromJson(costCodeData.data());
      workerCostCodeData['costCode'] = workerCostCodeData;

      CostCodeShift codeShift = CostCodeShift.fromJson(workerCostCodeData);
      print("codeShift ${codeShift.toString()}");
      print("costCode ${costCode.code.toString()}");
      codeShift.costCode = costCode;

      codeShifts.add(codeShift);
    }
    var workerDoc = await FirebaseFirestore.instance
        .collection("workers")
        .doc(widget.workerId.toString())
        .get();
    if (workerDoc.exists) {
      worker = Worker.fromJson(workerDoc.data() as Map<String, dynamic>);
    }

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
                            (worker?.firstName ?? "") +
                                " " +
                                (worker?.lastName ?? ""),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "Worker",
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
                      buildCostCodeOption(
                        title: "Cost code",
                        start: "Start",
                        finish: "Finish",
                        endText: "Break",
                        icon: Icons.code,
                      ),
                      for(var costCodeShift in codeShifts)
                        buildCostCodeOption(
                            title: costCodeShift.costCode?.code ?? "N/A",
                            start:
                            "${costCodeShift.startTime?.hour}:${costCodeShift.startTime?.minute.toString().padLeft(2, '0')}",
                            finish:
                            "${costCodeShift.endTime?.hour}:${costCodeShift.endTime?.minute.toString().padLeft(2, '0')}",
                            icon: Icons.code,
                            endText:
                            "${AppUtils.formatMinutesToHHMM(costCodeShift.breakMins ?? 0)}",
                           ),
                      SizedBox(
                        height: 8.0,
                      ),
                      SizedBox(height: 16,),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text("Total: ${calculateTotalWorkingHours(codeShifts)} HR", style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
  buildCostCodeOption(
      {required String title,
        required String start,
        required String finish,
        String? endText,
        required IconData icon,
        bool? hasDelete,
        Function? onPressDelete,
        bool hasAdd = false,
        Widget? subTitle}) {
    return Column(
      key: UniqueKey(),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  start,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey, fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: Text(
                  finish,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey, fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: Text(endText ?? "",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(),
        )
      ],
    );
  }
  calculateTotalWorkingHours(List<CostCodeShift> costCodeShifts) {
    int totalMins = 0;
    for(var costCodeShift in costCodeShifts) {
      Duration? difference = costCodeShift.endTime
          ?.difference(costCodeShift.startTime ?? DateTime.now());
      if (difference != null) {
        totalMins =
            totalMins + difference.inMinutes - (costCodeShift.breakMins ?? 0);
      }
    }
    int hours = totalMins ~/ 60;
    int minutes = totalMins % 60;

    String formattedTime = '$hours:${minutes.toString().padLeft(2, '0')}';

    return formattedTime;
  }


}
