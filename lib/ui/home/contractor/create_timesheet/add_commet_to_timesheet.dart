import 'package:flutter/material.dart';
import 'package:plumbata/providers/user.dart';
import 'package:provider/provider.dart';

class AddCommentToTimeSheet extends StatefulWidget {
  const AddCommentToTimeSheet({Key? key, this.previousComment=''}) : super(key: key);
  final String previousComment;
  @override
  State<AddCommentToTimeSheet> createState() => _AddCommentToTimeSheetState();
}

class _AddCommentToTimeSheetState extends State<AddCommentToTimeSheet> {
  TextEditingController commentController = TextEditingController();
  late UserProvider userProvider;

  @override
  void initState() {
    super.initState();
    userProvider = context.read<UserProvider>();
    commentController.text = widget.previousComment;
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Add Comments or Notes to the timesheet",
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 16,),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            height: 400,  // Adjust the height as needed
            child: TextField(
              minLines: 10,
              scrollPhysics: ClampingScrollPhysics(),
              scribbleEnabled: true,
              showCursor: true,
              scrollController: ScrollController(),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                hintText: 'Enter your comments',
              ),
              onSubmitted: (text){
                userProvider.uiTimeSheet.comment = text;
                setState(() {
                  // Handle the onChanged event if needed
                });
              },
              onChanged: (text) {
                userProvider.uiTimeSheet.comment = text;
                setState(() {
                  // Handle the onChanged event if needed
                });
              },
              controller: commentController,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        )
      ],
    );
  }
}
