import 'dart:math';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final size = 30;
  final dist = {};
  final prev = {};
  late List<List<int>> matrix;
  late Point<int> start;
  late Point<int> target;
  late HeapPriorityQueue queue;

  bool running = false;

  @override
  void initState() {
    super.initState();
    queue = HeapPriorityQueue((p1, p2) => dist[p1].compareTo(dist[p2]));
    initialState();
  }

  void initialState() {
    matrix = List<List<int>>.generate(
        size, (_) => List<int>.generate(size, (_) => 0));
    start = Point(size - 1, 0);
    target = Point(5, size - 10);
    matrix[start.x][start.y] = 1;
    matrix[target.x][target.y] = 3;
    for (var i = 10; i < 20; i++) {
      matrix[i][i] = 2;
      matrix[i][i + 1] = 2;
    }
    dist[start] = 0;
    for (var i = 0; i < size; i++) {
      for (var j = 0; j < size; j++) {
        final p = Point(i, j);
        if (p != start) {
          dist[p] = double.infinity;
        }
        queue.add(p);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Table(
              defaultColumnWidth: const IntrinsicColumnWidth(),
              border: TableBorder.all(),
              children: matrix
                  .map(
                    (r) => TableRow(
                      children: r.map((e) => _cell(e)).toList(),
                    ),
                  )
                  .toList(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => setState(() {
                    running = !running;
                    if (running) {
                      run();
                    }
                  }),
                  color: running ? Colors.red : Colors.green,
                  icon: running
                      ? const Icon(Icons.stop)
                      : const Icon(Icons.play_arrow),
                ),
                IconButton(
                  onPressed: running
                      ? null
                      : () => setState(() {
                            running = false;
                            initialState();
                          }),
                  color: Colors.blue,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void run() async {
    while (queue.isNotEmpty && running) {
      await Future.delayed(const Duration(
        milliseconds: 5,
      ));
      final u = queue.removeFirst();
      if (u == target) {
        running = false;
        var p = prev[u];
        while (p != start) {
          matrix[p.x.toInt()][p.y.toInt()] = 4;
          p = prev[p];
        }
        matrix[target.x.toInt()][target.y.toInt()] = 3;
        matrix[start.x.toInt()][start.y.toInt()] = 1;
        setState(() {});
        break;
      }
      final neighbors = _neighbors(u);
      for (var n in neighbors) {
        setState(() {
          matrix[n.x.toInt()][n.y.toInt()] = 5;
        });
        final currentDist = dist[u] + 1;
        if (currentDist < dist[n]) {
          dist[n] = currentDist;
          prev[n] = u;
          queue.remove(n);
          queue.add(n);
        }
      }
    }
  }

  List<Point> _neighbors(Point p) {
    return [
      Point(p.x - 1, p.y),
      Point(p.x + 1, p.y),
      Point(p.x, p.y + 1),
      Point(p.x, p.y - 1),
      Point(p.x + 1, p.y + 1),
      Point(p.x - 1, p.y + 1),
      Point(p.x + 1, p.y - 1),
      Point(p.x - 1, p.y - 1),
    ]
        .where((p) =>
            p.x >= 0 &&
            p.y >= 0 &&
            p.x < size &&
            p.y < size &&
            (matrix[p.x.toInt()][p.y.toInt()] == 0 || p == target))
        .toList();
  }

  Widget _cell(int type) => Container(
        width: 10,
        height: 10,
        color: _cellColor(type),
      );

  Color _cellColor(int type) {
    return [
      Colors.white,
      Colors.purple,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple.withAlpha(128)
    ][type];
  }
}
