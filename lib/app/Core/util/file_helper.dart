import 'package:flutter/material.dart';

IconData getFileIcon(String path) {
  final ext = getFileExtension(path).toLowerCase();

  switch (ext) {
    case 'pdf':
      return Icons.picture_as_pdf;

    case 'doc':
    case 'docx':
      return Icons.description;

    case 'xls':
    case 'xlsx':
      return Icons.table_chart;

    case 'ppt':
    case 'pptx':
      return Icons.slideshow;

    case 'txt':
      return Icons.text_snippet;

    case 'csv':
      return Icons.grid_on;

    case 'zip':
      return Icons.folder_zip;

    case 'rar':
      return Icons.folder_zip;

    case '7z':
      return Icons.folder_zip;

    default:
      return Icons.insert_drive_file;
  }
}

Color getFileColor(String path) {
  final ext = getFileExtension(path).toLowerCase();

  switch (ext) {
    case 'pdf':
      return Colors.red;

    case 'doc':
    case 'docx':
      return Colors.blue;

    case 'xls':
    case 'xlsx':
      return Colors.green;

    case 'ppt':
    case 'pptx':
      return Colors.orange;

    case 'txt':
      return Colors.grey.shade700;

    case 'csv':
      return Colors.teal;

    case 'zip':
    case 'rar':
    case '7z':
      return Colors.deepPurple;

    default:
      return Colors.grey;
  }
}

String getFileExtension(String path) {
  if (!path.contains('.')) return "";
  return path.split('.').last.toLowerCase();
}

String removeDuplicateExtension(String name) {
  final extensions = [
    '.pdf',
    '.doc',
    '.docx',
    '.xls',
    '.xlsx',
    '.ppt',
    '.pptx',
    '.txt',
    '.csv',
    '.zip',
    '.rar',
    '.7z',
  ];

  for (final ext in extensions) {
    if (name.toLowerCase().endsWith('$ext$ext')) {
      return name.replaceFirst(
        RegExp('$ext\$',
            caseSensitive: false),
        '',
      );
    }
  }

  return name;
}