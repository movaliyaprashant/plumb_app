import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import '../../widgets/audio_recorder.dart';

import 'package:flutter_sound/flutter_sound.dart' as sound;
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:plumbata/net/model/comment_model.dart';
import 'package:plumbata/providers/user.dart';
import 'package:plumbata/services/files/types.dart';
import 'package:plumbata/ui/home/contractor/audio_recorder.dart';
import 'package:plumbata/ui/home/contractor/chat_bubble.dart';
import 'package:plumbata/ui/home/contractor/comment_card.dart';
import 'package:plumbata/ui/home/contractor/voice_message.dart';
import 'package:plumbata/ui/widgets/appbar.dart';
import 'package:plumbata/ui/widgets/buttons.dart';
import 'package:plumbata/utils/app_utils.dart';
import 'package:plumbata/utils/colors.dart';
import 'package:plumbata/utils/error_utils.dart';
import 'package:plumbata/utils/icons.dart';
import 'package:plumbata/utils/style.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

class TimesheetComments extends StatefulWidget {
  const TimesheetComments(
      {Key? key,
      required this.timesheetId,
      this.requestChanges = false,
      this.onRequestChanges})
      : super(key: key);
  final String timesheetId;
  final bool requestChanges;
  final Function? onRequestChanges;

  @override
  State<TimesheetComments> createState() => _TimesheetCommentsState();
}

class _TimesheetCommentsState extends State<TimesheetComments> {
  TextEditingController details = TextEditingController();
  TextEditingController comment = TextEditingController();
  late BuildContext mainContext;
  bool isAddingComment = false;
  bool isAddingFile = false;
  User? currentUser;
  bool isLoading = false;

  String currentUserId = '';
  bool canAddNewComment = true;
  List<dynamic>? selectedFiles = [];

  bool didUpdateComments = false;
  late UserProvider repo;
  double? uploadPercent = 0;
  bool isRecording = false;
  String recordTime = "00:00";
  late Directory tempDir;
  late String outputFile;
  final sound.Codec _codec = sound.Codec.aacMP4;
  bool isInit = true;
  bool didRecord = false;
  bool isRecorderReady = false;
  final recorder = FlutterSoundRecorder();
  File? audioFile;
  bool hasRecordInQueue = false;

  List<AppComment>? comments = [];

  @override
  void initState() {
    super.initState();
    repo = context.read<UserProvider>();
    initRecorder();
    getCommentsData();
    mainContext = context;
  }

  getCommentsData() async {
    setState(() {
      isLoading = true;
    });
    comments = await repo.getTimeSheetComments(widget.timesheetId);
    print("Comments ${comments}");
    setState(() {
      isLoading = false;
    });
  }

  initRecorder() async {
    final status = await Permission.microphone.status;
    if (status != PermissionStatus.granted) {
      PermissionStatus result = await Permission.microphone.request();
      debugPrint("Permission result $result ");
      if (result != PermissionStatus.granted) {
        throw "Microphone permission is not granted";
      }
    }
    String name = repo.recordFileName ?? "sgRecord.m4a";
    tempDir = await getTemporaryDirectory();
    outputFile = '${tempDir.path}/$name';
    await recorder.openRecorder();
    isRecorderReady = true;
    recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  _refreshDetails() async {
    var repo = context.read<UserProvider>();
  }

  @override
  Widget build(BuildContext context) {
    mainContext = context;
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        appBar: GeneralAppBar(
            title: "Comments",
            backBtn: true,
            actions: Padding(
              padding: const EdgeInsets.only(top: 2, left: 4),
              child: widget.requestChanges == true
                  ? TextButton(
                      onPressed: () {
                        if (widget.onRequestChanges != null) {
                          widget.onRequestChanges!();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors
                            .lightAccentColor, // Set the background color
                      ),
                      child: Text(
                        "Propose",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                    )
                  : SizedBox(),
            )),
        body: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
                bottom: 20,
                right: 0,
                child: SizedBox(
                  width: !ResponsiveBreakpoints.of(context).isPhone
                      ? MediaQuery.of(context).size.width * 0.65
                      : MediaQuery.of(context).size.width,
                  child: _buildAddCommentRow(),
                )),
            isLoading
                ? Center(
                    child: CircularProgressIndicator.adaptive(),
                  )
                : Padding(
                    padding:
                        EdgeInsets.only(bottom: hasRecordInQueue ? 150 : 80),
                    child: ListView.builder(
                      itemCount: (isAddingFile
                          ? (comments?.length ?? 0) + 1
                          : comments?.length ?? 0),
                      padding: const EdgeInsets.only(top: 12, bottom: 96),
                      itemBuilder: (BuildContext context, int index) {
                        if (isAddingFile && index == (comments?.length ?? 0)) {
                          return addingFileWidget();
                        }

                        return buildCommentCard(comments?[index]);
                      },
                    ),
                  )
          ],
        ),
      ),
    );
  }

  _buildAddCommentRow() {
    return Column(
      children: [
        const Divider(
          thickness: 1,
        ),
        hasRecordInQueue
            ? Container(
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: VoiceMessage(
                          audioFile: Future.value(audioFile),
                          meBgColor: AppColors.lightPrimaryColor,
                          me: true,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox(),
        const SizedBox(
          height: 4,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () async {
                            if (isRecording || hasRecordInQueue) {
                              await stopRecording();
                              setState(() {
                                audioFile = null;
                                isRecording = false;
                                hasRecordInQueue = false;
                              });
                            } else {
                              AppUtils.showPickSource(context, pickFile);
                            }
                          },
                          child: isRecording || hasRecordInQueue
                              ? const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 30,
                                )
                              : Icon(
                                  Icons.add,
                                  size: 32,
                                  color: AppColors.lightPrimaryColor,
                                ),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Expanded(
                          child: Container(
                            // width: MediaQuery.of(context).size.width * 0.63,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 0.5, color: const Color(0xffA7ACB0)),
                                borderRadius: BorderRadius.circular(30.0)),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                buildTextInput(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              FloatingActionButton(
                onPressed: () {
                  if (hasRecordInQueue) {
                    print("addNewVoiceRecordComment");

                    addNewVoiceRecordComment();
                  }
                  if (comment.text.isNotEmpty) {
                    addNewComment();
                  }
                },
                backgroundColor: AppColors.lightPrimaryColor,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                      color: AppColors.lightPrimaryColor,
                      border: Border.all(
                          width: 0.5, color: const Color(0xffA7ACB0)),
                      borderRadius: BorderRadius.circular(100.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: comment.text.isEmpty == true
                        ? hasRecordInQueue
                            ? InkWell(
                                child: const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                ),
                                onTap: () {
                                  if (hasRecordInQueue) {
                                    addNewVoiceRecordComment();
                                  }
                                },
                              )
                            : InkWell(
                                onTap: () {
                                  setState(() {
                                    hasRecordInQueue = false;
                                    isRecording = !isRecording;
                                  });
                                  if (isRecording) {
                                    startRecording();
                                  } else {
                                    stopRecording();
                                  }
                                },
                                child: isRecording
                                    ? const Icon(
                                        Icons.pause,
                                        color: Colors.white,
                                      )
                                    : SvgPicture.asset(kMicIcon))
                        : const Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  buildTextInput() {
    return StreamBuilder<RecordingDisposition>(
        stream: recorder.onProgress,
        builder: (context, snap) {
          final duration = snap.hasData ? snap.data!.duration : Duration.zero;

          String twoDigits(int n) => n.toString().padLeft(2);
          final twoDigitsMinutes = twoDigits(duration.inMinutes.remainder(60));
          final twoDigitsSeconds = twoDigits(duration.inSeconds.remainder(60));

          return SizedBox(
              width: !ResponsiveBreakpoints.of(context).isPhone
                  ? MediaQuery.of(context).size.width * 0.60 * 0.65
                  : (MediaQuery.of(context).size.width * 0.60),
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 4, bottom: 4),
                child: TextFormField(
                    style: Theme.of(context).textTheme.bodyMedium,
                    enabled: !isRecording && !hasRecordInQueue,
                    controller: comment,
                    onChanged: (txt) {
                      setState(() {});
                    },
                    maxLines: 5,
                    minLines: 1,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context).scaffoldBackgroundColor,
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.only(
                            left: 15, bottom: 11, top: 11, right: 15),
                        hintText: isRecording
                            ? "Recording ${"$twoDigitsMinutes:$twoDigitsSeconds s"}"
                            : "Your comment",
                        hintStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.grey))),
              ));
        });
  }

  pickFile({required PickSource source}) async {
    var repo = context.read<UserProvider>();
    XFile? file = await repo.pickFile(source: source);

    if (file != null) {
      selectedFiles?.add(file);
      addFileComment(file);
    }

    if (mainContext != null && mainContext?.mounted == true) {
      Navigator.pop(mainContext);
      setState(() {});
    }
  }

  showRecordChoice() {
    repo.setRecordFileName(
        "record_${DateTime.now().millisecondsSinceEpoch}.m4a");

    showMaterialModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      context: context,
      builder: (context) => StatefulBuilder(builder: (BuildContext context,
          StateSetter setModalState /*You can rename this!*/) {
        return AudioRecorder(
          onDone: (File file) {
            selectedFiles?.add(file);
            addFileComment(file);
            WidgetsBinding.instance
                .addPostFrameCallback((_) => setState(() {}));
          },
        );
      }),
    );
  }

  addFileComment(file) async {
    List uploadedFiles = [];
    setState(() {
      isAddingComment = true;
      isAddingFile = true;
    });
    //await addFileCommentCall(uploadedFiles);
    await _refreshDetails();

    setState(() {
      isAddingComment = false;
      didUpdateComments = true;
      isAddingFile = false;
    });
  }

  buildCommentCard(AppComment? comment) {
    if (comment?.type == "loading") {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircularProgressIndicator.adaptive(),
      );
    }
    return CommentCard(
      comment: comment,
    );
  }

  showAddCommentBottomSheet() {
    showMaterialModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      context: context,
      builder: (context) => StatefulBuilder(builder: (BuildContext context,
          StateSetter setModalState /*You can rename this!*/) {
        return Container(
          height: 400,
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(12.0),
              )),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 16,
                ),
                LongAppInputField(
                  controller: details,
                  title: "Description",
                ),
                const SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: PrimaryButton("Add", isLoading: isAddingComment,
                      onPressed: () {
                    addNewComment();
                    Navigator.pop(context);
                  }),
                )
              ],
            ),
          ),
        );
      }),
    );
  }

  addNewVoiceRecordComment() async {
    setState(() {
      isAddingComment = true;
      canAddNewComment = false;
      hasRecordInQueue = false;
      isRecording = false;
    });
    try {
      var _firestore = FirebaseFirestore.instance;
      comments?.add(AppComment(
        addedBy: _firestore.collection('users').doc(repo.currentUser?.uid),
        addedAt: Timestamp.now(),
        type: "loading",
        comment: "",
        contract: _firestore
            .collection('contracts')
            .doc(repo.currentContract?.contractId ?? ""),
        timesheet: _firestore.collection('timesheets').doc(widget.timesheetId),
      ));
      setState(() {});

      String? url =
          await repo.addNewVoiceComment(outputFile, widget.timesheetId);

      if (url != null) {
        comments?[(comments?.length ?? 1) - 1] = (AppComment(
          addedBy: _firestore.collection('users').doc(repo.currentUser?.uid),
          addedAt: Timestamp.now(),
          type: "voice",
          comment: url,
          contract: _firestore
              .collection('contracts')
              .doc(repo.currentContract?.contractId ?? ""),
          timesheet:
              _firestore.collection('timesheets').doc(widget.timesheetId),
        ));
      } else {
        ErrorUtils.showGeneralError(
          context,
          "Could not add the voice",
          duration: const Duration(seconds: 5),
        );
      }

      comment.clear();
    } catch (e, s) {
      debugPrint("Error while adding new voice comment $e $s");

      ErrorUtils.showGeneralError(
        context,
        "Could not add the voice",
        duration: const Duration(seconds: 5),
      );
    }
    setState(() {
      isAddingComment = false;
      canAddNewComment = true;
      didUpdateComments = true;
      hasRecordInQueue = false;
      isRecording = false;
    });
  }

  addNewComment() async {
    setState(() {
      isAddingComment = true;
      canAddNewComment = false;
    });
    try {
      var _firestore = FirebaseFirestore.instance;

      String commentText = comment.text.trim();
      comments?.add(AppComment(
        addedBy: _firestore.collection('users').doc(repo.currentUser?.uid),
        addedAt: Timestamp.now(),
        type: "text",
        comment: commentText,
        contract: _firestore
            .collection('contracts')
            .doc(repo.currentContract?.contractId ?? ""),
        timesheet: _firestore.collection('timesheets').doc(widget.timesheetId),
      ));
      setState(() {});
      repo.addNewTextComment(commentText, widget.timesheetId);
      comment.clear();
    } catch (e, s) {
      debugPrint("Error while adding new comment $e $s");

      ErrorUtils.showGeneralError(
        context,
        "Could not add the comment",
        duration: const Duration(seconds: 5),
      );
    }
    setState(() {
      isAddingComment = false;
      canAddNewComment = true;
      didUpdateComments = true;
    });
  }

  // String getUserName(Note note, clientUsers) {
  //   for (ClientUser? user in clientUsers) {
  //     if (user?.id == note.user) {
  //       return user?.name ?? "";
  //     }
  //   }
  //   if (note.id == currentUserId) {
  //     return currentUser?.name ?? "";
  //   }
  //   return "N/A";
  // }

  addingFileWidget() {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: SizedBox(
              width: 160.0,
              child: CustomPaint(
                painter: AppSpecialChatBubbleThree(
                    color: const Color(0xFFE8E8EE),
                    alignment: Alignment.topRight,
                    tail: true),
                child: LinearPercentIndicator(
                  backgroundColor: const Color(0xFFE8E8EE),
                  padding: const EdgeInsets.only(right: 11),
                  //fillColor: Colors.green.withOpacity(0.6),
                  progressColor: Colors.green.withOpacity(0.6),
                  lineHeight: 60,
                  percent: (uploadPercent ?? 0.0 / 100) / 100,
                  center: Text(
                    "${uploadPercent?.toInt()}%",
                    style: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  barRadius: const Radius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  stopRecording() async {
    if (!isRecorderReady) return;

    final path = await recorder.stopRecorder();
    audioFile = File(path!);
    setState(() {
      hasRecordInQueue = true;
    });

    debugPrint('Recorded Audio $audioFile');
  }

  submitVoiceRecord() {
    selectedFiles?.add(audioFile);
    addFileComment(audioFile);
    hasRecordInQueue = false;
    isRecording = false;
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  startRecording() async {
    if (!isRecorderReady) return;
    recorder.startRecorder(
        toFile: outputFile, codec: _codec, audioSource: AudioSource.microphone);
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await stopRecording();
    recorder.closeRecorder();
  }
}

class LongAppInputField extends StatelessWidget {
  const LongAppInputField(
      {Key? key,
      required this.controller,
      required this.title,
      this.isEnable = true})
      : super(key: key);
  final TextEditingController controller;
  final String title;
  final bool isEnable;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    title,
                    textAlign: TextAlign.left,
                    style: Style().appTextTheme(context).headline2?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).textTheme.bodyText1?.color),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                TextFormField(
                  style: Theme.of(context).textTheme.bodyMedium,
                  enabled: isEnable,
                  minLines: 4,
                  controller: controller,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: InputDecoration(
                    filled: true, // Enable filling the background
                    fillColor: Theme.of(context).scaffoldBackgroundColor, //
                    border: Style()
                        .light(context)
                        .inputDecorationTheme
                        .enabledBorder
                        ?.copyWith(
                            borderSide: const BorderSide(
                                color: Color(0xffDCDCDC), width: 2)),
                  ),
                ),
              ],
            )));
  }
}
