import 'dart:convert';
import 'dart:io';

import 'package:cosmoscap/failure_model.dart';
import 'package:cosmoscap/item_model.dart';
import 'package:http/http.dart' as http;
//import 'package:flutter_dotenv/flutter_dotenv.dart';

//https://developers.notion.com/reference/post-database-query

class CosmosRepository {
  static const String _baseUrl = 'https://FILL THIS UP/https://api.notion.com/v1/'; //'get a proxy server setup in heokuapp, then it's {proxy/http://api.notion.com/v1'}

  final http.Client _client;

  CosmosRepository({http.Client client}) : _client = client ?? http.Client();

  void dispose() {
    _client.close();
  }

  Future<List<Item>> getItems() async {
    try {
      //final url = '${_baseUrl}databases/FILL THIS UP/query';
      final response = await _client.post(
        Uri.parse(url),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer FILL THIS UP',
          'Notion-Version': '2021-05-13',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return (data['results'] as List).map((e) => Item.fromMap(e)).toList()..sort((a, b) => a.date.compareTo(b.date));
      } else {
        throw const Failure(message: 'Something went wrong!');
      }
    } catch (_) {
      throw const Failure(message: 'Something went wrong!');
    }
  }
}
