// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_counter_app/utilities/theme_list.dart';

import '../main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class SettingsMenu extends StatefulWidget {
  const SettingsMenu({super.key, required this.updater});
  final Function() updater;

  @override
  State<SettingsMenu> createState() => _SettingsMenuState();
}

class _SettingsMenuState extends State<SettingsMenu> {
  var settingsTextStyle = TextStyle(
      fontSize: 20, color: ColorTheme.themeList[DataHandler.selectedTheme][1]);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 450,
      width: 350,
      decoration: BoxDecoration(
          color: ColorTheme.themeList[DataHandler.selectedTheme][0],
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Column(
        children: [
          SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Set Goal: ',
                style: settingsTextStyle,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 18.0),
                child: Container(
                  height: 20,
                  width: 37,
                  child: TextField(
                      controller: DataHandler.newgoal,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                        LengthLimitingTextInputFormatter(3),
                      ],
                      textAlign: TextAlign.center,
                      style: settingsTextStyle,
                      decoration: InputDecoration(
                          hintText: DataHandler.CounterController.page == 0.0
                              ? DataHandler.goal.toString()
                              : DataHandler.goal2.toString(),
                          hintStyle: settingsTextStyle)),
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Disable Goal:',
                style: settingsTextStyle,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Theme(
                  data: ThemeData(
                      unselectedWidgetColor:
                          ColorTheme.themeList[DataHandler.selectedTheme][1]),
                  child: Checkbox(
                      value: DataHandler.CounterController.page == 0.0
                          ? DataHandler.disableGoal
                          : DataHandler.disableGoal2,
                      activeColor:
                          ColorTheme.themeList[DataHandler.selectedTheme][1],
                      checkColor:
                          ColorTheme.themeList[DataHandler.selectedTheme][2],
                      onChanged: (value) {
                        setState(() {
                          if (DataHandler.CounterController.page == 0.0) {
                            if (value is bool) {
                              DataHandler.disableGoal = value;
                              DataSaver.saveBoolData(
                                  'disableGoal', DataHandler.disableGoal);
                            }
                            if (DataHandler.disableGoal == false &&
                                DataHandler.counter > DataHandler.goal) {
                              DataHandler.counter = DataHandler.goal;
                              DataSaver.saveData(
                                  'counter', DataHandler.counter);
                            }
                          } else {
                            if (value is bool) {
                              DataHandler.disableGoal2 = value;
                              DataSaver.saveBoolData(
                                  'disableGoal2', DataHandler.disableGoal2);
                            }
                            if (DataHandler.disableGoal2 == false &&
                                DataHandler.counter2 > DataHandler.goal2) {
                              DataHandler.counter2 = DataHandler.goal2;
                              DataSaver.saveData(
                                  'counter2', DataHandler.counter2);
                            }
                          }
                          widget.updater();
                        });
                      }),
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Daily reminders:', style: settingsTextStyle),
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Theme(
                  data: ThemeData(
                      unselectedWidgetColor:
                          ColorTheme.themeList[DataHandler.selectedTheme][1]),
                  child: Checkbox(
                      value: DataHandler.dailyReminders,
                      activeColor:
                          ColorTheme.themeList[DataHandler.selectedTheme][1],
                      checkColor:
                          ColorTheme.themeList[DataHandler.selectedTheme][2],
                      onChanged: (value) {
                        setState(() {
                          if (value is bool) {
                            DataHandler.dailyReminders = value;
                            DataSaver.saveBoolData(
                                'dailyreminders', DataHandler.dailyReminders);
                          }
                        });
                        setState(() async {
                          if (value == true) {
                            await NotificationApi
                                .flutterLocalNotificationsPlugin
                                .zonedSchedule(
                                    0,
                                    'scheduled title',
                                    'scheduled body',
                                    NotificationApi.nextInstanceOfTenAM(),
                                    const NotificationDetails(
                                        android: AndroidNotificationDetails(
                                            'your channel id',
                                            'your channel name',
                                            channelDescription:
                                                'your channel description')),
                                    uiLocalNotificationDateInterpretation:
                                        UILocalNotificationDateInterpretation
                                            .absoluteTime,
                                    androidAllowWhileIdle: true,
                                    matchDateTimeComponents:
                                        DateTimeComponents.dateAndTime);
                          }
                        });
                      }),
                ),
              )
            ],
          ),
          SizedBox(height: 90),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              'Auto reset:',
              style: settingsTextStyle,
            ),
            SizedBox(width: 20),
            DropdownButton(
                dropdownColor: ColorTheme.themeList[DataHandler.selectedTheme]
                    [0],
                items: [
                  DropdownMenuItem(
                      value: 'none',
                      child: Text('none', style: settingsTextStyle)),
                  DropdownMenuItem(
                      value: 'day',
                      child: Text('daily', style: settingsTextStyle)),
                  DropdownMenuItem(
                      value: 'week',
                      child: Text('weekly', style: settingsTextStyle)),
                  DropdownMenuItem(
                      value: 'month',
                      child: Text('monthly', style: settingsTextStyle))
                ],
                value: DataHandler.dropdownValue3,
                onChanged: ((selectedValue) {
                  setState(() {
                    if (selectedValue is String) {
                      DataHandler.dropdownValue3 = selectedValue;
                    }
                    DataSaver.saveStringData(
                        'autoReset', DataHandler.dropdownValue3);
                    DataHandler.currentDate = DateTime.now();
                    DataSaver.saveStringData(
                        'currentDate', DateTime.now().toIso8601String());
                  });
                }))
          ]),
          SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('Select Theme:', style: settingsTextStyle),
            SizedBox(width: 20),
            DropdownButton(
              dropdownColor: ColorTheme.themeList[DataHandler.selectedTheme][0],
              items: [
                DropdownMenuItem(
                    value: 0,
                    child: Text('metaverse', style: settingsTextStyle)),
                DropdownMenuItem(
                    value: 1,
                    child: Text('superuser', style: settingsTextStyle)),
                DropdownMenuItem(
                    value: 2, child: Text('dracula', style: settingsTextStyle))
              ],
              value: DataHandler.dropdownValue2,
              onChanged: (selectedValue) {
                setState(() {
                  if (selectedValue is int) {
                    DataHandler.dropdownValue2 = selectedValue;
                  }
                  DataHandler.selectedTheme = DataHandler.dropdownValue2;
                  DataSaver.saveData('theme', DataHandler.selectedTheme);
                  settingsTextStyle = TextStyle(
                      fontSize: 20,
                      color: ColorTheme.themeList[DataHandler.selectedTheme]
                          [1]);
                  widget.updater();
                });
              },
            )
          ]),
          SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: ColorTheme.themeList[DataHandler.selectedTheme]
                    [2]),
            onPressed: (() {
              setState(() {
                if (DataHandler.newgoal.text.isNotEmpty) {
                  if (DataHandler.CounterController.page == 0.0) {
                    if (int.parse(DataHandler.newgoal.text) <
                        DataHandler.counter) {
                      DataHandler.counter = int.parse(DataHandler.newgoal.text);
                      DataSaver.saveData('counter', DataHandler.counter);
                    }
                    DataHandler.goal = int.parse(DataHandler.newgoal.text);
                    DataSaver.saveData('goal', DataHandler.goal);
                  } else {
                    if (int.parse(DataHandler.newgoal.text) <
                        DataHandler.counter2) {
                      DataHandler.counter2 =
                          int.parse(DataHandler.newgoal.text);
                      DataSaver.saveData('counter2', DataHandler.counter2);
                    }
                    DataHandler.goal2 = int.parse(DataHandler.newgoal.text);
                    DataSaver.saveData('goal2', DataHandler.goal2);
                  }

                  DataHandler.newgoal.clear();
                  DataHandler.disableGoal = false;
                  DataSaver.saveBoolData('disableGoal', false);
                  widget.updater();
                }
              });
              Navigator.pop(context, false);
            }),
            child: Text(
              'Ok',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}
