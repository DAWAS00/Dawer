import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dawa_chat_constants.dart';

/// Shows a bottom sheet that lets the user pick an image source for the chat
/// scanner. [onPicked] is invoked with the chosen [ImageSource] after the sheet
/// closes.
Future<void> showDawaImagePickSheet(
  BuildContext context, {
  required ValueChanged<ImageSource> onPicked,
}) {
  return showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(
              Icons.camera_alt_rounded,
              color: kDawaPrimaryGreen,
            ),
            title: const Text(
              'التقاط صورة بالكاميرا',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
            onTap: () {
              Navigator.pop(sheetContext);
              onPicked(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.photo_library_rounded,
              color: kDawaPrimaryGreen,
            ),
            title: const Text(
              'اختيار من المعرض',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
            onTap: () {
              Navigator.pop(sheetContext);
              onPicked(ImageSource.gallery);
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );
}
