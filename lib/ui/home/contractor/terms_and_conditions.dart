import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:plumbata/net/model/privacy.dart';
import 'package:plumbata/providers/user.dart';
import 'package:plumbata/ui/widgets/appbar.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';

class TermsAndConditions extends StatefulWidget {
  const TermsAndConditions({super.key, required this.title});
  final String title;
  @override
  State<TermsAndConditions> createState() => _TermsAndConditionsState();
}

class _TermsAndConditionsState extends State<TermsAndConditions> {
  late UserProvider userProvider;
  bool isLoading = false;
  late Privacy privacy;
  @override
  void initState() {
    super.initState();
    userProvider = context.read<UserProvider>();
    getPrivacy();
  }

  getPrivacy() async {
    setState(() {
      isLoading = true;
    });
    privacy = await userProvider.getPrivacyAndTerms(isTerms: true);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GeneralAppBar(
        title: widget.title,
        backBtn: true,
      ),
      body: privacyPolicyLinkAndTermsOfService(),
    );
  }

  Widget privacyPolicyLinkAndTermsOfService() {
    return Container(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: isLoading
            ? Center(
          child: CircularProgressIndicator.adaptive(),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${privacy.title}',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16,),
            Text(
              'Last Updated: ${(privacy.lastUpdate?.toDate())?.day}, ${(privacy.lastUpdate?.toDate())?.month}, ${(privacy.lastUpdate?.toDate())?.year}',
              style: TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 16.0),
            HtmlWidget(
              // the first parameter (`html`) is required
              '''
             ${privacy.paragraph}

            ''',

              // all other parameters are optional, a few notable params:

              // specify custom styling for an element
              // see supported inline styling below
              customStylesBuilder: (element) {
                if (element.classes.contains('foo')) {
                  return {'color': 'red'};
                }

                return null;
              },
            ),
            SizedBox(
              height: 64,
            )
          ],
        ),
      ),
    );
  }
}
