import 'package:flutter/material.dart';

class GraphField {
  static const createdTime = 'createdTime';
}

class Graph {
  // ignore: non_constant_identifier_names
  String graph_id;
  String name;
  int price;
  String type;
  DateTime createdTime;

  Graph({
    @required this.graph_id,
    @required this.name,
    @required this.price,
    @required this.type,
  });
}
