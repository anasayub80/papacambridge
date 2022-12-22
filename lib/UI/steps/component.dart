import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'package:studento/pages/past_papers_details_select.dart';
import 'package:studento/model/MainFolder.dart';
import 'package:http/http.dart' as http;

class ComponentStep extends StatefulWidget {
  // final Subject subject;
  final session;
  final year;
  final MainFolder subject;
  const ComponentStep(this.subject, {this.session, this.year});

  @override
  // ignore: library_private_types_in_public_api
  _ComponentStepState createState() => _ComponentStepState();
}

class _ComponentStepState extends State<ComponentStep> {
  List? components;

  @override
  void initState() {
    loadComponents();
    super.initState();
  }

  /// Loads the components of the selected subjects from json file.
  Future<void> loadComponents() async {
    print(widget.year);
    print('tttttttttttttttttttttttttttttttt');
    http.Response res = await http.get(Uri.parse(
        'https://myaccount.papacambridge.com/api.php?main_folder=${widget.subject.parent}&id=${widget.subject.id}&year=${widget.year}'));
    print(res.body);
    var assetPath = 'assets/json/components.json';
    var fileData = await rootBundle.loadString(assetPath);
    // ignore: no_leading_underscores_for_local_identifiers
    var _decodedData = json.decode(fileData);

    setState(() => components = _decodedData[widget.subject.folderCode]);
  }

  @override
  Widget build(BuildContext context) {
    if (components == null)
      return Container(child: CircularProgressIndicator());

    Widget headerText = Padding(
      padding: EdgeInsets.only(
        top: 15.0,
        bottom: 30.0,
      ),
      child: Text(
        "Pick a number, any number... the component number!",
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 20.0,
        ),
      ),
    );

    return Container(
      child: Column(
        children: <Widget>[
          headerText,
          GridView.builder(
            itemCount: components!.length,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(vertical: 30.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 2.5,
              crossAxisCount: 3,
              mainAxisSpacing: 10.0,
            ),
            shrinkWrap: true,
            itemBuilder: (_, i) => ComponentWidget(components![i]),
          ),
        ],
      ),
    );
  }
}

class ComponentWidget extends StatelessWidget {
  const ComponentWidget(this.component);
  final int component;

  @override
  Widget build(BuildContext context) {
    bool isComponentSelected =
        (PaperDetailsSelectionPage.of(context)!.selectedComponent == component);

    final shapeDeco = ShapeDecoration(
      color: (isComponentSelected) ? Colors.black87 : Colors.transparent,
      shape: StadiumBorder(),
    );

    final textStyle = TextStyle(
      fontSize: 20.0,
      fontWeight: FontWeight.w600,
      color: (isComponentSelected) ? Colors.blue : Colors.black,
    );

    return SizedBox(
      height: 40.0,
      width: 100.0,
      child: InkWell(
        onTap: () => PaperDetailsSelectionPage.of(context)!.selectedComponent =
            component,
        child: Card(
          elevation: isComponentSelected ? 2 : 4,
          shape: StadiumBorder(),
          child: Container(
            decoration: shapeDeco,
            child: Center(
              child: Text(
                '$component',
                style: textStyle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
