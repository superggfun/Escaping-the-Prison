import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'sqllite.dart';
import 'package:just_audio/just_audio.dart';
// ignore: depend_on_referenced_packages
import 'package:audio_session/audio_session.dart';

class MyFlutterApp extends StatefulWidget {
  const MyFlutterApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MyFlutterState();
  }
}

class MyFlutterState extends State<MyFlutterApp> {
  //WRITE VARIABLES AND EVENT HANDLERS HERE
  late int index;
  int yes = 0;
  int no = 0;
  var color = Colors.red[500];
  String left = "Start";
  String right = "";
  String description = "You are in a Prison, you want to escape";
  //String question = "Start";
  String image = "images/prison.png";
  final _player = AudioPlayer();
  late Future<Database> database;

  @override
  void initState() {
    _init();
    super.initState();
    database = initializeDB();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  Future<void> _init() async {
    // Inform the operating system of our app's audio attributes etc.
    // We pick a reasonable default for an app that plays speech.
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    // Listen to errors during playback.
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });
    // Try to load audio from a source and catch any errors.
    try {
      await _player.setAudioSource(AudioSource.uri(Uri.parse(
          "https://cdn.jsdelivr.net/gh/superggfun/Escaping-the-Prison/assets/music.mp3")));
    } catch (e) {
      print("Error loading audio source: $e");
    }
  }

  Future<Map> getValue(int index) async {
    final db = await database;
    List<Map> query = await db.rawQuery("SELECT * From Data WHERE ROWS=$index");
    return query[0];
  }

  void clickYes() async {
    var data = await getValue(yes);

    setState(() {
      index = data['ROWS'];
      yes = data['LEFTID'];
      no = data['RIGHTID'];

      if (yes != no) {
        left = data['Left'];
        right = data['Right'];
      } else {
        left = data['Left'];
        right = "";
      }

      description = data['DESCRIPTION'];
      image = data['image'];
    });
  }

  void clickNo() async {
    var data = await getValue(no);
    setState(() {
      index = data['ROWS'];
      yes = data['LEFTID'];
      no = data['RIGHTID'];
      if (yes != no) {
        left = data['Left'];
        right = data['Right'];
      } else {
        left = data['Left'];
        right = "";
      }

      description = data['DESCRIPTION'];
      image = data['image'];
    });
  }

  bool check = true;
  final player = AudioPlayer();
  @override
  Widget build(BuildContext context) {
    Widget titleSection = Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () async {
          setState(() {
            if (check) {
              _player.play();
              color = Colors.green[500];
            } else {
              _player.pause();
              color = Colors.red[500];
            }
            check = !check;
          });
        },
        child: Icon(
          Icons.music_note,
          color: color,
        ),
      ),
    );

    // Color color = Theme.of(context).primaryColor;

    Widget textSection1 = Padding(
      padding: const EdgeInsets.all(0),
      child: _buildTextColumn(Colors.black, description),
    );

    Widget buttonSection = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _chooseButton(Colors.green, Icons.crop_square, left, () {
          clickYes();
        }),
        _chooseButton(Colors.red, Icons.radio_button_off, right, () {
          clickNo();
        }),
      ],
    );

    List<Widget> myBody() {
      List<Widget> list = [];
      list.add(
        Image.asset(
          image,
          width: 600,
          height: 300,
          fit: BoxFit.fitHeight,
        ),
      );
      list.add(titleSection);
      if (description != "-") {
        list.add(textSection1);
      }

      if (yes == no) {
        list.add(_chooseButton(Colors.green, Icons.done_all, left, () {
          clickYes();
        }));
      } else {
        list.add(buttonSection);
      }

      return list;
    }

    return MaterialApp(
      title: 'Escaping the Prison',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Escaping the Prison'),
        ),
        body: ListView(children: myBody()),
      ),
    );
  }

  TextButton _chooseButton(
      Color color, IconData icon, String label, Function() f) {
    return TextButton(
      onPressed: f,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          Container(
            margin: const EdgeInsets.only(top: 8),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Text _buildTextColumn(Color color, String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 30,
        color: color,
      ),
      textAlign: TextAlign.center,
      softWrap: true,
    );
  }
}
