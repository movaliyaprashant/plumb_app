import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:plumbata/net/model/app_user.dart';
import 'package:plumbata/providers/user.dart';
import 'package:provider/provider.dart';

class ChatUserName extends StatefulWidget {
  const ChatUserName({super.key, required this.userRef});
  final DocumentReference? userRef;

  @override
  State<ChatUserName> createState() => _ChatUserNameState();
}

class _ChatUserNameState extends State<ChatUserName> {
  bool isLoading = false;
  late UserProvider repo;
  AppUser? appUser;

  @override
  void initState() {
    super.initState();
    repo = context.read<UserProvider>();
    getUserName();
  }

  getUserName() async {
    setState(() {
      isLoading = true;
    });
    appUser = await repo.getUserDataById(ref: widget.userRef);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Text(
            "Loading...",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
          )
        : Text(
            "${appUser?.firstName} ${appUser?.lastName}",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
          );
  }
}
