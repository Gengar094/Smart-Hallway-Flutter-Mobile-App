import 'package:app_bar_with_search_switch/app_bar_with_search_switch.dart';
import 'package:flutter/material.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:smart_hallway/history_page/report.dart';
import 'package:smart_hallway/model/history_item.dart';
import 'package:smart_hallway/util/client.dart';
import '../history_page/save.dart';
import 'package:sqflite/sqflite.dart';
import 'package:csv/csv.dart';

class HistoryPage extends StatefulWidget {
  final Database db;
  const HistoryPage({super.key, required this.db});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // hardcoded datalist
  // List<HistoryItem> _items = List<HistoryItem>.generate(
  //     50,
  //     (index) => HistoryItem(
  //         trialId: index,
  //         comment: "this is hardcoded",
  //         fileName: index.toString() + " test"));

  List<HistoryItem> _items = [];
  List<HistoryItem> savedList = List.empty(growable: true);

  List<HistoryItem> resultList = [];
  Client io = Client();

  @override
  void initState() {
    // TODO: implement initState
    _loadItems().then((value) {
        print("herer");
        _loadSavedItems().then((savedItems) {
          setState(() {
            _items = List.from(value);
            savedList = List.from(savedItems);
            resultList = List.from(_items);
          });
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarWithSearchSwitch(
            onChanged: (text) {
              filterItems(text);
            },
            backgroundColor: Colors.green,
            fieldHintText: 'Search by trial name',
            appBarBuilder: (context) {
              return AppBar(
                centerTitle: true,
                title: const Text('Smart Hallway'),
                backgroundColor: Colors.green,
                actions: const [
                  AppBarSearchButton(),
                ],
              );
            }),
        bottomNavigationBar: BottomAppBar(
          color: Colors.green,
          shape: const CircularNotchedRectangle(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.star),
                color: Colors.white,
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => savedPage(
                            savedList: savedList,
                            resultList: resultList,
                            parentDelete: _remove,
                            parentUnsave: _unsave,
                          )));
                },
              ),
              // SizedBox(),
              PopupMenuButton(
                  icon: Icon(Icons.sort_sharp),
                  color: Colors.white,
                  offset: Offset(500, 500),
                  onSelected: (result) {
                    sort(result);
                  },
                  itemBuilder: (BuildContext context) => const <PopupMenuEntry>[
                        PopupMenuItem(
                          value: 0,
                          child: Text('Time: Old to New'),
                        ),
                        PopupMenuItem(
                          value: 1,
                          child: Text('Time: New to old'),
                        ),
                        PopupMenuItem(
                          value: 2,
                          child: Text('Trial Id: Low to High'),
                        ),
                        PopupMenuItem(
                          value: 3,
                          child: Text('Trial Id: High to Low'),
                        ),
                        PopupMenuItem(value: 4, child: Text('None'))
                      ]),
            ],
          ),
        ),
        body: ListView.separated(
            itemCount: resultList.length,
            separatorBuilder: (_, index) {
              return Divider(color: Colors.grey.shade400);
            },
            itemBuilder: (_, index) {
              final item = resultList[index];
              return ExpansionTileCard(
                title: Text(item.fileName),
                children: [
                  const Divider(
                    thickness: 1.0,
                    height: 1.0,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Text('Trial Id: ' + item.trialId.toString())),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Text(
                            "Recorded Time: " + item.trialTime.toString())),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Text("Comment: " + item.comment.toString())),
                  ),
                  ButtonBar(
                    alignment: MainAxisAlignment.spaceAround,
                    buttonPadding: EdgeInsets.all(0),
                    children: [
                      item.saved
                          ? _createButton("Unsave", item.trialId, item.fileName)
                          : _createButton("Save", item.trialId, item.fileName),
                      _createButton("Report", item.trialId, item.fileName),
                      _createButton("Delete", item.trialId, item.fileName),
                    ],
                  )
                ],
              );
            }));
  }

  Widget _createButton(String type, int trialId, String filename) {
    IconData icon = type == 'Save'
        ? Icons.star_border
        : type == 'Unsave'
            ? Icons.star
            : type == 'Report'
                ? Icons.my_library_books
                : Icons.delete_forever;

    return TextButton(
      onPressed: () {
        if (type == 'Delete') {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                    title: Text('Warning'),
                    content: Text('Are you sure you want to delete this item? You will not be able to find it later'),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel')),
                      TextButton(
                          onPressed: () {
                            _remove(trialId);
                            Navigator.of(context).pop();
                          },
                          child: Text('Delete'))
                    ],
                );
              });
        } else if (type == 'Save') {
          setState(() {
            _save(trialId);
          });
        } else if (type == 'Unsave') {
          setState(() {
            _unsave(trialId);
          });
        } else {
          // _fetchReport(trialId);
          if (io.isConnected() ?? true) {
            io.fetchReport(filename).then((value) {
              if (value == 'file is not found') {
                _showNotExist();
              } else {
                final csv = const CsvToListConverter().convert(value, eol: '\n');
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => CSVDataTable(data: csv)));
              }
            });
          } else {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Error'),
                  content: const Text(
                      'Connection error'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('OK')),
                  ],
                ));
          }
        }
      },
      child: Column(
        children: <Widget>[
          Icon(icon),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 2.0),
          ),
          Text(type),
        ],
      ),
    );
  }

  _remove(int trialId) {
    setState(() {
      savedList.removeWhere((element) => element.trialId == trialId);
      resultList.removeWhere((element) => element.trialId == trialId);
      _items.removeWhere((element) => element.trialId == trialId);
      _removeFromDB(trialId);
    });
  }

  _removeFromDB(int trialId) async{
    await widget.db.delete(
      'history',
      where: 'trialId = ?',
      whereArgs: [trialId],
    );
  }

  _save(int trialId) {
    for (var item in _items) {
      if (item.trialId == trialId) {
        item.saved = true;
        savedList.add(item);
        _changeToSavedInDB(trialId, true);
      }
    }
  }

  _changeToSavedInDB(int trialId, bool saved) async{
    if (saved) {
      await widget.db.rawUpdate(
          'UPDATE history SET saved = 1 WHERE trialId = ?',
          [trialId]
      );
    } else {
      await widget.db.rawUpdate(
          'UPDATE history SET saved = 0 WHERE trialId = ?',
          [trialId]
      );
    }
  }

  _unsave(int trialId) {
    setState(() {
      for (var item in _items) {
        if (item.trialId == trialId) {
          item.saved = false;
          savedList.removeWhere((e) => e.trialId == trialId);
          _changeToSavedInDB(trialId, false);
        }
      }
    });
  }


  void filterItems(String text) {
    resultList =
        _items.where((element) => element.fileName.contains(text)).toList();
    setState(() {});
  }

  sort(int type) {
    setState(() {
      switch (type) {
        case 0:
          resultList.sort((a, b) => a.trialTime.compareTo(b.trialTime));
          break;
        case 1:
          resultList.sort((b, a) => a.trialTime.compareTo(b.trialTime));
          break;
        case 2:
          resultList.sort((a, b) => a.trialId.compareTo(b.trialId));
          break;
        case 3:
          resultList.sort((b, a) => a.trialId.compareTo(b.trialId));
          break;
        default:
          return;
      }
    });
  }

  Future<List<HistoryItem>> _loadItems() async{
    List<Map<String, dynamic>> dataList = await widget.db.query('history');
    return dataList.map((data) => HistoryItem.fromMap(data)).toList();
  }

  Future<List<HistoryItem>> _loadSavedItems() async{
    List<Map<String, dynamic>> dataList = await widget.db.rawQuery(
      'SELECT * FROM history where saved = 1;'
    );
    return dataList.map((data) => HistoryItem.fromMap(data)).toList();
  }

  void _showNotExist() {
    showDialog(
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text(
              'File does not exist, please check the server if the report has been generated'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK')),
          ],
        ), context: context);
  }

}

