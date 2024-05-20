import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:plumbata/net/model/worker.dart';
import 'package:plumbata/providers/user.dart';
import 'package:plumbata/ui/widgets/appbar.dart';
import 'package:plumbata/ui/widgets/buttons.dart';
import 'package:plumbata/utils/app_utils.dart';
import 'package:plumbata/utils/colors.dart';
import 'package:plumbata/utils/fonts.dart';
import 'package:plumbata/utils/icons.dart';
import 'package:provider/provider.dart';

class ContractWorkers extends StatefulWidget {
  const ContractWorkers({super.key});

  @override
  State<ContractWorkers> createState() => _ContractWorkersState();
}

class _ContractWorkersState extends State<ContractWorkers> {
  late UserProvider userProvider;

  TextEditingController _fname = TextEditingController();
  FocusNode _fnameFocusNode = FocusNode();
  FocusNode _lnameFocusNode = FocusNode();
  FocusNode _classificationFocusNode = FocusNode();

  TextEditingController _lname = TextEditingController();
  TextEditingController _classification = TextEditingController();

  String _fnameValueBeforeEdit = '';
  String _lnameValueBeforeEdit = '';
  String _classificationValueBeforeEdit = '';

  bool _isLoading = false;

  List<Worker> workers = [];
  bool isLoading = false;

  String? validateError;

  @override
  void initState() {
    super.initState();
    userProvider = context.read<UserProvider>();
    getContractWorkers();
  }

  getContractWorkers() async {
    setState(() {
      isLoading = true;
    });
    workers = await userProvider.getContractWorkers(
        contractId: userProvider.currentContract?.contractId ?? "");

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context, listen: true);

    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            addNewWorker();
          },
          backgroundColor: AppColors.lightAccentColor,
          child: Icon(Icons.add),
        ),
        appBar: GeneralAppBar(title: "Contract Workers", backBtn: true),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : workers.isEmpty
                ? Center(
                    child: Text(
                      "There's no workers yet",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: workers.length,
                    itemBuilder: (ctx, index) {
                      return workerCard(workers[index]);
                    }));
  }

  workerCard(Worker worker) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                (capitalize(worker.firstName ?? "")) +
                    " " +
                    (capitalize(worker.lastName ?? "")),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600, fontSize: 18.0),
              ),
            ),
            Divider(),
            ListTile(
              title: Text(
                (capitalize(worker.classification.toString())),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600, fontSize: 16.0),
              ),
            ),
            Container(
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SimpleOutlinedButton(
                        "Edit Worker",
                        bgColor: AppColors.lightBorderColor.withOpacity(0.5),
                        onPressed: () async {
                          addNewWorker(isEdit: true, worker: worker);
                        },
                        textStyle: TextStyle(
                          color: Color(0xfff16075),
                          fontSize: 14,
                          fontFamily: kOpenSansFont,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SimpleOutlinedButton(
                        "Delete Worker",
                        bgColor: AppColors.lightBorderColor.withOpacity(0.5),
                        onPressed: () {
                          AppUtils.showYesNoDialog(context, onYes: () async {
                            await userProvider.deleteWorker(worker.workerId);
                            getContractWorkers();
                          },
                              onNo: () {},
                              title: 'Delete Worker',
                              message:
                                  'Are you sure you want to delete the worker ${(capitalize(worker.firstName ?? "")) + " " + (capitalize(worker.lastName ?? ""))}?');
                        },
                        textStyle: TextStyle(
                          color: Color(0xfff16075),
                          fontSize: 14,
                          fontFamily: kOpenSansFont,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  addNewWorker({isEdit = false, Worker? worker}) async {
    if (isEdit == true) {
      _fname.text = worker?.firstName ?? "";
      _lname.text = worker?.lastName ?? "";
      _classification.text = worker?.classification ?? "";

      _fnameValueBeforeEdit = worker?.firstName ?? "";
      _lnameValueBeforeEdit = worker?.lastName ?? "";
      _classificationValueBeforeEdit = worker?.classification ?? "";
    }

    await showMaterialModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        context: context,
        builder: (context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setModalState) {
              return Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: SizedBox(
                  height: 600,
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          children: [
                            Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: TextFormField(
                                  controller: _fname,
                                  inputFormatters: <TextInputFormatter>[
                                    UpperCaseTextFormatter()
                                  ],
                                  textCapitalization: TextCapitalization.words,
                                  keyboardType: TextInputType.name,
                                  focusNode: _fnameFocusNode,
                                  onTap: () {
                                    // Set cursor position when the text field is tapped
                                    _setCursorPosition(_fname, _fnameFocusNode);
                                  },
                                  onChanged: (value) {
                                    // Capitalize the first letter
                                    setModalState(() {});
                                  },
                                  maxLength: 30,
                                  decoration:  AppUtils.getInputDecoration("First Name", Icons.person),
                                  validator: (String? value) {
                                    if (value == null || value == '') {
                                      return 'Enter first name';
                                    }
                                    if (value.trim().length < 2) {
                                      return "The name can not be less than 2 chars";
                                    }
                                    return null;
                                  },
                                  autovalidateMode: AutovalidateMode.always,
                                )),
                            SizedBox(
                              height: 16,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: TextFormField(
                                textCapitalization: TextCapitalization.words,
                                controller: _lname,
                                inputFormatters: <TextInputFormatter>[
                                  UpperCaseTextFormatter()
                                ],
                                autocorrect: false,
                                focusNode: _lnameFocusNode,
                                onTap: () {
                                  // Set cursor position when the text field is tapped
                                  _setCursorPosition(_lname, _lnameFocusNode);
                                },
                                onChanged: (value) {
                                  // Capitalize the first letter
                                  setModalState(() {});
                                },
                                keyboardType: TextInputType.name,
                                maxLength: 30,
                                decoration:  AppUtils.getInputDecoration("Last Name", Icons.person),
                                validator: (String? value) {
                                  if (value == null || value == '') {
                                    return 'Enter last name';
                                  }
                                  if (value.trim().length < 2) {
                                    return "The name can not be less than 2 chars";
                                  }
                                  return null;
                                },
                                autovalidateMode: AutovalidateMode.always,
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: TextFormField(
                                textCapitalization: TextCapitalization.words,
                                controller: _classification,
                                autocorrect: false,
                                focusNode: _classificationFocusNode,
                                onTap: () {
                                  // Set cursor position when the text field is tapped
                                  _setCursorPosition(_classification, _classificationFocusNode);
                                },
                                onChanged: (value) {
                                  // Capitalize the first letter
                                  setModalState(() {});
                                },
                                keyboardType: TextInputType.text,
                                maxLength: 80,
                                decoration:
                                    AppUtils.getInputDecoration("Classification", Icons.type_specimen),
                                validator: (String? value) {
                                  if (value == null || value == '') {
                                    return 'Enter worker classification';
                                  }
                                  if (value.trim().length < 3) {
                                    return "The classification can not be less than 3 chars";
                                  }
                                  return null;
                                },
                                autovalidateMode: AutovalidateMode.always,
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: PrimaryButton(
                          isEdit == true ? "Update" : 'Add Worker',
                          isLoading: _isLoading,
                          enabled: _validateForm(isEdit),
                          onPressed: () async {
                            bool isValid = _validateForm(isEdit);
                            setModalState(() {});
                            if (isValid) {
                              setModalState(() {
                                _isLoading = true;
                              });
                              if (isEdit == true) {
                                await addNewWorkerCall(worker: worker);
                              } else {
                                await addNewWorkerCall();
                              }

                              setModalState(() {
                                _isLoading = false;
                              });
                              Navigator.pop(context);
                              await Future.delayed(Duration(seconds: 1));
                              _lname.clear();
                              _fname.clear();
                              _classification.clear();

                              await getContractWorkers();
                            }
                          },
                        ),
                      ),
                      SizedBox(
                        height: 32,
                      ),
                    ],
                  ),
                ),
              );
            }));
    await Future.delayed(Duration(milliseconds: 500));
    _fname.clear();
    _lname.clear();
    _classification.clear();
  }

  void _setCursorPosition(_controller, _focusNode) {
    // Set cursor position to the end of the text
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset tapPosition = renderBox.globalToLocal(Offset.zero);
    TextPosition position = _controller.getPositionForOffset(tapPosition);

    _controller.selection = TextSelection.fromPosition(position);
    _focusNode.requestFocus();
  }
  _validateForm(isEdit) {
    if (_lname.text.isNotEmpty &&
        _fname.text.length >= 2 &&
        _lname.text.isNotEmpty &&
        _lname.text.length >= 2 &&
        _classification.text.isNotEmpty &&
        _classification.text.length >= 3) {
      if(isEdit){
        if(_fnameValueBeforeEdit != _fname.text
          || _lnameValueBeforeEdit != _lname.text
          || _classification.text != _classificationValueBeforeEdit
        ){
          return true;
        }else{
          return false;
        }
      }else {
        return true;
      }
    }
    return false;
  }

  addNewWorkerCall({Worker? worker}) async {
    if (worker != null) {
      await userProvider.addNewWorker(
          workerId: worker.workerId,
          firstName: _fname.text.trim(),
          lastName: _lname.text.trim(),
          classification: _classification.text.trim(),
          contractId: userProvider.currentContract?.contractId ?? "");
    } else {
      await userProvider.addNewWorker(
          firstName: _fname.text.trim(),
          lastName: _lname.text.trim(),
          classification: _classification.text.trim(),
          contractId: userProvider.currentContract?.contractId ?? "");
    }
  }

  String capitalize(String? s) {
    if (s == '' || s == null) return "";
    return s[0].toUpperCase() + s.substring(1);
  }
}
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: capitalize(newValue.text),
      selection: newValue.selection,
    );
  }
}
String capitalize(String value) {
  if(value.trim().isEmpty) return "";
  return "${value[0].toUpperCase()}${value.substring(1).toLowerCase()}";
}
