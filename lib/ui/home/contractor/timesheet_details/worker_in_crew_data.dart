

import 'package:flutter/material.dart';
import 'package:plumbata/net/model/timesheet.dart';
import 'package:plumbata/net/model/worker.dart';
import 'package:plumbata/utils/app_utils.dart';

class WorkerInCrewData extends StatefulWidget {
  const WorkerInCrewData({super.key,
    required this.worker,
    required this.costCodeShifts,
  });

  final Worker worker;
  final List<CostCodeShift>? costCodeShifts;

  @override
  State<WorkerInCrewData> createState() => _WorkerInCrewDataState();
}

class _WorkerInCrewDataState extends State<WorkerInCrewData> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                (widget.worker.firstName ?? "") +
                    " " +
                    (widget.worker?.lastName ?? ""),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
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
          for(var costCodeShift in widget.costCodeShifts??[])
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
                Text("Total: ${calculateTotalWorkingHours(widget.costCodeShifts)} HR", style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.0
                ),),
              ],
            ),
          ),
          SizedBox(height: 16,),
        ],
      ),
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
  calculateTotalWorkingHours(List<CostCodeShift>? costCodeShifts) {
    int totalMins = 0;
    for(var costCodeShift in costCodeShifts??[]) {
      Duration? difference = costCodeShift.endTime
          ?.difference(costCodeShift.startTime ?? DateTime.now());
      if (difference != null) {
        totalMins =
        (totalMins + difference.inMinutes - (costCodeShift.breakMins ?? 0)).toInt();
      }
    }
    int hours = totalMins ~/ 60;
    int minutes = totalMins % 60;

    String formattedTime = '$hours:${minutes.toString().padLeft(2, '0')}';

    return formattedTime;
  }
}
