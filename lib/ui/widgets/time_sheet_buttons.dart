import 'package:flutter/material.dart';

class AcceptButton extends StatelessWidget {
  AcceptButton({required this.onPress});
  final Function onPress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        onPress();
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Approve Timesheet",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 16,),
              Icon(
                Icons.check,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RejectButton extends StatelessWidget {
  RejectButton({required this.onPress});

  final Function onPress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        onPress();
      },
      child: Container(
        width: (MediaQuery.of(context).size.width * 0.5) - 16,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Reject Timesheet",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 16,),
              Text(
                'X',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
