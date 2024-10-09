import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Directory? dir;
  FilePickerResult? pickedFile;
  String? fileName;
  String? dirName;
  String separator = Platform.isWindows ? '\\' : '/';
  List<File> files = [];
  Map<String, String> excelList = {};
  Map<String, String> fileList = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Rename Files',
          style: TextStyle(color: Colors.white),
        ),
      ),
      floatingActionButton: dir == null || fileName == null
          ? FloatingActionButton(
              backgroundColor: Colors.grey,
              child: const Icon(
                Icons.shuffle,
                color: Colors.white,
              ),
              onPressed: () {})
          : FloatingActionButton(
              backgroundColor: Colors.blue,
              tooltip: 'Rename Files',
              child: const Icon(
                Icons.shuffle,
                color: Colors.white,
              ),
              onPressed: () {
                if (dir != null) {
                  for (var file in files) {
                    String oldName = p.basename(file.path);
                    String path = p.dirname(file.path);
                    String addString = excelList[oldName.split('_')[0]] ??
                        excelList[oldName.split(' ')[0]] ??
                        '';
                    if (addString != '') {
                      String newName = '${addString.replaceAll('/', '_')}_$oldName';
                      file.rename('$path/$newName');
                    }
                  }
                  setState(() {
                    List<FileSystemEntity> entities = dir!.listSync();
                    files = entities.whereType<File>().toList();
                    dir = null;
                  });
                }
                _dialogBuilder(context);
              },
            ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text('Add meg a átnevezedő fájlok mappáját:   '),
                ElevatedButton(
                  onPressed: () async {
                    String? selectedDirectory =
                        await FilePicker.platform.getDirectoryPath();
                    setState(() {
                      dir = Directory(selectedDirectory!);
                      dirName = selectedDirectory;
                      List<FileSystemEntity> entities = dir!.listSync();
                      files = entities.whereType<File>().toList();
                      createFilelist();
                    });
                  },
                  child: const Icon(Icons.add),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(dirName ?? ''),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text('Válaszd ki az excel fájl:   '),
                ElevatedButton(
                  onPressed: () async {
                    FilePickerResult? pickedFile =
                        await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['xlsx'],
                      allowMultiple: false,
                    );

                    /// file might be picked
                    setState(() {
                      if (pickedFile != null) {
                       fileName = pickedFile.files.single.name;
                        var bytes = File(pickedFile.files.first.path!)
                            .readAsBytesSync();
                        var excel = Excel.decodeBytes(bytes);
                        for (var table in excel.tables.keys) {
                          for (var row in excel.tables[table]!.rows) {
                            //print('${row[9]!.value}');
                            //print('${row[1]!.value}'.substring(3));
                            excelList['${row[9]!.value}'] = '${row[1]!.value}'.substring(3);
                          }
                        }
                      }
                    });
                    createFilelist();
                  },
                  child: const Icon(Icons.add),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(fileName ?? ''),
                )
              ],
            ),
          ),
          dataTable(),
        ],
      ),
    );
  }

  Widget dataTable() {
    return DataTable(
      columns: const <DataColumn>[
        DataColumn(
          label: Text(
            'Régi név',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
        DataColumn(
          label: Text(
            'Új név',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      ],
      rows: fileList.entries
          .map(
            (entry) => DataRow(
              cells: [
                DataCell(Text(entry.key)),
                DataCell(Text(entry.value)),
              ],
            ),
          )
          .toList(),
    );
  }

  void createFilelist() {
    if (excelList.isNotEmpty && files.isNotEmpty) {
      for (var file in files) {
        String oldName = p.basename(file.path);
       // print('Oldname $oldName');  
        String path = p.dirname(file.path);
        String addString = excelList[oldName.split('_')[0]] ??
            excelList[oldName.split(' ')[0]] ??
            '';
          //  print('addString $addString');
        if (addString != '') {
          String newName = '${addString.replaceAll('/', '_')}_$oldName';
          fileList[oldName] = newName;
        }
      }
    }
    print(fileList);
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Kész'),
          content: const Text(
            'Az átnevezés sikeresen befejeződött.',
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
