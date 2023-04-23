import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:smart_hallway/util/client.dart';

class CSVDataTable extends StatelessWidget {
  final List<List<dynamic>> data;


  CSVDataTable({required this.data});

  @override
  Widget build(BuildContext context) {
    final columns = data[0]
        .map((column) => DataColumn(label: Text(column.toString())))
        .toList();

    final rows = data
        .sublist(1)
        .map((row) => DataRow(
      cells: row
          .map((cell) => DataCell(Text(cell.toString())))
          .toList(),
    ))
        .where((row) => row.cells.length == columns.length)
        .toList();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text('Smart Hallway'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(columns: columns, rows: rows),
        ),
      )
    );
  }
}