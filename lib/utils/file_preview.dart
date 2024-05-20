import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:plumbata/ui/widgets/appbar.dart';


class AppFileViewer extends StatefulWidget {
  const AppFileViewer(
      {Key? key, required this.link, required this.title})
      : super(key: key);
  final String link;
  final String title;

  @override
  State<AppFileViewer> createState() => _AppFileViewerState();
}

class _AppFileViewerState extends State<AppFileViewer> {
  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GeneralAppBar(
        title: widget.title ?? "",
        backBtn: true,
      ),
      body:PhotoView(
        imageProvider: NetworkImage(widget.link),
      ),
    );
  }
}
