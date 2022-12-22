// ignore_for_file: library_private_types_in_public_api, unnecessary_null_comparison, no_leading_underscores_for_local_identifiers, use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:studento/UI/confirm_delete_dialog.dart';
import 'package:studento/model/class_item.dart';

class EditClass extends StatefulWidget {
  /// When editing an existing [ClassItem], the [ClassItem]
  /// passed here. [null] when this page is being used to add a new class.
  final ClassItem? existingClass;

  /// The weekday to which the [ClassItem] being created/edited belongs to.
  final int? weekDay;

  const EditClass({this.existingClass, this.weekDay});

  @override
  _EditClassState createState() => _EditClassState();
}

class _EditClassState extends State<EditClass> {
  GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey();

  /// Whether we're editing an existing class, or adding a new class.
  bool isEditing = false;

  TextEditingController _subjectTextController = TextEditingController();
  TextEditingController _locationTextController = TextEditingController();
  TextEditingController _teacherTextController = TextEditingController();

  static final _initialTime = DateTime(
    1,
    1,
    1,
    DateTime.now().hour,
    DateTime.now().minute,
  );

  /// The start time of the class.
  DateTime startTime = _initialTime;

  /// The end time of the class.
  DateTime endTime = _initialTime;

  @override
  void initState() {
    super.initState();
    isEditing = (widget.existingClass != null);

    if (isEditing) {
      initVarsWithInitialData();
    }
  }

  /// Initialise controllers/tiles with the data from the [ExistingClass].
  void initVarsWithInitialData() {
    var _class = widget.existingClass;
    startTime = _class!.startTime!;
    endTime = _class.endTime!;
    _subjectTextController.text = _class.subject!;
    _teacherTextController.text = _class.teacher!;
    _locationTextController.text = _class.location!;
  }

  @override
  void dispose() {
    _subjectTextController.dispose();
    _locationTextController.dispose();
    _teacherTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var classTextField = TextFormField(
      maxLength: 20,
      autofocus: true,
      style: TextStyle(fontSize: 24.0),
      controller: _subjectTextController,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: "Enter class",
        contentPadding: EdgeInsets.only(left: 20),
        hintStyle: TextStyle(
          color: Theme.of(context).textTheme.bodyText1!.color,
          fontSize: 24.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    );

    var saveButton = Container(
      padding: EdgeInsets.all(10),
      child: ElevatedButton(
        child: Text(
          "Save",
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: StadiumBorder(),
        ),
        onPressed: () {
          bool isValid =
              validateTime() && validateSubject(_subjectTextController.text);
          if (isValid) returnClass();
        },
      ),
    );

    var closeButton = IconButton(
      icon: Icon(
        Icons.close,
        color: Theme.of(context).iconTheme.color,
      ),
      onPressed: () async {
        bool shouldPop = await showConfirmationDialog();
        if (shouldPop) {
          Navigator.pop(context);
        }
      },
    );

    var appBar = AppBar(
      actions: <Widget>[saveButton],
      leading: closeButton,
      // backgroundColor: Colors.white,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: Padding(
          padding: EdgeInsets.only(bottom: 20, left: 20, right: 20),
          child: classTextField,
        ),
      ),
    );

    var startTimeTile = TimeTile(
      label: "Starts",
      time: startTime,
      onTap: () => getStartTime(context),
    );

    var endTimeTile = TimeTile(
      label: "Ends",
      time: endTime,
      onTap: () => getEndTime(context),
    );

    var teacherTextField = TextFieldTile(
      leadingIcon: Icons.person_outline,
      controller: _teacherTextController,
      hintText: "Add a teacher",
      onSubmitted: (String value) {},
    );

    var locationTextField = TextFieldTile(
      leadingIcon: Icons.location_on,
      controller: _locationTextController,
      hintText: "Add a location",
      onSubmitted: (text) {
        validateSubject(text);
      },
    );

    return Scaffold(
      key: _scaffoldKey,
      appBar: appBar,
      body: Form(
        onWillPop: () async => false,
        child: ListView(
          padding: EdgeInsets.only(left: 15),
          children: <Widget>[
            timingHeader(context),
            startTimeTile,
            endTimeTile,
            Divider(),
            teacherTextField,
            locationTextField,
          ],
        ),
      ),
    );
  }

  Future<void> getStartTime(BuildContext context) async {
    TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(startTime),
    );

    if (newTime != null) {
      setState(
          () => startTime = DateTime(1, 1, 1, newTime.hour, newTime.minute));
    }
  }

  Future<void> getEndTime(BuildContext context) async {
    var selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(endTime),
    );

    if (selectedTime != null) {
      setState(() =>
          endTime = DateTime(1, 1, 1, selectedTime.hour, selectedTime.minute));
    }
  }

  Widget timingHeader(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.all(0),
        title: Row(children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.alarm,
              color: Theme.of(context).iconTheme.color!.withOpacity(0.6),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 0),
            child: Text(
              "Timing",
              style: TextStyle(
                  fontSize: 20.0,
                  color: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .color!
                      .withOpacity(0.6),
                  fontWeight: FontWeight.w500),
            ),
          ),
        ]),
      );

  bool validateSubject(String text) {
    if (text.trim().isNotEmpty) {
      return true;
    }
    return false;
  }

  bool validateTime() {
    if (endTime.isBefore(startTime)) {
      _scaffoldKey.currentState!.showSnackBar(SnackBar(
        content: Text("The class can't end before it starts!"),
        backgroundColor: Colors.red[400],
      ));

      return false;
    }
    return true;
  }

  showConfirmationDialog() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => ConfirmDeleteDialog(
        bodyMsg: "Are you sure you want to discard your changes to this class?",
        redButtonLabel: "Discard",
        onRedPressed: () => Navigator.of(context).pop(true),
        altButtonLabel: "Keep editing",
        onAltPressed: () => Navigator.of(context).pop(false),
      ),
    );
  }

  /// Construct a ClassItem with the data from the form,
  /// then pop and return it to [SchedulePage].
  void returnClass() {
    ClassItem _classItem = getClass();
    if (isEditing) {
      _classItem.id = widget.existingClass!.id;
    }

    Navigator.pop(context, _classItem);
  }

  getClass() => ClassItem(
        _subjectTextController.text,
        startTime,
        endTime,
        weekDay: (isEditing) ? widget.existingClass!.weekDay : widget.weekDay,
        teacher: _teacherTextController.text.trim().isNotEmpty
            ? _teacherTextController.text
            : null,
        location: _locationTextController.text.trim().isNotEmpty
            ? _locationTextController.text
            : null,
      );
}

class TextFieldTile extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData leadingIcon;
  final ValueChanged<String> onSubmitted;

  const TextFieldTile({
    required this.controller,
    required this.hintText,
    required this.leadingIcon,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    var hintStyle = TextStyle(
      color: Colors.black54,
      fontWeight: FontWeight.w500,
    );

    var textFieldDeco = InputDecoration(
      icon: Icon(leadingIcon),
      border: InputBorder.none,
      hintText: hintText,
      hintStyle: hintStyle,
    );

    return Container(
      alignment: Alignment.bottomLeft,
      child: TextFormField(
        onFieldSubmitted: onSubmitted,
        controller: controller,
        decoration: textFieldDeco,
        style: TextStyle(fontSize: 18.0),
      ),
      padding: EdgeInsets.symmetric(vertical: 5.0),
    );
  }
}

class TimeTile extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final DateTime time;

  const TimeTile({
    required this.onTap,
    required this.time,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        child: Row(
          children: <Widget>[
            Text(label),
            Spacer(),
            valueText(),
          ],
        ),
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 45),
      ),
    );
  }

  Widget valueText() {
    final formatter = DateFormat('jm');
    return Text(
      formatter.format(time),
      textAlign: TextAlign.end,
      style: TextStyle(fontSize: 15.0),
    );
  }
}
