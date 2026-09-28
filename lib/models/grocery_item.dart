import 'package:form_app/data/categories.dart';
import 'package:form_app/models/category.dart';

class GroceryItem {
  const GroceryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.category,
  });

  final String id;
  final String name;
  final int quantity;
  final Category category;

  Map<String, dynamic> toFirestore() {
    return firestoreData(name: name, quantity: quantity, category: category);
  }

  static Map<String, dynamic> firestoreData({
    required String name,
    required int quantity,
    required Category category,
  }) {
    return {'name': name, 'quantity': quantity, 'category': category.title};
  }

  factory GroceryItem.fromFirestore(String id, Map<String, dynamic> data) {
    final name = data['name'];
    final quantity = data['quantity'];
    final categoryTitle = data['category'];
    if (name is! String || quantity is! int || categoryTitle is! String) {
      throw const FormatException('Invalid grocery item data.');
    }

    final matchingCategories = categories.values.where(
      (category) => category.title == categoryTitle,
    );
    if (matchingCategories.isEmpty) {
      throw const FormatException('Unknown grocery item category.');
    }

    return GroceryItem(
      id: id,
      name: name,
      quantity: quantity,
      category: matchingCategories.first,
    );
  }
}
