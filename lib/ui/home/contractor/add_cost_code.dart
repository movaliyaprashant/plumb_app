import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plumbata/net/model/cost_code.dart';
import 'package:plumbata/providers/user.dart';
import 'package:plumbata/ui/widgets/appbar.dart';
import 'package:plumbata/ui/widgets/buttons.dart';
import 'package:plumbata/utils/colors.dart';
import 'package:plumbata/utils/error_utils.dart';
import 'package:plumbata/utils/icons.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:provider/provider.dart';

class AddNewCostCode extends StatefulWidget {
  const AddNewCostCode({super.key, this.code, this.isEdit});
  final CostCode? code;
  final bool? isEdit;

  @override
  State<AddNewCostCode> createState() => _AddNewCostCodeState();
}

class _AddNewCostCodeState extends State<AddNewCostCode> {
  bool isLoading = false;
  late UserProvider userProvider;

  TextEditingController _code = TextEditingController();
  TextEditingController _description = TextEditingController();
  TextEditingController _progress = TextEditingController();
  TextEditingController _completedHours = TextEditingController();
  TextEditingController _estimatedHours = TextEditingController();
  TextEditingController _startDate = TextEditingController();
  DateTime startDate = DateTime.now();
  TextEditingController _targetCompleteDate = TextEditingController();
  DateTime targetCompleteDate = DateTime.now();

  String verifyError = "";

  @override
  void initState() {
    super.initState();
    userProvider = context.read<UserProvider>();
    if (widget.isEdit == true) {
      _code.text = widget.code?.code ?? "";
      _description.text = widget.code?.description ?? "";
      _completedHours.text = widget.code?.completedHours.toString() ?? "0";
      _estimatedHours.text = widget.code?.estimatedHours.toString() ?? "0";
      _startDate.text = widget.code?.startDate?.toDate().toIso8601String() ??
          DateTime.now().toIso8601String();
      startDate = DateTime.parse(_startDate.text);
      _targetCompleteDate.text =
          widget.code?.targetCompletionDate?.toDate().toIso8601String() ??
              DateTime.now().toIso8601String();
      targetCompleteDate = DateTime.parse(_targetCompleteDate.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GeneralAppBar(
        title: widget.isEdit == true ? 'Edit Contract Code' : 'Add Contract Code',
        backBtn: true,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      SizedBox(
                        height: 16,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextFormField(
                          controller: _code,
                          autocorrect: false,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              hintText: 'Code',
                              prefixIcon: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Icon(Icons.abc))),
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextFormField(
                          controller: _description,
                          autocorrect: false,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              hintText: 'Description',
                              prefixIcon: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Icon(Icons.description))),
                        ),
                      ),
                      // SizedBox(
                      //   height: 16,
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      //   child: TextFormField(
                      //     controller: _progress,
                      //     autocorrect: false,
                      //     keyboardType: TextInputType.number,
                      //     decoration: InputDecoration(
                      //         contentPadding: EdgeInsets.symmetric(
                      //             horizontal: 16, vertical: 16),
                      //         hintText: 'Progress',
                      //         prefixIcon: Padding(
                      //             padding: const EdgeInsets.all(16.0),
                      //             child: Icon(Icons.percent_sharp))),
                      //   ),
                      // ),
                      SizedBox(
                        height: 16,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextFormField(
                          controller: _completedHours,
                          autocorrect: false,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              hintText: 'Completed Hours',
                              prefixIcon: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Icon(Icons.numbers))),
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextFormField(
                          controller: _estimatedHours,
                          autocorrect: false,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              hintText: 'Estimated Hours',
                              prefixIcon: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Icon(Icons.numbers))),
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          "Start Date",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          showDatePicker(_startDate);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: TextFormField(
                            controller: _startDate,
                            autocorrect: false,
                            enabled: false,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                hintText: 'Set Start Date',
                                prefixIcon: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Icon(Icons.timelapse_outlined))),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          "Target Complete Date",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          showDatePicker(_targetCompleteDate);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: TextFormField(
                            controller: _targetCompleteDate,
                            autocorrect: false,
                            enabled: false,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                hintText: 'Set Target Complete Date',
                                prefixIcon: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Icon(Icons.timelapse))),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      verifyError != ""
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Text(
                                verifyError,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: AppColors.errorColor),
                              ),
                            )
                          : SizedBox(),
                      SizedBox(
                        height: 16,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: PrimaryButton(
                    widget.isEdit == true ? "Edit Contract Code" : 'Add Contract Code',
                    isLoading: isLoading,
                    onPressed: () {
                      addNewCostCode();
                    },
                  ),
                ),
                SizedBox(
                  height: 32,
                )
              ],
            ),
    );
  }

  addNewCostCode() async {
    verifyError = "";
    if (_code.text.isEmpty) {
      verifyError += " * Code should not be empty";
    }
    if (_description.text.isEmpty) {
      verifyError += "\n * Description should not be empty";
    }
    if (_estimatedHours.text.isEmpty) {
      verifyError += "\n * Estimate Hours should not be empty";
    }
    if (_startDate.text.isEmpty) {
      verifyError += "\n * Start Date should not be empty";
    }
    if (_targetCompleteDate.text.isEmpty) {
      verifyError += "\n * Target Complete Date should not be empty";
    }
    setState(() {});
    if (verifyError != "") {
      print("verifyError $verifyError");
      return;
    }
    print("verifyError $verifyError");

    setState(() {
      isLoading = true;
    });

    bool result = await userProvider.addNewCostCode(
        code: _code.text.trim(),
        description: _description.text.trim(),
        estimatedHours: int.parse(_estimatedHours.text.trim()),
        //progress: _progress.text.isEmpty ? 0 : int.parse(_progress.text.trim()),
        completedHours: _completedHours.text.isEmpty
            ? 0
            : int.parse(_completedHours.text.trim()),
        startDate: startDate,
        targetCompletionDate: targetCompleteDate,
        isEdit: widget.isEdit == true,
        editCostCode: widget.code,
    );

    if (result == true) {
      ErrorUtils.showSuccessMessage(context, "Contract Code added successfully");

      _code.clear();
      _description.clear();
      _completedHours.clear();
      _estimatedHours.clear();
      _startDate.clear();
      _targetCompleteDate.clear();

      setState(() {
        isLoading = false;
      });

      await Future.delayed(Duration(seconds: 2));
      Navigator.pop(context);
      Navigator.pop(context);
    } else {
      ErrorUtils.showGeneralError(context, "Contract Code could not be added",
          duration: Duration(seconds: 3));
    }
    setState(() {
      isLoading = false;
    });
  }

  showDatePicker(TextEditingController controller) {
    picker.DatePicker.showDateTimePicker(context,
        showTitleActions: true,
        minTime: DateTime(2018, 3, 5),
        maxTime: DateTime(2025, 6, 7), onChanged: (date) {
      print('change $date in time zone ' +
          date.timeZoneOffset.inHours.toString());
    }, onConfirm: (date) {
      print('confirm $date');
      if (controller == _startDate) {
        startDate = date;
      } else {
        targetCompleteDate = date;
      }
      controller.text =
          "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2,'0')}";
      setState(() {});
    }, currentTime: DateTime.now(), locale: picker.LocaleType.en);
  }
}
