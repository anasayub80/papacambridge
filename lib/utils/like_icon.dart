// // import 'package:flutter/material.dart';

// // class LikeIcon extends StatefulWidget {
// //   @override
// //   State<LikeIcon> createState() => _LikeIconState();
// // }

// // class _LikeIconState extends State<LikeIcon>
// //     with SingleTickerProviderStateMixin {
// //   AnimationController? _animationController;
// //   // Animation<Color>? _colorAnimation;
// //   Animation<double>? _animation;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _animationController = AnimationController(
// //       vsync: this,
// //       duration: Duration(seconds: 1),
// //     );
// //     _animation =
// //         CurvedAnimation(parent: _animationController!, curve: Curves.easeIn);
// //     Future.delayed(
// //       Duration.zero,
// //       () {
// //         _toggleFavorite();
// //       },
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     _animationController!.dispose();
// //     super.dispose();
// //   }

// //   void _toggleFavorite() {
// //     if (_animationController!.isCompleted) {
// //       _animationController!.reverse();
// //     } else {
// //       _animationController!.forward();
// //     }
// //   }

// //   Future<Future> tempFuture() async {
// //     return Future<dynamic>.delayed(Duration(seconds: 6));
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Center(
// //       child: FutureBuilder(
// //         future: tempFuture(),
// //         builder: (context, snapshot) =>
// //             snapshot.connectionState != ConnectionState.done
// //                 ? FadeTransition(
// //                     opacity: _animation!,
// //                     child: IconButton(
// //                       icon: Icon(Icons.favorite),
// //                       onPressed: _toggleFavorite,
// //                       color: Colors.red,
// //                       iconSize: 175,
// //                     ),
// //                   )
// //                 : SizedBox(),
// //       ),
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';

// class FavoriteButton extends StatefulWidget {
//   @override
//   _FavoriteButtonState createState() => _FavoriteButtonState();
// }

// class _FavoriteButtonState extends State<FavoriteButton>
//     with SingleTickerProviderStateMixin {
//   AnimationController? _animationController;
//   Animation<double>? _sizeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 300),
//     );
//     _sizeAnimation = Tween<double>(begin: 50, end: 70).animate(
//       CurvedAnimation(
//         parent: _animationController!,
//         curve: Curves.easeInOut,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _animationController!.dispose();
//     super.dispose();
//   }

//   void _toggleFavorite() {
//     if (_animationController!.isCompleted) {
//       _animationController!.reverse();
//     } else {
//       _animationController!.forward();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedContainer(
//       height: _sizeAnimation.value,
//       width: _sizeAnimation.value,
//       duration: Duration(milliseconds: 300),
//       child: IconButton(
//         icon: Icon(Icons.favorite),
//         onPressed: _toggleFavorite,
//         color: Colors.red,
//       ),
//     );
//   }
// }
import 'dart:developer';

import 'package:flutter/material.dart';

class CustomAlertDialog extends StatefulWidget {
  const CustomAlertDialog({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CustomAlertDialogState createState() => _CustomAlertDialogState();
}

class _CustomAlertDialogState extends State<CustomAlertDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  // late Animation<double> animation;
  Animation<double>? _sizeAnimation;

  @override
  void initState() {
    super.initState();
    _initFadeAnimation();
  }

  _initFadeAnimation() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _sizeAnimation = Tween<double>(begin: 0.5, end: 0.8).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.bounceIn,
      ),
    );
    // animation = Tween<double>(begin: 0, end: 1.0).animate(controller);
    // animation =
    //     CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    _sizeAnimation!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        log('complete');
        _sizeAnimation =
            CurvedAnimation(parent: controller, curve: Curves.bounceOut);
      }
    });
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(
      Duration(seconds: 1),
      () {
        Navigator.pop(context);
      },
    );
    return ScaleTransition(
      scale: _sizeAnimation!,
      child: const AlertDialog(
        backgroundColor: Colors.transparent,
        title: Center(
          child: Icon(
            Icons.favorite,
            color: Colors.red,
            size: 175,
          ),
        ),
      ),
    );
  }
}
