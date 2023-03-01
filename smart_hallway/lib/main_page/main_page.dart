import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:im_stepper/stepper.dart';
import 'package:smart_hallway/main_page/info_container.dart';
import 'package:smart_hallway/util/util.dart';
import '../setting_page/setting.dart';
import '../history_page/history.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool start = false;
  int _trialId = -1;
  String _fileName = '';
  String _comment = '';

  int _activeStep = 0;
  int _upperBound = 4;

  final minController = TextEditingController();
  final _minKey = GlobalKey<FormState>();
  final secController = TextEditingController();
  final _secKey = GlobalKey<FormState>();

  int min = 0;
  int sec = 0;

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
        .push(MaterialPageRoute(builder: (context) => HistoryPage()));
  }

  _onPressSetting() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => SettingPage()));
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
    return Center(
      child: Column(
        children: [
          Container(
              width: 350,
              margin: const EdgeInsets.fromLTRB(0, 50, 0, 20),
              child: const TextField(
                scrollPadding: EdgeInsets.only(bottom: 40),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Trial Id',
                ),
              )),
          Container(
              width: 350,
              margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
              child: const TextField(
                scrollPadding: EdgeInsets.only(bottom: 40),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'File Name (Optional)',
                ),
              )),
          Container(
              width: 350,
              margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
              child: const TextField(
                maxLines: null,
                scrollPadding: EdgeInsets.only(bottom: 40),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Comment (Optional)',
                ),
              )),
        ],
      ),
    );
  }

  Widget _createTimerForm() {
    return Center(
        heightFactor: 5,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              width: 50,
              height: 30,
              child: TextFormField(
                controller: minController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _minInputError ? Colors.red : Colors.grey,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty || !isNumeric(value)) {
                    return 'Please enter a valid min number';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _minInputError = !_minKey.currentState!.validate();
                  });
                },
              ),
            ),
            Text('Min(s)'),
            SizedBox(
              width: 50,
              height: 30,
              child: TextField(
                controller: secController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Text('Sec(s)'),
          ],
        ));
  }

  _createButtons(int activeStep) {
    print(activeStep);
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
        return _empty();
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

  Widget _createAllSetPage() {
    return Container(
        margin: const EdgeInsets.fromLTRB(0, 150, 0, 20),
        child: const Text(
            'You are all set! You should be able to see the data in the history page!'));
  }

  Widget _empty() {
    return Container();
  }

  Widget _createTimerPage() {
    int duration = min * 60 + sec;
    return Container(
      child: CircularCountDownTimer(
        width: MediaQuery.of(context).size.width / 3,
        height: MediaQuery.of(context).size.height / 3,
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
    );
  }
}
