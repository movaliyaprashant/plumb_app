import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:plumbata/net/model/comment_model.dart';
import 'package:plumbata/providers/theme.dart';
import 'package:plumbata/providers/user.dart';
import 'package:plumbata/ui/home/contractor/chat_bubble.dart';
import 'package:plumbata/ui/home/contractor/username_widget.dart';
import 'package:plumbata/ui/home/contractor/voice_message.dart';
import 'package:plumbata/utils/app_utils.dart';
import 'package:plumbata/utils/colors.dart';
import 'package:plumbata/utils/style.dart';
import 'package:provider/provider.dart';

class CommentCard extends StatefulWidget {
  const CommentCard({super.key, this.comment});
  final AppComment? comment;
  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  late ThemeProvider themeProvider;
  late String? currentUserId;
  late UserProvider repo;
  User? currentUser;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    repo = context.read<UserProvider>();
    currentUserId = repo.currentUser?.uid;
    currentUser = repo.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    themeProvider = Provider.of<ThemeProvider>(context);
    if(isLoading){
      return Container(
          width: 30,
          height: 30,
          child: CircularProgressIndicator.adaptive());
    }
    if (widget.comment?.type == "text") {
      return buildCommentCard(widget.comment);
    }
    if(widget.comment?.type == "voice"){
      return _buildChatVoice(widget.comment);
    }

    return _buildAttachRow(widget.comment);
  }

  buildCommentCard(AppComment? comment) {
    List<Widget> notes = [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [

          comment?.addedBy?.path.contains(currentUserId??"N/A") == true
              ? const SizedBox(
            height: 8,
          )
              : Padding(
            padding: const EdgeInsets.only(left: 28.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: ChatUserName(userRef: comment?.addedBy,),
            ),
          ),
          AppBubbleSpecialThree(
            text: comment?.comment??"N/A",
            textStyle: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.black) ??
                TextStyle(fontSize: 16),
            color: themeProvider.isDarkMode()
                ? Color(0xFFA9A9A9)
                : Color(0xFFDCDCDC),
            tail: true,
            date: AppUtils.formatTimeDate(comment?.addedAt?.toDate()),
            userNameTextStyle: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.black) ??
                TextStyle(fontSize: 16),
            isSender: comment?.addedBy?.path.contains(currentUserId??"N/A") == true,
          ),
        ],
      ),
    );
  }

  _buildChatVoice(AppComment? comment) {

    if (isLoading) {
      return CircularProgressIndicator.adaptive();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment:
        comment?.addedBy?.path.contains(currentUserId??"N/A") == true ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          comment?.addedBy?.path.contains(currentUserId??"N/A") == true
              ? const SizedBox(
            height: 8,
          )
              : Padding(
            padding: const EdgeInsets.only(left: 28.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: ChatUserName(userRef: comment?.addedBy,),
            ),
          ),
          VoiceMessage(
            audioSrc: comment?.comment,
            me: comment?.addedBy?.path.contains(currentUserId??"N/A") == true,
            meBgColor: AppColors.lightPrimaryColor,
          )
        ],
      ),
    );
  }



  _buildAttachRow(AppComment? comment) {

    return InkWell(
      onTap: () async {

      },
      child: Row(
        children: [
          Flexible(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  comment?.type ?? "--",
                  overflow: TextOverflow.clip,
                  style: Style().appTextTheme(context).bodyMedium?.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).textTheme.bodyText1?.color),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
