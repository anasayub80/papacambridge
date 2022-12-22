/// Based on Original Flutter Code, which was written by the Flutter project
/// authors. Please see the AUTHORS file of the Flutter project for details.
/// All rights reserved. Use of this source code is governed by a BSD-style
/// license that can be found in the Flutter project's LICENSE file.
import 'dart:math';

import 'package:flutter/material.dart';

import 'setup.dart';
import 'package:studento/UI/gradient_background.dart';

/// Template for each page which showcases the features of the studento.
class IntroPage extends StatefulWidget {
  @override
  State createState() => IntroPageState();
}

class IntroPageState extends State<IntroPage> {
  final _controller = PageController();

  static const _kDuration = Duration(milliseconds: 300);

  static const _kCurve = Curves.ease;

  final _kArrowColor = Colors.black.withOpacity(0.8);

  final List<Widget> _pages = <Widget>[
    IntroPageModel(
      title: "Past Papers",
      subtitle:
          "Access past papers anytime, anywhere, just a couple taps away.",
      mainIcon: Icons.library_books,
    ),
    IntroPageModel(
      title: "Syllabus",
      subtitle:
          "Know what you don't know, so that you're never surprised on the day of exams.",
      mainIcon: Icons.subtitles,
    ),
    IntroPageModel(
      title: "Todo List",
      subtitle:
          "A virtual todo list that brings tracking homework and tasks to the next level.",
      mainIcon: Icons.assignment,
    ),
    IntroPageModel(
      title: "Schedule",
      subtitle:
          "Be productive and keep track of classes by using Papa Cambridge schedule feature",
      mainIcon: Icons.table_chart,
    ),
  ];

  Widget scrollableIntroPageBuilder() => PageView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        controller: _controller,
        itemBuilder: (BuildContext context, int index) {
          return _pages[index % _pages.length];
        },
      );

  Widget buildGetStartedButton() => Positioned(
        bottom: 40.0,
        left: 0.0,
        right: 0.0,
        child: Center(
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
              textStyle: TextStyle(
                color: Colors.white,
              ),
            ),
            child: Text(
              "GET STARTED!",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => Setup()),
            ),
          ),
        ),
      );

  Widget buildPageIndicatorButton() => Positioned(
        bottom: 105.0,
        left: 0.0,
        right: 0.0,
        child: Center(
          child: DotsIndicator(
            controller: _controller,
            itemCount: _pages.length,
            onPageSelected: (int page) {
              _controller.animateToPage(
                page,
                duration: _kDuration,
                curve: _kCurve,
              );
            },
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: GradientBackground.getGradient(Colors.blueAccent),
        ),
        child: IconTheme(
          data: IconThemeData(color: _kArrowColor),
          child: Stack(
            children: <Widget>[
              scrollableIntroPageBuilder(),
              buildPageIndicatorButton(),
              buildGetStartedButton(),
            ],
          ),
        ),
      ),
    );
  }
}

/// An indicator showing the currently selected page of a PageController
class DotsIndicator extends AnimatedWidget {
  const DotsIndicator({
    required this.controller,
    this.itemCount,
    this.onPageSelected,
    this.color = Colors.white,
  }) : super(listenable: controller);

  /// The PageController that this DotsIndicator is representing.
  final PageController controller;

  /// The number of items managed by the PageController
  final int? itemCount;

  /// Called when a dot is tapped
  final ValueChanged<int>? onPageSelected;

  /// The color of the dots.
  ///
  /// Defaults to `Colors.white`.
  final Color color;

  // The base size of the dots
  static const double _kDotSize = 8.0;

  // The increase in the size of the selected dot
  static const double _kMaxZoom = 2.0;

  // The distance between the center of each dot
  static const double _kDotSpacing = 25.0;

  Widget _buildDot(int index) {
    double selectedness = Curves.easeOut.transform(
      max(
        0.0,
        1.0 -
            (((controller.page ?? controller.initialPage) % 4) - index)
                .abs(), // The 4 (length of _pages) here is a quick fix
      ),
    );
    double zoom = 1.0 + (_kMaxZoom - 1.0) * selectedness;
    return Container(
      width: _kDotSpacing,
      child: Center(
        child: Material(
          color: color,
          type: MaterialType.circle,
          child: Container(
            width: _kDotSize * zoom,
            height: _kDotSize * zoom,
            child: InkWell(
              onTap: () => onPageSelected!(index),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(itemCount!, _buildDot),
    );
  }
}

class IntroPageModel extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData mainIcon;

  const IntroPageModel(
      {required this.title, required this.subtitle, required this.mainIcon});

  Widget buildTitle() => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          title,
          textScaleFactor: 2.0,
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 20),
        ),
      );

  Widget buildMainIcon() => Padding(
        padding: const EdgeInsets.all(15.0),
        child: Icon(mainIcon, size: 100.0, color: Colors.white),
      );

  Widget buildSubtitle() => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        buildTitle(),
        // Padding(padding: EdgeInsets.all(20.0)),
        buildMainIcon(),
        // Padding(padding: EdgeInsets.all(20.0)),
        buildSubtitle(),
      ],
    );
  }
}
