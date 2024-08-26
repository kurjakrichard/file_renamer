import 'package:flutter/material.dart';
import 'screens/homepage.dart';

void main() {
  runApp(const FileRenamer());
}

class FileRenamer extends StatelessWidget {
  const FileRenamer({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'File Renamer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}
