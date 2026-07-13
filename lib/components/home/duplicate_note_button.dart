import 'package:flutter/material.dart';
import 'package:saber/data/file_manager/file_manager.dart';
import 'package:saber/i18n/strings.g.dart';
import 'package:saber/pages/editor/editor.dart';

class DuplicateNoteButton extends StatelessWidget {
  const DuplicateNoteButton({
    super.key,
    required this.filesToDuplicate,
    required this.unselectNotes,
  });

  final List<String> filesToDuplicate;
  final void Function() unselectNotes;

  Future<void> _duplicateNotes() async {
    await Future.wait([
      for (final filePath in filesToDuplicate)
        Future.value(
          FileManager.doesFileExist(filePath + Editor.extensionOldJson),
        ).then((oldExtension) {
          final extension = oldExtension
              ? Editor.extensionOldJson
              : Editor.extension;
          return FileManager.copyFile(
            filePath + extension,
            filePath + extension,
          );
        }),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: .zero,
      tooltip: t.home.duplicateNote,
      onPressed: () async {
        await _duplicateNotes();
        unselectNotes();
      },
      icon: const Icon(Icons.file_copy),
    );
  }
}
