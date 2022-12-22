import 'package:flutter/material.dart';

class TaskProgressIndicator extends StatelessWidget {
  final Color color;
  final Color textColor;
  final progress;

  final _progressBarHeight = 3.0;

  const TaskProgressIndicator({
    required this.color,
    this.textColor = Colors.black,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (_, BoxConstraints constraints) {
              return Stack(children: [
                emptyBar(),
                completedBar(constraints),
              ]);
            },
          ),
        ),
        percentageProgressText(context),
      ],
    );
  }

  Widget completedBar(BoxConstraints constraints) => AnimatedContainer(
        height: _progressBarHeight,
        width: (progress / 100) * constraints.maxWidth,
        color: color,
        duration: Duration(milliseconds: 300),
      );

  Widget emptyBar() => Container(
        height: _progressBarHeight,
        color: Colors.grey.withOpacity(0.1),
      );

  Container percentageProgressText(BuildContext context) => Container(
        margin: EdgeInsets.only(left: 8.0),
        child: Text(
          "$progress%",
          style: TextStyle(color: textColor),
        ),
      );
}
