import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:form_app/models/category.dart';
import 'package:form_app/models/grocery_item.dart';

abstract interface class GroceryRepository {
  Future<List<GroceryItem>> fetchItems();

  Future<GroceryItem> addItem({
    required String name,
    required int quantity,
    required Category category,
  });

  Future<void> deleteItem(String id);
}

class FirestoreGroceryRepository implements GroceryRepository {
  FirestoreGroceryRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  static const collectionName = 'shopping-list';
  static const _requestTimeout = Duration(seconds: 15);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _items =>
      _firestore.collection(collectionName);

  @override
  Future<List<GroceryItem>> fetchItems() async {
    final snapshot = await _items.get().timeout(_requestTimeout);
    return snapshot.docs
        .map(
          (document) => GroceryItem.fromFirestore(document.id, document.data()),
        )
        .toList();
  }

  @override
  Future<GroceryItem> addItem({
    required String name,
    required int quantity,
    required Category category,
  }) async {
    final document = await _items
        .add(
          GroceryItem.firestoreData(
            name: name,
            quantity: quantity,
            category: category,
          ),
        )
        .timeout(_requestTimeout);
    return GroceryItem(
      id: document.id,
      name: name,
      quantity: quantity,
      category: category,
    );
  }

  @override
  Future<void> deleteItem(String id) async {
    await _items.doc(id).delete().timeout(_requestTimeout);
  }
}
