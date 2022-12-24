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
    final response = await http.get(Uri.parse("http://publicinfobanjir.water.gov.my/wp-content/themes/shapely/agency/searchresultrainfall.php?state=${state}&district=ALL&station=ALL&language=1&loginStatus=0"));
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
    final response = await http.get(Uri.parse("http://publicinfobanjir.water.gov.my/aras-air/data-paras-air/aras-air-data/?state=${state}&district=ALL&station=ALL&lang=en"));
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
      title: 'Public Info Banjir',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Public Info Banjir'),
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

  final List<Map<String, String>> STATE = [
    <String, String>{ "value": "PLS", "name": "Perlis", "flag": "https://upload.wikimedia.org/wikipedia/commons/thumb/a/aa/Flag_of_Perlis.svg/100px-Flag_of_Perlis.svg.png" },
    <String, String>{ "value": "KDH", "name": "Kedah", "flag": "https://upload.wikimedia.org/wikipedia/commons/thumb/c/cc/Flag_of_Kedah.svg/100px-Flag_of_Kedah.svg.png" },
    <String, String>{ "value": "PNG", "name": "Pulau Pinang", "flag": "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d4/Flag_of_Penang_%28Malaysia%29.svg/100px-Flag_of_Penang_%28Malaysia%29.svg.png" },
    <String, String>{ "value": "PRK", "name": "Perak", "flag": "https://upload.wikimedia.org/wikipedia/commons/thumb/8/87/Flag_of_Perak.svg/100px-Flag_of_Perak.svg.png" },
    <String, String>{ "value": "SEL", "name": "Selangor", "flag": "https://upload.wikimedia.org/wikipedia/commons/thumb/0/0c/Flag_of_Selangor.svg/100px-Flag_of_Selangor.svg.png" },
    <String, String>{ "value": "WLH", "name": "Wilayah Persekutuan Kuala Lumpur", "flag": "https://upload.wikimedia.org/wikipedia/commons/thumb/6/64/Flag_of_Kuala_Lumpur%2C_Malaysia.svg/100px-Flag_of_Kuala_Lumpur%2C_Malaysia.svg.png" },
    <String, String>{ "value": "PTJ", "name": "Wilayah Persekutuan Putrajaya", "flag": "https://upload.wikimedia.org/wikipedia/commons/thumb/9/9f/Flag_of_Putrajaya.svg/100px-Flag_of_Putrajaya.svg.png" },
    <String, String>{ "value": "NSN", "name": "Negeri Sembilan", "flag": "https://upload.wikimedia.org/wikipedia/commons/thumb/d/db/Flag_of_Negeri_Sembilan.svg/100px-Flag_of_Negeri_Sembilan.svg.png" },
    <String, String>{ "value": "MLK", "name": "Melaka", "flag": "https://upload.wikimedia.org/wikipedia/commons/thumb/0/09/Flag_of_Malacca.svg/100px-Flag_of_Malacca.svg.png" },
    <String, String>{ "value": "JHR", "name": "Johor", "flag": "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5a/Flag_of_Johor.svg/100px-Flag_of_Johor.svg.png" },
    <String, String>{ "value": "PHG", "name": "Pahang", "flag": "https://upload.wikimedia.org/wikipedia/commons/thumb/a/aa/Flag_of_Pahang.svg/100px-Flag_of_Pahang.svg.png" },
    <String, String>{ "value": "TRG", "name": "Terengganu", "flag": "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6b/Flag_of_Terengganu.svg/100px-Flag_of_Terengganu.svg.png" },
    <String, String>{ "value": "KEL", "name": "Kelantan", "flag": "https://upload.wikimedia.org/wikipedia/commons/thumb/6/61/Flag_of_Kelantan.svg/100px-Flag_of_Kelantan.svg.png" },
    <String, String>{ "value": "SRK", "name": "Sarawak", "flag": "https://upload.wikimedia.org/wikipedia/commons/thumb/7/7e/Flag_of_Sarawak.svg/100px-Flag_of_Sarawak.svg.png" },
    <String, String>{ "value": "SAB", "name": "Sabah", "flag": "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Flag_of_Sabah.svg/100px-Flag_of_Sabah.svg.png" },
    <String, String>{ "value": "WLP", "name": "Wilayah Persekutuan Labuan", "flag": "https://upload.wikimedia.org/wikipedia/commons/thumb/6/69/Flag_of_Labuan.svg/100px-Flag_of_Labuan.svg.png" },
  ];

  int _counter = 0;

  void _incrementCounter() async {
    try {
      final Map<String, dynamic> rivers = await RiverLevel("KEL");
      print(rivers);
      final Map<String, dynamic> railfalls = await Railfall("KEL");
      print(railfalls);
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
      body: Container(
        child: ListView.builder(
          itemCount: STATE.length,
          itemBuilder: (BuildContext _, int index) {
            return ListTile(
                leading:  Image.network(STATE[index]["flag"]!),
                trailing: const Icon(Icons.arrow_forward_ios ),
                title: Text(STATE[index]["name"]!),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 5.0,
                    vertical: 5.0,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return StateReportTabView(STATE[index]["value"]!, STATE[index]["name"]!, STATE[index]["flag"]!);
                    }),
                  );
                }
              );
          }),
      ),
    );
  }
}

class StateReportTabView extends StatelessWidget {

  final String value;
  final String name;
  final String flag;

  StateReportTabView(this.value, this.name, this.flag);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: new Scaffold(
        appBar: AppBar(
          title: Text(name),
        ),
        body: TabBarView(
          children: [
            new RainfallTab(value),
            new RiverTab(value),
          ],
        ),
        bottomNavigationBar: new TabBar(
          tabs: [
            Tab(
              icon: new Icon(Icons.cloud),
              text: 'Railfall',
            ),
            Tab(
              icon: new Icon(Icons.water),
              text: 'River',
            ),
          ],
          labelColor: Colors.red,
          unselectedLabelColor: Colors.blue,
          indicatorSize: TabBarIndicatorSize.label,
          indicatorPadding: EdgeInsets.all(5.0),
          indicatorColor: Colors.red,
        ),
      )
    );
  }
}

class RainfallTab extends StatefulWidget {

  final String value;

  RainfallTab(this.value);

  @override
  _RainfallTabState createState() => new _RainfallTabState();
}

class _RainfallTabState extends State<RainfallTab> with AutomaticKeepAliveClientMixin<RainfallTab> {

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return new Container(
      color: Colors.white,
      child: Center(
        child: Text('RainfallTab ${widget.value}'),
      )
    );
  }
}

class RiverTab extends StatefulWidget {

  final String value;

  RiverTab(this.value);

  @override
  _RiverTabState createState() => new _RiverTabState();
}

class _RiverTabState extends State<RiverTab> with AutomaticKeepAliveClientMixin<RiverTab> {

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return new Container(
      color: Colors.white,
      child: Center(
        child: Text('RiverTab ${widget.value}'),
      )
    );
  }
}
