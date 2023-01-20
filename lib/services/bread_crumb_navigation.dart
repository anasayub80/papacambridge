import 'package:flutter/material.dart';
import 'navigate_observe.dart';

class BreadCrumbNavigator extends StatelessWidget {
  final List<Route> currentRouteStack;

  BreadCrumbNavigator() : currentRouteStack = routeStack.toList();
  String prettifySubjectName(String subjectName) {
    return subjectName.replaceFirst("\r\n", "");
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: ListView(
        shrinkWrap: true,
        children: List<Widget>.from(currentRouteStack
            .asMap()
            .map(
              (index, value) => MapEntry(
                  index,
                  GestureDetector(
                      onTap: () {
                        print('back call');
                        Navigator.popUntil(context,
                            (route) => route == currentRouteStack[index]);
                      },
                      child: currentRouteStack[index].settings.name == null
                          ? SizedBox.shrink()
                          : _BreadButton(
                              prettifySubjectName(
                                  currentRouteStack[index].settings.name!),
                              index == 0))),
            )
            .values),
        // mainAxisSize: MainAxisSize.max,
        // innerDistance: -16,
        scrollDirection: Axis.horizontal,
      ),
      width: MediaQuery.of(context).size.width,
      height: 30,
    );
  }
}

class _BreadButton extends StatelessWidget {
  final String text;
  final bool isFirstButton;

  const _BreadButton(this.text, this.isFirstButton);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _TriangleClipper(!isFirstButton),
      child: Container(
        color: Colors.pink,
        child: Padding(
          padding: EdgeInsetsDirectional.only(
              start: isFirstButton ? 8 : 20, end: 28, top: 5, bottom: 8),
          child: Center(
            child: Text(
              text,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }
}

class _TriangleClipper extends CustomClipper<Path> {
  final bool twoSideClip;

  _TriangleClipper(this.twoSideClip);

  @override
  Path getClip(Size size) {
    final Path path = Path();
    if (twoSideClip) {
      path.moveTo(20, 0.0);
      path.lineTo(0.0, size.height / 2);
      path.lineTo(20, size.height);
    } else {
      path.lineTo(0, size.height);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(size.width - 20, size.height / 2);
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
