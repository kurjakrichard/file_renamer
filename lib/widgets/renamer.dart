import 'package:flutter/material.dart';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';
import '../widgets/alertdialog.dart';

enum Companies {Spirax, EuroPuppy }
class Renamer extends StatefulWidget {
  const Renamer({super.key});

  @override
  State<Renamer> createState() => _RenamerState();
}

class _RenamerState extends State<Renamer> {
  Companies _currencySelected = Companies.Spirax;

   //file renamer part
  String separator = Platform.isWindows ? '\\' : '/';
  Directory? selectedDir;
  FilePickerResult? renamerPickedFile;
  String? selectedFileName;
  String? selectedDirName;
  List<File> renameFiles = [];
  Map<String, String> excelList = {};
  Map renameFileList = {};

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: fileRenamer(),
      
      floatingActionButton: floatingActionButton(),
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

    Widget fileRenamer() {
    return ListView(
      children: [      
         Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16),  
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text('Válaszd ki a céget:   ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          dropDownButton()
            ],
          ),
        ),
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
                      selectedDir = Directory(selectedDirectory);
                      selectedDirName = selectedDirectory;
                      List<FileSystemEntity> entities = selectedDir!.listSync();
                      renameFiles = entities.whereType<File>().toList();
                      createFilelist();
                    });
                  }
                },
                child: const Icon(Icons.add),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(selectedDirName ?? ''),
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
                      selectedFileName = pickedFile.files.single.name;
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
                child: Text(selectedFileName ?? ''),
              )
            ],
          ),
        ),
        dataTable(),
      ],
    );
  }
  Widget dropDownButton() {
    return DropdownButton<Companies>(
        underline: Container(
          height: 1,
          color: Colors.white,
        ),
        value: _currencySelected,
        items: Companies.values.map((Companies value) {
          return DropdownMenuItem(value: value, child: Text(value.name));
        }).toList(),
        onChanged: (newValueSelected) {
          setState(() {
            _currencySelected = newValueSelected!;
          });
        });
  }

    FloatingActionButton floatingActionButton() {
    return selectedDir == null || selectedFileName == null
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
              if (selectedDir != null) {
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
                  List<FileSystemEntity> entities = selectedDir!.listSync();
                  renameFiles = entities.whereType<File>().toList();
                  selectedDir = null;
                });
              }
              alertDialog(
                  context, 'Kész', 'Az átnevezés sikeresen befejeződött.');
            },
          );
  }
}