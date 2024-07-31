import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

List<Widget> parseHtml(String htmlString) {
  // Clean the HTML string
  String cleanedHtmlString = htmlString
      .replaceAll('&nbsp;', ' ')
      .replaceAll('\n', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  dom.Document document = html_parser.parse(cleanedHtmlString);
  List<Widget> widgets = [];
  List<dom.Element> elements = document.querySelectorAll('dt, dd');

  for (int i = 0; i < elements.length; i++) {
    dom.Element element = elements[i];
    if (element.localName == 'dt') {
      String label = element.text.replaceAll('/', '').trim(); // Trim whitespace and colons
      String value = '';

      if (i + 1 < elements.length && elements[i + 1].localName == 'dd') {
        dom.Element nextElement = elements[i + 1];
        value = nextElement.text.trim().replaceAll(RegExp(r'^,|,$'), ''); // Remove leading/trailing commas

        List<dom.Element> links = nextElement.querySelectorAll('a');
        if (links.isNotEmpty) {
          value = links.map((link) => link.text.trim()).join(', ');
        } else {
          value = nextElement.text.trim();
        }

        // Skip next element since it's already processed
        i++;
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Text(
            '$label $value',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  return widgets;
}

String getCurrentYearMonth() {
  final now = DateTime.now();
  final year = now.year.toString();
  final month = now.month.toString().padLeft(2, '0'); // Ensures the month is always two digits
  return '$year$month';
}