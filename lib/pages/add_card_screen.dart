import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'package:studento/model/todo/todo_list_model.dart';
import 'package:studento/model/todo/task_model.dart';
import 'package:studento/UI/todo_badge.dart';
import 'package:studento/UI/icon_picker.dart';
import 'package:studento/utils/color_utils.dart';

class AddCardScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  String? newTask;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Color? taskColor;
  IconData? taskIcon;
  late TodoListModel _todoListModel;

  @override
  void initState() {
    super.initState();
    _todoListModel = TodoListModel();
    setState(() {
      newTask = '';
      taskColor = ColorUtils.defaultColors[3];
      taskIcon = Icons.all_inclusive;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<TodoListModel>(
      model: _todoListModel,
      child: ScopedModelDescendant<TodoListModel>(
        builder: (BuildContext context, child, TodoListModel model) {
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text(
                'New Category',
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge!.color),
              ),
              centerTitle: true,
              elevation: 0,
              iconTheme:
                  IconThemeData(color: Theme.of(context).iconTheme.color),
              // ignore: deprecated_member_use
              brightness: Brightness.light,
            ),
            body: Container(
              constraints: BoxConstraints.expand(),
              padding: EdgeInsets.symmetric(horizontal: 36.0, vertical: 36.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add a new category to group your tasks',
                    style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .color!
                            .withOpacity(0.5),
                        fontWeight: FontWeight.w600,
                        fontSize: 16.0),
                  ),
                  Container(
                    height: 16.0,
                  ),
                  TextField(
                    onChanged: (text) {
                      setState(() => newTask = text);
                    },
                    cursorColor: taskColor,
                    autofocus: true,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Category Name...',
                        hintStyle: TextStyle(
                          color: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .color!
                              .withOpacity(0.3),
                        )),
                    style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .color!
                            .withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                        fontSize: 36.0),
                  ),
                  Container(
                    height: 26.0,
                  ),
                  Row(
                    children: [
                      Tooltip(
                        message: "Choose category color",
                        child: ColorPickerBuilder(
                            color: taskColor!,
                            onColorChanged: (newColor) =>
                                setState(() => taskColor = newColor)),
                      ),
                      Container(
                        width: 22.0,
                      ),
                      Tooltip(
                        message: "Choose category icon",
                        child: IconPickerBuilder(
                            iconData: taskIcon!,
                            highlightColor: taskColor!,
                            action: (newIcon) =>
                                setState(() => taskIcon = newIcon)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Builder(
              builder: (BuildContext context) {
                return FloatingActionButton.extended(
                  heroTag: 'fab_new_card',
                  icon: Icon(
                    Icons.save,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  backgroundColor: taskColor,
                  label: Text(
                    'Create New Card',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  onPressed: () {
                    if (newTask!.isEmpty) {
                      final snackBar = SnackBar(
                        content: Text(
                          'Please choose a name for your category :)',
                          style: Theme.of(context).textTheme.bodyMedium!,
                        ),
                        backgroundColor: taskColor,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      // _scaffoldKey.currentState.showSnackBar(snackBar);
                    } else {
                      model.addTask(Task(newTask!,
                          codePoint: taskIcon!.codePoint,
                          color: taskColor!.value));
                      Navigator.pop(context, true);
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class ColorPickerBuilder extends StatelessWidget {
  final Color color;
  final ValueChanged<Color> onColorChanged;

  const ColorPickerBuilder({required this.color, required this.onColorChanged});

  @override
  Widget build(BuildContext context) {
    //https://stackoverflow.com/questions/45424621/inkwell-not-showing-ripple-effect
    return ClipOval(
      child: Container(
        height: 32.0,
        width: 32.0,
        child: Material(
          color: color,
          child: InkWell(
            borderRadius: BorderRadius.circular(50.0),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    title: Text(
                      'Select a color',
                      textAlign: TextAlign.center,
                    ),
                    content: SingleChildScrollView(
                      child: BlockPicker(
                        availableColors: ColorUtils.defaultColors,
                        pickerColor: color,
                        onColorChanged: onColorChanged,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class IconPickerBuilder extends StatelessWidget {
  final IconData iconData;
  final ValueChanged<IconData> action;
  final Color highlightColor;

  const IconPickerBuilder({
    required this.iconData,
    required this.action,
    required Color highlightColor,
    // ignore: prefer_initializing_formals
  }) : highlightColor = highlightColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(50.0),
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Select an icon',
                textAlign: TextAlign.center,
              ),
              content: SingleChildScrollView(
                child: IconPicker(
                  currentIconData: iconData,
                  onIconChanged: action,
                  highlightColor: highlightColor,
                ),
              ),
            );
          },
        );
      },
      child: TodoBadge(
        id: 'id',
        codePoint: iconData.codePoint,
        color: Colors.blueGrey,
        size: 24,
      ),
    );
  }
}

// Reason for wraping fab with builder (to get scafold context)
// https://stackoverflow.com/a/52123080/4934757
