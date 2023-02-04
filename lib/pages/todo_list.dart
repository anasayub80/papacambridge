import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:studento/model/todo/todo_list_model.dart';

import 'package:studento/UI/gradient_background.dart';
import 'package:studento/UI/task_progress_indicator.dart';
import 'package:studento/pages/add_card_screen.dart';
import 'package:studento/model/todo/hero_id_model.dart';
import 'package:studento/model/todo/task_model.dart';
import 'package:studento/scale_route.dart';
import 'package:studento/utils/color_utils.dart';
import 'package:studento/utils/datetime_utils.dart';
import 'package:studento/pages/detail_screen.dart';
import 'package:studento/UI/todo_badge.dart';

class TodoListPage extends StatefulWidget {
  HeroId _generateHeroIds(Task task) {
    return HeroId(
      codePointId: 'code_point_id_${task.id}',
      progressId: 'progress_id_${task.id}',
      titleId: 'title_id_${task.id}',
      remainingTaskId: 'remaining_task_id_${task.id}',
    );
  }

  String currentDay(BuildContext context) {
    return DateTimeUtils.currentDay;
  }

  @override
  // ignore: library_private_types_in_public_api
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final GlobalKey _backdropKey = GlobalKey(debugLabel: 'Backdrop');
  PageController? _pageController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _pageController = PageController(initialPage: 0, viewportFraction: 0.8);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<TodoListModel>(
        builder: (BuildContext context, child, TodoListModel model) {
      var isLoading = model.isLoading;
      var tasks = model.tasks;
      var todos = model.todos;
      if (!isLoading) {
        // move the animation value towards upperbound only when loading is complete
        _controller.forward();
      }
      return Scaffold(
        // backgroundColor: Colors.white,
        // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          leading: BackButton(),
          iconTheme: Theme.of(context).iconTheme,
          elevation: 0.0,
          backgroundColor: Colors.transparent,
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  strokeWidth: 1.0,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : FadeTransition(
                opacity: _animation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 0.0, left: 56.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            child: Text(widget.currentDay(context),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 35)),
                          ),
                          Text(
                            '${DateTimeUtils.currentDate} ${DateTimeUtils.currentMonth}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 30,
                            ),
                          ),
                          Container(height: 16.0),
                          Text(
                            'You have ${todos.where((todo) => todo.isCompleted == 0).length} tasks to complete!',
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 16),
                          ),
                          Container(
                            height: 16.0,
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      key: _backdropKey,
                      flex: 1,
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification is ScrollEndNotification) {
                            print(
                                "ScrollNotification = ${_pageController!.page}");
                            var currentPage =
                                _pageController!.page!.round().toInt();
                            if (_currentPageIndex != currentPage) {
                              setState(() => _currentPageIndex = currentPage);
                            }
                          }
                          return true;
                        },
                        child: PageView.builder(
                          controller: _pageController,
                          itemBuilder: (BuildContext context, int index) {
                            if (index == tasks.length) {
                              return AddPageCard(
                                color: Colors.deepPurple,
                                // rebuildCategoriesFunc: reloadPage,
                              );
                            } else {
                              return TaskCard(
                                backdropKey: _backdropKey,
                                color: ColorUtils.getColorFrom(
                                    id: tasks[index].color)!,
                                getHeroIds: widget._generateHeroIds,
                                getTaskCompletionPercent:
                                    model.getTaskCompletionPercent,
                                getTotalTodos: model.getTotalTodosFrom,
                                task: tasks[index],
                              );
                            }
                          },
                          itemCount: tasks.length + 1,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 32.0),
                    ),
                  ],
                ),
              ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class AddPageCard extends StatelessWidget {
  final Color color;

  // When a new card is added, call this function to rebuild the parent Widget, i.e. [TodoListPage]
  // final Function rebuildCategoriesFunc;

  const AddPageCard({
    Key? key,
    this.color = Colors.black,
    // required this.rebuildCategoriesFunc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Material(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 2.0,
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: GradientBackground.getGradient(color),
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          child: InkWell(
            onTap: () async {
              bool isNewCategoryCreated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddCardScreen(),
                    ),
                  ) ??
                  false;

              if (isNewCategoryCreated) {
                // ignore: use_build_context_synchronously
                TodoListModel.of(context).loadTodos();
              }
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    size: 52.0,
                    color: Colors.white,
                  ),
                  Container(
                    height: 8.0,
                  ),
                  Text(
                    'Add Category',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

typedef TaskGetter<T, V> = V Function(T value);

class TaskCard extends StatelessWidget {
  final GlobalKey backdropKey;
  final Task task;
  final Color color;

  final TaskGetter<Task, int> getTotalTodos;
  final TaskGetter<Task, HeroId> getHeroIds;
  final TaskGetter<Task, int?> getTaskCompletionPercent;

  const TaskCard({
    required this.backdropKey,
    required this.color,
    required this.task,
    required this.getTotalTodos,
    required this.getHeroIds,
    required this.getTaskCompletionPercent,
  });

  @override
  Widget build(BuildContext context) {
    var heroIds = getHeroIds(task);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Material(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 2.0,
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: GradientBackground.getGradient(color),
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          child: InkWell(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TodoBadge(
                      id: heroIds.codePointId,
                      codePoint: task.codePoint,
                      color: color,
                    ),
                    Spacer(
                      flex: 8,
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 4.0),
                      child: Hero(
                        tag: heroIds.remainingTaskId,
                        child: Text(
                          "${getTotalTodos(task)} Tasks",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: Colors.white.withOpacity(0.8)),
                        ),
                      ),
                    ),
                    Container(
                      child: Hero(
                        tag: heroIds.titleId,
                        child: Text(task.name,
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium!
                                .copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500)),
                      ),
                    ),
                    Spacer(),
                    Hero(
                      tag: heroIds.progressId,
                      child: TaskProgressIndicator(
                        color: color,
                        textColor: Colors.white70,
                        progress: getTaskCompletionPercent(task),
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () {
                final RenderBox renderBox =
                    backdropKey.currentContext!.findRenderObject() as RenderBox;
                var backDropHeight = renderBox.size.height;
                var bottomOffset = 60.0;
                var horizontalOffset = 52.0;
                var topOffset =
                    MediaQuery.of(context).size.height - backDropHeight;

                var rect = RelativeRect.fromLTRB(horizontalOffset, topOffset,
                    horizontalOffset, bottomOffset);
                Navigator.push(
                  context,
                  ScaleRoute(
                    rect: rect,
                    widget: DetailScreen(
                      taskId: task.id,
                      heroIds: heroIds,
                    ),
                  ),
                );
              }),
        ),
      ),
    );
  }
}
