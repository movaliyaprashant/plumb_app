import 'package:flutter/material.dart';
import 'package:plumbata/net/model/app_user.dart';
import 'package:plumbata/net/model/timesheet.dart';
import 'package:plumbata/providers/user.dart';
import 'package:plumbata/ui/home/contractor/timesheet_details/timesheet_details.dart';
import 'package:plumbata/ui/widgets/appbar.dart';
import 'package:plumbata/utils/app_utils.dart';
import 'package:plumbata/utils/colors.dart';
import 'package:provider/provider.dart';

class TimesheetList extends StatefulWidget {
  const TimesheetList({super.key, required this.status});
  final String status;

  @override
  State<TimesheetList> createState() => _TimesheetListState();
}

class _TimesheetListState extends State<TimesheetList> {
  bool isLoading = false;
  List<TimeSheet> timeSheets = [];
  Map<String, AppUser?> users = {};
  late UserProvider userProvider;

  @override
  void initState() {
    super.initState();
    userProvider = context.read<UserProvider>();

    getTimeSheets();
  }

  getTimeSheets() async {
    setState(() {
      isLoading = true;
    });

    timeSheets = await userProvider.getTimeSheets(status: widget.status);

    for (var timesheet in timeSheets) {
      var data = await timesheet.addedBy.get();
      if (data.exists == true) {
        AppUser user =
            AppUser.fromJson((data.data() ?? {}) as Map<String, dynamic>);
        print("user ${user.toJson().toString()}");
        users[user.uid ?? ""] = user;
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GeneralAppBar(
        title: 'Timesheets',
        backBtn: true,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : timeSheets.isEmpty
              ? Center(
                  child: Text(
                    "There's no Timesheets yet",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: timeSheets.length,
                  itemBuilder: (ctx, index) {
                    return buildTimeSheetCard(index);
                  }),
    );
  }

  buildTimeSheetCard(index) {
    return InkWell(
      onTap: () async {
        await Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => TimesheetDetails(
                  total: "".toString(),
                  timeSheet: timeSheets[index],
                  addedBy:
                      "${users[timeSheets[index].addedBy.path.replaceAll("users/", "").toString()]?.firstName}"
                      " ${users[timeSheets[index].addedBy.path.replaceAll("users/", "")..toString()]?.lastName}",
                )));
        getTimeSheets();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(15),
              bottomLeft: Radius.circular(15),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Created By:",
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.lightPrimaryColor,
                                  ),
                        ),
                        Text(
                          "${users[timeSheets[index].addedBy.path.replaceAll("users/", "").toString()]?.firstName}"
                          " ${users[timeSheets[index].addedBy.path.replaceAll("users/", "").toString()]?.lastName}",
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.lightPrimaryColor,
                                  ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.lightPrimaryColor),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(15),
                          bottomLeft: Radius.circular(15),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          AppUtils.capitalize(
                              timeSheets[index].isResubmitted == true
                                  ? "resubmitted"
                                  : timeSheets[index].status),
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyText1?.color,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 8.0,
                ),
                Row(
                  children: [
                    Icon(
                      Icons.watch_later_outlined,
                      color: AppColors.lightAccentColor,
                    ),
                    SizedBox(
                      width: 4.0,
                    ),
                    Text(
                      "Performed on: " +
                              formatDate(timeSheets[index].datePerformedOn) ??
                          "",
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.blueGrey),
                    ),
                  ],
                ),
                SizedBox(
                  height: 8.0,
                ),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: AppColors.lightAccentColor,
                    ),
                    SizedBox(
                      width: 4.0,
                    ),
                    Text(
                      timeSheets[index].workers.length.toString() + " Workers",
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.blueGrey),
                    ),
                  ],
                ),
                SizedBox(
                  height: 4.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  formatDate(DateTime? time) {
    if (time == null) time = DateTime.now();
    var t = "${time.day}/${time.month}/${time.year}";
    return t;
  }

  String calculateOverallTime(List<TimeSlot>? timeSlots) {
    Duration overallTime = Duration();

    for (TimeSlot slot in timeSlots ?? []) {
      DateTime? startTime = slot.startTime?.toDate();
      DateTime? endTime = slot.endTime?.toDate();

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

      Duration breakDuration = Duration(
        hours: slot.breakHrs ?? 0,
        minutes: slot.breakMins ?? 0,
      );

      Duration? timeSlotDuration = eTime.difference(sTime) - breakDuration;

      overallTime += timeSlotDuration;
    }

    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(overallTime.inMinutes.remainder(60));
    String twoDigitHours = twoDigits(overallTime.inHours);

    return "$twoDigitHours:$twoDigitMinutes";
  }

  getWorkerOrCrewName(TimeSheet timeSheet) {}
}
