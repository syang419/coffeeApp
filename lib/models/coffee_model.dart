import 'package:cloud_firestore/cloud_firestore.dart';

class CoffeeModel {
  final String id;
  final String name;
  final String sub;
  final String img;
  final double price;
  final double rating;
  final String category;
  final String description;

  CoffeeModel({
    required this.id,
    required this.name,
    required this.sub,
    required this.price,
    required this.rating,
    required this.img,
    required this.category,
    required this.description,
  });

  factory CoffeeModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return CoffeeModel(
      id: doc.id,
      name: data['name'] ?? '',
      sub: data['sub'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      rating: (data['rating'] ?? 0).toDouble(),
      img: data['img'] ?? '',
      category: data['category'] ?? 'All Coffee',
      description: data['description'] ?? '',
    );
  }
}