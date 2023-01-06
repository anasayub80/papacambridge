// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:studento/pages/past_papers_details_select.dart';
import 'package:studento/model/MainFolder.dart';

class YearStep extends StatefulWidget {
  final MainFolder subject;
  final int? startDate;
  final int? endDate;
  // final Subject subject;

  const YearStep(this.subject, {this.startDate, this.endDate, Key? key})
      : super(key: key);
  @override
  _YearStepState createState() => _YearStepState();
}

class _YearStepState extends State<YearStep> {
  Widget headerText = Padding(
    padding: EdgeInsets.only(
      // left: 15.0,
      top: 15.0,
      bottom: 30.0,
    ),
    child: Text(
      "Choose the year of the paper! How old?",
      style: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 20.0,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var body = theme.textTheme.bodyText2!.copyWith(color: Colors.white);
    var textTheme = theme.textTheme.copyWith(bodyText2: body);
    theme = theme.copyWith(textTheme: textTheme);

    var divider = BorderSide(
      style: BorderStyle.solid,
      width: 0.5,
      color: Colors.white54,
    );
    Decoration decoration = BoxDecoration(
      border: Border(
        top: divider,
        bottom: divider,
      ),
    );

    return Container(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          headerText,
          InkWell(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Swipe to choose another year."),
              ),
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              color: Colors.black87,
              elevation: 6.0,
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(vertical: 30.0, horizontal: 15.0),
                child: Theme(
                  data: theme,
                  child: NumberPicker(
                    decoration: decoration,
                    minValue: widget.startDate!, // widget.subject.startYear,
                    maxValue: widget.endDate!, //widget.subject.endYear,
                    infiniteLoop: true,
                    onChanged: setYear,
                    value: PaperDetailsSelectionPage.of(context)!.selectedYear!,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void setYear(var year) {
    setState(() => PaperDetailsSelectionPage.of(context)!.selectedYear = year);
  }
}
