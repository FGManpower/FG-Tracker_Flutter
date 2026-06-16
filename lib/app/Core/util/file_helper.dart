

import 'package:flutter/material.dart';

IconData getFileIcon(String path) {
  final ext =
  path.split('.').last.toLowerCase();

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

    default:
      return Icons.insert_drive_file;
  }
}

Color getFileColor(String path) {
  final ext =
  path.split('.').last.toLowerCase();

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

    default:
      return Colors.grey;
  }
}

String getFileExtension(String path) {
  return path.split('.').last;
}