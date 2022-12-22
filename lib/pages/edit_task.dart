import 'package:flutter/material.dart';
import 'package:studento/model/todo/todo_model.dart';

class EditTaskWidget extends StatefulWidget {
  final Todo todoToEdit;

  const EditTaskWidget(this.todoToEdit);
  @override
  EditTaskWidgetState createState() => EditTaskWidgetState();
}

class EditTaskWidgetState extends State<EditTaskWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    _controller.text = widget.todoToEdit.name!;
    super.initState();
  }

  @override
  void dispose() {
    _controller.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roundedCornersDeco = BoxDecoration(
      color: Theme.of(context).scaffoldBackgroundColor,
      borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(10.0),
          topRight: const Radius.circular(10.0)),
    );

    final paddingForKeyboard =
        EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom);

    final saveButton = TextButton(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        'SAVE',
        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
      ),
      onPressed: () => Navigator.pop(
        context,
        widget.todoToEdit.copy(name: _controller.text.toString()),
      ),
    );

    return Padding(
      padding: paddingForKeyboard,
      child: Container(
        decoration: roundedCornersDeco,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              nameTextField(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  deleteButton(),
                  saveButton,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  deleteButton() => IconButton(
        icon: Icon(
          Icons.delete,
          color: Colors.red,
        ),
        onPressed: () {
          Navigator.pop(context, true);
        },
      );

  nameTextField() => TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Edit Task',
        ),
        autocorrect: false,
        keyboardType: TextInputType.text,
      );
}
