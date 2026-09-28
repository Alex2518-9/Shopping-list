import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter/material.dart';
import 'package:form_app/data/grocery_repository.dart';
import 'package:form_app/models/grocery_item.dart';
import 'package:form_app/widgets/new_tem.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key, this.repository});

  final GroceryRepository? repository;

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  late final GroceryRepository _repository;
  List<GroceryItem> _groceryItems = [];

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? FirestoreGroceryRepository();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final loadedItems = await _repository.fetchItems();
      if (!mounted) return;
      setState(() {
        _groceryItems = loadedItems;
        _isLoading = false;
      });
    } on FirebaseException catch (error, stackTrace) {
      _logDatabaseError('loading groceries', error, stackTrace);
      _showLoadError();
    } on FormatException catch (error, stackTrace) {
      _logDatabaseError('parsing groceries', error, stackTrace);
      _showLoadError();
    } on TimeoutException catch (error, stackTrace) {
      _logDatabaseError('loading groceries', error, stackTrace);
      _showLoadError();
    }
  }

  void _logDatabaseError(
    String operation,
    Object error,
    StackTrace stackTrace,
  ) {
    if (kDebugMode) {
      debugPrint('Firestore $operation failed: $error\n$stackTrace');
    }
  }

  void _showLoadError() {
    if (!mounted) return;
    setState(() {
      _error = 'Could not load groceries. Check your connection and try again.';
      _isLoading = false;
    });
  }

  Future<void> _removeItem(GroceryItem item) async {
    setState(() {
      _groceryItems.removeWhere((groceryItem) => groceryItem.id == item.id);
    });
    try {
      await _repository.deleteItem(item.id);
    } on FirebaseException catch (error, stackTrace) {
      _logDatabaseError('deleting grocery item', error, stackTrace);
      _restoreDeletedItem(item);
    } on TimeoutException catch (error, stackTrace) {
      _logDatabaseError('deleting grocery item', error, stackTrace);
      _restoreDeletedItem(item);
    }
  }

  void _restoreDeletedItem(GroceryItem item) {
    if (!mounted) return;
    setState(() {
      _groceryItems.add(item);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not delete item. Please try again.')),
    );
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem?>(
      MaterialPageRoute(builder: (ctx) => NewItem(repository: _repository)),
    );

    if (newItem != null && mounted) {
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

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      content = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            TextButton(onPressed: _loadItems, child: const Text('Retry')),
          ],
        ),
      );
    } else if (!_isLoading && _groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemBuilder: (ctx, index) => Dismissible(
          key: ValueKey(_groceryItems[index].id),
          background: Container(color: Colors.red),
          onDismissed: (direction) {
            _removeItem(_groceryItems[index]);
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
