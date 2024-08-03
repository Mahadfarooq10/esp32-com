import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class FileExplorer extends StatefulWidget {
  final Function(String) onFileSelected;

  FileExplorer({required this.onFileSelected});

  @override
  _FileExplorerState createState() => _FileExplorerState();
}

class _FileExplorerState extends State<FileExplorer> {
  String? selectedFileName;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      initialDirectory: '/storage/emulated/0/Download',
    );

    if (result != null) {
      String fileName = result.files.single.name;
      setState(() {
        selectedFileName = fileName;
      });

      widget.onFileSelected(fileName);
    } else {
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _pickFile,
          child: Text('Select File'),
        ),
        if (selectedFileName != null)
          Text('Selected file: $selectedFileName'),
      ],
    );
  }
}