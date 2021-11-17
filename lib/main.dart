import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';

void main() async {
  await Hive.initFlutter();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: MyHomePage(title: 'To Do List'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;
  final List item = [
    {'done': 0, 'val': 'Ok1'},
    {'done': 0, 'val': 'Ok2'},
    {'done': 0, 'val': 'Ok3'},
    {'done': 0, 'val': 'Ok4'},
    {'done': 0, 'val': 'Ok5'},
  ];

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  dynamic txtInputedt = false;
  dynamic todoData = [];

  void reorderData(int oldindex, int newindex) {
    setState(() {
      if (newindex > oldindex) {
        newindex -= 1;
      }
      final items = widget.item.removeAt(oldindex);
      widget.item.insert(newindex, items);
    });
  }

  ontapEdit(items) {
    setState(() {
      txtInputedt = widget.item.indexOf(items);
    });
  }

  void onDismiss(DismissDirection direction, items) {
// Remove the item from the data source.
    setState(() {
      if (direction == DismissDirection.endToStart) {
        widget.item.removeAt(widget.item.indexOf(items));
      } else {
        widget.item[widget.item.indexOf(items)] = {
          'done': 1,
          'val': '${widget.item[widget.item.indexOf(items)]['val']}'
        };
      }
    });
  }

  Future onRefresh() {
    if (widget.item.isEmpty ||
        widget.item[widget.item.length - 1]['val'] != '') {
      setState(() {
        widget.item.add({'done': 0, 'val': ''});
      });
    }
    return Future.value();
  }

  editItem(items, index, val) {
    setState(() {
      if (val != '') {
        if (items['val'] == '') {
          widget.item[widget.item.length - 1]['val'] = val;
        } else {
          widget.item[widget.item.indexOf(items)]['val'] = val;
          txtInputedt = false;
        }
      }
    });
  }

  box() async {
    var box = await Hive.openBox('todoData');
    box.addAll(widget.item);
//print(box.values);
  }

  @override
  void initState() {
    super.initState();
    box();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.title,
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: ReorderableListView(
          children: <Widget>[
            for (final items in widget.item)
              Visibility(
                  key: ValueKey(items),
                  visible: items['val'] == '' ||
                      txtInputedt == widget.item.indexOf(items),
                  child: ListTile(
                      key: ValueKey(items),
                      tileColor: Colors
                          .deepOrange[(widget.item.indexOf(items) + 1) * 100],
                      title: TextFormField(
                        initialValue: items['val'],
                        onFieldSubmitted: (val) =>
                            editItem(items, widget.item.indexOf(items), val),
                      )),
                  replacement: Dismissible(
                      onDismissed: (dir) {
                        onDismiss(dir, items);
                      },
                      key: ValueKey(items),
                      child: Card(
                          elevation: 2,
                          child: ListTile(
                            onTap: () =>
                                items['done'] == 0 ? ontapEdit(items) : null,
                            tileColor: items['done'] == 0
                                ? Colors.deepOrange[
                                    (widget.item.indexOf(items) + 1) * 100]
                                : Colors.grey,
                            title: Text(
                              items['val'],
                              style: TextStyle(
                                  decoration: items['done'] == 0
                                      ? TextDecoration.none
                                      : TextDecoration.lineThrough),
                            ),
                            leading: const Icon(
                              Icons.work,
                              color: Colors.black,
                            ),
                          )))),
          ],
          onReorder: reorderData,
        ),
      ),
    );
  }
}
