import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class TileNavigationButton extends StatelessWidget {
  final String routeName;
  final String title;

  //I want to create an unchangeable object, all fields must be final
  const TileNavigationButton({required this.routeName, required this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100.0,
      child: Card(
        child: InkWell(
          onTap: () {
            RM.navigate.toNamed(routeName);
          },
          child: Center(
            child: Text(title),
          ),
        ),
      ),
    );
  }
}
