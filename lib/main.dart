import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF292929),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final controller = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: controller,
        children: const [
          DetailPage(headline: 'Heute', daysInPast: 0),
          DetailPage(headline: 'Gestern', daysInPast: 1)
        ],
      ),
    );
  }
}

class DetailPage extends StatefulWidget {
  const DetailPage({Key? key, required this.headline, required this.daysInPast})
      : super(key: key);

  final String headline;
  final int daysInPast;

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0, 48, 0, 32),
        child: Column(
          children: [
            Text(
              widget.headline,
              style: const TextStyle(fontSize: 48, color: Colors.white),
            ),
            TrackingElement(
              color: const Color(0xFF8BEF11),
              iconData: Icons.directions_run,
              unit: 'm',
              max: 5000,
              daysInPast: widget.daysInPast,
            ),
            TrackingElement(
              color: const Color(0xFF3B53EA),
              iconData: Icons.local_drink,
              unit: 'ml',
              max: 3000,
              daysInPast: widget.daysInPast,
            ),
            TrackingElement(
              color: const Color(0xFFC42541),
              iconData: Icons.fastfood,
              unit: 'kcal',
              max: 1800,
              daysInPast: widget.daysInPast,
            ),
          ],
        ));
  }
}

class TrackingElement extends StatefulWidget {
  const TrackingElement(
      {Key? key,
      required this.color,
      required this.iconData,
      required this.unit,
      required this.max,
      required this.daysInPast})
      : super(key: key);

  final Color color;
  final IconData iconData;
  final String unit;
  final double max;
  final int daysInPast;

  @override
  _TrackingElementState createState() => _TrackingElementState();
}

class _TrackingElementState extends State<TrackingElement> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  int _counter = 0;
  double _progress = 0;
  var now = DateTime.now();
  String _storageKey = '';

  void _incrementCounter() async {
    setState(() {
      _counter += 200;
      _progress = _counter / widget.max;
    });
    (await _prefs).setInt(_storageKey, _counter);
  }

  String _calculateStorageKeyDate() {
    if (now.day - widget.daysInPast > 0) {
      return '${now.year}-${now.month}-${now.day - widget.daysInPast}';
    } else if (now.month - 1 > 0) {
      int day =
          DateTime(now.year, now.month, 0).day - widget.daysInPast + now.day;
      return '${now.year}-${now.month - 1}-$day';
    } else {
      int day = DateTime(now.year - 1, DateTime.december + 1, 0).day -
          widget.daysInPast +
          now.day;
      return '${now.year - 1}-${DateTime.december}-$day';
    }
  }

  @override
  void initState() {
    super.initState();
    _storageKey = '${_calculateStorageKeyDate()}_${widget.unit}';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _prefs.then((prefs) {
      setState(() {
        _counter = prefs.getInt(_storageKey) ?? 0;
        _progress = _counter / widget.max;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _incrementCounter,
      child: Column(
        children: <Widget>[
          Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(32, 64, 32, 24),
              child: Row(
                children: <Widget>[
                  Icon(
                    widget.iconData,
                    color: Colors.white70,
                    size: 50,
                  ),
                  Text(
                    '$_counter / ${widget.max.toInt()} ${widget.unit}',
                    style: const TextStyle(color: Colors.white70, fontSize: 24),
                  ),
                ],
              )),
          LinearProgressIndicator(
            value: _progress,
            color: widget.color,
            backgroundColor: const Color(0x40FFFFFF),
            minHeight: 12,
          )
        ],
      ),
    );
  }
}
