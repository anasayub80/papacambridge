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
          SeasonTile(Season.summer),
          SeasonTile(Season.winter)
        ],
      ),
    );
  }
}

class SeasonTile extends StatelessWidget {
  const SeasonTile(this.season);
  final Season season;

  @override
  Widget build(BuildContext context) {
    bool isSeasonSelected =
        PaperDetailsSelectionPage.of(context)!.selectedSeason == season;

    final seasonTile = ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.5),
      leading: Container(
        padding: EdgeInsets.only(right: 12.0),
        child: Icon(
          (season == Season.summer) ? Icons.wb_sunny : Icons.ac_unit,
          color: (isSeasonSelected) ? Colors.blue : Colors.grey,
        ),
      ),
      title: Text(
        (season == Season.summer) ? "Summer" : "Winter",
        style: TextStyle(
          color: (isSeasonSelected) ? Colors.white : Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        (season == Season.summer) ? "May/June" : "October/November",
        style:
            TextStyle(color: (isSeasonSelected) ? Colors.white : Colors.grey),
      ),
    );

    final borderDeco = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0),
      side: BorderSide(color: Colors.transparent, width: 0.0),
    );

    return InkWell(
      onTap: () => (setSeason(season, context)),
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
    // Future.delayed(Duration(milliseconds: 150),
    //     () => PaperDetailsSelectionPage.of(context).continueStep());
  }
}
