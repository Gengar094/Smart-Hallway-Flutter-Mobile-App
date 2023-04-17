import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:im_stepper/stepper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_hallway/main_page/info_container.dart';
import 'package:smart_hallway/util/ssh.dart';
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

  final _formKey = GlobalKey<FormState>();
  int _trialId = -1;
  final trialIdController = TextEditingController();
  bool trialIdValidate = false;
  bool fileNameValidate = false;
  String _fileName = '';
  final fileNameController = TextEditingController();
  String _comment = '';
  final commentController = TextEditingController();
  final DESIGNATED_PATH = 'Desktop/workspace';
  SSHConnection ssh = SSHConnection();


  bool numValidate = false;
  int _activeStep = 0;
  int _upperBound = 4;
  CountDownController controller = CountDownController();

  int min = 0;
  final minController = TextEditingController();
  final _minKey = GlobalKey<FormState>();
  int sec = 0;
  final secController = TextEditingController();
  final _secKey = GlobalKey<FormState>();

  bool _minInputError = false;
  bool _secInputError = false;

  bool _isConnected = false;

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
                      Icon(Icons.timer),
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
        return _createTimerForm();
      case 2:
        return _createTimerPage();
      case 3:
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

  Widget _createTimerForm() {
    return SingleChildScrollView(
        child: Column(
          children: [
            Padding(
                padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height / 15, 0, 0)
            ),
            Container(
                width: MediaQuery.of(context).size.width / 1.18,
                child: TextField(
                  controller: minController,
                  textAlign: TextAlign.left,
                  scrollPadding: EdgeInsets.only(bottom: 40),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Minutes',
                    errorText: numValidate ? minErrorText : null,
                  ),
                  onTap:() {
                    setState(() {
                      numValidate = true;
                    });
                  },
                  onChanged: (value) {
                    setState(() {
                      try {
                        min = int.parse(value);
                      } catch (e) {
                        print('should not happen');
                      }
                    });
                  },
                )),
            Padding(
                padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height / 50, 0, 0)
            ),
            Container(
                width: MediaQuery.of(context).size.width / 1.18,
                child: TextField(
                  controller: secController,
                  textAlign: TextAlign.left,
                  scrollPadding: EdgeInsets.only(bottom: 40),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Seconds',
                    errorText: numValidate ? secErrorText : null,
                  ),
                  onTap:() {
                    setState(() {
                      numValidate = true;
                    });
                  },
                  onChanged: (value) {
                    setState(() {
                      try {
                        sec = int.parse(value);
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
          ],
        ));
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
                'You are all set! You should be able to see the data in the history page!')
        ),
      ],
    );
  }


  Widget _createTimerPage() {
    int duration = min * 60 + sec;
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
              padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height / 15, 0, 0)
          ),
          Container(
            child: CircularCountDownTimer(
              width: MediaQuery.of(context).size.width / 3,
              height: MediaQuery.of(context).size.height / 4,
              duration: duration,
              fillColor: Colors.green.shade100,
              ringColor: Colors.green,
              controller: controller,
              onStart: () {
                ssh.start(_fileName, min, sec).then((value) {
                  ssh.moveTo(DESIGNATED_PATH).then((value) {
                    ssh.startRecording();
                  });
                });
              },
              onComplete: () {
                // send request through ssh
                // ssh.endRecording().then((value) {}
                // );
                setState(() {
                  _activeStep++;
                });
              },
            ),
          ),
          Text("Filming in progress..."),

        ],
      ),
    );
  }

  _createButtons(int activeStep) {
    switch (activeStep) {
      case 0:
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
                              _activeStep++;
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
      case 1:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
                onPressed: () {
                  setState(() {
                    _activeStep--;
                  });
                },
                child: Text('Back')),
            TextButton(
                onPressed: () {
                  setState(() {
                    print(minErrorText);
                    print(secErrorText);
                    if (minErrorText == null && secErrorText == null) {
                      _activeStep++;
                      min = int.parse(minController.value.text);
                      sec = int.parse(secController.value.text);
                    }
                  });
                },
                child: Text('Continue')),
          ],
        );
      case 2:
        return TextButton(
            onPressed: () {
              setState(() {
                print('cancel');
                _activeStep--;
              });
            },
            child: Text('Cancel'));
      case 3:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
                onPressed: () {
                  setState(() {
                    _activeStep = 0;
                    addToHistory();
                    reset();
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
                                    setState(() {
                                      start = false;
                                    });
                                  },
                                  child: const Text('OK')),
                            ],
                          ));
                    }
                  });
                },
                child: Text('Start over')),
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
      default:
        return Container();
    }
  }

  void reset() {
    _trialId = -1;
    _fileName = '';
    _comment = '';
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

    // bool res = await exist(int.parse(text));
    // if (res) {
    //   return 2;
    // }
    return -1;
  }

  int _fileNameError() {
    final text = fileNameController.value.text;

    if (text.isEmpty) {
      return 0;
    }

    // bool res = await exist(int.parse(text));
    // if (res) {
    //   return 2;
    // }
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

    // print('hhh');
    //
    //  exist(int.parse(text)).then((value) {
    //   print(value);
    //   print(value.isNotEmpty);
    //   if (value.isNotEmpty) {
    //     return 'trial Id has been used';
    //   }
    // });

  }

  String? get _fileNameErrorText {
    final text = fileNameController.value.text;

    if (text.isEmpty) {
      return 'Please provide the file name';
    }
  }

  String? get minErrorText {
    final text = minController.value.text;
    if (text.isEmpty) {
      return 'Cannot be empty';
    }
    try {
      int.parse(text);
    } catch (e) {
      return 'Please enter numbers';
    }
    int num = int.parse(text);
    if (num < 0) {
      return 'Please enter positive numbers or zero';
    }
  }

  String? get secErrorText {
    final text = secController.value.text;
    if (text.isEmpty) {
      return 'Cannot be empty';
    }
    try {
      int.parse(text);
    } catch (e) {
      return 'Please enter numbers';
    }
    int num = int.parse(text);
    if (num <= 0) {
      return 'Please enter positive numbers';
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
