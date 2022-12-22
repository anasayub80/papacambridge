import 'dart:math';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'package:studento/UI/loading_page.dart';
import 'package:studento/UI/random_gradient.dart';
import 'package:auto_size_text/auto_size_text.dart';

class RandomQuoteContainer extends StatefulWidget {
  @override
  RandomQuoteContainerState createState() => RandomQuoteContainerState();
}

class RandomQuoteContainerState extends State<RandomQuoteContainer> {
  List? quotesList;
  final gradientDeco = BoxDecoration(gradient: getRandomGradient());

  /// Read the quotes from the json file into [quotesList].
  void _getQuotes() async {
    String data = await rootBundle.loadString('assets/json/quotes.json');
    setState(() => quotesList = json.decode(data));
  }

  @override
  void initState() {
    _getQuotes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // While the quotes are being loaded, display a progress indicator.
    if (quotesList == null) return loadingPage();

    return _buildRandomQuoteWidget();
  }

  Widget _buildRandomQuoteWidget() {
    // Get a random quote and the corresponding author from the list.
    int randomIndex = Random().nextInt(quotesList!.length);
    final String? quote = quotesList![randomIndex]["Quote String"];
    final String? quoteAuthor = quotesList![randomIndex]["Quote Author"];

    const TextStyle quoteStyle = TextStyle(
      fontWeight: FontWeight.w800,
      letterSpacing: 0.8,
      color: Colors.white,
    );

    const TextStyle quoteAuthorStyle = TextStyle(
      fontFamily: 'Playfair Display',
      fontWeight: FontWeight.w900,
      fontStyle: FontStyle.italic,
      color: Colors.white,
    );

    Widget quoteTextContainer() => Expanded(
          child: Center(
            child: AutoSizeText(
              "“ $quote",
              presetFontSizes: [22, 18, 16, 14],
              minFontSize: 14,
              style: quoteStyle,
              textAlign: TextAlign.center,
            ),
          ),
        );

    Widget authorContainer() => Container(
          alignment: FractionalOffset.bottomRight,
          padding: EdgeInsets.all(7.0),
          child: Text(
            ('- $quoteAuthor'),
            textAlign: TextAlign.end,
            style: quoteAuthorStyle,
          ),
        );

    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Container(
        height: 200,
        decoration: gradientDeco,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(),
            quoteTextContainer(),
            Align(
              alignment: Alignment.bottomCenter,
              child: authorContainer(),
            ),
          ],
        ),
      ),
    );
  }
}
