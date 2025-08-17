import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../widgets/alertdialog.dart';
import '../widgets/checkdir.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //bottomnavigation part
  int _selectedindex = 0;

  //file renamer part
  String separator = Platform.isWindows ? '\\' : '/';
  Directory? renamerDir;
  FilePickerResult? renamerPickedFile;
  String? renameFileName;
  String? renameDirName;
  List<File> renameFiles = [];
  Map<String, String> excelList = {};
  Map renameFileList = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          _selectedindex == 0 ? appBar('File renamer') : appBar('Check dir'),
      body: _selectedindex == 0 ? fileRenamer() : const CheckDir(),
      floatingActionButton: _selectedindex == 0 ? floatingActionButton() : null,
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedindex,
          selectedItemColor: Colors.blue,
          onTap: navigateBottomBar,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home), label: 'File renamer'),
            BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Check dir'),
          ]),
    );
  }

  AppBar appBar(String text) {
    return AppBar(
      backgroundColor: Colors.blue,
      title: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  void navigateBottomBar(int index) {
    setState(() {
      _selectedindex = index;
    });
  }

  Widget fileRenamer() {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text('Add meg a átnevezedő fájlok mappáját:   ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ElevatedButton(
                onPressed: () async {
                  String? selectedDirectory =
                      await FilePicker.platform.getDirectoryPath();
                  if (selectedDirectory != null) {
                    setState(() {
                      renamerDir = Directory(selectedDirectory);
                      renameDirName = selectedDirectory;
                      List<FileSystemEntity> entities = renamerDir!.listSync();
                      renameFiles = entities.whereType<File>().toList();
                      createFilelist();
                    });
                  }
                },
                child: const Icon(Icons.add),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(renameDirName ?? ''),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text('Válaszd ki az excel fájl:   ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                      renameFileName = pickedFile.files.single.name;
                      var bytes =
                          File(pickedFile.files.first.path!).readAsBytesSync();
                      var excel = Excel.decodeBytes(bytes);
                      for (var table in excel.tables.keys) {
                        for (var row in excel.tables[table]!.rows) {
                          //print('${row[9]!.value}');
                          //print('${row[1]!.value}'.substring(3));
                          excelList['${row[9]!.value}'] =
                              '${row[1]!.value}'.substring(3);
                        }
                      }
                      print(excelList);
                    }
                  });
                  createFilelist();
                },
                child: const Icon(Icons.add),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(renameFileName ?? ''),
              )
            ],
          ),
        ),
        dataTable(),
      ],
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
      rows: renameFileList.entries
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
    if (excelList.isNotEmpty && renameFiles.isNotEmpty) {
      for (var file in renameFiles) {
        String oldName = p.basename(file.path);
        // print('Oldname $oldName');
        // String path = p.dirname(file.path);
        String addString = excelList[oldName.split('_')[0]] ??
            excelList[oldName.split(' ')[0]] ??
            '';
        //  print('addString $addString');
        if (addString != '') {
          String newName = '${addString.replaceAll('/', '_')}_$oldName';
          renameFileList[oldName] = newName;
        }
      }
    }
    print('RenameFileList: $renameFileList');
  }

  FloatingActionButton floatingActionButton() {
    return renamerDir == null || renameFileName == null
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
              if (renamerDir != null) {
                for (var file in renameFiles) {
                  String oldName = p.basename(file.path);
                  String path = p.dirname(file.path);
                  String addString = excelList[oldName.split('_')[0]] ??
                      excelList[oldName.split(' ')[0]] ??
                      '';
                  if (addString != '') {
                    String newName =
                        '${addString.replaceAll('/', '_')}_$oldName';
                    file.rename('$path/$newName');
                  }
                }
                setState(() {
                  List<FileSystemEntity> entities = renamerDir!.listSync();
                  renameFiles = entities.whereType<File>().toList();
                  renamerDir = null;
                });
              }
              alertDialog(
                  context, 'Kész', 'Az átnevezés sikeresen befejeződött.');
            },
          );
  }
}
