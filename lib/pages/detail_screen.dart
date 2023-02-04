// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:studento/model/todo/todo_list_model.dart';

import 'package:studento/UI/task_progress_indicator.dart';
import 'package:studento/UI/todo_badge.dart';
import 'package:studento/model/todo/hero_id_model.dart';
import 'package:studento/model/todo/todo_model.dart';
import 'package:studento/utils/color_utils.dart';
import 'package:studento/pages/add_todo_screen.dart';
import 'package:studento/model/todo/data/choice_card.dart';

import 'package:studento/pages/edit_task.dart';
import 'package:studento/UI/confirm_delete_dialog.dart';

class DetailScreen extends StatefulWidget {
  final String taskId;
  final HeroId heroIds;

  const DetailScreen({
    required this.taskId,
    required this.heroIds,
  });

  @override
  State<StatefulWidget> createState() {
    return _DetailScreenState();
  }
}

class _DetailScreenState extends State<DetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  // ignore: unused_field
  Animation<Offset>? _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = Tween<Offset>(begin: Offset(0, 1.0), end: Offset(0.0, 0.0))
        .animate(_controller);
  }

  reloadTodoListPage() => TodoListModel.of(context).loadTodos();
  @override
  Widget build(BuildContext context) {
    _controller.forward();
    return ScopedModelDescendant<TodoListModel>(
      builder: (BuildContext context, child, TodoListModel model) {
        var _task;

        try {
          _task = model.tasks.firstWhere((it) => it.id == widget.taskId);
        } catch (e) {
          return Container(
            color: Colors.white,
          );
        }
        var _todos =
            model.todos.where((it) => it.parent == widget.taskId).toList();
        var _hero = widget.heroIds;
        var _color = ColorUtils.getColorFrom(id: _task.color);

        Widget checkButton(Todo todo, Color _color, bool _isCompleted) =>
            InkWell(
              onTap: () => model.updateTodo(
                todo.copy(isCompleted: _isCompleted ? 0 : 1),
              ),
              child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isCompleted ? _color : Colors.transparent,
                    border: Border.all(width: 2, color: _color)),
                child: Icon(
                  Icons.done,
                  size: 18.0,
                  color: Colors.white,
                ),
              ),
            );

        Widget buildFAB(HeroId _hero, Color _color) => FloatingActionButton(
              heroTag: 'fab_new_task',
              onPressed: () async {
                String newTask = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddTodoScreen(
                            taskId: widget.taskId, heroIds: _hero),
                      ),
                    ) ??
                    '';
                if (newTask.isNotEmpty)
                  model.addTodo(Todo(newTask, parent: widget.taskId));
              },
              tooltip: 'New Todo',
              backgroundColor: _color,
              foregroundColor: Colors.white,
              child: Icon(Icons.add),
            );

        showEditTaskSheet(Todo todo) async {
          {
            var result = await showModalBottomSheet(
              context: context,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              builder: (context) => EditTaskWidget(todo),
            );

            if (result != null) {
              // If user made a change, non-null val would be returned
              if (result is bool) {
                // if user clicked on delete button, a bool would have been returned.
                if (result) // User confirmed delete todo
                  model.removeTodo(todo);
              }
              if (result
                  is Todo) //  if user edited the todo name, the edited todo was returned
                model.updateTodo(result);
            }
          }
        }

        Widget buildTodoList() {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  var todo = _todos[index];
                  bool _isCompleted = todo.isCompleted == 1;

                  return Container(
                    padding: EdgeInsets.only(left: 22.0, right: 22.0),
                    child: ListTile(
                      onTap: () => showEditTaskSheet(todo),
                      contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                      leading: checkButton(todo, _color!, _isCompleted),
                      title: Text(
                        todo.name!,
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                          // color: _isCompleted ? _color : Colors.black54,
                          color: _isCompleted
                              ? _color
                              : Theme.of(context).textTheme.bodyLarge!.color,
                          decoration: _isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ),
                  );
                },
                itemCount: _todos.length,
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black26),
            // ignore: deprecated_member_use
            brightness: Brightness.light,
            backgroundColor: _color,
            actions: [
              PopUpMenuWithDeleteDialog(
                onActionPressed: () {
                  // I tried using ScopedModel.of(context).loadTodos to refresh the parent page, but that didn't work and the removed category would still be displayed.
                  model.removeTask(_task);
                },
              ),
            ],
          ),
          floatingActionButton: buildFAB(_hero, _color!),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.0),
            child: Column(children: [
              SizedBox(
                height: 10,
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 36.0),
                height: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        TodoBadge(
                          color: _color,
                          codePoint: _task.codePoint,
                          id: _hero.codePointId,
                        ),
                        Padding(padding: EdgeInsets.all(5)),
                        Hero(
                          tag: 'title_hero_unused', //_hero.titleId,
                          child: Text(_task.name,
                              style: Theme.of(context).textTheme.titleLarge),
                        ),
                      ],
                    ),
                    Spacer(),
                    Hero(
                      tag: _hero.progressId,
                      child: TaskProgressIndicator(
                        color: _color,
                        progress: model.getTaskCompletionPercent(_task),
                        textColor:
                            Theme.of(context).textTheme.bodyLarge?.color ??
                                Colors.black,
                      ),
                    )
                  ],
                ),
              ),
              buildTodoList(),
            ]),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

typedef Callback = void Function();

class PopUpMenuWithDeleteDialog extends StatelessWidget {
  final Callback onActionPressed;

  const PopUpMenuWithDeleteDialog({required this.onActionPressed});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Choice>(
      onSelected: (choice) {
        showDialog(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: showConfirmDeleteDialog,
        );
      },
      itemBuilder: (BuildContext context) {
        return choices.map((Choice choice) {
          return PopupMenuItem<Choice>(
            value: choice,
            child: Text(choice.title!),
          );
        }).toList();
      },
    );
  }

  Widget showConfirmDeleteDialog(BuildContext context) {
    final confirmMsg =
        "This is a one way street! Deleting this will remove all the task assigned in this card.";

    return ConfirmDeleteDialog(
      bodyMsg: confirmMsg,
      onRedPressed: () {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        onActionPressed();
      },
      onAltPressed: () => Navigator.of(context).pop(),
    );
  }
}
