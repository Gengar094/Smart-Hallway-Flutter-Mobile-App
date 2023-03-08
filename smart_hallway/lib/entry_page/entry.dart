import 'package:flutter/material.dart';
import '../main_page/main_page.dart';

class Entry extends StatelessWidget {
  const Entry({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Smart Hallway"),
        backgroundColor: Colors.green,
      ),
      body: Center(
          heightFactor: 1,
          child: SingleChildScrollView(
            child: Column(children: [
              Container(
                  width: 350,
                  margin: const EdgeInsets.fromLTRB(0, 50, 0, 20),
                  child: const TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Server IP address',
                    ),
                    autofocus: true,
                  )),
              Container(
                  width: 350,
                  margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                  child: const TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Server port number',
                    ),
                    autofocus: true,
                  )),
              SizedBox(
                width: 90,
                child: TextButton(
                  onPressed: () {
                    // try to connect the server
                    // Navigator.push(context,
                    //     MaterialPageRoute(builder: (context) => MainPage()));
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'Connect',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ]),
          )),
    );
  }
}
