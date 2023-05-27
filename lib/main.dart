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

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
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
  //TODO: Fix hardcoding of current name
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
    notifyListeners();
    print('check $current');
    flipped = false;
  }

  void addPickedNames() {
    persons.add(current);
    jsonData.remove(current);
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
          SizedBox(
            width: 72, // Width of the NavigationRail
            child: SafeArea(
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
                  // For custom names, currently unused
                  // NavigationRailDestination(
                  //   icon: Icon(Icons.settings_sharp),
                  //   label: Text('Add'),
                  // ),
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
          ),
          Container(
            width: MediaQuery.of(context).size.width - 72, // Adjusted width based on NavigationRail
            color: Theme.of(context).colorScheme.primaryContainer,
            child: page,
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
          BigButton(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                child: ElevatedButton(
                  onPressed: () {
                    appState.addPickedNames();
                    appState.getNext();
                  },
                  child: Text('Já'),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text("Nei"),
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
    // TODO: Make this more readable, should be able to fetch description from dictionary instead of splitting the string 
    var split = pair.split(': ');
    var name = split[1].split(',')[0];
    var description = split[2].split(', Gender')[0].toString().capitalize();
    var gender = split[3][0];
    var theme = Theme.of(context);
    //description = description.capitalize();
    var color = theme.colorScheme.primary;
    if (gender == 'F') {
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
    var personList = appState.persons;

    return Align(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: personList.map((item) => BigButton(pair: item)).toList(),
        ),
      ),
    );
  }
}

class CustomName extends StatefulWidget {
  @override
  State<CustomName> createState() => _CustomName();
}

/* Adding a custom name, currently unused */
class _CustomName extends State<CustomName> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var person_list = appState.persons;
    var custom_name = "";
    var custom_description = "";
    var custom_gender = "";
    bool? maleValue = false;
    bool? femaleValue = false;

    TextEditingController text_controller1 = new TextEditingController();
    TextEditingController text_controller2 = new TextEditingController();
    TextEditingController text_controller3 = new TextEditingController();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FractionallySizedBox(
            widthFactor: 0.3,
            child: TextField(
              controller: text_controller1,
              textAlign: TextAlign.center,
              onChanged: (text) {
                custom_name = text;
              },
              onSubmitted: (text) {
                appState.addCustomNames(custom_name);
                text_controller1.clear();
              },
            ),
          ),
          FractionallySizedBox(
            widthFactor: 0.3,
            child: TextField(
              controller: text_controller2,
              textAlign: TextAlign.center,
              onChanged: (descr) {
                custom_description = descr;
              },
              onSubmitted: (descr) {
                appState.addCustomNames(custom_name);
                text_controller2.clear();
              },
            ),
          ),
          CheckboxListTile(
            title: new Center(child: new Text("Male")),
            activeColor: Colors.black,
            value: maleValue,
            onChanged: (bool? newValue) {
              custom_gender = 'M';
            },
          ),
          CheckboxListTile(
            title: new Center(child: new Text("Female")),
            activeColor: Colors.black,
            value: maleValue,
            onChanged: (bool? newValue) {
              custom_gender = 'M';
            },
          ),
          SizedBox(height: 10),
          SizedBox(
            child: ElevatedButton(
                onPressed: () {
                  var element_to_add =
                      "{Name: $custom_name, Description: $custom_description, Gender: $custom_gender}";
                  appState.addCustomNames(element_to_add);
                  text_controller1.clear();
                  text_controller2.clear();
                  text_controller3.clear();
                },
                child: Text("Submit")),
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
