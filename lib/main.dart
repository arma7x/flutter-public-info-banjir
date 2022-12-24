import 'package:flutter/material.dart';

import 'dart:core';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as DOM;

void main() {
  runApp(const MyApp());
}

Future<Map<String, dynamic>> Railfall(String state) async {
  try {
    final response = await http.get(Uri.parse("https://api.codetabs.com/v1/proxy?quest=http://publicinfobanjir.water.gov.my/wp-content/themes/shapely/agency/searchresultrainfall.php?state=${state}&district=ALL&station=ALL&language=1&loginStatus=0"));
    if (response.statusCode == 200) {
      final DOM.Document document = parse(response.body);
      List<DOM.Element> tables = document.getElementsByTagName("table");
      List<DOM.Element> theads = tables[0].getElementsByTagName('thead');
      List<String> textHeaders = [];
      List<String> dailyRainfallHeaders = [];
      for (var i = 0; i < theads[0].children.length; i++) {
        if (i == 1) {
          for (var j = 0; j < theads[0].children[i].children.length; j++) {
            textHeaders.add(theads[0].children[i].children[j].text.trim().replaceAll(' ', '_'));
          }
        } else if (i == 2) {
          for (var j = 0; j < theads[0].children[i].children.length; j++) {
            dailyRainfallHeaders.add(theads[0].children[i].children[j].text.trim().replaceAll(' ', '_'));
          }
        }
      }
      Map<String, dynamic> result = <String, dynamic>{};
      List<Map<String, dynamic>> rowsData = [];
      List<DOM.Element> tbodys = tables[0].getElementsByTagName('tbody');
      for (var i = 0; i < tbodys[0].children.length; i++) {
        if (tbodys[0].children[i].text.trim() != "") {
          Map<String, dynamic> data = <String, dynamic>{};
          List<String> daily = [];
          int headerIndex = 0;
          for (var j = 0; j < tbodys[0].children[i].children.length; j++) {
            if (j >= 5 && j <= 10) {
              daily.add(tbodys[0].children[i].children[j].text.trim());
              if (j == 10)
                headerIndex++;
            } else {
              data[textHeaders[headerIndex]] = tbodys[0].children[i].children[j].text.trim();
              headerIndex++;
            }
          }
          data[textHeaders[5]] = daily;
          rowsData.add(data);
        }
      }
      result["textHeaders"] = textHeaders;
      result["dailyRainfallHeaders"] = dailyRainfallHeaders;
      result["data"] = rowsData;
      return Future<Map<String, dynamic>>.value(result);
    } else {
      throw('Unknown error');
    }
  } on Exception catch (e) {
    rethrow;
  }
}

Future<Map<String, dynamic>> RiverLevel(String state) async {
  try {
    final response = await http.get(Uri.parse("https://api.codetabs.com/v1/proxy?quest=http://publicinfobanjir.water.gov.my/aras-air/data-paras-air/aras-air-data/?state=${state}&district=ALL&station=ALL&lang=en"));
    if (response.statusCode == 200) {
      final DOM.Document document = parse(response.body);
      List<DOM.Element> tables = document.getElementsByTagName("table");
      List<DOM.Element> theads = tables[0].getElementsByTagName('thead');
      List<String> textHeaders = [];
      List<String> thresholdHeaders = [];
      for (var i = 0; i < theads[0].children.length; i++) {
        if (i == 1) {
          for (var j = 0; j < theads[0].children[i].children.length; j++) {
            textHeaders.add(theads[0].children[i].children[j].text.trim().replaceAll(' ', '_'));
          }
        } else if (i == 2) {
          for (var j = 0; j < theads[0].children[i].children.length; j++) {
            thresholdHeaders.add(theads[0].children[i].children[j].text.trim().replaceAll(' ', '_'));
          }
        }
      }
      Map<String, dynamic> result = <String, dynamic>{};
      List<Map<String, dynamic>> rowsData = [];
      List<DOM.Element> tbodys = tables[0].getElementsByTagName('tbody');
      for (var i = 0; i < tbodys[0].children.length; i++) {
        if (tbodys[0].children[i].text.trim() != "") {
          Map<String, dynamic> data = <String, dynamic>{};
          List<String> thresholds = [];
          for (var j = 0; j < tbodys[0].children[i].children.length; j++) {
            if (j <= 7) {
              data[textHeaders[j]] = tbodys[0].children[i].children[j].text.trim();
            } else {
              thresholds.add(tbodys[0].children[i].children[j].text.trim());
            }
          }
          data[textHeaders[8]] = thresholds;
          rowsData.add(data);
        }
      }
      result["textHeaders"] = textHeaders;
      result["thresholdHeaders"] = thresholdHeaders;
      result["data"] = rowsData;
      return Future<Map<String, dynamic>>.value(result);
    } else {
      throw('Unknown error');
    }
  } on Exception catch (e) {
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() async {
    try {
      RiverLevel("KEL");
      //final Map<String, dynamic> data = await Railfall("KEL");
      //print(data);
    } on Exception catch (e) {
      print('Unknown exception: $e');
    }
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
