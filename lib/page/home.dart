// page/home.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<Order> _orders = [];
  final Order _order = Order();

  @override
  void initState() {
    super.initState();
    _loadOrders(); // Load saved orders on startup
  }

  String? _validateItem(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an item name';
    }
    return null;
  }

  Future<void> _loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedOrders = prefs.getString('orders');
    if (savedOrders != null) {
      final List<dynamic> decoded = jsonDecode(savedOrders);
      setState(() {
        _orders.clear();
        _orders.addAll(decoded.map((e) => Order.fromJson(e)).toList());
      });
    }
  }

  Future<void> _saveOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_orders.map((e) => e.toJson()).toList());
    await prefs.setString('orders', encoded);
  }

  void _submitOrder() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _orders.add(Order(item: _order.item, quantity: _order.quantity));
      });
      _saveOrders(); // Save after every submission
      _formKey.currentState!.reset();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item: ${_order.item}, Quantity: ${_order.quantity}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order Form')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Item'),
                validator: _validateItem,
                onSaved: (value) => _order.item = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                onSaved:
                    (value) =>
                        _order.quantity = int.tryParse(value ?? '0') ?? 0,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitOrder,
                child: Text('Submit Order'),
              ),
              SizedBox(height: 20),
              Expanded(
                child:
                    _orders.isEmpty
                        ? Center(child: Text('No orders yet.'))
                        : ListView.builder(
                          itemCount: _orders.length,
                          itemBuilder: (context, index) {
                            final order = _orders[index];
                            return ListTile(
                              title: Text(order.item),
                              subtitle: Text('Quantity: ${order.quantity}'),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Order {
  String item;
  int quantity;

  Order({this.item = '', this.quantity = 0});

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(item: json['item'], quantity: json['quantity']);
  }

  Map<String, dynamic> toJson() => {'item': item, 'quantity': quantity};
}
