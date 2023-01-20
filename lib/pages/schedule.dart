// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, unnecessary_null_comparison

import 'dart:async';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:studento/UI/edit_class.dart';
import 'package:studento/UI/random_gradient.dart';
import 'package:studento/UI/confirm_delete_dialog.dart';
import 'package:studento/UI/studento_app_bar.dart';
import 'package:studento/model/class_item.dart';
import 'package:studento/db/class_db.dart';

class SchedulePage extends StatefulWidget {
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage>
    with SingleTickerProviderStateMixin {
  static List<Widget> tabs = <Widget>[
    Tab(text: "MON"),
    Tab(text: "TUE"),
    Tab(text: "WED"),
    Tab(text: "THU"),
    Tab(text: "FRI")
  ];

  var db = ClassDB();

  late int initialTabIndex;
  TabController? _tabController;

  /// Whether Classes have been loaded from the DB.
  bool isLoaded = false;

  // Custom getters/setters since I need the UI to update every time this list
  // changes anyway.
  Map<int, List<ClassItem>> _classes = {};
  Map<int, List<ClassItem>> get classes => _classes;
  set classes(Map<int, List<ClassItem>> x) => setState(() => _classes = x);

  /// The selected weekday. Values from 1 to 5 inclusive. Updated automagically
  /// when [TabController]'s index is updated.
  int? selectedDay;

  // Holds all the ListView widgets for all the bads.
  late List<Widget> classListViews;

  @override
  void initState() {
    super.initState();
    initTabController();
    // ignore: avoid_types_as_parameter_names
    getClassesFromDB().then((bool) => setState(() => isLoaded = true));
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  void initTabController() {
    // When it's the week-end, set to Monday.
    bool isNotWeekEnd = DateTime.now().weekday < 6;
    initialTabIndex = (isNotWeekEnd)
        ? (DateTime.now().weekday - 1) // minus 1 because index starts at 0
        : 0;

    selectedDay = initialTabIndex + 1;
    _tabController = TabController(
      vsync: this,
      length: tabs.length,
      initialIndex: initialTabIndex,
    );

    _tabController!.addListener(_handleTabSelection);
  }

  Future<void> getClassesFromDB() async {
    // ignore: no_leading_underscores_for_local_identifiers
    Map<int, List<ClassItem>> _temp = <int, List<ClassItem>>{};

    for (var day = 1; day <= tabs.length; day++) {
      _temp[day] = await db.getClasses(weekDay: day) ?? [];
    }

    classes = _temp;
  }

  void _handleTabSelection() {
    setState(() => selectedDay = _tabController!.index + 1);
  }

  void initListViews() {
    classListViews = List<Widget>.filled(5, SizedBox.shrink(), growable: false);

    for (var day = 1; day <= tabs.length; day++) {
      var widget;

      if (isLoaded) {
        bool isAnyClassAddedToThisDay = classes[day]!.isNotEmpty;

        if (isAnyClassAddedToThisDay) {
          widget = ListView.separated(
            padding: EdgeInsets.only(top: 10, bottom: 50),
            itemCount: classes[day]!.length,
            itemBuilder: (_, i) => buildClassTile(_, i, day),
            separatorBuilder: (_, i) => Divider(height: 5.0),
          );
        } else {
          widget = Column(
            children: <Widget>[
              Spacer(flex: 1),
              Image.asset("assets/illustrations/no-classes.png"),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Text("New day, blank canvas.\nYours to fill.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    )),
              ),
              Spacer(flex: 2),
            ],
          );
        }
      } else {
        widget = Center(child: CircularProgressIndicator());
      }

      classListViews[day - 1] = widget;
    }
  }

  @override
  Widget build(BuildContext context) {
    initListViews();
    return Scaffold(
      appBar: buildAppBar(),
      body: TabBarView(
        controller: _tabController,
        children: classListViews,
      ),
      floatingActionButton: buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget buildFAB() => FloatingActionButton.extended(
        label: Text("Add Class"),
        icon: Icon(Icons.add),
        onPressed: addClass,
      );

  PreferredSizeWidget buildAppBar() => StudentoAppBar(
        context: context,
        title: "Schedule",
        bottom: TabBar(
          tabs: tabs,
          controller: _tabController,
          labelColor: Theme.of(context).textTheme.bodyText1!.color,
          labelStyle: selectedLabelStyle,
          unselectedLabelStyle: unselectedLabelStyle,
        ),
      );

  void addClass() async {
    ClassItem? newClass = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditClass(weekDay: selectedDay),
      ),
    );

    if (newClass != null) {
      int savedClassId = await db.saveClass(newClass);
      ClassItem? savedClass = await db.getClass(savedClassId);

      setState(() => classes[selectedDay]!.add(savedClass!));
    }
  }

  Future<void> editClass(BuildContext context, ClassItem itemToBeEdited) async {
    Navigator.of(context).pop(); // Close bottom sheet.

    // Get the edited class data from Edit Form.
    ClassItem editedClass = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EditClass(existingClass: itemToBeEdited),
        )) as ClassItem;

    if (editedClass != null) {
      db.updateClass(editedClass);

      classes[selectedDay]!
        ..removeWhere((ClassItem item) => item.id == editedClass.id)
        ..add((editedClass));
    }
  }

  Future<void> deleteClass(
      BuildContext context, ClassItem? classToBeDeleted) async {
    Navigator.of(context).pop(); // close bottom sheet.

    bool shouldDelete = await showConfirmationDialog(context);
    if (shouldDelete) {
      db.deleteClass(classToBeDeleted!.id!);
      setState(() {
        classes[selectedDay!]!
            .removeWhere((ClassItem? item) => item!.id == classToBeDeleted.id);
      });
    }
  }

  showConfirmationDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ConfirmDeleteDialog(
        bodyMsg: "Are you sure you want to delete this class?",
        redButtonLabel: "Delete",
        altButtonLabel: "Keep",
        onRedPressed: () => Navigator.pop(context, true),
        onAltPressed: () => Navigator.pop(context, false),
      ),
    );
  }

  final selectedLabelStyle = TextStyle(
    color: Colors.green,
    fontWeight: FontWeight.w700,
    fontFamily: "Montserrat",
  );

  final unselectedLabelStyle = TextStyle(
    color: Colors.amber,
    fontWeight: FontWeight.w500,
    fontFamily: "Montserrat",
  );

  Widget buildClassTile(BuildContext context, int i, int day) {
    var classItem = classes[day]![i];
    return ClassTile(
      classNo: i,
      classItem: classItem,
      onEdit: () => editClass(context, classItem),
      onDelete: () => deleteClass(context, classItem),
    );
  }
}

// ignore: must_be_immutable
class ClassTile extends StatelessWidget {
  final int classNo;
  final ClassItem classItem;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  ClassTile({
    required this.classNo,
    required this.classItem,
    required this.onEdit,
    required this.onDelete,
  });

  /// Whether the class is currently ongoing.
  bool isOngoing = false;

  /// Formatter for time.
  var formatter = DateFormat('jm'); // Time and time period format. E.g. 7:30 AM

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 5.0),
      child: ListTile(
        onTap: () => showOptions(context),
        contentPadding: EdgeInsets.only(
          bottom: 5.0,
          top: 10.0,
          right: 10.0,
          left: 0.0,
        ),
        leading: periodNoIndicator(classNo),
        title: subjectName(classItem.subject!, isOngoing, context),
        trailing: timeIndicator(context),
        subtitle: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 5),
            locationAndTeacher(
              location: classItem.location ?? '',
              teacher: classItem.teacher ?? '',
              context: context,
            ),
            SizedBox(height: 7),
            // * Row(children: todoItems(noOfItems: 3, color: color))
          ],
        ),
      ),
    );
  }

  /// A circle with a number within indicating the class number.

  Widget periodNoIndicator(int classNo) {
    final circleDeco = BoxDecoration(
      gradient: getRandomGradient(),
      shape: BoxShape.rectangle,
      borderRadius: BorderRadius.circular(5.0),
    );

    return Container(
      margin: EdgeInsets.only(left: 5),
      decoration: circleDeco,
      height: 30.0,
      width: 30.0,
      child: Center(
        child: Text(
          (classNo + 1).toString(),
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
        ),
      ),
    );
  }

  subjectName(String name, bool isOngoing, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: Text(
        name,
        style: TextStyle(
            color: isOngoing
                ? Theme.of(context).textTheme.bodyText1!.color
                : Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .color!
                    .withOpacity(0.6),
            fontWeight: isOngoing ? FontWeight.w600 : FontWeight.w500,
            fontSize: 20.0),
      ),
    );
  }

  /// Display the location/teacher if set.

  Widget locationAndTeacher(
      {String? teacher, String? location, required BuildContext context}) {
    String? text = "";
    bool isTeacherAndLocationSet = teacher != null && location != null;
    bool isEitherSet = teacher != null || location != null;

    if (isTeacherAndLocationSet) {
      text = "$teacher - $location";
    } else if (isEitherSet) {
      text = teacher ?? location;
    }

    return Text(
      text!,
      style: TextStyle(
        fontSize: 15,
        color: Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.8),
      ),
    );
  }

  /// If class is ongoing or starts/ends soon, then the ongoing status or the time
  /// left is indicated. Else, start/end times are shown.

  Widget timeIndicator(BuildContext context) {
    String startTime = formatter.format(classItem.startTime!);
    String endTime = formatter.format(classItem.endTime!);
    String indication = "$startTime-$endTime";

    // ignore: no_leading_underscores_for_local_identifiers
    var _now = DateTime.now();
    var timeNow = DateTime(1, 1, 1, _now.hour, _now.minute);

    Duration diffBetweenNowAndStart = classItem.startTime!.difference(timeNow);
    Duration diffBetweenNowAndEnd = classItem.endTime!.difference(timeNow);

    bool isSoon(Duration dur) => !dur.isNegative && dur.inMinutes <= 20;

    var classStartsSoon = isSoon(diffBetweenNowAndStart);
    var classEndsSoon = isSoon(diffBetweenNowAndEnd);

    isOngoing = timeNow.isAfter(classItem.startTime!) &&
        timeNow.isBefore(classItem.endTime!);
    if (isOngoing) {
      if (classEndsSoon) {
        indication = "Ends in ${diffBetweenNowAndEnd.inMinutes} mins";
      } else {
        indication = "Ongoing";
      }
    } else if (classStartsSoon) {
      indication = "Starts in ${diffBetweenNowAndStart.inMinutes} mins";
    }

    /// Emphasize the indication when the class starts soon/is ongoing/ends soon.
    bool isTimeHighlighted = classStartsSoon || isOngoing || classEndsSoon;

    return Padding(
      padding: EdgeInsets.only(top: 30.0),
      child: Text(
        indication,
        style: (isTimeHighlighted)
            ? TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              )
            : TextStyle(color: Theme.of(context).textTheme.bodyText1!.color),
      ),
    );
  }

  /// Opens a bottom sheet with the options to edit or delete the class.
  void showOptions(context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => BottomSheet(
        enableDrag: true,
        onClosing: () {},
        builder: (_) => Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Text("Edit Class"),
              onTap: onEdit,
              leading:
                  Icon(Icons.edit, color: Theme.of(context).iconTheme.color),
            ),
            ListTile(
              title: Text("Delete Class"),
              onTap: onDelete,
              leading: Icon(Icons.delete, color: Colors.red[300]),
            ),
          ],
        ),
      ),
    );
  }
  // ignore: todo
  // * TODO: Todos displayed in schedule to be added in next release.
}
