// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_counter_app/utilities/increase_selec_text.dart';
import 'package:flutter_counter_app/utilities/settings_menu.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter_counter_app/utilities/theme_list.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:developer';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:flutter_counter_app/utilities/Workout_storage.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  tz.initializeTimeZones();
  await DataSaver.init();

  await NotificationApi.flutterLocalNotificationsPlugin
      .initialize(NotificationApi.initializationSettings);

  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GlobalKey<ExpandableBottomSheetState> key = new GlobalKey();
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
      body: SlidingUpPanel(
        minHeight: 20,
        maxHeight: 420,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        color: ColorTheme.themeList[DataHandler.selectedTheme][0],
        backdropEnabled: true,
        panel: Column(
          children: [
            SizedBox(
              height: 9,
            ),
            Container(
                height: 5,
                width: 100,
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.all(Radius.circular(20)))),
            SizedBox(height: 20),
            Text(
                "Your did 330 " +
                    (DataHandler.currentpage == 0 ? "push up" : "pull up"),
                style: GoogleFonts.archivoNarrow(
                    textStyle: TextStyle(
                        fontSize: 20,
                        color: ColorTheme.themeList[DataHandler.selectedTheme]
                            [1],
                        fontWeight: FontWeight.bold))),
            SizedBox(height: 10),
            HeatMapCalendar(
              showColorTip: false,
              monthTextColor: ColorTheme.themeList[DataHandler.selectedTheme]
                  [1],
              weekTextColor: ColorTheme.themeList[DataHandler.selectedTheme][1],
              colorsets: const {
                1: Colors.lime,
                2: Colors.lightGreen,
                3: Colors.green
              },
              datasets: DataHandler.currentpage == 0
                  ? DataHandler.push_up_saves
                  : DataHandler.pull_up_saves,
            )
          ],
        ),
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
                              if (DataHandler.CounterController.page == 0.0) {
                                setState(() {
                                  DataHandler.counter = 0;
                                  DataSaver.saveData(
                                      'counter', DataHandler.counter);
                                });
                              } else {
                                setState(() {
                                  DataHandler.counter2 = 0;
                                  DataSaver.saveData(
                                      'counter2', DataHandler.counter2);
                                });
                              }
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
                  SizedBox(height: 100),
                  Container(
                      height: 400,
                      child: PageView(
                        controller: DataHandler.CounterController,
                        physics: BouncingScrollPhysics(),
                        children: [
                          Column(children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(right: 210, bottom: 30),
                              child: Text("Push up",
                                  style: GoogleFonts.archivoNarrow(
                                      textStyle: TextStyle(
                                          fontSize: 40,
                                          color: ColorTheme.themeList[
                                              DataHandler.selectedTheme][1],
                                          fontWeight: FontWeight.bold))),
                            ),
                            CircularPercentIndicator(
                                radius: 100,
                                lineWidth: 12,
                                circularStrokeCap: CircularStrokeCap.round,
                                animation: true,
                                animateFromLastPercent: true,
                                backgroundColor: ColorTheme
                                    .themeList[DataHandler.selectedTheme][1],
                                progressColor: ColorTheme
                                    .themeList[DataHandler.selectedTheme][2],
                                percent: DataHandler.disableGoal
                                    ? 1
                                    : (DataHandler.counter / DataHandler.goal),
                                center: Text(
                                  DataHandler.counter.toString(),
                                  style: TextStyle(
                                      fontSize: 50,
                                      color: ColorTheme.themeList[
                                          DataHandler.selectedTheme][2]),
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
                                      color: ColorTheme.themeList[
                                          DataHandler.selectedTheme][1])),
                            ),
                          ]),
                          //
                          // Second counter displayer + goal
                          //
                          Column(children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(right: 230, bottom: 30),
                              child: Text("Pull up",
                                  style: GoogleFonts.archivoNarrow(
                                      textStyle: TextStyle(
                                          fontSize: 40,
                                          color: ColorTheme.themeList[
                                              DataHandler.selectedTheme][1],
                                          fontWeight: FontWeight.bold))),
                            ),
                            CircularPercentIndicator(
                                radius: 100,
                                lineWidth: 12,
                                circularStrokeCap: CircularStrokeCap.round,
                                animation: true,
                                animateFromLastPercent: true,
                                backgroundColor: ColorTheme
                                    .themeList[DataHandler.selectedTheme][1],
                                progressColor: ColorTheme
                                    .themeList[DataHandler.selectedTheme][2],
                                percent: DataHandler.disableGoal2
                                    ? 1
                                    : (DataHandler.counter2 /
                                        DataHandler.goal2),
                                center: Text(
                                  DataHandler.counter2.toString(),
                                  style: TextStyle(
                                      fontSize: 50,
                                      color: ColorTheme.themeList[
                                          DataHandler.selectedTheme][2]),
                                )),
                            SizedBox(height: 35),
                            Visibility(
                              visible: !DataHandler.disableGoal2,
                              maintainSize: true,
                              maintainAnimation: true,
                              maintainState: true,
                              child: Text('Goal: ${DataHandler.goal2}',
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: ColorTheme.themeList[
                                          DataHandler.selectedTheme][1])),
                            ),
                          ]),
                        ],
                        onPageChanged: (value) {
                          setState(() {
                            DataHandler.currentpage = value;
                          });
                        },
                      )),

                  //
                  //
                  //
                  // addin system at the bottom of the page
                  //
                  //
                  SizedBox(height: 100),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DropdownButton(
                          dropdownColor: ColorTheme
                              .themeList[DataHandler.selectedTheme][0],
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
                            if (DataHandler.CounterController.page == 0.0) {
                              setState(() {
                                if (DataHandler.counter < DataHandler.goal ||
                                    DataHandler.disableGoal) {
                                  DataHandler.counter +=
                                      DataHandler._dropdownValue;
                                }
                                if (DataHandler.counter > DataHandler.goal &&
                                    !DataHandler.disableGoal) {
                                  DataHandler.counter = DataHandler.goal;
                                }
                              });
                            } else {
                              setState(() {
                                if (DataHandler.counter2 < DataHandler.goal2 ||
                                    DataHandler.disableGoal2) {
                                  DataHandler.counter2 +=
                                      DataHandler._dropdownValue;
                                }
                                if (DataHandler.counter2 > DataHandler.goal2 &&
                                    !DataHandler.disableGoal2) {
                                  DataHandler.counter2 = DataHandler.goal2;
                                }
                              });
                            }

                            await DataSaver.saveData(
                                'counter', DataHandler.counter);
                            await DataSaver.saveData(
                                'counter2', DataHandler.counter2);
                          }),
                          child: Text('+')),
                    ],
                  ),
                ],
              ),
            )),
      ),
    );
  }
}

class DataHandler {
  static PageController CounterController = PageController();
  static int currentpage = 0;
  static int counter = DataSaver.loadData('counter') ?? 0;
  static int counter2 = DataSaver.loadData('counter2') ?? 0;
  static int _dropdownValue = 1;
  static int _dropdownValue2 = 0;
  static String dropdownValue3 =
      DataSaver.loadStringData('autoReset') ?? 'none';
  static int goal = DataSaver.loadData('goal') ?? 100;
  static int goal2 = DataSaver.loadData('goal2') ?? 100;
  static int selectedTheme = DataSaver.loadData('theme') ?? 0;
  static TextEditingController newgoal = TextEditingController();
  static bool disableGoal = false;
  static bool disableGoal2 = false;
  static bool dailyReminders = false;
  static DateFormat formatter = DateFormat("dd-MM-yyyy");
  static DateTime currentDate = DateTime.parse(
      DataSaver.loadStringData('currentDate') ??
          DateTime.now().toIso8601String());
  static Map<DateTime, int>? push_up_saves;
  static Map<DateTime, int>? pull_up_saves;

  static int get dropdownValue2 {
    return _dropdownValue2;
  }

  static void set dropdownValue2(int value) {
    _dropdownValue2 = value;
  }

  static init() {
    counter = DataSaver.loadData('counter') ?? 0;
    counter2 = DataSaver.loadData('counter2') ?? 0;
    _dropdownValue = 1;
    _dropdownValue2 = DataSaver.loadData('theme') ?? 0;
    dropdownValue3 = DataSaver.loadStringData('autoReset') ?? 'none';
    goal = DataSaver.loadData('goal') ?? 100;
    goal2 = DataSaver.loadData('goal2') ?? 100;
    selectedTheme = DataSaver.loadData('theme') ?? 0;
    newgoal = TextEditingController();
    disableGoal = DataSaver.loadBoolData('disableGoal') ?? false;
    disableGoal2 = DataSaver.loadBoolData('disableGoal2') ?? false;
    dailyReminders = DataSaver.loadBoolData('dailyreminders') ?? false;
    currentDate = DateTime.parse(DataSaver.loadStringData('currentDate') ??
        DateTime.now().toIso8601String());
    currentpage = 0;
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
      DataHandler.counter2 = 0;
      DataSaver.saveData('counter2', 0);
      DataSaver.saveStringData('currentDate', DateTime.now().toIso8601String());
    }
  } else if (DataHandler.dropdownValue3 == 'week') {
    if (DataHandler.formatter.format(DataHandler.currentDate
            .subtract(Duration(days: DataHandler.currentDate.weekday))) !=
        DataHandler.formatter.format(
            DateTime.now().subtract(Duration(days: DateTime.now().weekday)))) {
      DataHandler.counter = 0;
      DataSaver.saveData('counter', 0);
      DataHandler.counter2 = 0;
      DataSaver.saveData('counter2', 0);
      DataSaver.saveStringData('currentDate', DateTime.now().toIso8601String());
    }
  } else if (DataHandler.dropdownValue3 == 'month') {
    if (DataHandler.formatter.format(DataHandler.currentDate
            .subtract(Duration(days: DataHandler.currentDate.day))) !=
        DataHandler.formatter.format(
            DateTime.now().subtract(Duration(days: DateTime.now().day)))) {
      DataHandler.counter = 0;
      DataSaver.saveData('counter', 0);
      DataHandler.counter2 = 0;
      DataSaver.saveData('counter2', 0);
      DataSaver.saveStringData('currentDate', DateTime.now().toIso8601String());
    }
  }
}

class NotificationApi {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  static final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  static tz.TZDateTime nextInstanceOfTenAM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 10);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
