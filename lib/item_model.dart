import 'package:flutter/foundation.dart';

class Item {
  final String name;
  final String category;
  //final double price;
  final String link;
  final DateTime date;

  const Item({
    @required this.name,
    @required this.category,
    //required this.price,
    @required this.link,
    @required this.date,
  });

  factory Item.fromMap(Map<String, dynamic> map) {
    final properties = map['properties'] as Map<String, dynamic>;
    final nameList = (properties['Name']['title'] ?? []) as List;
    final dateStr = properties['Date']['date']['start'];
    final linkList = (properties['Link']['rich_text'] ?? []) as List;

    return Item(
        name: nameList.isNotEmpty ? nameList[0]['plain_text'] : '?',
        category: properties['Category']['select']['name'] ?? 'Any',

        // price: (properties['Price']?['number'] ?? 0).toDouble(),

        link: linkList.isNotEmpty ? linkList[0]['plain_text'] : '?',
        date: dateStr != null ? DateTime.parse(dateStr) : DateTime.now());
  }
}
