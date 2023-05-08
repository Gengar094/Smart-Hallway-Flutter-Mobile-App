import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:smart_hallway/history_page/report.dart';
import 'package:smart_hallway/model/history_item.dart';
import 'package:smart_hallway/util/client.dart';
import '../history_page/history.dart';

class savedPage extends StatefulWidget {
  final List<HistoryItem> savedList;
  final List<HistoryItem> resultList;
  final Function parentDelete;
  final Function parentUnsave;
  const savedPage(
      {super.key,
      required this.savedList,
      required this.resultList,
      required this.parentDelete,
      required this.parentUnsave});

  @override
  State<savedPage> createState() => _savedPageState();
}

class _savedPageState extends State<savedPage> {
  Client io = Client();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Smart Hallway'),
        backgroundColor: Colors.green,
      ),
      body: ListView.separated(
          itemCount: widget.savedList.length,
          separatorBuilder: (_, index) {
            return Divider(color: Colors.grey.shade400);
          },
          itemBuilder: (_, index) {
            final item = widget.savedList[index];
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
                      child:
                          Text("Recorded Time: " + item.trialTime.toString())),
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
                    _createButton("Unsave", item.trialId, item.fileName),
                    _createButton("Report", item.trialId, item.fileName),
                    _createButton("Delete", item.trialId, item.fileName),
                  ],
                )
              ],
            );
          }),
    );
  }

  _createButton(String type, trialId, String filename) {
    IconData icon = type == 'Unsave'
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
                          widget.parentDelete(trialId);
                          Navigator.of(context).pop();
                        },
                        child: Text('Delete'))
                  ],
                );
              });
        } else if (type == 'Unsave') {
          setState(() {
            _unsave(trialId);
            widget.parentUnsave(trialId);
          });
        } else {
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

  void _remove(trialId) {
    setState(() {
      widget.resultList.removeWhere((element) => element.trialId == trialId);
      widget.savedList.removeWhere((element) => element.trialId == trialId);
    });
  }

  void _unsave(trialId) {
    for (var element in widget.savedList) {
      if (element.trialId == trialId) {
        element.saved = false;
      }
    }
    widget.savedList.removeWhere((element) => element.trialId == trialId);
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
