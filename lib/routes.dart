import 'package:studento/pages/ebook_page.dart';
import 'package:studento/pages/get_pro.dart';
import 'package:flutter/material.dart';
import 'package:studento/pages/home_page.dart';
import 'package:studento/pages/notes_page.dart';
import 'package:studento/pages/otherres_page.dart';
import 'package:studento/pages/past_papers.dart';
import 'package:studento/pages/syllabus.dart';
import 'package:studento/pages/settings.dart';
import 'package:studento/pages/schedule.dart';
import 'package:studento/pages/timetable_page.dart';
import 'package:studento/pages/todo_list.dart';

const String homeRoute = 'home_page';

const String pastPapersPageRoute = 'past_papers_page';
const String schedulePageRoute = 'schedule_page';
const String syllabusPageRoute = 'syllabus_page';
const String topicNotesPageRoute = 'topic_notes_page';
const String eventsPageRoute = 'events_page';
const String timetablePageRoute = 'timetable_page';
const String notesPageRoute = 'notes_page';
const String ebookPageRoute = 'ebook_page';
const String otherResRoute = 'otherres_page';

const String marksCalculatorPageRoute = 'marks_calculator_page';
const String getProPageRoute = 'get_pro_page';
const String settingsPageRoute = 'settings_page';
const String todoListPageRoute = 'todo_list_page';

Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
  homeRoute: (BuildContext context) => HomePage(),
  // pastPapersPageRoute: (BuildContext context) => PastPapersPage(),
  // otherResRoute: (BuildContext context) => OtherResources(),
  // notesPageRoute: (BuildContext context) => NotesPage(),
  // ebookPageRoute: (BuildContext context) => EBookPage(),
  // timetablePageRoute: (BuildContext context) => TimeTablePage(),
  schedulePageRoute: (BuildContext context) => SchedulePage(),
  // syllabusPageRoute: (BuildContext context) => SyllabusPage(),
  getProPageRoute: (BuildContext context) => GetProPage(),
  settingsPageRoute: (BuildContext context) => SettingsPage(),
  todoListPageRoute: (BuildContext context) => TodoListPage(),
};
