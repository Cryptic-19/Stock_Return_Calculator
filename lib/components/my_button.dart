import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final fnc;
  final num;
  final Color? bgcolor;
  final Color? fgcolor;
  final Color? shcolor;
  final double? wd;
  const MyButton({
    super.key,
    required this.fnc,
    required this.num,
    this.bgcolor,
    this.fgcolor,
    this.shcolor,
    this.wd,
  });

  @override
  Widget build(BuildContext context) {
    double displayW = MediaQuery.of(context).size.width;
    double displayH = MediaQuery.of(context).size.height;
    double y = 0.20;
    if (wd == 0.90) {
      y = 0.90;
    }
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgcolor,
        foregroundColor: fgcolor,
        shadowColor: shcolor,
        elevation: 3,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        minimumSize: Size(displayW * y, displayH * 0.075),
      ),
      onPressed: fnc,
      child: num,
    );
  }
}
