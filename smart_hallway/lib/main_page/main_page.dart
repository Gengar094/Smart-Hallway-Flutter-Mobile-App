import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:im_stepper/stepper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_hallway/main.dart';
import 'package:smart_hallway/main_page/info_container.dart';
import 'package:smart_hallway/util/util.dart';
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
  String _fileName = '';
  final fileNameController = TextEditingController();
  String _comment = '';
  final commentController = TextEditingController();

  int _activeStep = 0;
  int _upperBound = 4;

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
    print(_activeStep);
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
        onPressed: () => _startRecording(),
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

  Widget _createStepPage(int activeStep) {
    print(activeStep);
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
                    child: TextFormField(
                      controller: trialIdController,
                      scrollPadding: EdgeInsets.only(bottom: 40),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Trial Id',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the Trial Id';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _trialId = int.parse(value);
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
                        labelText: 'File Name (Optional)',
                      ),
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
                  ),
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
                  ),
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

    Container(
        margin: const EdgeInsets.fromLTRB(20, 150, 20, 20),
        child: const Text(
            'You are all set! You should be able to see the data in the history page!'));
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
              onStart: () {
                print('Countdown Started');
              },
              onComplete: () {
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
                        _activeStep++;
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
                    _activeStep++;
                    min = int.parse(minController.text);
                    sec = int.parse(secController.text);
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
        ;
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
}
