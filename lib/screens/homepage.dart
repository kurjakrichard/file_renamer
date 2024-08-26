import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';
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
  List<File> files = [];
  Map<String, String>? excelList = {};

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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(
          Icons.shuffle,
          color: Colors.white,
        ),
        onPressed: () {
          if (dir != null) {
            for (var file in files) {
              String oldName = p.basename(file.path);
              print(oldName);
              String path = p.dirname(file.path);
              String searchString = oldName.split('_')[0];
              print(searchString);
              String addString = excelList![searchString]!;
              String newName = '${addString}_$oldName';
              file.rename('$path/$newName');
            }
            setState(() {
              List<FileSystemEntity> entities = dir!.listSync();
              files = entities.whereType<File>().toList();
            });
          }
        },
      ),
      body: Column(
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
                          //print(table); //sheet Name
                          //print(excel.tables[table]!.maxColumns);
                          //print(excel.tables[table]!.maxRows);
                          for (var row in excel.tables[table]!.rows) {
                            excelList?['${row[1]!.value}'] = '${row[0]!.value}';

                            /*      for (var cell in row) {
                              print(
                                  'cell ${cell!.rowIndex}/${cell.columnIndex}');
                              final value = cell.value;
                              final numFormat = cell.cellStyle?.numberFormat ??
                                  NumFormat.standard_0;
                              switch (value) {
                                case null:
                                  print('  empty cell');
                                  print('  format: ${numFormat}');
                                case TextCellValue():
                                  print('  text: ${value.value}');
                                case FormulaCellValue():
                                  print('  formula: ${value.formula}');
                                  print('  format: ${numFormat}');
                                case IntCellValue():
                                  print('  int: ${value.value}');
                                  print('  format: ${numFormat}');
                                case BoolCellValue():
                                  print(
                                      '  bool: ${value.value ? 'YES!!' : 'NO..'}');
                                  print('  format: ${numFormat}');
                                case DoubleCellValue():
                                  print('  double: ${value.value}');
                                  print('  format: ${numFormat}');
                                case DateCellValue():
                                  print(
                                      '  date: ${value.year} ${value.month} ${value.day} (${value.asDateTimeLocal()})');
                                case TimeCellValue():
                                  print(
                                      '  time: ${value.hour} ${value.minute} ... (${value.asDuration()})');
                                case DateTimeCellValue():
                                  print(
                                      '  date with time: ${value.year} ${value.month} ${value.day} ${value.hour} ... (${value.asDateTimeLocal()})');
                              }
                            }
                          */
                          }
                          print(excelList);
                        }
                      }
                    });
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
          Flexible(
            child: files.isEmpty
                ? const Text('')
                : ListView.builder(
                    itemCount: files.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(files[index].path.split('/').last),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
