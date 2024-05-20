import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:plumbata/net/model/app_user.dart';
import 'package:plumbata/net/model/contract.dart';
import 'package:plumbata/net/model/timesheet.dart';
import 'package:plumbata/providers/user.dart';
import 'package:plumbata/ui/widgets/appbar.dart';
import 'package:plumbata/ui/widgets/contract_datails_card.dart';
import 'package:plumbata/ui/widgets/contract_timer.dart';
import 'package:plumbata/ui/widgets/cost_code_card.dart';
import 'package:plumbata/ui/widgets/members_card.dart';
import 'package:plumbata/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContractorHome extends StatefulWidget {
  const ContractorHome({super.key});

  @override
  State<ContractorHome> createState() => _ContractorHomeState();
}

class _ContractorHomeState extends State<ContractorHome> {
  AppUser? appUserData;
  late UserProvider userProvider;
  bool _isLoading = false;
  List<Contract?> allContracts = [];
  Function? setModalState;
  TextEditingController search = TextEditingController();
  List<Contract?> filteredContracts = [];
  int pendingCount = 0;
  @override
  void initState() {
    super.initState();
    userProvider = context.read<UserProvider>();
    appUserData = userProvider.currUserData;
    print("appUserData ${appUserData?.contracts.toString()}");
    loadContractsDetails();
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context, listen: true);

    return Scaffold(
      appBar: ContractsAppBar(
        title: allContracts.isNotEmpty
            ? "${userProvider.currentContract?.code} - ${userProvider.currentContract?.title}" ??
                ""
            : "...",
        onActionItemPressed: showChoseContract,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator.adaptive(),
            )
          : ListView(
              children: [
                ContractTimer(
                  contractLocation: allContracts.isNotEmpty
                      ? userProvider.currentContract?.address ?? ""
                      : "...",
                ),
                ContractDetailsCard(contract: userProvider.currentContract, pendingCount: pendingCount,),

                userProvider.isSuperIntendent() ? SizedBox() : MembersCard(contract: userProvider.currentContract),
                userProvider.isSuperIntendent() ? SizedBox() : CostCodeCard(contract: userProvider.currentContract),

                SizedBox(
                  height: 50,
                )
              ],
            ),
    );
  }

  showChoseContract() {
    final rootContext =
        context.findRootAncestorStateOfType<NavigatorState>()?.context;

    showCupertinoModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      context: rootContext ?? context,
      builder: (context) => Scaffold(
        body: StatefulBuilder(builder: (BuildContext context,
            StateSetter setState /*You can rename this!*/) {
          setModalState = setState;

          return Container(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : allContracts.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            "No Active contracts, please contact your Superintendant",
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: search.text.isNotEmpty
                            ? (filteredContracts.length ?? 0) + 1
                            : (allContracts.length ?? 0) + 1,
                        itemBuilder: (ctx, index) {
                          var contracts;
                          if (search.text.isNotEmpty && search.text != "") {
                            contracts = filteredContracts;
                          } else {
                            contracts = allContracts;
                          }
                          print("contracts are ${contracts.toString()}");
                          print("index is ${index}");

                          if (index == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          height: 50,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 16.0),
                                            child: TextFormField(
                                              controller: search,
                                              autocorrect: false,
                                              onChanged: (text) {
                                                filteredContracts = contracts
                                                    .where((element) =>
                                                        element?.title
                                                            .toString()
                                                            .toLowerCase()
                                                            ?.contains(text
                                                                .toLowerCase()) ==
                                                        true)
                                                    .toList();
                                                setModalState!(() {});
                                              },
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 4),
                                                hintText: 'Search',
                                                prefixIcon: Icon(
                                                  Icons.search,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      RawMaterialButton(
                                        onPressed: () {
                                          Navigator.pop(rootContext ?? context);
                                        },
                                        elevation: 0.0,
                                        fillColor: Colors.grey.withOpacity(0.5),
                                        child: Icon(
                                          Icons.close,
                                          size: 15.0,
                                        ),
                                        padding: EdgeInsets.all(4.0),
                                        shape: CircleBorder(),
                                      )
                                    ],
                                  ),
                                  Divider()
                                ],
                              ),
                            );
                          }
                          index = index - 1;

                          print("index 2 is ${index}");
                          print("index 2 len ${contracts.length.toString()}");

                          return InkWell(
                            onTap: () {
                              Navigator.pop(rootContext ?? context);
                            },
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Card(
                                    child: ListTile(
                                      onTap: () {
                                        setModalState!(() {
                                          userProvider.setCurrentContract(
                                              contracts[index]);
                                        });
                                      },
                                      trailing: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: contracts[index]
                                                      ?.contractId ==
                                                  userProvider.currentContract
                                                      ?.contractId
                                              ? Icon(
                                                  Icons.check,
                                                  color: AppColors
                                                      .lightPrimaryColor,
                                                )
                                              : SizedBox()),
                                      contentPadding: EdgeInsets.all(4.0),
                                      title: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          contracts[index]?.title ?? "",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ),
                                      subtitle: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          (contracts[index]?.code ?? "") +
                                              " | " +
                                              (contracts[index]?.address ??
                                                  ""),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
          );
        }),
      ),
    );
  }

  loadContractsDetails() async {
    setState(() {
      _isLoading = true;
    });
    if (setModalState != null) {
      setModalState!(() {
        _isLoading = true;
      });
    }
    for (DocumentReference ref in appUserData?.contracts ?? []) {
      var data = await ref.get();
      if(data.exists) {
        Contract? contract = await Contract.fromJson(
            (data.data() ?? {}) as Map<String, dynamic>);
        allContracts.add(contract);
      }
    }
    if (userProvider.currentContract == null && allContracts.isNotEmpty) {
      SharedPreferences prefs = GetIt.I.get();
      String? savedId =
          prefs.getString("current_contract_id") ?? allContracts[0]?.contractId;
      print("savedId $savedId");

      Contract? active = allContracts.firstWhere(
          (element) => element?.contractId == savedId,
          orElse: () => allContracts[0]);
      userProvider.setCurrentContract(active);
    }
    print("contracts $allContracts");

    List<TimeSheet> pendingTimeSheets = await userProvider.getTimeSheets(status: "pending");
    pendingCount = pendingTimeSheets.length;


    setState(() {
      _isLoading = false;
    });
    if (setModalState != null) {
      setModalState!(() {
        _isLoading = false;
      });
    }
  }
}
