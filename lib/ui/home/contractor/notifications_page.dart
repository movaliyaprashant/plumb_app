import 'package:flutter/material.dart';
import 'package:plumbata/net/model/app_user.dart';
import 'package:plumbata/net/model/notification.dart';
import 'package:plumbata/providers/user.dart';
import 'package:plumbata/ui/widgets/appbar.dart';
import 'package:provider/provider.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<AppNotification?> notifications = [];
  bool isLoading = false;
  late UserProvider userProvider;

  @override
  void initState() {
    super.initState();
    userProvider = context.read<UserProvider>();
    getNotifications();
  }

  getNotifications() async {
    setState(() {
      isLoading = true;
    });

    notifications = await userProvider.getNotifications();

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GeneralAppBar(
        title: "Notifications",
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : notifications.isEmpty
              ? Center(
                  child: Text(
                    "There's no Notifications yet",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (ctx, index) {
                      return NotficationsCard(appNotification: notifications[index]);
                    },
                  ),
                ),
    );
  }
}

class NotficationsCard extends StatefulWidget {
  const NotficationsCard({super.key, required this.appNotification});
  final AppNotification? appNotification;
  @override
  State<NotficationsCard> createState() => _NotficationsCardState();
}

class _NotficationsCardState extends State<NotficationsCard> {
  String? profilePic;
  late UserProvider userProvider;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    userProvider = context.read<UserProvider>();
    getProfilePic();
  }

  getProfilePic() async {
    setState(() {
      isLoading = true;
    });
    AppUser? appUser = await userProvider.getUserDataById(
        id: widget.appNotification?.sender ?? "");
    profilePic = appUser?.profileImage;
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return notificationCard(
      widget.appNotification,
    );
  }

  notificationCard(AppNotification? notification) {
    /// Displayed as a profile image if the user doesn't have one.
    const placeholderImage =
        'https://upload.wikimedia.org/wikipedia/commons/c/cd/Portrait_Placeholder_Square.png';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          leading: isLoading
              ? Center(child: CircularProgressIndicator.adaptive())
              : CircleAvatar(
                  maxRadius: 30,
                  backgroundImage: NetworkImage(
                    profilePic ?? placeholderImage,
                  ),
                ),
          title: Text(
            notification?.title ?? "",
            style:
                Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              notification?.description ?? "",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ),
    );
  }
}
