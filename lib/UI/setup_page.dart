// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:studento/UI/random_gradient.dart';

Widget buildTopBackground(
        IconData icon, BuildContext context, topBackgroundDecoration) =>
    Column(
      children: <Widget>[
        Container(
          height: 200.0,
          width: MediaQuery.of(context).size.width,
          decoration: topBackgroundDecoration,
          child: Icon(
            icon,
            size: 50.0,
            color: Colors.white,
          ),
        ),
      ],
    );
Widget buildPageCaption(caption) => Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            caption!,
            textAlign: TextAlign.start,
            textScaleFactor: 1.5,
          ),
        ],
      ),
    );

/// A template Widget used for creating each of the setup pages. This Widget
/// creates a [Scaffold] with a configurable [FloatingActionButton], a body
/// that contains a gradient background at the top which has a centered Icon,
/// caption of [page] and a sub-[body].
// ignore: must_be_immutable
class SetupPage extends StatefulWidget {
  /// The Icon that's displayed in the center of the Container at the top of
  /// The Icon that's displayed in the center of the Container at the top of
  /// the [SetupPage].
  final IconData leadIcon;

  /// The caption Text that's right below the Icon and its Container, denoting
  /// what the [SetupPage] is about.
  final String? caption;

  /// The main body of the [SubjectPage], containing [Widget]s such as [TextField]s,
  /// [Slider]s, etc that allow the user to configure Studento.
  final Widget? body;

  /// The callback function to execute when the [FloatingActionButton] on this
  /// [SetupPage] is pressed.
  final VoidCallback? onFloatingButtonPressed;
  final VoidCallback? onFloatingButtonPressed2;
  bool issubject = false;

  SetupPage({
    required this.leadIcon,
    this.caption,
    this.body,
    this.onFloatingButtonPressed,
    required this.issubject,
    this.onFloatingButtonPressed2,
  });
  @override
  _SetupPageState createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  BoxDecoration topBackgroundDecoration =
      BoxDecoration(gradient: getRandomGradient());

  Widget buildNextButton() => Container(
        height: 50,
        width: 150,
        child: FloatingActionButton.extended(
          tooltip: 'NEXT',
          label: Row(
            children: <Widget>[
              Text("NEXT",
                  style: Theme.of(context).textTheme.subtitle1!.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w600)),
              Icon(
                Icons.arrow_forward,
                color: Colors.white,
              ),
            ],
          ),
          onPressed: widget.onFloatingButtonPressed,
          backgroundColor: Colors.blue, // Imperialish blue
          shape: StadiumBorder(),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: buildNextButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          buildTopBackground(widget.leadIcon, context, topBackgroundDecoration),
          buildPageCaption(widget.caption),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: widget.body,
            ),
          ),
        ],
      ),
    );
  }
}
