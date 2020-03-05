import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import 'package:speech_recognition/speech_recognition.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.greenAccent,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GoogleTranslator translator = GoogleTranslator();
  TextEditingController _controller = TextEditingController();
  String out = "";
  bool isPlaying = false;
  // FlutterTts _flutterTts;
  SpeechRecognition _speechRecognition;
  bool isAvailable = false;
  bool isListening = false;
  String translateFrom = "en";
  String translateTo = "yo";
  String translatedText = " ";
  static List<String> lanaguages = [
    'English',
    'Yoruba',
    'Igbo',
    'French',
    'Hausa'
  ];
  List<Widget> translation = [];
  String locale = "en_NG";
  String output = " ";
  FlutterTts flutterTts = FlutterTts();
  String _value = lanaguages[0];
  String translatedValue = "Yoruba";

  @override
  void initState() {
    super.initState();
    initializeSpeech();
    initializeTts();
  }

  initializeSpeech() {
    _speechRecognition = SpeechRecognition();
    _speechRecognition.setAvailabilityHandler(
        (bool result) => setState(() => isAvailable = result));
    _speechRecognition
        .setRecognitionStartedHandler(() => setState(() => isListening = true));
    _speechRecognition.setRecognitionResultHandler(
        (String speech) => setState(() => _controller.text = speech));
    _speechRecognition.setRecognitionCompleteHandler(
        () => setState(() => isListening = false));
    _speechRecognition
        .activate()
        .then((result) => setState(() => isAvailable = result));
  }

  setTtsLanguage() async {
    await flutterTts.setLanguage(localeEncoding());
  }

  initializeTts() {
    setTtsLanguage();
    flutterTts.setStartHandler(() {
      setState(() {
        isPlaying = true;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        isPlaying = false;
      });
    });
  }

  Future _speak(String text) async {
    setTtsLanguage();
    if (text != null && text.isNotEmpty) {
      var result = await flutterTts.speak(translatedText);
      if (result == 1) setState(() => isPlaying = true);
    }
  }

  trans(String text) {
    if (text != null && text.isNotEmpty) {
      translator
          .translate(text,
              from: translateFrom, to: languageCode(translatedValue))
          .then((output) {
        setState(() {
          translatedText = output.toString();
        });
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Voice translator'),
          elevation: 0.0,
          centerTitle: true,
        ),
        body: ListView(children: [
          Container(
              padding: EdgeInsets.all(20.0),
              child: Material(
                color: Colors.greenAccent,
                elevation: 10,
                borderRadius: BorderRadius.circular(10.0),
                child: Column(children: [
                  Material(
                    // color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(10.0),
                    child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(10.0)),
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        minLines: 5,
                        onChanged: ((String inputText) => setState(() {
                              out = inputText;
                            }))),
                  ),
                  Row(children: [
                    Expanded(
                        child: DropdownButton<String>(
                      value: _value,
                      items: lanaguages.map((String dropdownStringItem) {
                        return DropdownMenuItem<String>(
                          value: dropdownStringItem,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              dropdownStringItem,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String newValue) {
                        setState(() {
                          _value = newValue;
                        });
                      },
                    )),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: FloatingActionButton(
                        // borderRadius: BorderRadius.circular(10.0),
                        // elevation: 10,
                        child: Icon(
                          Icons.compare_arrows,
                          size: 35.0,
                        ),
                        onPressed: (() {
                          setState(() {
                            out = _controller.text;

                            trans(out);
                          });
                        }),
                      ),
                    ),
                    Expanded(
                      child: DropdownButton<String>(
                        value: translatedValue,
                        items: lanaguages.map((String dropdownStringItem) {
                          return DropdownMenuItem<String>(
                            value: dropdownStringItem,
                            child: Text(
                              dropdownStringItem,
                            ),
                          );
                        }).toList(),
                        onChanged: (String newValue) {
                          setState(() {
                            translatedValue = newValue;
                          });
                        },
                      ),
                    ),
                  ])
                ]),
              )),
          GestureDetector(child: Text(out)),
          translatedText == " " ? Container() : translationOutput(),
          SizedBox(height: 50.0),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              FloatingActionButton(
                  elevation: 20.0,
                  child: Icon(Icons.mic),
                  onPressed: () {
                    if (isAvailable && !isListening) {
                      _speechRecognition.listen(locale: localeEncoding());
                      setTtsLanguage();

                      _speak(translatedText);
                    }
                  }),
              FloatingActionButton(
                  child: Icon(Icons.speaker_phone),
                  onPressed: () {
                    setState(() {
                      out = _controller.text;

                      trans(out);
                      setTtsLanguage();
                      _speak(translatedText);
                    });
                  }),
            ]),
          ),
        ]));
  }

  Widget translationOutput() {
    return Material(
      elevation: 10.0,
      color: Colors.grey[300],
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(children: [
          Align(
              alignment: Alignment.topLeft,
              child: Text('$out -> $_value',
                  style: TextStyle(color: Colors.black, fontSize: 15.0))),
          SizedBox(
            height: 10.0,
          ),
          Align(
              alignment: Alignment.bottomRight,
              child: Text('$translatedText -> $translatedValue',
                  style: TextStyle(color: Colors.blueAccent, fontSize: 15.0))),
        ]),
      ),
    );
  }

  String localeEncoding() {
    setState(() {
      if (_value == "English") {
        return "en_NG";
      }
      if (_value == "Yoruba") {
        return "yo_NG";
      }
      if (_value == "Igbo") {
        return "ig_NG";
      }
      if (_value == "French") {
        return "fr_fr";
      }
      if (_value == "Hausa") {
        return "ha_NG";
      }
      return "en_NG";
    });
    return "en_NG";
  }

  String languageCode(String selectedValue) {
    if (selectedValue == "English") {
      return "en";
    }
    if (selectedValue == "Yoruba") {
      return "yo";
    }
    if (selectedValue == "Igbo") {
      return "ig";
    }
    if (selectedValue == "French") {
      return "fr";
    }
    if (selectedValue == "Hausa") {
      return "ha";
    }
    return "en";
  }
}
