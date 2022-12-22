import 'package:flutter/material.dart';

class Choice {
  const Choice({this.title, this.icon});

  final String? title;
  final IconData? icon;
}

// ignore: unnecessary_const
const List<Choice> choices = const <Choice>[
  Choice(title: 'Delete Category', icon: Icons.delete_forever),
];
