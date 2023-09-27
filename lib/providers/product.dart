import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product(
      {@required this.id,
      @required this.title,
      @required this.description,
      @required this.price,
      @required this.imageUrl,
      this.isFavorite = false});

  Future<void> toggleFavoriteStatus(
      String id, String authToken, String userId) async {
    isFavorite = !isFavorite;

    final url =
        'https://fluttertest-d572e.firebaseio.com/userFavorites/$userId/$id.json?auth=$authToken';
    final response = await http.put(url,
        body: json.encode(
          isFavorite,
        ));
    if (response.statusCode >= 400) {
      notifyListeners();
      isFavorite = !isFavorite;
      throw HttpException('Could not toggle favorite status');
    }
    notifyListeners();
  }
}
