import 'package:flutter/material.dart';
import 'package:flutter_counter_app/utilities/theme_list.dart';

class IncreaseSelecText extends StatelessWidget {
  IncreaseSelecText(this.text, this.theme);
  final String text;
  int theme;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(fontSize: 25, color: ColorTheme.themeList[theme][1]));
  }
}
