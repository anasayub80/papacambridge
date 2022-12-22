import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studento/UI/loading_page.dart';

// ignore: must_be_immutable
class ShowSelectedLevel extends StatelessWidget {
  ShowSelectedLevel({super.key});
  List? level;
  initLevel() async {
    log('***level init***');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    level = prefs.getStringList('level');
    print(level.toString());
    return level;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: initLevel(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator());

          default:
            if (snapshot.hasError) {
              return Text('Error');
            } else if (snapshot.data != null) {
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 5.0,
                  mainAxisSpacing: 5.0,
                ),
                shrinkWrap: true,
                itemCount: level!.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: (){
                       Navigator.pop(context,level![index]);
                      },
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Image.asset(
                              'assets/icons/folder.png',
                              height: 45,
                              width: 45,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(level![index]),
                            )
                          ],
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Theme.of(context).cardColor),
                      ),
                    ),
                  );
                },
              );
            } else {
              return loadingPage();
            }
        }
      },
    );
  }
}
