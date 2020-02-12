import 'package:fattarny/menu_Page.dart';
import 'package:flutter/material.dart';

class MenuListFattarny extends StatefulWidget {
  final int id,restaurantId;
  final int price;
  final String name;
  int quantityOfItem;
  MenuListFattarny(
      {this.id,
      this.name,
      this.price,
      this.restaurantId,
      this.quantityOfItem = 0});

  @override
  _MenuListFattarnyState createState() => _MenuListFattarnyState();
}

class _MenuListFattarnyState extends State<MenuListFattarny> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 2, left: 2),
      child: Card(
        elevation: 8.0,
        child: ListTile(
            leading: IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    MenuList.cart[widget.id]++;
                  });
                }),
            title: Text(
              ' \$${widget.price} ' + widget.name,
              style: TextStyle(fontSize: 18.0),
            ),
            subtitle: Text(
              'Quantity: ${MenuList.cart[widget.id]}',
              style: TextStyle(color: Colors.grey, fontSize: 15.0),
            ),
            trailing: IconButton(
                icon: Icon(Icons.remove),
                onPressed: () {
                  setState(() {
                    if (MenuList.cart[widget.id] > 0) {
                      MenuList.cart[widget.id]--;
                    }
                  });
                })),
      ),
    );
  }
}
