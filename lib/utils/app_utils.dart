import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:plumbata/net/model/worker.dart';
import 'package:plumbata/services/files/types.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:plumbata/utils/app_audio_player.dart';
import 'package:plumbata/utils/colors.dart';
import 'package:plumbata/utils/file_preview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class AppUtils {
  static showPickSource(context, pickFile) {
    showMaterialModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      context: context,
      builder: (context) =>
          SizedBox(
            height: 400,
            child: Column(
              children: [
                const SizedBox(
                  height: 16,
                ),
                ListTile(
                  title: Text("Gallery",
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodyMedium),
                  leading: const Icon(Icons.photo),
                  onTap: () => pickFile(isCamera: false),
                ),
                const Divider(),
                ListTile(
                  title:
                  Text("Camera", style: Theme
                      .of(context)
                      .textTheme
                      .bodyMedium),
                  leading: const Icon(Icons.camera_alt_rounded),
                  onTap: () => pickFile(isCamera: true),
                ),
              ],
            ),
          ),
    );
  }

  static Future<XFile?> pickCameraPhoto() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile;
    pickedFile = await _picker.pickImage(source: ImageSource.camera);
    return pickedFile;
  }

  static Future<XFile?> pickCameraVideo() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile;
    pickedFile = await _picker.pickVideo(source: ImageSource.camera);
    return pickedFile;
  }

  static Future<XFile?> pickGalleryVideo() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile;
    pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    return pickedFile;
  }

  static Future<XFile?> pickGalleryPhoto() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile;
    pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    return pickedFile;
  }
  static Future<XFile?> pickGeneralFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      XFile file = XFile(result.files.single.path!);
      return file;
    } else {
      return null;
    }
  }

  static showPickFileSource(context, pickFile) {
    showMaterialModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      context: context,
      builder: (context) =>
          SizedBox(
            height: 450,
            child: Column(
              children: [
                const SizedBox(
                  height: 16,
                ),
                ListTile(
                  title: Text(
                    "File",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  leading: const Icon(Icons.file_upload),
                  onTap: () => pickFile(source: PickSource.FILE),
                ),
                const Divider(),
                const SizedBox(
                  height: 16,
                ),
                ListTile(
                  title: Text("Gallery Photo",
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodyMedium),
                  leading: const Icon(Icons.photo),
                  onTap: () => pickFile(isCamera: false, isVideo: false),
                ),
                const Divider(),
                ListTile(
                  title: Text("Camera Photo",
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodyMedium),
                  leading: const Icon(Icons.camera_alt_rounded),
                  onTap: () => pickFile(isCamera: true, isVideo: false),
                ),
                const Divider(),
                ListTile(
                  title: Text("Gallery Video",
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodyMedium),
                  leading: const Icon(Icons.video_camera_back_outlined),
                  onTap: () => pickFile(isCamera: false, isVideo: true),
                ),
                const Divider(),
                ListTile(
                  title: Text("Camera Video",
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodyMedium),
                  leading: const Icon(Icons.video_camera_back_outlined),
                  onTap: () => pickFile(isCamera: true, isVideo: true),
                ),
                const Divider(),
              ],
            ),
          ),
    );
  }

  static double calculateTotalSlotToalTime(DateTime startTime, DateTime endTime, int breakMin, int breakHrs) {
    // Calculate total break time in minutes
    int totalBreakMinutes = breakMin + breakHrs * 60;

    // Calculate total duration in minutes
    int totalDurationMinutes = endTime.difference(startTime).inMinutes;

    // Subtract break time from total duration
    int effectiveDurationMinutes = max(0, totalDurationMinutes - totalBreakMinutes);

    // Convert effective duration to hours with two decimal places
    double totalHours = effectiveDurationMinutes / 60.0;

    return double.parse(totalHours.toStringAsFixed(2));
  }
  static Duration? calculateTimeDifference(TimeOfDay? startTime,
      TimeOfDay? endTime,
      int? breakHours,
      int? breakMinutes,
      bool isCrew,
      int crewWorkers) {
    if (startTime == null || endTime == null) {
      return null;
    }

    DateTime now = DateTime.now();
    DateTime startDate = DateTime(
        now.year, now.month, now.day, startTime.hour, startTime.minute);
    DateTime endDate =
    DateTime(now.year, now.month, now.day, endTime.hour, endTime.minute);

    if (startDate.isAfter(endDate)) {
      return null;
    }

    Duration workDuration = endDate.difference(startDate);
    Duration breakDuration =
    Duration(hours: breakHours ?? 0, minutes: breakMinutes ?? 0);
    Duration netDuration = workDuration - breakDuration;
    if (netDuration.isNegative) {
      return null;
    }
    if (isCrew) {
      netDuration = netDuration * crewWorkers;
    }
    return netDuration;
  }

  static String formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes % 60;

    // Use sprintf to format hours and minutes with leading zeros
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(
        2, '0')}';
  }

  static FileType getXFileType(XFile xFile) {
    File file = File(xFile.path);

    if (isImage(xFile)) {
      return FileType.photo;
    }

    if (isVideo(xFile)) {
      return FileType.video;
    }

    return FileType.unknown;
  }

  static bool isImage(XFile xFile) {
    File file = File(xFile.path);
    try {
      Uint8List bytes = file.readAsBytesSync();
      img.Image? decodedImage = img.decodeImage(bytes);

      return decodedImage != null;
    } catch (e) {
      return false;
    }
  }

  static bool isVideo(XFile xFile) {
    File file = File(xFile.path);
    try {
      FileStat fileStat = file.statSync();

      return fileStat.size > 0;
    } catch (e) {
      return false;
    }
  }
  static String convertToHHMM(double timeInHours) {
    // Separate whole number and decimal part
    int wholeNumberPart = timeInHours.floor();
    double decimalPart = timeInHours - wholeNumberPart;

    // Calculate minutes
    int minutes = (decimalPart * 60).round();

    // Format the result
    String formattedTime =
        '${wholeNumberPart.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';

    return formattedTime;
  }
  static Future<void> utilLaunchUrl(link, name, context) async {
    final Uri url = Uri.parse(link);
    String? fileType = AppUtils.getFileExtension(name)?.toLowerCase().trim();
    List<String> photosExt = [
      ".JPEG",
      ".GIF",
      ".JPG",
      ".PNG",
      ".TIFF",
      ".BMP",
      ".WebP",
      ".HEIF"
    ];
    debugPrint("fileType $fileType");
    debugPrint("fileType ${fileType?.contains(".m4a") == true}");
    if (photosExt.contains(fileType?.toUpperCase())) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (ctx) => AppFileViewer(
                link: link,
                title: name,
              )));
    } else if (fileType?.contains(".m4a") == true) {
      showMaterialModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        context: context,
        builder: (context) => StatefulBuilder(builder: (BuildContext context,
            StateSetter setModalState /*You can rename this!*/) {
          return AppAudioPlayer(link: link);
        }),
      );
    } else {
      debugPrint("External LINK");
      if (!await launchUrl(
        url,
        webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true, enableDomStorage: true),
        mode: LaunchMode.externalApplication,
      )) {
        throw 'Could not launch $url';
      }
    }
  }
  static String? getFileExtension(String fileName) {
    try {
      return ".${fileName.split('.').last}";
    } catch (e) {
      return null;
    }
  }
  static String calculateTotalDuration(
      startTime, endTime, int breakHrs, int breakMins) {
    if (startTime != null && endTime != null) {
      // Calculate the total duration in minutes
      DateTime now = DateTime.now();
      DateTime start = DateTime(
          now.year, now.month, now.day, startTime.hour, startTime.minute);
      DateTime end =
      DateTime(now.year, now.month, now.day, endTime.hour, endTime.minute);

      int totalMinutes = end.difference(start).inMinutes;

      print("totalMinutes $totalMinutes");

      // Subtract break time
      totalMinutes = totalMinutes - (breakHrs * 60);
      totalMinutes = totalMinutes - breakMins;

      // Convert total minutes to hours and minutes
      int hours = (totalMinutes / 60).floor();

      int minutes = totalMinutes % 60;

      // Format the result as "hh:mm"
      String formattedTime = '$hours:${minutes.toString().padLeft(2, '0')}';

      return formattedTime;
    } else {
      return '0:00'; // Handle the case where either startTime or endTime is null
    }
  }

  static String capitalize(String? s) {
    if (s == null || s == '') {
      s = '';
      return s;
    }
    return s[0].toUpperCase() + s.substring(1);
  }
  static formatTimeDate(DateTime? date) {
    if (date != null) {
      var outputFormat = DateFormat.yMd().add_Hm().format(date);
      return outputFormat;
    }
    return '';
  }

  static getInputDecoration(String hint,IconData prefixIcon) {
    return InputDecoration(
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.lightAccentColor, width: 2),
          borderRadius: BorderRadius.circular(10)),
      focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.errorColor, width: 2),
          borderRadius: BorderRadius.circular(10)),
      labelText: hint,
      prefixIcon: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Icon(prefixIcon),
      ),
      floatingLabelStyle: MaterialStateTextStyle.resolveWith(
            (Set<MaterialState> states) {
          final Color color = states.contains(MaterialState.error)
              ? AppColors.errorColor
              : Colors.black;
          return TextStyle(color: color, letterSpacing: 1.3);
        },
      ),
    );
  }



  static void showConfirmationDialog(BuildContext context, String message, onYes) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text(
            message,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Handle "No" button press
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'No',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () {
                // Handle "Yes" button press
                // You can add your approval logic here
                onYes();
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'Yes',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

static Timestamp parseTimeStringToTimeStamp(String timeString) {
    // Assuming timeString is in "H:mm" format
    final parts = timeString.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);

    final currentTime = DateTime.now();
    final startTime = DateTime(currentTime.year, currentTime.month, currentTime.day, hours, minutes);

    return Timestamp.fromDate(startTime);
  }

  static String formatMinutesToHHMM(int minutes) {
    // Calculate hours and remaining minutes
    print("minutes ${minutes}");

    int hours = minutes ~/ 60;
    int remainingMinutes = minutes % 60;

    // Format the time
    String formattedTime =
        '${hours.toString().padLeft(2, '0')}:${remainingMinutes.toString().padLeft(2, '0')}';

    return formattedTime;
  }

  static showYesNoDialog(BuildContext context, {
    required onYes,
    required onNo,
    required String title,
    required String message

  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: Theme.of(context).textTheme.bodyMedium,),
          content: Text(message, style: Theme.of(context).textTheme.bodyMedium,),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Handle 'No' button press
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onYes();
              },
              child: Text('Yes'),
            ),

          ],
        );
      },
    ).then((result) {
      // Handle the result of the dialog (true for 'Yes', false for 'No')
      if (result != null && result) {
        onYes();
      } else {
        // User pressed 'No'
        // Add your logic here
        onNo();
        print('User pressed No');
      }
    });
  }

}
/// Get screen media.
final MediaQueryData media =
MediaQueryData.fromView(WidgetsBinding.instance.window);

/// This extention help us to make widget responsive.
extension NumberParsing on num {
  double w(context, {widthRatio = 150}) {
    if (media.size.width < 450) {
      return this * media.size.width / 100;
    }
    return this * media.size.width / (widthRatio ?? 200);
  }

  double h() => this * media.size.height / 100;
}


enum FileType { photo, video, unknown }
