import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:studento/pages/past_papers_details_select.dart';

class SeasonStep extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _SeasonStepState createState() => _SeasonStepState();
}

class _SeasonStepState extends State<SeasonStep> {
  final headerText = Padding(
    padding: EdgeInsets.only(
      left: 5.0,
      top: 15.0,
      bottom: 30.0,
    ),
    child: Text(
      "Choose your season! Hot or cold?",
      style: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 20.0,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          headerText,
          GestureDetector(
              onTap: (() {
                setState(() {
                  showPapers = false;
                });
                log('setState');
              }),
              child: SeasonTile(Season.spring)),
          SeasonTile(Season.summer),
          SeasonTile(Season.winter),
        ],
      ),
    );
  }
}

class SeasonTile extends StatefulWidget {
  const SeasonTile(this.season);
  final Season season;

  @override
  State<SeasonTile> createState() => _SeasonTileState();
}

class _SeasonTileState extends State<SeasonTile> {
  @override
  Widget build(BuildContext context) {
    bool isSeasonSelected =
        PaperDetailsSelectionPage.of(context)!.selectedSeason == widget.season;
    IconData returnIcons(selectedSeason) {
      IconData? icon;
      switch (selectedSeason) {
        case Season.summer:
          icon = Icons.wb_sunny;
          break;
        case Season.spring:
          icon = Icons.sunny_snowing;
          break;
        case Season.winter:
          icon = Icons.ac_unit;
          break;
        default:
      }

      return icon!;
    }

    String returnSeasonName(selectedSeason) {
      var find;
      switch (selectedSeason) {
        case Season.summer:
          find = 'Summer';
          break;
        case Season.spring:
          find = 'Spring';
          break;
        case Season.winter:
          find = 'Winter';
          break;
        default:
      }

      return find;
    }

    String returnSubtitle(selectedSeason) {
      var find;
      switch (selectedSeason) {
        case Season.summer:
          find = 'May/June';
          break;
        case Season.spring:
          find = 'March';
          break;
        case Season.winter:
          find = 'October/November';
          break;
        default:
      }

      return find;
    }

    final seasonTile = ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.5),
      leading: Container(
        padding: EdgeInsets.only(right: 12.0),
        child: Icon(
          returnIcons(widget.season),
          // (season == Season.summer)
          //     ? Icons.wb_sunny
          //     : Season.spring
          //         ? Icons.abc
          //         : Icons.ac_unit,
          color: (isSeasonSelected) ? Colors.blue : Colors.grey,
        ),
      ),
      title: Text(
        returnSeasonName(widget.season),
        // (season == Season.summer)
        //     ? "Summer"
        //     : Season.spring
        //         ? "Spring"
        //         : "Winter",
        style: TextStyle(
          color: (isSeasonSelected) ? Colors.white : Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        returnSubtitle(widget.season),
        // (season == Season.summer)
        //     ? "May/June"
        //     : Season.spring
        //         ? "March"
        //         : "October/November",
        style:
            TextStyle(color: (isSeasonSelected) ? Colors.white : Colors.grey),
      ),
    );

    final borderDeco = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0),
      side: BorderSide(color: Colors.transparent, width: 0.0),
    );

    return InkWell(
      onTap: () {
        setSeason(widget.season, context);
        setState(() {
          showPapers = false;
        });
      },
      child: Card(
        elevation: (isSeasonSelected) ? 3.0 : 6.0,
        margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        shape: borderDeco,
        child: Container(
          decoration: ShapeDecoration(
            color: (isSeasonSelected) ? Colors.black87 : Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              side: BorderSide(
                color: Colors.transparent,
                width: 0.0,
              ),
            ),
          ),
          child: seasonTile,
        ),
      ),
    );
  }

  void setSeason(Season season, BuildContext context) {
    PaperDetailsSelectionPage.of(context)!.selectedSeason = season;
    log('season change called');
    // Future.delayed(Duration(milliseconds: 150),
    //     () => PaperDetailsSelectionPage.of(context).continueStep());
  }
}
