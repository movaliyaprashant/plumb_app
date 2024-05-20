import 'package:flutter/material.dart';
import 'package:plumbata/net/model/cost_code.dart';
import 'package:plumbata/providers/user.dart';
import 'package:plumbata/ui/home/contractor/add_cost_code.dart';
import 'package:plumbata/ui/home/contractor/cost_code_details.dart';
import 'package:plumbata/ui/widgets/appbar.dart';
import 'package:plumbata/ui/widgets/buttons.dart';
import 'package:plumbata/ui/widgets/complete_counter.dart';
import 'package:plumbata/utils/app_utils.dart';
import 'package:plumbata/utils/colors.dart';
import 'package:plumbata/utils/fonts.dart';
import 'package:provider/provider.dart';

class CostCodes extends StatefulWidget {
  const CostCodes({super.key});

  @override
  State<CostCodes> createState() => _CostCodesState();
}

class _CostCodesState extends State<CostCodes> {
  bool isLoading = false;
  late UserProvider userProvider;
  List<CostCode> codes = [];

  @override
  void initState() {
    super.initState();
    userProvider = context.read<UserProvider>();
    getCostCodes();
  }

  getCostCodes() async {
    setState(() {
      isLoading = true;
    });

    codes = await userProvider.getCostCodes(
        contractId: userProvider.currentContract?.contractId ?? "");

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: userProvider.isSuperIntendent() ?
        FloatingActionButton(
          onPressed: () async {
            await Navigator.of(context, rootNavigator: true)
                .push(MaterialPageRoute(builder: (ctx) => AddNewCostCode()));
            getCostCodes();
          },
          backgroundColor: AppColors.lightAccentColor,
          child: Icon(Icons.add),
        ):SizedBox(),
        appBar: GeneralAppBar(
          title: 'Cost Codes',
          backBtn: true,
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator.adaptive(),
              )
            : codes.isEmpty
                ? Center(
                    child: Text(
                      "There's no costcodes yet",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: codes.length,
                    itemBuilder: (ctx, index) {
                      return costCodeCard(codes[index]);
                    }));
  }

  costCodeCard(CostCode code) {

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Card(
          elevation: 2.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    (AppUtils.capitalize(code.code ?? "")),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600, fontSize: 18.0),
                  ),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    "Description:",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600, fontSize: 16.0),
                  ),
                ),
                ListTile(
                  title: Text(
                    (AppUtils.capitalize(code.description.toString())),
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
                     userProvider.isSuperIntendent() ?  Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SimpleOutlinedButton(
                            "Edit Costcode",
                            bgColor: AppColors.lightBorderColor.withOpacity(0.5),
                            onPressed: () async {

                            },
                            textStyle: TextStyle(
                              color: Color(0xfff16075),
                              fontSize: 14,
                              fontFamily: kOpenSansFont,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ):SizedBox(),
                     Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SimpleOutlinedButton(
                            "Details",
                            bgColor: AppColors.lightBorderColor.withOpacity(0.5),
                            onPressed: () async {
                              await Navigator.of(context, rootNavigator: true)
                                  .push(MaterialPageRoute(
                                  builder: (ctx) => CostCodeDetails(
                                    costCode: code,
                                  )));
                              await getCostCodes();
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
        ),
      );

  }
}
