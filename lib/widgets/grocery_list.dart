import 'package:flutter/material.dart';
import 'package:form_app/data/dummy_items.dart';
import 'package:form_app/models/grocery_item.dart';
import 'package:form_app/widgets/new_tem.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryItems = [...groceryItems];

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

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('No items added yet.', style: TextStyle(fontSize: 20)),
    );

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemBuilder: (ctx, index) => Dismissible(
          key: ValueKey(_groceryItems[index].id),
          background: Container(color: Colors.red),
          onDismissed: (direction) {
            setState(() {
              _groceryItems.removeAt(index);
            });
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
