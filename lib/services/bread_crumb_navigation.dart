import 'package:flutter/material.dart';
import 'navigate_observe.dart';

class BreadCrumbNavigator extends StatefulWidget {
  final List<Route> currentRouteStack;

  BreadCrumbNavigator() : currentRouteStack = routeStack.toList();

  @override
  State<BreadCrumbNavigator> createState() => _BreadCrumbNavigatorState();
}

class _BreadCrumbNavigatorState extends State<BreadCrumbNavigator> {
  String prettifySubjectName(String subjectName) {
    var name = subjectName.replaceFirst("\r", "");
    return name.replaceFirst("\n", "");
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      addAutomaticKeepAlives: false,

      children: List<Widget>.from(widget.currentRouteStack
          .asMap()
          .map(
            (index, value) => MapEntry(
                index,
                GestureDetector(
                    onTap: () {
                      print('back call');
                      Navigator.popUntil(context,
                          (route) => route == widget.currentRouteStack[index]);
                    },
                    child: widget.currentRouteStack[index].settings.name == null
                        ? SizedBox.shrink()
                        : _BreadButton(
                            prettifySubjectName(
                                widget.currentRouteStack[index].settings.name!),
                            index == 0,
                            widget.currentRouteStack[index] ==
                                widget.currentRouteStack.last))),
          )
          .values),
      // mainAxisSize: MainAxisSize.max,
      // innerDistance: -16,
      scrollDirection: Axis.horizontal,
    );
  }
}

class _BreadButton extends StatelessWidget {
  final String text;
  final bool isFirstButton;
  final bool isLastButton;

  const _BreadButton(this.text, this.isFirstButton, this.isLastButton);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _TriangleClipper(!isFirstButton),
      child: Container(
        color: isLastButton ? Colors.grey : Colors.pink,
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
