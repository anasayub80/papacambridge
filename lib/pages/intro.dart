import 'package:flutter/material.dart';
import 'package:liquid_swipe/liquid_swipe.dart';

import 'setup.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  Widget buildSubtitle(subtitle, Color color) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(color: color, fontSize: 16),
        ),
      );
  Widget buildTitle(title, Color color) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          title,
          textScaleFactor: 1.5,
          style: TextStyle(
              color: color, fontWeight: FontWeight.w600, fontSize: 20),
        ),
      );

  LiquidController? liquidController;

  @override
  void initState() {
    super.initState();
    liquidController = LiquidController();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/illustrations/notebook.png'),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              // width: MediaQuery.of(context).size.width * 0.45,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  buildTitle("Past Papers", Colors.black),
                  buildSubtitle(
                      'Access past papers anytime, anywhere, just a couple taps away.',
                      Colors.black),
                ],
              ),
            )
          ],
        ),
        color: Colors.white,
      ),
      Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/illustrations/syllabus.png'),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              // width: MediaQuery.of(context).size.width * 0.45,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  buildTitle("Syllabuss", Colors.white),
                  buildSubtitle(
                      "Know what you don't know, so that you're never surprised on the day of exams.",
                      Colors.white),
                ],
              ),
            )
          ],
        ),
        color: Color(0xffDB3869),
      ),
      // Container(
      //   color: Color(0xff4D96FF),
      // ),
      Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/illustrations/todo.png'),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              // width: MediaQuery.of(context).size.width * 0.45,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  buildTitle("Todo List", Colors.white),
                  buildSubtitle(
                      "A virtual todo list that brings tracking homework and tasks to the next level.",
                      Colors.white),
                ],
              ),
            )
          ],
        ),
        color: Color(0xff4D96FF),
      ),
      Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/illustrations/schedule.png'),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              // width: MediaQuery.of(context).size.width * 0.45,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  buildTitle("Schedule", Colors.white),
                  buildSubtitle(
                      "Be productive and keep track of classes by using PapaCambridge schedule feature",
                      Colors.white),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) => Setup()));
                    },
                    child: Text('Get Started'),
                  )
                ],
              ),
            )
          ],
        ),
        color: Color(0xff14114D),
      ),
    ];
    return Scaffold(
        body: LiquidSwipe(
      pages: pages,

      liquidController: liquidController,
      onPageChangeCallback: (activePageIndex) {
        setState(() {});
        print(activePageIndex.toString());
      },
      // enableLoop: true,
      waveType: WaveType.liquidReveal,
      positionSlideIcon: 0.8,
      ignoreUserGestureWhileAnimating: true,
      slideIconWidget: Icon(
        Icons.keyboard_arrow_right,
        size: 36,
        color: liquidController!.currentPage >= 3 ? Colors.black : Colors.white,
      ),
      fullTransitionValue: 600,
      enableSideReveal: liquidController!.currentPage >= 2 ? false : true,
    ));
  }
}
