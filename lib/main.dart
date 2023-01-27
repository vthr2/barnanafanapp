import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import "dart:math";
import 'package:csv/csv.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

//TODO mismunandi litir fyrir kyn láta favourites síðuna virka með klikki

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: Color.fromARGB(199, 94, 164, 233)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = "{Name: Ljósbjört, Description: björt sem ljós., Gender: F}";
  var names = ["Li", "gu", "smith"];
  var temp = "";
  var current_description = "test";
  var persons = [];
  bool flipped = false;
  List jsonData = [];
  var j = Random().nextInt(1500);
  MyAppState() {
    loadJson().then((value) => jsonData = value);
  }

  Future<List> loadJson() async {
    String data = await rootBundle.loadString('assets/names_json.json');
    var jsonResult = json.decode(data);
    var result = jsonResult["names"];
    return result;
  }

  void initializeNames() {
    //var j = Random().nextInt(jsonData.length);
    //current = jsonData[j]["Name"];
  }

  void getNext() {
    j = Random().nextInt(jsonData.length);
    current = jsonData[j].toString();
    //persons.add(current.toString());
    notifyListeners();
    print('check $current');
    flipped = false;
  }

  void addPickedNames() {
    persons.add(current);
    notifyListeners();
  }

  void addCustomNames(custom_name) {
    persons.add(custom_name);
    notifyListeners();
  }

  void flipCard() {
    flipped = !flipped;
    //current = value;
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    //csvData = processCsv();
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = NamePage();
        break;
      case 2:
        page = CustomName();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: false,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Pick'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.favorite),
                  label: Text('Names'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_sharp),
                  label: Text('Add'),
                ),
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (value) {
                print('selected: $value');
                setState(() {
                  selectedIndex = value;
                });
              },
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            ),
          ),
        ],
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  /*
  Future<String> get _loadVenueDatabase async {
    return await rootBundle.loadString('assets/name_data.csv');
  }

  Future<List<dynamic>> loadCsv() async {
    String data = await _loadVenueDatabase;
    List<List<dynamic>> rowsAsListOfValues =
        const CsvToListConverter().convert(data);

    return rowsAsListOfValues;
  }*/

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    appState.initializeNames();
    var pair = appState.current;
    var person_list = appState.persons;
    var display_text;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Baby Names'),
          BigButton(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                child: ElevatedButton(
                  onPressed: () {
                    //appState.initializeName();
                    appState.getNext();
                    appState.addPickedNames();
                  },
                  child: Text('Like'),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text("Don't Like"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigButton extends StatelessWidget {
  const BigButton({
    Key? key,
    required this.pair,
  }) : super(key: key);

  final pair;

  @override
  Widget build(BuildContext context) {
    var split = pair.split(':');
    var name = split[1].split(',')[0];
    var description = split[2].split(', Gender')[0];
    var gender = split[3][1];
    var theme = Theme.of(context);
    //description = description.capitalize();
    var color = theme.colorScheme.primary;
    if (gender == 'F') {
      print("yesyesyes");
      color = Color.fromARGB(198, 244, 168, 229);
    }
    var appState = context.watch<MyAppState>();
    var flipBoolean = appState.flipped;
    var display_text = name;
    if (flipBoolean == true) {
      display_text = description;
    }
    var boxStyle = ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ));


    var fontStyle = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onSecondary,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );

    return SizedBox(
      width: 340,
      height: 200,
      child: ElevatedButton(
          onPressed: () {
            appState.flipCard();
          },
          style: boxStyle,
          child: Text("$display_text", style: fontStyle)),
    );
  }
}

class NamePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var person_list = appState.persons;

    return Align(
      alignment: Alignment.topLeft,
      child: Expanded(
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (var item in person_list) BigButton(pair: item),
          ],
        ),
      ),
    );
  }
}

class CustomName extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var person_list = appState.persons;
    var custom_name = "";

    TextEditingController text_controller = new TextEditingController();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FractionallySizedBox(
            widthFactor: 0.3,
            child: TextField(
              controller: text_controller,
              textAlign: TextAlign.center,
              onChanged: (text) {
                custom_name = text;
              },
              onSubmitted: (text) {
                appState.addCustomNames(custom_name);
                text_controller.clear();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    Key? key,
    required this.pair,
  }) : super(key: key);

  final pair;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onSecondary,
    );
    return Card(
      color: theme.colorScheme.secondary,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(pair, style: style),
      ),
    );
  }
}
