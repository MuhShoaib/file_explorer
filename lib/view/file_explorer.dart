import 'dart:convert';
import 'package:file_explorer/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'method.dart';

class FileExplorer extends StatefulWidget {
  const FileExplorer({super.key});

  @override
  State<FileExplorer> createState() => _FileExplorerState();
}

class _FileExplorerState extends State<FileExplorer> {
  late Future<List> myFile;
  TextEditingController search = TextEditingController();
  Future<List> loadFile() async {
    String data = await rootBundle.loadString('assets/file.json');
    return json.decode(data);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myFile = loadFile();
  }

  final List<String> _expandedList = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: primary,
      appBar: AppBar(
        elevation: 5,
        title: const Text(
          "File Explorer Component",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: Colors.black.withOpacity(0.6),
      ),
      body: FutureBuilder(
        future: myFile,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final filteredData = _filterData(snapshot.data!, search.text);
            return Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: TextField(
                    controller: search,
                    onChanged: (value) {
                      setState(() {});
                    },
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(left: 10),
                        labelText: 'Search Folder',
                        labelStyle: TextStyle(color: textColor),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: textColor)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: textColor))),
                  ),
                ),
                _buildNode(filteredData, 0), // Use filteredData here
              ],
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Error loading data'),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  List<dynamic> _filterData(List data, String query) {
    if (query.isEmpty) {
      return List.from(data);
    } else {
      List<dynamic> filteredList = [];
      for (var item in data) {
        var copyItem = Map.from(item);
        if (copyItem['title'].toLowerCase().contains(query.toLowerCase())) {
          filteredList.add(copyItem);
        } else if (copyItem.containsKey('childrens')) {
          List<dynamic> children = _filterData(copyItem['childrens'], query);
          if (children.isNotEmpty) {
            copyItem['childrens'] = children;
            filteredList.add(copyItem);
          }
        }
      }
      return filteredList;
    }
  }

  Widget _buildNode(List data, int depth) {
    return ListView.builder(
      itemCount: data.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final item = data[index];
        final bool isFolder = item.containsKey('childrens');
        final bool isExpanded = _expandedList.contains(item['title']);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                if (!isFolder) {
                  showDepth(item, depth, context);
                }
                setState(() {
                  if (isFolder) {
                    if (isExpanded) {
                      _expandedList.remove(item['title']);
                    } else {
                      _expandedList.add(item['title']);
                    }
                  }
                });
              },
              child: ListTile(
                tileColor: Colors.transparent,
                splashColor: Colors.transparent,
                hoverColor: Colors.transparent,
                leading: isFolder
                    ? isExpanded
                        ? FittedBox(
                            fit: BoxFit.fill,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  color: textColor,
                                ),
                                Icon(
                                  Icons.folder,
                                  color: textColor,
                                )
                              ],
                            ),
                          )
                        : FittedBox(
                            fit: BoxFit.fill,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.keyboard_arrow_right,
                                  color: textColor,
                                ),
                                Icon(Icons.folder, color: textColor)
                              ],
                            ),
                          )
                    : Icon(
                        Icons.file_copy_outlined,
                        color: textColor,
                      ),
                title: Text(
                  item['title'],
                  style: TextStyle(color: textColor),
                ),
              ),
            ),
            if (isExpanded && isFolder)
              Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: _buildNode(item['childrens'], depth + 1),
              ),
          ],
        );
      },
    );
  }
}
