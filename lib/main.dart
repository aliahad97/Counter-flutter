import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'Counter',
      // theme: ThemeData(
      //   primarySwatch: Colors.grey,
      // ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    _loadCounter();
    _assetsAudioPlayer.open(AssetsAudio(
        asset: "song1.mp3",
        folder: "assets/audios/",
    ));
  }

  AssetsAudioPlayer _assetsAudioPlayer = AssetsAudioPlayer();
  int _counter = 0;
  bool _isButtonDisabled= true;
  int _limit = 0;
  Future<void> _ackAlert(BuildContext context) {
    return showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Complete!'),
          content: const Text('The cap has been reached.'),
          actions: <Widget>[
            FlatButton(
              child: Text('continue'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  Future<int> _asyncInputDialog(BuildContext context) async {
    int limit = _limit;
    return showDialog<int>(
      context: context,
      barrierDismissible: false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Buzz every:'),
          content: new Row(
            children: <Widget>[
              new Expanded(
                  child: new TextField(
                autofocus: true,
                keyboardType: TextInputType.number,
                decoration: new InputDecoration(
                    labelText: 'Number ', hintText: 'eg. 99'),
                onChanged: (value) {
                  if(int.tryParse(value) != null){
                    limit = int.parse(value);
                  }
                },
              ))
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop(limit);
              },
            ),
          ],
        );
      },
    );
  }
  _updateLimit(BuildContext context) async {
    _isButtonDisabled = false;
    Vibration.vibrate(duration: 10);
    // Vibration.vibrate(pattern: [500, 1000, 500]);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int value = await _asyncInputDialog(context);
    if(value != _limit){
      _limit = value;
      await prefs.setInt('limit', _limit);
    }
    setState(() {
      _isButtonDisabled= true;
    });
  }
  _loadCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = (prefs.getInt('counter') ?? 0);
      _limit = (prefs.getInt('limit') ?? 99); 
    });
  }
  _incrementCounter(BuildContext context) async {
    _isButtonDisabled = false;
    Vibration.vibrate(duration: 10);
    // Vibration.vibrate(pattern: [500, 1000, 500]);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _counter = (prefs.getInt('counter') ?? 0) + 1;
    print('Pressed $_counter times.');
    if((_counter % _limit) == 0){
      Vibration.vibrate(pattern: [0,200,100,1000]);
      _assetsAudioPlayer.play();
      await _ackAlert(context);
    }
    setState(() {
      _isButtonDisabled= true;
    });
    await prefs.setInt('counter', _counter);
  }
  void _doNothing(){
    print('button unclickable');
  }
  _decrementCounter() async {
    Vibration.vibrate(duration: 10);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _counter = (prefs.getInt('counter') ?? 0) - 1;
    _counter = _counter < 0 ? 0 : _counter;
    print('Pressed $_counter times.');
    setState(() {
    });
    await prefs.setInt('counter', _counter);
  }
  _resetCounter() async {
    Vibration.vibrate(duration: 10);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _counter = 0;
    print('Pressed $_counter times.');
    await prefs.setInt('counter', _counter);
    setState(() {
    });
  }
  
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.height;
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.settings, size: 40, color: Colors.white),
          onPressed: (){
            _updateLimit(context);
          },
        ),
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        // title: Text(widget.title),
      ),
      // backgroundColor: Colors.black,
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$_counter',
              style: TextStyle(color: Colors.black , fontSize: width/3, ),
              
            ),
            Spacer(),
            Container(
              height: 3*width/4,
              width: 3*width/4,
              child: FloatingActionButton(
                onPressed: !_isButtonDisabled ? _doNothing : (){_incrementCounter(context);},
                tooltip: 'Increment',
                child: Icon(Icons.add, size: 3*width/4,),
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: width/3,
                    height: width/3,
                    padding: EdgeInsets.fromLTRB(50, 0, 0, 0),
                    child: FloatingActionButton(
                      onPressed: !_isButtonDisabled ? _doNothing : _resetCounter,
                      tooltip: 'reset',
                      child: Icon(Icons.refresh),
                    ),
                  ),
                  Spacer(),
                  Container(
                    width: width/3,
                    height: width/3,
                    padding: EdgeInsets.only(right: 50),
                    child: FloatingActionButton(
                      onPressed: !_isButtonDisabled ? _doNothing : _decrementCounter,
                      tooltip: 'decrement',
                      child: Icon(Icons.remove),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
