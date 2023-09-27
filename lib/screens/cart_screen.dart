import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart' show Cart;
import '../providers/orders.dart';

import '../widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static const routeName = 'cart';

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<Cart>(context);
    final ordersProvider = Provider.of<Orders>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Column(
        children: <Widget>[
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: <Widget>[
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      '${cartProvider.totalAmount}',
                      style: TextStyle(
                          color: Theme.of(context)
                              .primaryTextTheme
                              .headline6
                              .color),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  OrderButton(
                      cartProvider: cartProvider,
                      ordersProvider: ordersProvider)
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: cartProvider.items.length,
              itemBuilder: (ctx, index) {
                final item = cartProvider.items.values.toList()[index];
                return CartItem(
                    item.id,
                    cartProvider.items.keys.toList()[index],
                    item.title,
                    item.price,
                    item.quantity);
              },
            ),
          )
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.cartProvider,
    @required this.ordersProvider,
  }) : super(key: key);

  final Cart cartProvider;
  final Orders ordersProvider;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: _isLoading ? CircularProgressIndicator() : Text('ORDER NOW',
      style: TextStyle(
        color: Theme.of(context).primaryColor,
      ),
      ),
      onPressed: (widget.cartProvider.totalAmount <= 0 || _isLoading)
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });
              try {
                await widget.ordersProvider.addOrder(
                    widget.cartProvider.items.values.toList(),
                    widget.cartProvider.totalAmount);
                widget.cartProvider.clear();
              } catch (error) {
                if (error.toString() == 'Could not place the order')
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Could not place the order'),
                      duration: Duration(milliseconds: 750),
                    ),
                  );
              }
              setState(() {
                _isLoading = false;
              });
            },

    );
  }
}
