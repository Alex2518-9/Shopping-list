import 'package:firebase_core/firebase_core.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:form_app/data/categories.dart';
import 'package:form_app/data/grocery_repository.dart';
import 'package:form_app/models/category.dart';
import 'package:form_app/models/grocery_item.dart';
import 'package:form_app/widgets/grocery_list.dart';

class _FakeGroceryRepository implements GroceryRepository {
  _FakeGroceryRepository({this.shouldFail = false});

  final bool shouldFail;
  final items = <GroceryItem>[];
  var _nextId = 0;

  void _maybeFail() {
    if (shouldFail) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
        message: 'Permission denied',
      );
    }
  }

  @override
  Future<List<GroceryItem>> fetchItems() async {
    _maybeFail();
    return List.of(items);
  }

  @override
  Future<GroceryItem> addItem({
    required String name,
    required int quantity,
    required Category category,
  }) async {
    _maybeFail();
    final item = GroceryItem(
      id: 'item-${_nextId++}',
      name: name,
      quantity: quantity,
      category: category,
    );
    items.add(item);
    return item;
  }

  @override
  Future<void> deleteItem(String id) async {
    _maybeFail();
    items.removeWhere((item) => item.id == id);
  }
}

void main() {
  test('serializes and parses the Firestore grocery item shape', () {
    final item = GroceryItem(
      id: 'document-id',
      name: 'Milk',
      quantity: 2,
      category: categories[Categories.dairy]!,
    );

    expect(item.toFirestore(), {
      'name': 'Milk',
      'quantity': 2,
      'category': 'Dairy',
    });
    expect(
      GroceryItem.fromFirestore('document-id', item.toFirestore()).name,
      'Milk',
    );
    expect(
      GroceryItem.fromFirestore('document-id', item.toFirestore()).category,
      categories[Categories.dairy],
    );
  });

  test(
    'Firestore repository adds, fetches, and deletes grocery documents',
    () async {
      final firestore = FakeFirebaseFirestore();
      final repository = FirestoreGroceryRepository(firestore: firestore);

      final addedItem = await repository.addItem(
        name: 'Milk',
        quantity: 2,
        category: categories[Categories.dairy]!,
      );
      final document = await firestore
          .collection(FirestoreGroceryRepository.collectionName)
          .doc(addedItem.id)
          .get();

      expect(addedItem.id, isNotEmpty);
      expect(document.data(), {
        'name': 'Milk',
        'quantity': 2,
        'category': 'Dairy',
      });
      expect((await repository.fetchItems()).single.name, 'Milk');

      await repository.deleteItem(addedItem.id);
      expect(await repository.fetchItems(), isEmpty);
    },
  );

  testWidgets('shows the grocery list when the server returns no items', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: GroceryList(repository: _FakeGroceryRepository())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your Groceries'), findsOneWidget);
    expect(find.text('No items added yet.'), findsOneWidget);
  });

  testWidgets('shows a generic error and retry action when loading fails', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: GroceryList(repository: _FakeGroceryRepository(shouldFail: true)),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Could not load groceries. Check your connection and try again.',
      ),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
    expect(find.textContaining('Permission denied'), findsNothing);
  });

  testWidgets('adds an item returned by the repository', (
    WidgetTester tester,
  ) async {
    final repository = _FakeGroceryRepository();
    await tester.pumpWidget(
      MaterialApp(home: GroceryList(repository: repository)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Milk');
    await tester.tap(find.text('Add Item'));
    await tester.pumpAndSettle();

    expect(find.text('Milk'), findsOneWidget);
    expect(repository.items.single.name, 'Milk');
  });

  testWidgets('shows a generic error when adding is denied', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: GroceryList(repository: _FakeGroceryRepository(shouldFail: true)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Milk');
    await tester.tap(find.text('Add Item'));
    await tester.pumpAndSettle();

    expect(
      find.text('Could not add item. Check your connection and try again.'),
      findsOneWidget,
    );
    expect(find.textContaining('Permission denied'), findsNothing);
  });
}
