// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_counter_app/utilities/increase_selec_text.dart';
import 'package:flutter_counter_app/utilities/settings_menu.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter_counter_app/utilities/theme_list.dart';
import 'package:intl/intl.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await DataSaver.init();

  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    DataHandler.init();
    counterResetter();
  }

  void dropdownCallBack(
    int? selectedValue,
  ) {
    if (selectedValue is int) {
      setState(() {
        DataHandler._dropdownValue = selectedValue;
      });
    }
  }

  void updateSettings() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
          color: ColorTheme.themeList[DataHandler.selectedTheme][0],
          child: Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: Column(
              children: [
                //
                //
                // Settings (button and menu) and reset button at the the top of the page
                //
                //

                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          iconSize: 40,
                          onPressed: (() {
                            showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                    insetPadding:
                                        EdgeInsets.symmetric(horizontal: 25),
                                    backgroundColor:
                                        Color.fromARGB(0, 35, 35, 35),
                                    content: SettingsMenu(
                                      updater: updateSettings,
                                    )));
                          }),
                          icon: Icon(Icons.settings,
                              color: ColorTheme
                                  .themeList[DataHandler.selectedTheme][1])),
                      IconButton(
                          iconSize: 40,
                          onPressed: () {
                            setState(() {
                              DataHandler.counter = 0;
                              DataSaver.saveData(
                                  'counter', DataHandler.counter);
                            });
                          },
                          icon: Icon(
                            Icons.refresh,
                            color: ColorTheme
                                .themeList[DataHandler.selectedTheme][1],
                          )),
                    ]), //or restart_alt],)

                //
                //
                //
                // circular progress idicator, current number and goal at the center of the page
                //
                //
                SizedBox(height: 150),
                CircularPercentIndicator(
                    radius: 100,
                    lineWidth: 12,
                    circularStrokeCap: CircularStrokeCap.round,
                    animation: true,
                    animateFromLastPercent: true,
                    backgroundColor:
                        ColorTheme.themeList[DataHandler.selectedTheme][1],
                    progressColor:
                        ColorTheme.themeList[DataHandler.selectedTheme][2],
                    percent: DataHandler.disableGoal
                        ? 1
                        : (DataHandler.counter / DataHandler.goal),
                    center: Text(
                      DataHandler.counter.toString(),
                      style: TextStyle(
                          fontSize: 50,
                          color: ColorTheme.themeList[DataHandler.selectedTheme]
                              [2]),
                    )),
                SizedBox(height: 35),
                Visibility(
                  visible: !DataHandler.disableGoal,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: Text('Goal: ${DataHandler.goal}',
                      style: TextStyle(
                          fontSize: 20,
                          color: ColorTheme.themeList[DataHandler.selectedTheme]
                              [1])),
                ),

                //
                //
                //
                // addin system at the bottom of the page
                //
                //
                SizedBox(height: 180),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DropdownButton(
                        dropdownColor:
                            ColorTheme.themeList[DataHandler.selectedTheme][0],
                        items: [
                          DropdownMenuItem(
                              value: 1,
                              child: IncreaseSelecText(
                                  '1', DataHandler.selectedTheme)),
                          DropdownMenuItem(
                              value: 5,
                              child: IncreaseSelecText(
                                  '5', DataHandler.selectedTheme)),
                          DropdownMenuItem(
                              value: 10,
                              child: IncreaseSelecText(
                                  '10', DataHandler.selectedTheme)),
                          DropdownMenuItem(
                              value: 15,
                              child: IncreaseSelecText(
                                  '15', DataHandler.selectedTheme)),
                          DropdownMenuItem(
                              value: 20,
                              child: IncreaseSelecText(
                                  '20', DataHandler.selectedTheme))
                        ],
                        value: DataHandler._dropdownValue,
                        onChanged: dropdownCallBack),
                    SizedBox(
                      width: 30,
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            minimumSize: Size(30, 40),
                            backgroundColor: ColorTheme
                                .themeList[DataHandler.selectedTheme][2],
                            textStyle: TextStyle(fontSize: 30)),
                        onPressed: (() async {
                          setState(() {
                            if (DataHandler.counter < DataHandler.goal ||
                                DataHandler.disableGoal) {
                              DataHandler.counter += DataHandler._dropdownValue;
                            }
                            if (DataHandler.counter > DataHandler.goal &&
                                !DataHandler.disableGoal) {
                              DataHandler.counter = DataHandler.goal;
                            }
                          });

                          await DataSaver.saveData(
                              'counter', DataHandler.counter);
                        }),
                        child: Text('+')),
                  ],
                ),
              ],
            ),
          )),
    );
  }
}

class DataHandler {
  static int counter = DataSaver.loadData('counter') ?? 0;
  static int _dropdownValue = 1;
  static int _dropdownValue2 = 0;
  static String dropdownValue3 =
      DataSaver.loadStringData('autoReset') ?? 'none';
  static int goal = DataSaver.loadData('goal') ?? 100;
  static int selectedTheme = DataSaver.loadData('theme') ?? 0;
  static TextEditingController newgoal = TextEditingController();
  static bool disableGoal = false;
  static DateFormat formatter = DateFormat("dd-MM-yyyy");
  static DateTime currentDate = DateTime.parse(
      DataSaver.loadStringData('currentDate') ??
          DateTime.now().toIso8601String());

  static int get dropdownValue2 {
    return _dropdownValue2;
  }

  static void set dropdownValue2(int value) {
    _dropdownValue2 = value;
  }

  static init() {
    counter = DataSaver.loadData('counter') ?? 0;
    _dropdownValue = 1;
    _dropdownValue2 = DataSaver.loadData('theme') ?? 0;
    dropdownValue3 = DataSaver.loadStringData('autoReset') ?? 'none';
    goal = DataSaver.loadData('goal') ?? 100;
    selectedTheme = DataSaver.loadData('theme') ?? 0;
    newgoal = TextEditingController();
    disableGoal = DataSaver.loadBoolData('disableGoal') ?? false;
    currentDate = DateTime.parse(DataSaver.loadStringData('currentDate') ??
        DateTime.now().toIso8601String());
    ;
  }
}

class DataSaver {
  static SharedPreferences? prefs;

  static Future init() async => prefs = await SharedPreferences.getInstance();
  static Future saveData(String dataName, int counter) async =>
      await prefs?.setInt(dataName, counter);
  static Future saveStringData(String dataName, String data) async =>
      await prefs?.setString(dataName, data);
  static Future saveBoolData(String dataName, data) async =>
      await prefs?.setBool(dataName, data);
  static int? loadData(String dataName) => prefs?.getInt(dataName);
  static String? loadStringData(String dataName) => prefs?.getString(dataName);
  static bool? loadBoolData(String dataName) => prefs?.getBool(dataName);
}

void counterResetter() {
  if (DataHandler.dropdownValue3 == 'day') {
    if (DataHandler.formatter.format(DataHandler.currentDate) !=
        DataHandler.formatter.format(DateTime.now())) {
      DataHandler.counter = 0;
      DataSaver.saveData('counter', 0);
      DataSaver.saveStringData('currentDate', DateTime.now().toIso8601String());
    }
  } else if (DataHandler.dropdownValue3 == 'week') {
    if (DataHandler.formatter.format(DataHandler.currentDate
            .subtract(Duration(days: DataHandler.currentDate.weekday))) !=
        DataHandler.formatter.format(
            DateTime.now().subtract(Duration(days: DateTime.now().weekday)))) {
      DataHandler.counter = 0;
      DataSaver.saveData('counter', 0);
      DataSaver.saveStringData('currentDate', DateTime.now().toIso8601String());
    }
  } else if (DataHandler.dropdownValue3 == 'month') {
    if (DataHandler.formatter.format(DataHandler.currentDate
            .subtract(Duration(days: DataHandler.currentDate.day))) !=
        DataHandler.formatter.format(
            DateTime.now().subtract(Duration(days: DateTime.now().day)))) {
      DataHandler.counter = 0;
      DataSaver.saveData('counter', 0);
      DataSaver.saveStringData('currentDate', DateTime.now().toIso8601String());
    }
  }
}
