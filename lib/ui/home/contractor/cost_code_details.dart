import 'package:flutter/material.dart';
import 'package:plumbata/net/model/cost_code.dart';
import 'package:plumbata/providers/user.dart';
import 'package:plumbata/ui/home/contractor/add_cost_code.dart';
import 'package:plumbata/ui/widgets/appbar.dart';
import 'package:plumbata/ui/widgets/complete_counter.dart';
import 'package:plumbata/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class CostCodeDetails extends StatefulWidget {
  const CostCodeDetails({super.key, required this.costCode});
  final CostCode costCode;
  @override
  State<CostCodeDetails> createState() => _CostCodeDetailsState();
}

class _CostCodeDetailsState extends State<CostCodeDetails> {
  late CostCode code;
  bool _isHorizontalOrientation = true;
  late UserProvider userProvider;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    code = widget.costCode;
    userProvider = context.read<UserProvider>();
  }

  updateData() async {
    setState(() {
      isLoading = true;
    });

    code = widget.costCode;
    userProvider = context.read<UserProvider>();
    code =
        await userProvider.getCostCodeById(costCodeId: code.costCodeId ?? "");

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GeneralAppBar(
        title: "Costcode details",
        backBtn: true,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator.adaptive(),
            )
          : ListView(
              children: [
                SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                        child: Text(
                      code.code ?? "",
                      style: Theme.of(context).textTheme.bodyLarge,
                    )),
                    userProvider.isSuperIntendent() ? IconButton(
                        onPressed: () async {
                          await Navigator.of(context).push(MaterialPageRoute(
                              builder: (ctx) =>
                                  AddNewCostCode(isEdit: true, code: code)));
                          code = await userProvider.getCostCodeById(
                              costCodeId: code.costCodeId ?? "");
                          updateData();
                        },
                        icon: Icon(Icons.edit)):SizedBox()
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Description",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    code.description ?? "",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontSize: 20),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Divider(
                  thickness: 2,
                ),
                _getLinearGauge(),
                SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Last Update ${formatDate(code.lastUpdateDate?.toDate())}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Divider(
                  thickness: 2,
                ),
                SizedBox(
                  height: 16,
                ),
                CompleteCounter(
                  code: code,
                )
              ],
            ),
    );
  }

  Widget _getLinearGauge() {
    return Container(
      child: _buildTextLabels(context),
      margin: EdgeInsets.all(10),
    );
  }

  Widget _buildTextLabels(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    const double orderState = 0;
    const double shippedState = 10;
    const double deliveredState = 30;
    const double deliveryStatus = 30;

    const Color activeColor =
        deliveryStatus > orderState ? Color(0xff0DC9AB) : Color(0xffD1D9DD);
    final Color inactiveColor = brightness == Brightness.dark
        ? const Color(0xff62686A)
        : const Color(0xFFD1D9DD);

    return SizedBox(
        height: _isHorizontalOrientation ? 100 : 300,
        child: SfLinearGauge(
          orientation: _isHorizontalOrientation
              ? LinearGaugeOrientation.horizontal
              : LinearGaugeOrientation.vertical,
          maximum: 30,
          labelOffset: 24,
          isAxisInversed: !_isHorizontalOrientation,
          showTicks: false,
          onGenerateLabels: () {
            return <LinearAxisLabel>[
              LinearAxisLabel(
                  text: ' Created\n ${formatDate(code.createdDate?.toDate())}',
                  value: 0),
              LinearAxisLabel(
                  text: ' Started\n ${formatDate(code.startDate?.toDate())}',
                  value: 10),
              LinearAxisLabel(
                  text:
                      ' Target Completed\n ${formatDate(code.targetCompletionDate?.toDate())}',
                  value: 30),
            ];
          },
          axisTrackStyle: LinearAxisTrackStyle(
            color: inactiveColor,
          ),
          barPointers: const <LinearBarPointer>[
            LinearBarPointer(
              value: deliveryStatus,
              color: activeColor,
              enableAnimation: false,
            ),
          ],
          markerPointers: <LinearMarkerPointer>[
            LinearWidgetPointer(
              value: orderState,
              enableAnimation: false,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(width: 4, color: activeColor),
                    borderRadius: const BorderRadius.all(Radius.circular(12))),
                child: const Center(
                  child:
                      Icon(Icons.check_rounded, size: 14, color: activeColor),
                ),
              ),
            ),
            LinearWidgetPointer(
              value: shippedState,
              enableAnimation: false,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(width: 4, color: activeColor),
                    borderRadius: const BorderRadius.all(Radius.circular(12))),
                child: const Center(
                  child:
                      Icon(Icons.check_rounded, size: 14, color: activeColor),
                ),
              ),
            ),
            LinearShapePointer(
              value: deliveredState,
              enableAnimation: false,
              color: inactiveColor,
              width: 24,
              height: 24,
              position: LinearElementPosition.cross,
              shapeType: LinearShapePointerType.circle,
            ),
          ],
        ));
  }

  formatDate(DateTime? time) {
    if (time == null) time = DateTime.now();
    var t = "${time.day}/${time.month}/${time.year}";
    return t;
  }
}
