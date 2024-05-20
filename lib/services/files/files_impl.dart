import 'dart:io';
import 'dart:typed_data';


import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plumbata/services/files/files_interface.dart';
import 'package:plumbata/services/files/types.dart';


class FilesServiceImpl extends FilesServices {
  @override
  Future<XFile?> pickFile({required PickSource source}) async {
    try {
      switch (source) {
        case PickSource.FILE:
          return (await _pickGeneralFile());
        case PickSource.GALLERY_VIDEO:
          return (await _pickGalleryFile(isVideo: true));
        case PickSource.GALLERY_PHOTO:
          return (await _pickGalleryFile(isVideo: false));
        case PickSource.CAMERA_PHOTO:
          return (await _pickCameraFile(isVideo: false));
        case PickSource.CAMERA_VIDEO:
          return (await _pickCameraFile(isVideo: true));
      }
    } catch (e) {
      debugPrint("Error while picking the file $e ");
      return null;
    }
  }

  Future<XFile?> _pickGeneralFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      XFile file = XFile(result.files.single.path!);
      return file;
    } else {
      return null;
    }
  }

  Future<XFile?> _pickCameraFile({required bool isVideo}) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile;
    if (isVideo) {
      pickedFile = await _picker.pickVideo(source: ImageSource.camera);
    } else {
      pickedFile = await _picker.pickImage(source: ImageSource.camera);
    }

    return pickedFile;
  }
  Future<XFile?> _pickGalleryFile({required bool isVideo}) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile;
    if (isVideo) {
      pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    } else {
      pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    }
    return pickedFile;
  }

}
