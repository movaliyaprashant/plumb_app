import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:plumbata/net/model/app_user.dart';
import 'package:plumbata/net/model/contract.dart';
import 'package:plumbata/providers/user.dart';
import 'package:plumbata/ui/widgets/appbar.dart';
import 'package:plumbata/ui/widgets/buttons.dart';
import 'package:plumbata/utils/colors.dart';
import 'package:plumbata/utils/error_utils.dart';
import 'package:plumbata/utils/icons.dart';
import 'package:provider/provider.dart';

class CreateContract extends StatefulWidget {
  const CreateContract({super.key, this.isEdit = false, this.contract});
  final bool isEdit;
  final Contract? contract;

  @override
  State<CreateContract> createState() => _CreateContractState();
}

class _CreateContractState extends State<CreateContract> {
  late UserProvider userProvider;
  bool isLoading = false;

  TextEditingController address = TextEditingController();
  TextEditingController code = TextEditingController();
  TextEditingController projectNumber = TextEditingController();
  TextEditingController approvedHours = TextEditingController();
  TextEditingController currentProgress = TextEditingController();
  TextEditingController estimatedHours = TextEditingController();
  TextEditingController scopeOfWork = TextEditingController();
  TextEditingController title = TextEditingController();
  TextEditingController vendor = TextEditingController();
  TextEditingController workLocation = TextEditingController();

  TextEditingController _searchController = TextEditingController();
  List<AppUser>? appUsers = [];
  List<AppUser>? filterAppUsers = [];
  List<AppUser?>? selectedAppUser = [];

  String errorString = '';

  Contract? contract;

  @override
  void initState() {
    super.initState();
    userProvider = context.read<UserProvider>();
    contract = widget.contract;
    getAppContractors();
  }

  getAppContractors() async {
    setState(() {
      isLoading = true;
    });
    appUsers = await userProvider.getAppContractors();
    setState(() {
      isLoading = false;
    });
    if (contract != null) {
      title.text = contract?.title.toString() ?? "";
      code.text = contract?.code.toString() ?? "";
      projectNumber.text = contract?.projectNumber.toString() ?? "";
      address.text = contract?.address.toString() ?? "";
      vendor.text = contract?.vendor.toString() ?? "";
      scopeOfWork.text = contract?.scopeOfWork.toString() ?? "";
      approvedHours.text = contract?.approvedHours.toString() ?? "";
      estimatedHours.text = contract?.estimatedHours.toString() ?? "";
      selectedAppUser = appUsers
          ?.where((e) => contract?.contractors?.contains(e.uid) == true)
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GeneralAppBar(
        title: widget.isEdit ? "Edit Contract" : "Create Contract",
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
                        height: 32,
                      ),
                      _buildTextInput(
                          title, "Title", Icons.title, TextInputType.text),
                      _buildTextInput(
                          code, "Code", Icons.code, TextInputType.text),
                      _buildTextInput(projectNumber, "Project Number",
                          Icons.map_sharp, TextInputType.text),
                      _buildTextInput(address, "Address", Icons.location_city,
                          TextInputType.text),
                      _buildTextInput(
                          vendor, "Vendor", Icons.home, TextInputType.text),
                      _buildTextInput(scopeOfWork, "Scope Of Work", Icons.build,
                          TextInputType.text),
                      _buildTextInput(approvedHours, "Approved Hours",
                          Icons.timer, TextInputType.number),
                      _buildTextInput(estimatedHours, "Estimated Hours",
                          Icons.timer, TextInputType.number),
                      SizedBox(
                        height: 16.0,
                      ),
                      InkWell(
                        onTap: () {
                          showContractorPick(context);
                        },
                        child: Center(
                            child: Text(
                          "Add Contractors",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  color: Colors.lightBlue,
                                  fontWeight: FontWeight.bold),
                        )),
                      ),
                      for (AppUser? user in selectedAppUser ?? [])
                        ListTile(
                          trailing: IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: AppColors.errorColor,
                            ),
                            onPressed: () {
                              selectedAppUser?.remove(user);
                              setState(() {});
                            },
                          ),
                          title: Text("${user?.firstName} ${user?.lastName}",
                              style: Theme.of(context).textTheme.bodyMedium),
                          subtitle: Text("${user?.email ?? user?.phone ?? ""}",
                              style: Theme.of(context).textTheme.bodySmall),
                          leading: Stack(
                            children: [
                              ClipRRect(
                                child: Container(
                                  height: 60,
                                  width: 60,
                                  color: Colors.grey,
                                ),
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              CircleAvatar(
                                radius: 30.0,
                                backgroundImage: NetworkImage(user
                                        ?.profileImage ??
                                    "https://firebasestorage.googleapis.com/v0/b/plumbata-prod.appspot.com/o/profileImages%2Fapp_logo.png?alt=media&token=f306f551-cb70-4367-918e-02fccfb24c87"),
                                backgroundColor: Colors.transparent,
                              ),
                            ],
                          ),
                        )
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      //   child: Divider(thickness: 2,),
                      // ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: PrimaryButton(
                    widget.isEdit ? "Edit Contract" : 'Create Contract',
                    isLoading: false,
                    onPressed: () {
                      _createNewContract(
                          address: address.text.trim(),
                          code: code.text.trim(),
                          projectNumber: projectNumber.text.trim(),
                          approvedHours:
                              int.tryParse(approvedHours.text.trim()) ?? 0,
                          currentProgress:
                              int.tryParse(currentProgress.text.trim()) ?? 0,
                          estimatedHours:
                              int.tryParse(estimatedHours.text.trim()) ?? 0,
                          scopeOfWork: scopeOfWork.text.trim(),
                          title: title.text.trim(),
                          vendor: vendor.text.trim(),
                          workLocation: workLocation.text.trim(),
                          contractors: selectedAppUser
                              ?.map((e) => e?.uid)
                              .toList()
                              .map((id) => FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(id))
                              .toList(),
                          isEdit: widget.isEdit,
                          docId: widget.contract?.contractId ?? "");
                    },
                  ),
                ),
                SizedBox(
                  height: 32.0,
                )
              ],
            ),
    );
  }

  showContractorPick(context) {
    showMaterialModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        context: context,
        builder: (context) => Scaffold(body: StatefulBuilder(
                builder: (BuildContext context, StateSetter setModalState) {
              return SizedBox(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _searchController.text.isNotEmpty
                            ? (filterAppUsers?.length ?? 0) + 1
                            : (appUsers?.length ?? 0) + 1,
                        itemBuilder: (ctx, index) {
                          if (index == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  top: 0.0,
                                  right: 16.0,
                                  left: 16.0,
                                  bottom: 16.0),
                              child: Row(
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      icon: Icon(Icons.arrow_back_ios)),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _searchController,
                                      autocorrect: false,
                                      onChanged: (text) {
                                        filterAppUsers = appUsers
                                            ?.where((element) =>
                                                "${element.firstName} ${element.lastName}"
                                                    .toLowerCase()
                                                    .contains(
                                                        text.toLowerCase()) ==
                                                true)
                                            .toList();
                                        setModalState(() {});
                                      },
                                      keyboardType: TextInputType.text,
                                      decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 16),
                                          hintText: 'User Name',
                                          prefixIcon: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Icon(Icons.search),
                                          )),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 8.0,
                                  )
                                ],
                              ),
                            );
                          }
                          index = index - 1;

                          return Column(
                            children: [
                              ListTile(
                                  onTap: () {
                                    AppUser? user;
                                    if (_searchController.text.isNotEmpty ==
                                        true) {
                                      user = filterAppUsers?[index];
                                    } else {
                                      user = appUsers?[index];
                                    }
                                    if (selectedAppUser?.contains(user) ==
                                        true) {
                                      selectedAppUser?.remove(user);
                                    } else {
                                      selectedAppUser?.add(user);
                                    }
                                    setState(() {});
                                    setModalState(() {});
                                  },
                                  title: Text(getUserName(index),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium),
                                  subtitle: Text(getUserDetails(index),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                  leading: Stack(
                                    children: [
                                      ClipRRect(
                                        child: Container(
                                          height: 60,
                                          width: 60,
                                          color: Colors.grey,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                      ),
                                      CircleAvatar(
                                        radius: 30.0,
                                        backgroundImage: NetworkImage(_searchController
                                                    .text.isNotEmpty ==
                                                true
                                            ? (filterAppUsers?[index]
                                                    ?.profileImage ??
                                                "https://firebasestorage.googleapis.com/v0/b/plumbata-prod.appspot.com/o/profileImages%2Fapp_logo.png?alt=media&token=f306f551-cb70-4367-918e-02fccfb24c87")
                                            : appUsers?[index]?.profileImage ??
                                                "https://firebasestorage.googleapis.com/v0/b/plumbata-prod.appspot.com/o/profileImages%2Fapp_logo.png?alt=media&token=f306f551-cb70-4367-918e-02fccfb24c87"),
                                        backgroundColor: Colors.transparent,
                                      ),
                                    ],
                                  ),
                                  trailing: _searchController.text.isNotEmpty
                                      ? selectedAppUser?.contains(
                                                  filterAppUsers?[index]) ==
                                              true
                                          ? Icon(
                                              Icons.check,
                                              color:
                                                  AppColors.lightPrimaryColor,
                                            )
                                          : SizedBox()
                                      : (selectedAppUser?.contains(
                                                  appUsers?[index]) ==
                                              true
                                          ? Icon(
                                              Icons.check,
                                              color:
                                                  AppColors.lightPrimaryColor,
                                            )
                                          : SizedBox())),
                              const SizedBox(
                                height: 8,
                              ),
                              const Divider(),
                            ],
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: PrimaryButton(
                        'Add Contractors',
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 32,
                    )
                  ],
                ),
              );
            })));
  }

  getUserName(index) {
    if (_searchController.text.isNotEmpty == true) {
      return filterAppUsers?[index].firstName ??
          "" + " " + (filterAppUsers?[index].lastName ?? "");
    }
    return appUsers?[index].firstName ??
        "" + " " + (appUsers?[index].lastName ?? "");
  }

  getUserDetails(index) {
    if (_searchController.text.isNotEmpty == true) {
      filterAppUsers?[index].email ?? filterAppUsers?[index].phone ?? "";
    }
    return appUsers?[index].email ?? appUsers?[index].phone ?? "";
  }

  _buildTextInput(TextEditingController controller, String hint, IconData icon,
      TextInputType type) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextFormField(
        controller: controller,
        autocorrect: false,
        keyboardType: type,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            hintText: hint,
            prefixIcon: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Icon(icon),
            )),
      ),
    );
  }

  _cleanInputs() {
    address.clear();
    code.clear();
    projectNumber.clear();
    approvedHours.clear();
    currentProgress.clear();
    estimatedHours.clear();
    scopeOfWork.clear();
    title.clear();
    vendor.clear();
    workLocation.clear();
    selectedAppUser = [];
  }

  _createNewContract({
    required String address,
    required String code,
    required String docId,
    required String projectNumber,
    required int approvedHours,
    required int currentProgress,
    required int estimatedHours,
    required String scopeOfWork,
    required String title,
    required String vendor,
    required String workLocation,
    required List<DocumentReference?>? contractors,
    required bool isEdit,
  }) async {
    validateFields();
    if (errorString != '') {
      showErrorMessage();
      return;
    }
    setState(() {
      isLoading = true;
    });
    var result = await userProvider.createNewContract(
        address: address,
        code: code,
        isEdit: isEdit,
        docId: docId,
        projectNumber: projectNumber,
        approvedHours: approvedHours,
        currentProgress: currentProgress,
        estimatedHours: estimatedHours,
        scopeOfWork: scopeOfWork,
        title: title,
        vendor: vendor,
        workLocation: workLocation,
        contractors: contractors);

    if (result == true) {
      if (widget.isEdit) {
        ErrorUtils.showSuccessMessage(context, "Contract Edited Successfully");
      } else {
        _cleanInputs();
        ErrorUtils.showSuccessMessage(context, "Contract Created Successfully");
      }
      //Navigator.pop(context);
    } else {
      if (widget.isEdit) {
        ErrorUtils.showGeneralError(context, "Could not update the contract",
            duration: Duration(seconds: 3));
      } else {
        _cleanInputs();
        ErrorUtils.showGeneralError(context, "Could not create the contract",
            duration: Duration(seconds: 3));
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  showErrorMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Not Valid Data',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          content:
              Text(errorString, style: Theme.of(context).textTheme.bodyMedium),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  validateFields() {
    errorString = '';
    if (address.text.isEmpty || address.text.length < 4) {
      errorString += "* Address should not be empty and 4+ chars \n";
    }
    if (code.text.isEmpty || code.text.length < 4) {
      errorString += "* Code should not be empty and 4+ chars \n";
    }
    if (projectNumber.text.isEmpty || projectNumber.text.length < 4) {
      errorString += "* Project Number should not be empty and 4+ chars \n";
    }
    if (scopeOfWork.text.isEmpty || scopeOfWork.text.length < 4) {
      errorString += "* Scope of Work should not be empty and 4+ chars \n";
    }
    if (title.text.isEmpty || title.text.length < 4) {
      errorString +=
          "* Contract Title of Work should not be empty and 4+ chars \n";
    }
    if (estimatedHours.text.isEmpty) {
      errorString += "* Estimated Hours should not be empty \n";
    }
    if (selectedAppUser?.isEmpty == true) {
      errorString += "* You have to add at least one contractor \n";
    }
  }
}
