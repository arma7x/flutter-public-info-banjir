import 'dart:async';
import 'package:flutter/material.dart';
import 'package:publicinfobanjir/api.dart';

void main() {
  runApp(const MyApp());
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

  final TextEditingController textController = TextEditingController();
  late FocusNode focusTextNode;
  bool searchInputVisibility = false;
  Timer? textTimer;
  List<Map<String, String>> stateList = <Map<String, String>>[];

  void onInput() {
    textTimer?.cancel();
    textTimer = Timer(Duration(seconds: 1), () {
      searching(textController.text.trim().toLowerCase());
    });
  }

  void searching(String text) {
    List<Map<String, String>> temp = <Map<String, String>>[];
    if (text == "") {
      temp = [...Api.STATE_LIST];
    } else {
      for (var s in Api.STATE_LIST) {
        if (s["name"]!.toLowerCase().contains(text))
          temp.add(s);
      }
    }
    setState(() {
      stateList = temp;
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      stateList = Api.STATE_LIST;
    });
    focusTextNode = FocusNode();
    textController.addListener(onInput);
  }

  @override
  void dispose() {
    focusTextNode.dispose();
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: searchInputVisibility ? TextFormField(
          controller: textController,
          focusNode: focusTextNode,
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(),
            isCollapsed: true,
            contentPadding: EdgeInsets.all(9),
          ),
        ) : Text(widget.title),
        actions: <Widget>[
          if (searchInputVisibility) IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              textController.clear();
              textTimer?.cancel();
              searching("");
              setState(() {
                searchInputVisibility = false;
              });
            },
          ) else IconButton(
            icon: const Icon(Icons.search),
            tooltip: "Show input search",
            onPressed: () {
              setState(() {
                searchInputVisibility = true;
                focusTextNode.requestFocus();
              });
            },
          ),
        ]
      ),
      body: Container(
        child: ListView.builder(
          itemCount: stateList.length,
          itemBuilder: (BuildContext _, int index) {
            return ListTile(
                leading:  Image.network(stateList[index]["flag"]!),
                trailing: const Icon(Icons.arrow_forward_ios ),
                title: Text(stateList[index]["name"]!),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 5.0,
                    vertical: 5.0,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return StateReportTabView(stateList[index]["value"]!, stateList[index]["name"]!, stateList[index]["flag"]!);
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

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  bool isLoading = true;
  bool hasError = false;
  String errorMessage = "";
  Map<String, dynamic> result = <String, dynamic>{};

  @override
  bool get wantKeepAlive => true;

  Future<void> getData() async {
    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = "";
    });
    try {
      Map<String, dynamic> temp = await Api.Railfall(widget.value);
      setState(() {
        result = temp;
      });
    } on Exception catch (e) {
      setState(() {
        hasError = true;
        errorMessage = e.toString();
      });
    }
    setState(() {
      isLoading = false;
    });
    return Future<void>.value(null);
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 200)).then((_) {
      _refreshIndicatorKey.currentState?.show();
    });
  }

  @override
  void dispose() {
    _refreshIndicatorKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return new Container(
      color: Colors.white,
      child: RefreshIndicator(
        key: _refreshIndicatorKey,
        color: Colors.white,
        backgroundColor: Colors.blue,
        onRefresh: getData,
        child: isLoading ? TempListView("Fetching data") :  (hasError ? TempListView(errorMessage) : ListView.builder(
          itemCount: result["data"]!.length,
          itemBuilder: (BuildContext _, int index) {
            return Card(
              color: Colors.grey[200],
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: new List.generate(result["textHeaders"]!.length,
                    (i) {
                      if (result["textHeaders"]![i] == "Daily_Rainfall")
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(result["textHeaders"]![i].replaceAll('_', ' ')),
                            ...(new List.generate(result["dailyRainfallHeaders"]!.length, (i2) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(result["dailyRainfallHeaders"]![i2]),
                                  Text(result["data"]![index][result["textHeaders"]![i]][i2] + "mm"),
                                ]
                              );
                            }).toList()),
                          ]
                        );
                      else {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(result["textHeaders"]![i].replaceAll('_', ' ')),
                            Text(result["data"]![index][result["textHeaders"]![i]] + (i > 5 ? "mm" : "")),
                          ]
                        );
                      }
                    }
                  ).toList()
                )
              ),
            );
          }
        )),
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

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  bool isLoading = true;
  bool hasError = false;
  String errorMessage = "";
  Map<String, dynamic> result = <String, dynamic>{};

  @override
  bool get wantKeepAlive => true;

  Future<void> getData() async {
    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = "";
    });
    try {
      Map<String, dynamic> temp = await Api.RiverLevel(widget.value);
      setState(() {
        result = temp;
      });
    } on Exception catch (e) {
      setState(() {
        hasError = true;
        errorMessage = e.toString();
      });
    }
    setState(() {
      isLoading = false;
    });
    return Future<void>.value(null);
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 200)).then((_) {
      _refreshIndicatorKey.currentState?.show();
    });
  }

  @override
  void dispose() {
    _refreshIndicatorKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return new Container(
      color: Colors.white,
      child: RefreshIndicator(
        key: _refreshIndicatorKey,
        color: Colors.white,
        backgroundColor: Colors.blue,
        onRefresh: getData,
        child: isLoading ? TempListView("Fetching data") :  (hasError ? TempListView(errorMessage) : ListView.builder(
          itemCount: result["data"]!.length,
          itemBuilder: (BuildContext _, int index) {
            return Card(
              color: Colors.grey[200],
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: new List.generate(result["textHeaders"]!.length,
                    (i) {
                      if (result["textHeaders"]![i] == "Threshold")
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(result["textHeaders"]![i].replaceAll('_', ' ')),
                            ...(new List.generate(result["thresholdHeaders"]!.length, (i2) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(result["thresholdHeaders"]![i2]),
                                  Text(result["data"]![index][result["textHeaders"]![i]][i2] + "m"),
                                ]
                              );
                            }).toList()),
                          ]
                        );
                      else {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(result["textHeaders"]![i].replaceAll('_', ' ')),
                            Text(result["data"]![index][result["textHeaders"]![i]] + (i == 7 ? "m" : "")),
                          ]
                        );
                      }
                    }
                  ).toList()
                )
              ),
            );
          }
        )),
      )
    );
  }
}

class TempListView extends StatelessWidget {

  final String text;

  TempListView(this.text);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      return ListView.builder(
        itemCount: 6,
        itemBuilder: (BuildContext _, int index) {
          return Card(
            color: Colors.grey[200],
            child: Container(
              height: (constraints.maxHeight - 50) / 6,
              child: Center(
                child: Text(text)
              )
            ),
          );
        }
      );
    });
  }
}
