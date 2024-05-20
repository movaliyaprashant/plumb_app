import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:plumbata/net/model/timesheet.dart';
import 'package:plumbata/providers/user.dart';
import 'package:plumbata/ui/widgets/appbar.dart';
import 'package:plumbata/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

/// The hove page which hosts the calendar
class ContractorCalender extends StatefulWidget {
  const ContractorCalender({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ContractorCalenderState createState() => _ContractorCalenderState();
}

class _ContractorCalenderState extends State<ContractorCalender> {
  late UserProvider userProvider;
  List<TimeSheet> timeSheets = [];
  bool isLoading = false;

  getTimeSheets() async {
    setState(() {
      isLoading = true;
    });
    timeSheets = await userProvider.getTimeSheets();
    print("timeSheets ${timeSheets}");
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    userProvider = context.read<UserProvider>();
    getTimeSheets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: GeneralAppBar(
          title: "Timesheets Calender",
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator.adaptive(),
              )
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SfCalendar(
                    showDatePickerButton: true,
                    showWeekNumber: true,
                    showNavigationArrow: true,
                    showCurrentTimeIndicator: true,
                    showTodayButton: true,
                    view: CalendarView.week,
                    dataSource: MeetingDataSource(_getDataSource()),
                    // by default the month appointment display mode set as Indicator, we can
                    // change the display mode as appointment using the appointment display
                    // mode property
                    monthViewSettings: const MonthViewSettings(
                        appointmentDisplayMode:
                            MonthAppointmentDisplayMode.appointment),
                  ),
                ),
              ));
  }

  List<TimeSlot> _getDataSource() {
    final List<TimeSlot> meetings = <TimeSlot>[];
    return meetings;
  }
}

/// An object to set the appointment collection data source to calendar, which
/// used to map the custom appointment data to the calendar appointment, and
/// allows to add, remove or reset the appointment collection.
class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<TimeSlot> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    Timestamp? time = _getTimeSlotData(index).startTime;
    return time?.toDate() ?? DateTime.now();
  }

  @override
  DateTime getEndTime(int index) {
    Timestamp? time = _getTimeSlotData(index).endTime;
    return time?.toDate() ?? DateTime.now();
  }

  @override
  String getSubject(int index) {
    return "";
  }

  @override
  Color getColor(int index) {
    String? status = _getTimeSlotData(index).status;
    if (status == "pending") {
      return Color(0xffF29339);
    } else if (status == "approved") {
      return Color(0xff039487);
    } else if (status == "rejected") {
      return Color(0xffa82e2e);
    }
    return Color(0xffF29339);
  }

  @override
  bool isAllDay(int index) {
    return false;
  }

  TimeSlot _getTimeSlotData(int index) {
    final dynamic timeSlot = appointments![index];
    late final TimeSlot timeSlotData;
    if (timeSlot is TimeSlot) {
      timeSlotData = timeSlot;
    }

    return timeSlotData;
  }
}
