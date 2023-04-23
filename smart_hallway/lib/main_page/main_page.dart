import 'dart:io';

import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:im_stepper/stepper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_hallway/main_page/info_container.dart';
import 'package:smart_hallway/util/client.dart';
import '../setting_page/setting.dart';
import '../history_page/history.dart';
import 'package:sqflite/sqflite.dart';

class MainPage extends StatefulWidget {
  final Database db;
  final SharedPreferences prefs;
  const MainPage({super.key, required this.db, required this.prefs});


  @override
  _MainPageState createState() => _MainPageState();
}


class _MainPageState extends State<MainPage> {

  bool start = false;

  int _trialId = -1;
  final trialIdController = TextEditingController();
  bool trialIdValidate = false;
  bool fileNameValidate = false;
  String _fileName = '';
  final fileNameController = TextEditingController();
  String _comment = '';
  final commentController = TextEditingController();
  Client io = Client();

  bool numValidate = false;
  int _activeStep = 0;
  int _upperBound = 4;

  String msg = '';
  bool capture = false;
  bool end = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Smart Hallway'),
        backgroundColor: Colors.green,
      ),
      body: start
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  IconStepper(
                    icons: const [
                      Icon(Icons.contact_page),
                      // Icon(Icons.timer),
                      Icon(Icons.wifi_protected_setup_sharp),
                      Icon(Icons.thumb_up_outlined),
                    ],
                    activeStep: _activeStep,
                    enableStepTapping: false,
                    enableNextPreviousButtons: false,
                  ),
                  _createStepPage(_activeStep),
                  _createButtons(_activeStep),
                ],
              ),
            )
          : InfoContainer(),
      bottomNavigationBar: BottomAppBar(
        color: Colors.green,
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
                icon: const Icon(Icons.history_rounded),
                color: Colors.white,
                onPressed: () => _onPressHistory()),
            SizedBox(),
            IconButton(
                icon: const Icon(Icons.settings),
                color: Colors.white,
                onPressed: () => _onPressSetting()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (widget.prefs.getBool('key-connected') == false) {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Connection Error'),
                  content:
                  const Text('Please connect to the server before starting the filming'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('OK')),
                  ],
                ));
          } else {
            _startRecording();
          }
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  _onPressHistory() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => HistoryPage(db: widget.db)));
  }

  _onPressSetting() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => SettingPage(prefs: widget.prefs)));
  }

  _startRecording() {
    setState(() {
      start = true;
    });
  }

  absortRecording() {
    setState(() {
      start = false;
      _activeStep = 0;
      reset();
    });
  }

  Widget _createStepPage(int activeStep) {
    switch (activeStep) {
      case 0:
        return _createInputForm();
      case 1:
        return _createFilmingPage();
      case 2:
        return _createAllSetPage();
      default:
        return Container();
    }
  }

  Widget _createInputForm() {
    return Form(
            child:SingleChildScrollView (
              child: Column(
              children: [
                Padding(
                    padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height / 15, 0, 0)
                ),
                Container(
                    width: MediaQuery.of(context).size.width / 1.18,
                    child: TextField(
                      controller: trialIdController,
                      scrollPadding: EdgeInsets.only(bottom: 40),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Trial Id',
                        errorText: trialIdValidate ? _trialIdErrorText : null,
                      ),
                      onTap:() {
                        setState(() {
                          trialIdValidate = true;
                        });
                      },
                      onChanged: (value) {
                        setState(() {
                          try {
                            _trialId = int.parse(value);
                          } catch (e) {
                            print('should not happen');
                          }
                        });
                      },
                    )
                ),
                Padding(
                    padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height / 50, 0, 0)
                ),
                Container(
                    width: MediaQuery.of(context).size.width / 1.18,
                    child: TextFormField(
                      controller: fileNameController,
                      scrollPadding: EdgeInsets.only(bottom: 40),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'File Name',
                        errorText: fileNameValidate ? _fileNameErrorText : null,
                      ),
                      onTap:() {
                        setState(() {
                          fileNameValidate = true;
                        });
                      },
                      onChanged: (value) {
                        _fileName = value;
                      },
                    )
                ),
                Padding(
                    padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height / 50, 0, 0)
                ),
                Container(
                    width: MediaQuery.of(context).size.width / 1.18,
                    child: TextFormField(
                      controller: commentController,
                      scrollPadding: EdgeInsets.only(bottom: 40),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Comment (Optional)',
                      ),
                      onChanged: (value) {
                        _comment = value;
                      },
                    )
                ),
                Padding(
                    padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height / 50, 0, 0)
                ),
              ],
            ),
    ));
  }

  Widget _createFilmingPage() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
              padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height / 5, 0, 0)
          ),
          getCurrentPage(),
          Padding(
              padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height / 10, 0, 0)
          ),
        ],
      ),
    );
  }

  Widget getCurrentPage() {
    if (!capture && !end) {
      return Text("Filming has not started ... ");
    } else if (capture && !end) {
      return Text("Filming is in progress ... ");
    } else if (capture && end) {
      return Text("Filming is waiting for the end ... ");
    }

    return Text("Something wrong ... ");
  }

  Widget _createAllSetPage() {
    return Column(
      children: [
        Padding(
            padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height / 50, 0, 0)
        ),
        Image.asset(
          'assets/image/682-6827427_thumbs-down-emoji-png.png',
          width: 200,
          height: 200,
        ),
        Container(
            margin: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            child: const Text(
                'You are all set! You should be able to see the data in the history page if you press the "Finish" button. If you press the "Cancel" button, no record will be added, but the video is stored in the server!')
        ),
      ],
    );
  }


  _createButtons(int activeStep) {
    switch (activeStep) {
      case 0:
        return firstPageButton();
      case 1:
        return secondPageButton();
      case 2:
        return thirdPageButton();
      default:
        return Container();
    }
  }

  Widget firstPageButton() {
    return Container(
        width: 350,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
                onPressed: () {
                  setState(() {
                    start = false;
                  });
                },
                child: Text('Cancel')),
            TextButton(
                onPressed: () {
                  setState(() {
                    exist(int.parse(trialIdController.value.text)).then((value) {
                      if (value.isEmpty) {
                        if (_trialIdError() == -1 && _fileNameError() == -1) {
                          print("set the file name");
                          io.setFileName(_fileName).then((v) {
                            _activeStep++;
                          });
                        }
                      } else {
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Error'),
                              content: const Text(
                                  'The trial Id has been used'),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('OK')),
                              ],
                            ));
                      }
                    });
                  });
                },
                child: Text('Continue')),
          ],
        ));
  }

  Widget secondPageButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        TextButton(
          onPressed: () {
            setState(() {
              print('cancel');
              _activeStep--;
             });
            },
          child: Text('Cancel')),
        capture ?
        TextButton(
            onPressed: () {
              if (end) {
                setState(() {
                  io.end().then((value) {
                    _activeStep++;
                  });
                });
              }
            },
            child: end ? Text('end') : Text('waiting')
        ) :
        TextButton(
            onPressed: () {
              setState(() {
                Socket? socket = io.getSocket();
                socket?.writeln("capture");
                setState(() {
                  capture = true;
                });
                io.stream.listen((event) {
                  String data = String.fromCharCodes(event);
                  print(data);
                  if (data == 'filming is waiting for ending ...') {
                    setState(() {
                      end = true;
                    });
                  }
                  if (data == 'a server error has occurred, please take a look on the server') {
                    showErrorPage(data);
                    // todo
                    io.disconnect().then((value) => {
                      widget.prefs.setBool('key-connected', false)
                    });
                  }
                  if (data == 'a filming error has occurred ... ') {
                    showErrorPage(data);
                  }
                }).onError((Object e) {
                  handleError(e);
                }
                );
              });
            },
            child: Text('Start')
          )
        ]
    );
  }

  void showErrorPage(String msg) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(
              msg),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _activeStep = 0;
                    start = false;
                    reset();
                  });
                },
                child: const Text('OK')),
          ],
        ));
  }

  void handleError(Object e) {
    print((e as Exception).toString());
  }

  Widget thirdPageButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        TextButton(
            onPressed: () {
              setState(() {
                _activeStep = 0;
                reset();
                start = false;
              });
            },
            child: Text('Cancel')),
        TextButton(
            onPressed: () {
              setState(() {
                _activeStep = 0;
                start = false;
                addToHistory();
                reset();
              });
            },
            child: Text('Finish')),
      ],
    );
  }

  void reset() {
    _trialId = -1;
    _fileName = '';
    _comment = '';
    fileNameController.text = '';
    trialIdController.text = '';
    commentController.text = '';
    fileNameValidate = false;
    trialIdValidate = false;
    end = false;
    capture = false;
  }

  void addToHistory() async{
    WidgetsFlutterBinding.ensureInitialized();
    await widget.db.insert(
        'history',
        {
          'trialId': _trialId,
          'comment': _comment,
          'fileName': _fileName,
          'trialTime': DateTime.now().toIso8601String(),
          'saved': 0
        }
        );
  }

  int _trialIdError() {
    final text = trialIdController.value.text;

    if (text.isEmpty) {
      return 0;
    }

    try {
      int.parse(text);
    } catch (e) {
      return 1;
    }

    return -1;
  }

  int _fileNameError() {
    final text = fileNameController.value.text;

    if (text.isEmpty) {
      return 0;
    }

    return -1;
  }

  String? get _trialIdErrorText {
    final text = trialIdController.value.text;

    if (text.isEmpty) {
      return 'Cannot be empty';
    }
    print(text);
    try {
      int.parse(text);
    } catch (e) {
      return 'Please enter numbers';
    }

  }

  String? get _fileNameErrorText {
    final text = fileNameController.value.text;

    if (text.isEmpty) {
      return 'Please provide the file name';
    }
  }



  Future<List<Map<String, Object?>>> exist(int id) async{
    return await widget.db.query(
      'history',
      where: 'trialId = ?',
      whereArgs: [id]
    );
  }
}
