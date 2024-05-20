import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:plumbata/net/model/crew.dart';
import 'package:plumbata/net/model/timesheet.dart';
import 'package:plumbata/net/model/worker.dart';
import 'package:plumbata/providers/user.dart';
import 'package:plumbata/ui/home/contractor/add_new_timesheet.dart';
import 'package:plumbata/ui/home/contractor/timesheet_chat.dart';
import 'package:plumbata/ui/home/contractor/timesheet_details/crew_card_info.dart';
import 'package:plumbata/ui/home/contractor/timesheet_details/worker_card_info.dart';
import 'package:plumbata/ui/widgets/appbar.dart';
import 'package:plumbata/ui/widgets/time_sheet_buttons.dart';
import 'package:plumbata/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class TimesheetDetails extends StatefulWidget {
  const TimesheetDetails(
      {super.key,
      required this.timeSheet,
      required this.addedBy,
      required this.total});
  final TimeSheet timeSheet;
  final String addedBy;
  final String total;

  @override
  State<TimesheetDetails> createState() => _TimesheetDetailsState();
}

class _TimesheetDetailsState extends State<TimesheetDetails> {
  TimeSheet? timeSheet;

  Map<String, Worker> workers = {};
  Map<String, Crew> crews = {};
  late UserProvider userProvider;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    timeSheet = widget.timeSheet;
    userProvider = context.read<UserProvider>();
    getWorkersAndCrews();
  }

  updateTimesheet() async {
    setState(() {
      isLoading = true;
    });

    timeSheet = await userProvider.getTimeSheetById(timeSheet?.timeSheetId);

    setState(() {
      isLoading = false;
    });
  }

  updateTimeSheet() async {
    setState(() {
      isLoading = true;
    });
    timeSheet = await userProvider.getTimeSheetById(timeSheet?.timeSheetId);
    setState(() {
      isLoading = false;
    });
  }

  getWorkersAndCrews() async {
    setState(() {
      isLoading = true;
    });
    List<Worker> workersList = await userProvider.getContractWorkers(
        contractId: userProvider.currentContract?.contractId ?? "");
    for (Worker w in workersList) {
      workers[w.workerId ?? ""] = w;
    }

    List<Crew> crewsList = await userProvider.getContractCrews(
        contractId: userProvider.currentContract?.contractId ?? "");
    for (Crew c in crewsList) {
      crews[c.crewId ?? ""] = c;
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(timeSheet?.files.toString());
    return Scaffold(
        appBar: GeneralAppBar(
            title: "Timesheet Details",
            backBtn: true,
            // actions: Padding(
            //   padding: const EdgeInsets.only(top: 2, left: 4),
            //   child: timeSheet?.status?.toString().toLowerCase() ==
            //           "need_changes"
            //       ? TextButton(
            //           onPressed: () {},
            //           style: ElevatedButton.styleFrom(
            //             backgroundColor: AppColors
            //                 .lightAccentColor, // Set the background color
            //           ),
            //           child: Text(
            //             "Edit",
            //             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            //                 color: Colors.white,
            //                 fontSize: 14,
            //                 fontWeight: FontWeight.w600),
            //           ),
            //         )
            //       : SizedBox(),
           // )
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.lightAccentColor,
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (ctx) => TimesheetComments(
                      timesheetId: timeSheet?.timeSheetId ?? "",
                    )));
          },
          child: Icon(Icons.chat_bubble),
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: 6 +
                    (timeSheet?.workersCostCodes.keys.length ?? 0) +
                    (timeSheet?.crewTimeSheet?.length ?? 0) +
                    (timeSheet?.files.length ?? 0),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildAddedBySection();
                  } else if (index == 1) {
                    return _buildPerformedOnSection();
                  } else if (index == 2) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Divider(
                        thickness: 2,
                      ),
                    );
                  } else if (index == 3) {
                    return _buildCommentSection();
                  } else if (index == 4) {
                    return SizedBox(height: 16.0);
                  } else if (index <
                      5 + (timeSheet?.workersCostCodes.keys.length ?? 0)) {
                    return _buildWorkerCardSection(index - 5);
                  } else if (index <
                      5 +
                          (timeSheet?.workersCostCodes.keys.length ?? 0) +
                          (timeSheet?.crewTimeSheet?.length ?? 0)) {
                    return _buildCrewCardSection(index -
                        5 -
                        (timeSheet?.workersCostCodes.keys.length ?? 0));
                  } else if (index <
                      5 +
                          (timeSheet?.workersCostCodes.keys.length ?? 0) +
                          (timeSheet?.crewTimeSheet?.length ?? 0) +
                          (timeSheet?.files.length ?? 0)) {
                    return _buildFileRowSection(index -
                        5 -
                        (timeSheet?.workersCostCodes.keys.length ?? 0) -
                        (timeSheet?.crewTimeSheet?.length ?? 0));
                  } else {
                    return _buildAcceptRejectSection();
                  }
                },
              ));
  }

  Widget _buildAddedBySection() {
    return ListTile(
      title: Text(
        "Added By: " + widget.addedBy,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
      trailing: statusTag(),
    );
  }

  Widget _buildPerformedOnSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        "Performed On: " +
            formatTimestampDate(Timestamp.fromDate(
                timeSheet?.datePerformedOn ?? DateTime.now())),
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: Color(0xff777777), fontWeight: FontWeight.w600),
      ),
    );
  }

  bool isPending() {
    return timeSheet?.status?.toString().toLowerCase() == "pending";
  }

  Widget _buildCommentSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        timeSheet?.comment == ""
            ? "There's no note about this timesheet"
            : timeSheet?.comment ?? "There's no note about this timesheet",
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: timeSheet?.comment == ""
                ? Colors.grey
                : AppColors.lightBodyTextColor),
      ),
    );
  }

  Widget _buildWorkerCardSection(int workerIndex) {
    var key = timeSheet?.workersCostCodes.keys.toList()[workerIndex];
    return WorkerCardInfo(
      key: ValueKey<int>(workerIndex),
      workerId: key ?? "$workerIndex",
      workerCostCodes: timeSheet?.workersCostCodes[key],
    );
  }

  Widget _buildCrewCardSection(int crewIndex) {
    var doc = timeSheet?.crewTimeSheet?[crewIndex];
    return CrewCardInfo(key: ValueKey<int>(crewIndex), crewTimesheetDoc: doc);
  }

  Widget _buildFileRowSection(int fileIndex) {
    return buildFileRow(timeSheet?.files[fileIndex], fileIndex);
  }

  Widget _buildAcceptRejectSection() {
    return userProvider.isSuperIntendent() &&
            timeSheet?.status.trim().toLowerCase() == "pending"
        ? Padding(
            padding: const EdgeInsets.only(
                top: 32.0, bottom: 80, right: 16.0, left: 16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: RoundedButton(
                        text: 'Request Changes',
                        color: Colors.grey,
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (ctx) => TimesheetComments(
                                    timesheetId: timeSheet?.timeSheetId ?? "",
                                    requestChanges: true,
                                    onRequestChanges: () async {
                                      await userProvider.rejectTimesheet(
                                          widget.timeSheet.timeSheetId);
                                      updateTimesheet();
                                      Navigator.pop(context);
                                    },
                                  )));
                        },
                      ),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Expanded(
                      child: RoundedButton(
                        text: 'Approve',
                        color: Colors.green,
                        onPressed: () {
                          showConfirmationDialog(context,
                              'Are you sure you want to approve this Timesheet?',
                              () async {
                            await userProvider
                                .approveTimesheet(widget.timeSheet.timeSheetId);
                            updateTimesheet();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                      ),
                      onPressed: () {
                        showConfirmationDialog(context,
                            'By Escalating this issue you wont\'t be able to edit this timesheet, are you sure?',
                            () async {
                          await userProvider
                              .esculateTimesheet(widget.timeSheet.timeSheetId);
                          updateTimesheet();
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.error,
                            color: AppColors.errorColor,
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Text(
                            "Escalate this timesheet to the manager",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.errorColor,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        : Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
      children: [
          timeSheet?.status.toString().toLowerCase() ==
              "need_changes" ? Expanded(
            child: RoundedButton(
              text: 'Edit Timesheet',
              color: AppColors.lightPrimaryColor,
              onPressed: () async {
                await Navigator.of(context)
                    .push(MaterialPageRoute(builder: (ctx) => AddNewTimeSheet(
                  timesheet: widget.timeSheet,
                  isEdit: true,
                )));
                updateTimesheet();
              },
            ),
          ):SizedBox(),
      ],
    ),
        );
  }

  statusTag() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: timeSheet != null
              ? timeSheet?.status.toLowerCase() == "pending"
                  ? Color(0xFFFFA500) // Pending color
                  : timeSheet?.status.toLowerCase() == "need_changes"
                      ? Colors.red // Rejected color
                      : timeSheet?.status.toLowerCase() == "approved"
                          ? Color(0xFF67B070) // Approved color
                          : Colors.black // Default color (if none of the above)
              : Colors.black, // Default color (if timeSheet is null),
          borderRadius: BorderRadius.circular(50.0),
        ),
        child: Text(
            timeSheet?.isResubmitted == true? "Resubmitted":
            (timeSheet?.status?.substring(0, 1).toUpperCase() ?? "") +
                    (timeSheet?.status?.substring(1).toLowerCase() ?? "") ??
                "",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 14.0,
                color: Colors.white,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  timeSlotRow(TimeSlot timeSlot) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ListTile(
                title: Text(
                  getName(timeSlot),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(getDetails(timeSlot)),
                trailing: Container(
                  decoration: BoxDecoration(
                    color: AppColors.lightAccentColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      "${calculateTime(timeSlot.startTime, timeSlot.endTime, timeSlot.breakHrs ?? 0, timeSlot.breakMins ?? 0)} hr",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 16.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                      child: slotItem("Start Time",
                          formatFirestoreTimestamp(timeSlot.startTime))),
                  Expanded(
                      child: slotItem("End Time",
                          formatFirestoreTimestamp(timeSlot.endTime))),
                  Expanded(
                      child: slotItem("Breaks",
                          "${timeSlot.breakHrs}:${timeSlot.breakMins.toString().padLeft(2, '0')}")),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  slotItem(String title, String details) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Color(0xFFeeeeee),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: Column(
            children: [
              SizedBox(
                height: 4,
              ),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold, color: Color(0xff474747)),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                details,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: Color(0xff474747)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String formatFirestoreTimestamp(Timestamp? firestoreTimestamp) {
    // Convert Firestore Timestamp to DateTime
    DateTime dateTime = firestoreTimestamp?.toDate() ?? DateTime.now();

    // Format the time part as "hh:mm"
    String formattedTime =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    return formattedTime;
  }

  String formatTimestampDate(Timestamp? timeStampDate) {
    DateTime dateTime = timeStampDate?.toDate() ?? DateTime.now();

    String formattedTime =
        '${dateTime.day.toString()}-${dateTime.month.toString()}-${dateTime.year.toString()}';

    return formattedTime;
  }

  String calculateTime(
      Timestamp? start, Timestamp? end, int breakHrs, int breakMins) {
    // Convert Firestore Timestamps to DateTime objects
    DateTime startTime = start?.toDate() ?? DateTime.now();
    DateTime endTime = end?.toDate() ?? DateTime.now();

    DateTime now = DateTime.now();
    DateTime sTime = DateTime(
        startTime?.year ?? now.year,
        startTime?.month ?? now.month,
        startTime?.day ?? now.day,
        startTime?.hour ?? now.hour,
        startTime?.minute ?? now.minute);
    DateTime eTime = DateTime(
        endTime?.year ?? now.year,
        endTime?.month ?? now.month,
        endTime?.day ?? now.day,
        endTime?.hour ?? now.hour,
        endTime?.minute ?? now.minute);

    // Calculate the time difference
    Duration difference = eTime.difference(sTime);

    // Subtract break time
    Duration breakTime = Duration(hours: breakHrs, minutes: breakMins);
    Duration netTime = difference - breakTime;

    // Format the net time as "HH:mm"
    String formattedNetTime =
        '${netTime.inHours.toString().padLeft(2, '0')}:${(netTime.inMinutes % 60).toString().padLeft(2, '0')}';

    return formattedNetTime;
  }

  getDetails(TimeSlot slot) {
    if (slot.workerId != null && slot.workerId != "") {
      if (workers.containsKey(slot.workerId)) {
        return (workers[slot.workerId]?.classification ?? "");
      }
    }
    if (slot.crewId != null && slot.crewId != "") {
      if (crews.containsKey(slot.crewId)) {
        return (crews[slot.crewId]?.workers?.length.toString() ?? "") +
            " workers";
      }
    }
    return "";
  }

  getName(TimeSlot slot) {
    if (slot.workerId != null && slot.workerId != "") {
      if (workers.containsKey(slot.workerId)) {
        return "Worker - " +
            (workers[slot.workerId]?.firstName ?? "") +
            " ${(workers[slot.workerId]?.lastName ?? "")}";
      }
    }
    if (slot.crewId != null && slot.crewId != "") {
      if (crews.containsKey(slot.crewId)) {
        return "Crew - " + (crews[slot.crewId]?.name.toString() ?? "");
      }
    }
    return "N/A";
  }

  buildFileRow(url, index) {
    return url != null
        ? Column(
            children: [
              ListTile(
                onTap: () async {
                  if (!await launchUrl(Uri.parse(url))) {
                    throw Exception('Could not launch $url');
                  }
                },
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xff1d8da3),
                ),
                title: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Timesheet file ${index.toString()}",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold, color: Color(0xff1d8da3)),
                  ),
                ),
              ),
              Divider(),
            ],
          )
        : SizedBox();
  }

  double convertToHours(String timeString) {
    // Split the string into hours and minutes
    List<String> parts = timeString.split(':');
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);

    // Calculate the total hours
    double totalHours = hours + (minutes / 60);

    // Round to two decimal places
    double roundedHours = double.parse(totalHours.toStringAsFixed(2));

    return roundedHours;
  }

  void showConfirmationDialog(BuildContext context, String message, onYes) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text(
            message,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Handle "No" button press
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'No',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () {
                // Handle "Yes" button press
                // You can add your approval logic here
                onYes();
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'Yes',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}

class RoundedButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;

  RoundedButton({
    required this.text,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      ),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}
