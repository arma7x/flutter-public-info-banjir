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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: ListView.builder(
          itemCount: Api.STATE.length,
          itemBuilder: (BuildContext _, int index) {
            return ListTile(
                leading:  Image.network(Api.STATE[index]["flag"]!),
                trailing: const Icon(Icons.arrow_forward_ios ),
                title: Text(Api.STATE[index]["name"]!),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 5.0,
                    vertical: 5.0,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return StateReportTabView(Api.STATE[index]["value"]!, Api.STATE[index]["name"]!, Api.STATE[index]["flag"]!);
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
