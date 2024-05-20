import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plumbata/net/model/cost_code.dart';
import 'package:plumbata/net/model/crew.dart';
import 'package:plumbata/net/model/timesheet.dart';
import 'package:plumbata/net/model/worker.dart';

class CrewTimeSheet {
  CrewTimeSheet({
    required this.crewWorkers,
    required this.crewWorkersCostCodeShifts,
    required this.crew,
  });
  List<Worker>? crewWorkers = [];
  Crew crew;
  Map<String, List<CostCodeShift>> crewWorkersCostCodeShifts = {};

  static fromFirestore(DocumentSnapshot document) async {
    final crewData = document.data() as Map<String, dynamic>;

    // Extracting Crew data
    final Crew crew = await Crew.crewFromRef(crewData['crew'] as DocumentReference);

    // Extracting Crew Workers data
    List<Worker> workers = [];
    for(var ref in crewData['crew_workers']){
      var workerDoc = await ref.get();
      if(workerDoc.exists == true){
        var WorkerData = workerDoc.data();
        Worker worker = Worker.fromJson(WorkerData);
        workers.add(worker);
      }
    }
    final List<Worker>? crewWorkers = workers;

    // Extracting Crew Workers Cost Code Shifts data
    final Map<String, List<CostCodeShift>> crewWorkersCostCodeShifts = {};

    final Map<String, dynamic>? costCodeShiftsData = crewData['crew_workers_cost_code_shifts'] as Map<String, dynamic>;

    print("costCodeShiftsData ${costCodeShiftsData.toString()}");
    if (costCodeShiftsData != null) {
      for (var workerId in costCodeShiftsData.keys) {
        var shiftsData = costCodeShiftsData[workerId];
        List<CostCodeShift> costCodeShifts = [];
        print("shiftsData** ${shiftsData.toString()}");

        for (var shiftData in shiftsData) {
          var shiftDataDoc = await shiftData.get();
          var shiftDataData = shiftDataDoc.data();
          var costCodeData = shiftDataData as Map<String, dynamic>;
          var costCodeDoc = await costCodeData['costCode'].get();
          CostCode costCode = CostCode.fromJson(costCodeDoc.data() as Map<String, dynamic>);
          CostCodeShift costCodeShift = CostCodeShift(
            costCode: costCode,
            startTime: shiftDataData['startTime'].toDate(),
            endTime: shiftDataData['endTime'].toDate(),
            breakMins: shiftDataData['breakMins'],
          );
          print("costCodeShift&& ${costCodeShift.toString()}");
          costCodeShifts.add(costCodeShift);
        }
        crewWorkersCostCodeShifts[workerId] = costCodeShifts;
      }
    }
    return CrewTimeSheet(
      crewWorkers: crewWorkers,
      crewWorkersCostCodeShifts: crewWorkersCostCodeShifts,
      crew: crew,
    );
  }

  String printData() {
    print('Crew Workers:');
    crewWorkers?.forEach((worker) {
      print(' - ${worker.toString()}');
    });

    print('\nCrew:');
    print(' - ${crew.toString()}');

    print('\nCrew Workers Cost Code Shifts:');
    crewWorkersCostCodeShifts.forEach((workerId, shifts) {
      print('Worker ID: $workerId');
      shifts.forEach((shift) {
        print('  - ${shift.toString()}');
      });
    });

    return "";
  }

}

