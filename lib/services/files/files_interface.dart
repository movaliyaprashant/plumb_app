import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:plumbata/services/files/types.dart';

abstract class FilesServices {
  Future<XFile?> pickFile({required PickSource source});
}
