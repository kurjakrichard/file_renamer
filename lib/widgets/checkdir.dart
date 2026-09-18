import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'alertdialog.dart';

class CheckDir extends StatefulWidget {
  const CheckDir({super.key});

  @override
  State<CheckDir> createState() => _CheckDirState();
}

class _CheckDirState extends State<CheckDir> {
  //check dir part
  String? checkedDirName;
  String? seriesSelected;
  Map<String, dynamic> seriesMap = {};
  List<String> missingInvoices = [];
  List<String> otherFiles = [];
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              text('Add meg az ellenőrizendő mappát:   '),
              ElevatedButton(
                onPressed: () async {
                  checkDirectory();
                },
                child: const Icon(Icons.add),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(checkedDirName ?? ''),
              )
            ],
          ),
        ),
        seriesMap.isEmpty
            ? Flexible(flex: 1, child: Container())
            : Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16),
                child: Row(
                  children: [
                    text(
                      'Vizsgált sorozat:   ',
                    ),
                    Text(
                      seriesSelected!,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    seriesMap.length > 1
                        ? Text(
                            'Sorozatok: ${seriesMap.keys.toString()}',
                            style: const TextStyle(fontSize: 16),
                          )
                        : Container()
                  ],
                ),
              ),
        missingInvoices.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Row(
                  children: [
                    text('Hiányzó fájlok: '),
                  ],
                ),
              )
            : Flexible(flex: 1, child: Container()),
        // Datatable for missing files
        missingInvoices.isNotEmpty
            ? Expanded(flex: 50, child: dataTable(missingInvoices))
            : Flexible(flex: 1, child: Container()),
        otherFiles.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Row(
                  children: [
                    text('Egyéb fájlok: '),
                  ],
                ),
              )
            : Flexible(flex: 1, child: Container()),
        // Datatable for other files
        otherFiles.isNotEmpty
            ? Expanded(flex: 50, child: dataTable(otherFiles))
            : Flexible(flex: 1, child: Container()) //Other files
      ],
    ));
  }

  void checkDirectory() async {
   
    List<File> checkedFiles = [];
    List<String> checkedFileNames = [];
    List<String> machinatorList = [];
    List<String> fullList = [];
    seriesSelected = null;
    seriesMap = {};  
    otherFiles = [];
    missingInvoices = [];

    checkedDirName = await FilePicker.platform.getDirectoryPath();
    if (checkedDirName != null) {
      setState(
        () {
          Directory checkedDir = Directory(checkedDirName!);
          List<FileSystemEntity> entities = checkedDir.listSync();
          checkedFiles = entities.whereType<File>().toList();
          for (File file in checkedFiles) {
            checkedFileNames.add(p.basename(file.path));
          }     
          for (var element in checkedFileNames) {   
               if (['-', '_'].contains(element[2]) &&
                ['-', '_'].contains(element[5]) && 
                int.tryParse(element.substring(6, 10)) != null &&
                ['-', '_', ' '].contains(element[11])
                ) {
            String elementseries = element.substring(0, 6);
              if (!seriesMap.containsKey(elementseries)) {
                seriesMap[elementseries] = 1;
              } else {
                seriesMap[elementseries] += 1;
              }
            }
          }

          if (seriesMap.isNotEmpty) {
            String highest = seriesMap.keys.first;
            var max = seriesMap.values.first;
            seriesMap.forEach((key, value) {
              if (max < value) {
                max = value;
                highest = key;
              }
            });

            seriesSelected = highest;

            if (seriesSelected != null) {
              checkedFileNames.where((filename) {
                 String machinatorNumber;

                 if(filename.length < 12){
                  machinatorNumber = filename;} else {
                  machinatorNumber = filename.substring(0, 12);
                  }
                       

                if (machinatorNumber.startsWith(seriesSelected!) &&
                    (machinatorNumber.substring(11, 12) == '_' ||
                        machinatorNumber.substring(11, 12) == '-')) {
                  machinatorList.add(machinatorNumber.substring(0, 11));
                }
                return machinatorNumber.startsWith(seriesSelected!);
              }).toList();
              machinatorList.sort();
              machinatorList.toSet().toList();

              fullList = List.generate(
                  int.parse(machinatorList.last.substring(6, 11)), (int index) {
                String numpart = '${index + 1}'.padLeft(5, '0');
                return ('$seriesSelected$numpart');
              });
            }

            otherFiles = List<String>.of(checkedFileNames);
            otherFiles.retainWhere((e) {
              return !e.startsWith(seriesSelected!) ||
                  (!e.substring(11, 12).endsWith('_') &&
                      !e.substring(11, 12).endsWith('-'));
            });
            otherFiles.sort();
            missingInvoices =
                fullList.toSet().difference(machinatorList.toSet()).toList();
          } else {
            checkedDirName = null;
            alertDialog(
                context, 'Hibás mappa', 'A mappa üres vagy nem megfelelő!');
          }
        },
      );
    }
  }

  Widget dataTable(List<String> datas) {
    return SingleChildScrollView(
      child: DataTable(
        headingRowHeight: 0,
        columns: <DataColumn>[
          DataColumn(
            label: Container(),
          ),
        ],
        rows: datas
            .map(
              (entry) => DataRow(
                cells: [
                  DataCell(Text(entry)),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  Widget text(String text) {
    return Text(text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
  }
}
