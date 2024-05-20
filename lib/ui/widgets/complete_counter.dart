import 'package:flutter/material.dart';
import 'package:plumbata/net/model/cost_code.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class CompleteCounter extends StatefulWidget {
  const CompleteCounter({super.key, required this.code});
  final CostCode code;
  @override
  State<CompleteCounter> createState() => _CompleteCounterState();
}

class _CompleteCounterState extends State<CompleteCounter> {
  late double _pointerValue;
  late CostCode code;

  @override
  void initState() {
    super.initState();
    code = widget.code;
    _pointerValue = code.completedHours?.toDouble() ?? 0.0;
  }
  @override
  Widget build(BuildContext context) {
    return _buildStepsCounter(context);
  }

  Widget _buildStepsCounter(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: SfLinearGauge(
              maximum: code.estimatedHours?.toDouble() ?? 100.0,
              interval:  code.estimatedHours?.toDouble() ?? 100.0,
              animateAxis: true,
              minorTicksPerInterval: 0,
              axisTrackStyle: LinearAxisTrackStyle(
                thickness: 32,
                borderWidth: 1,
                borderColor: brightness == Brightness.dark
                    ? const Color(0xff898989)
                    : Colors.grey[350],
                color: brightness == Brightness.light
                    ? const Color(0xffE8EAEB)
                    : const Color(0xff62686A),
              ),
              barPointers: <LinearBarPointer>[
                LinearBarPointer(
                    value: _pointerValue,
                    animationDuration: 3000,
                    thickness: 32,
                    color: const Color(0xff0DC9AB)),
                LinearBarPointer(
                    value: code.estimatedHours?.toDouble() ?? 100.0,
                    enableAnimation: false,
                    thickness: 25,
                    offset: 60,
                    color: Colors.transparent,
                    position: LinearElementPosition.outside,
                    child: const Text('Costcode Progress',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500))),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 65),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Completed Hours',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    _pointerValue.toStringAsFixed(0),
                    style: const TextStyle(
                        fontSize: 24,
                        color: Color(0xff0DC9AB),
                        fontWeight: FontWeight.bold),
                  )
                ]),
          )
        ],
      ),
    );
  }
}
