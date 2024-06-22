import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';


class CustomLoadingIndicator extends StatelessWidget {
  final Color color;
  final double size;

  CustomLoadingIndicator({this.color = Colors.blue, this.size = 50.0});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitRotatingCircle(
        color: color,
        size: size,
      ),
    );
  }
}