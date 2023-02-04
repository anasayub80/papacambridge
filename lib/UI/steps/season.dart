import 'dart:developer';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:studento/CAIE/past_papers_details_select.dart';
import 'package:studento/utils/theme_provider.dart';

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
        fontSize: 14.0,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Provider.of<ThemeSettings>(context, listen: false).currentTheme ==
              ThemeMode.dark
          ? MyTheme().darkTheme
          : MyTheme().lightTheme,
      child: Container(
        child: Column(
          children: <Widget>[
            headerText,
            SeasonTile(Season.spring),
            SeasonTile(Season.summer),
            SeasonTile(Season.winter),
          ],
        ),
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
          icon = Icons.sunny;
          break;
        case Season.spring:
          icon = Icons.spa;
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
          color: (isSeasonSelected)
              ? Colors.blue
              : Theme.of(context).textTheme.bodyLarge!.color,
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
          color: (isSeasonSelected)
              ? Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .color!
                          .computeLuminance() <
                      0.5
                  ? Colors.white
                  : Colors.black
              : Theme.of(context).textTheme.bodyLarge!.color,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        returnSubtitle(widget.season),
        // (season == Season.summer)
        //     ? "May/June"
        //     : Season.spring
        //         ? "March"
        //         : "October/November",
        style: TextStyle(
          color: (isSeasonSelected)
              ? Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .color!
                          .computeLuminance() <
                      0.5
                  ? Colors.white
                  : Colors.black
              : Theme.of(context).textTheme.bodyLarge!.color,
          fontSize: 12,
        ),
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
          PaperDetailsSelectionPage.of(context)!.selectedPdf = null;
          PaperDetailsSelectionPage.of(context)!.isLoading = true;
          showPapers = false;
        });
      },
      child: Card(
        elevation: (isSeasonSelected) ? 3.0 : 6.0,
        margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        shape: borderDeco,
        child: Container(
          decoration: ShapeDecoration(
            color: (isSeasonSelected)
                ? Theme.of(context).iconTheme.color
                : Colors.transparent,
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
