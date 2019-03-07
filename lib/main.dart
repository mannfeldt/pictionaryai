//import 'package:flutfire/mlkit/ml_detail.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mlkit/mlkit.dart';
import 'dart:async';
import 'package:camera/camera.dart';
import 'dart:math';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  File _file;
  String _targetWord;
  int _score;

  List<VisionLabel> _currentLabels = <VisionLabel>[];

  FirebaseVisionLabelDetector detector = FirebaseVisionLabelDetector.instance;
//gallery eller camera får vara valbart, två olika game modes.
//sätt upp hårdkodadde alternativ. detta är en prototyp som kan bli bättre med cloud vision api

  List<String> people = [
    'Crowd',
    'Selfie',
    'Smile',
    'Hand',
    'Ear',
    'Nose',
    'Mouth',
    'Feet',
    'Eyelash',
  ];
  List<String> activities = [
    'Dancing',
    'Eating',
    'Surfing',
    'Fun',
    'Cool',
    'Fireworks',
    'Vacation',
    'Nightclub',
    'Sports',
    'Sleep',
    'Sitting'
  ];
  List<String> animals = ['Bird', 'Cat', 'Dog', 'Pet'];
  List<String> things = [
    'Car',
    'Piano',
    'Receipt',
    'Chair',
    'Shoe',
    'Building',
    'Food',
    'Sunglasses',
    'Hat',
    'Skyscraper',
    'Toy',
    'Road',
    'Television'
  ];
  List<String> plants = [
    'Flower',
    'Fruit',
    'Vegetable',
  ];
  List<String> places = [
    'Beach',
    'Lake',
    'Mountain',
    'Sky',
    'Forest',
    'Stadium',
    'Garden'
  ];
  @override
  initState() {
    super.initState();
    List<String> allWords = [
      people,
      activities,
      animals,
      places,
      plants,
      things
    ].expand((x) => x).toList();

    final _random = new Random();
    String targetWord = allWords[_random.nextInt(allWords.length)];
    setState(() {
      _targetWord = targetWord;
    });
  }

  int getScore(List<VisionLabel> labels, String targetWord) {
    int score = 0;
    for (VisionLabel label in labels) {
      if (label.label.toUpperCase() == targetWord.toUpperCase()) {
        score = confidenceToScore(label.confidence);
        return score;
      }
    }
    return score;
  }

  int confidenceToScore(double confidence) {
    int score = (confidence * 100).toInt();
    return score;
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Image Labeling Firebase'),
        ),
        body: _buildBody(_file, _targetWord),
        floatingActionButton: new FloatingActionButton(
          onPressed: () async {
            try {
              var file =
                  await ImagePicker.pickImage(source: ImageSource.gallery);
              setState(() {
                _file = file;
              });

              var currentLabels =
                  await detector.detectFromBinary(_file?.readAsBytesSync());
              int score = getScore(currentLabels, _targetWord);

              setState(() {
                _currentLabels = currentLabels;
                _score = score;
              });
            } catch (e) {
              print(e.toString());
            }
          },
          child: new Icon(Icons.select_all),
        ),
      ),
    );
  }

  //Build body
  Widget _buildBody(File _file, String _targetWord) {
    return new Container(
      child: new Column(
        children: <Widget>[
          Text(_targetWord),
          displaySelectedFile(_file),
          _buildScore(_score),
          _buildList(_currentLabels)
        ],
      ),
    );
  }

  Widget _buildScore(int score) {
    return new Text('SCORE:' + score.toString(), textAlign: TextAlign.center);
  }

  Widget _buildList(List<VisionLabel> labels) {
    if (labels == null || labels.length == 0) {
      return new Text('Empty', textAlign: TextAlign.center);
    }
    return new Expanded(
      child: new Container(
        child: new ListView.builder(
            padding: const EdgeInsets.all(1.0),
            itemCount: labels.length,
            itemBuilder: (context, i) {
              return _buildRow(
                  labels[i].label, confidenceToScore(labels[i].confidence).toString());
            }),
      ),
    );
  }

  Widget displaySelectedFile(File file) {
    return new SizedBox(
      // height: 200.0,
      width: 150.0,
      child: file == null
          ? new Text('Sorry nothing selected!!')
          : new Image.file(file),
    );
  }

  //Display labels
  Widget _buildRow(String label, String confidence) {
    return new ListTile(
      title: new Text(
        "$label: $confidence%",
      ),
      dense: true,
    );
  }
}
