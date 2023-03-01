import 'package:flutter/material.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:smart_hallway/model/history_item.dart';
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
                    _createButton("Unsave", item.trialId),
                    _createButton("Report", item.trialId),
                    _createButton("Delete", item.trialId),
                  ],
                )
              ],
            );
          }),
    );
  }

  _createButton(String type, trialId) {
    IconData icon = type == 'Unsave'
        ? Icons.star
        : type == 'Report'
            ? Icons.my_library_books
            : Icons.delete_forever;

    return TextButton(
      onPressed: () {
        if (type == 'Delete') {
          _remove(trialId);
          widget.parentDelete(trialId);
        } else if (type == 'Unsave') {
          setState(() {
            _unsave(trialId);
            widget.parentUnsave(trialId);
          });
        } else {
          _fetchReport(trialId);
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

  void _fetchReport(trialId) {
    print("Reporst is downloaded and ready to be viewd");
  }
}
