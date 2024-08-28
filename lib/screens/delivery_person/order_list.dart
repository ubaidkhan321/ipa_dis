import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../helpers/api.dart';
import 'view_order.dart';

class OrderList extends StatefulWidget {
  final route_id;
  final retailer_id;
  const OrderList({Key? key, required this.route_id, required this.retailer_id})
      : super(key: key);

  @override
  _OrderListState createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  List _orders = [];
  bool _isLoading = false;
  String? user_id = '';
  Future<void> _fetchData(String user_id, String date, String status,
      String route, String shop) async {
    var res = await api.get_dm_orders(user_id, date, status, route, shop);
    print(res);
    if (res['code_status'] == true) {
      setState(
        () {
          _orders = res['rows'];
        },
      );
    }
  }

  static _read(thekey) async {
    final prefs = await SharedPreferences.getInstance();
    final key = thekey.toString();
    final value = prefs.getString(key);
    print('saved tester $value');
    String usu = (value != null ? value : '');
    return usu;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      user_id = await _read('user_id');
      var now = new DateTime.now();
      var inputFormat = DateFormat('yyyy-MM-dd');
      String formattedDate = inputFormat.format(now);
      _fetchData(user_id.toString(), formattedDate, '', widget.route_id,
          widget.retailer_id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Orders'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _orders.isEmpty
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: _orders.length,
                itemBuilder: (BuildContext ctx, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewOrder(
                              id: _orders[index]['sale_id'].toString(),
                              update_id: _orders[index]['id'].toString(),
                            ),
                          ));
                    },
                    child: Card(
                      child: ListTile(
                        leading: Icon(Icons.inventory_2),
                        title: Text(_orders[index]['reference_no']),
                        subtitle: Text(_orders[index]["delivery_date"]),
                        trailing: Column(
                          children: [
                            Text(
                              'Order Status : ' + _orders[index]["status"],
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      (_orders[index]["status"] == 'delivered')
                                          ? Colors.green
                                          : Colors.amber,
                                  fontSize: 15),
                            ),
                            Text(
                              'Payment Status : Partial',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                  fontSize: 15),
                            )
                          ],
                        ),
                        // trailing: (_orders[index]["status"] != "pending")
                        //     ? Icon(
                        //         Icons.check,
                        //         color: Colors.green,
                        //         size: 30.0,
                        //       )
                        //     : Icon(
                        //         Icons.mark_as_unread,
                        //         color: Colors.green,
                        //         size: 30.0,
                        //       ),
                      ),
                    ),
                  );
                }),
      ),
    );
  }
}
