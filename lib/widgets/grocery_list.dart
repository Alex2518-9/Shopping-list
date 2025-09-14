import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:form_app/data/categories.dart';
import 'package:form_app/models/grocery_item.dart';
import 'package:form_app/widgets/new_tem.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final url = Uri.https(
      'flutter-shopping-list-a39c2-default-rtdb.firebaseio.com',
      'shopping-list.json',
    );

    final response = await http.get(url);

    if (response.body == 'null') {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final Map<String, dynamic> listData = jsonDecode(response.body);
    final List<GroceryItem> loadedItems = [];
    for (var element in listData.entries) {
      loadedItems.add(
        GroceryItem(
          id: element.key,
          name: element.value['name'],
          quantity: element.value['quantity'],
          category: categories.entries
              .firstWhere((cat) => cat.value.title == element.value['category'])
              .value,
        ),
      );
    }
    setState(() {
      _groceryItems = loadedItems;
      _isLoading = false;
    });
  }

  void _addItem() async {
    final newItem = await Navigator.of(
      context,
    ).push<GroceryItem?>(MaterialPageRoute(builder: (ctx) => const NewItem()));

    if (newItem != null) {
      setState(() {
        _groceryItems.add(newItem);
      });
    }
  }

  void _removeItem(String id) async {
    final url = Uri.https(
      'flutter-shopping-list-a39c2-default-rtdb.firebaseio.com',
      'shopping-list/$id.json',
    );
    await http.delete(url);
    setState(() {
      _groceryItems.removeWhere((item) => item.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('No items added yet.', style: TextStyle(fontSize: 20)),
    );

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    }

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemBuilder: (ctx, index) => Dismissible(
          key: ValueKey(_groceryItems[index].id),
          background: Container(color: Colors.red),
          onDismissed: (direction) {
            _removeItem(_groceryItems[index].id);
          },
          child: ListTile(
            title: Text(_groceryItems[index].name),
            leading: Container(
              width: 24,
              height: 24,
              color: _groceryItems[index].category.color,
            ),
            trailing: Text('${_groceryItems[index].quantity}'),
          ),
        ),
        itemCount: _groceryItems.length,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
      ),
      body: content,
    );
  }
}
