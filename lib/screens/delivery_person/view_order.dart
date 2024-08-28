import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:linear/const/appColors.dart';
import 'package:linear/screens/delivery_person/dp_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../helpers/globals.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../helpers/api.dart';

import 'payment_collection.dart';
import 'reatiler_visit.dart';

class ViewOrder extends StatefulWidget {
  final String id;
  final String update_id;
  const ViewOrder({Key? key, required this.id, required this.update_id})
      : super(key: key);

  @override
  _ViewOrderState createState() => _ViewOrderState();
}

class _ViewOrderState extends State<ViewOrder> {
  Map _order = {};
  var secret = globals.secret_key;
  bool _isLoading = false;
  var items = [];
  String? user_id = '';
  Future<void> _fetchData(String id) async {
    print(id);
    var res = await api.get_single_sale(id);
    print('Order Details $res');
    if (res['code_status'] == true) {
      setState(
        () {
          _order['data'] = res['order'];
        },
      );
    } else {
      show_msg('error', res['message'], context);
    }
  }

  Future<void> _updateStatus(String id, String user_id, String status) async {
    print(id);
    var res = await api.dm_update_status(user_id, id, status);
    print('Update Status $res');
    if (res['code_status'] == true) {
      show_msg('success', res['message'], context);
    } else {
      show_msg('error', res['message'], context);
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
      await _fetchData(widget.id);
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
        title: Text('Orders Details'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.home, color: Colors.black),
              onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReatilerVisit(),
                    ),
                  )),
        ],
      ),
      body: _order.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Card(
                    child: ListTile(
                        title: Text("Customer Info"),
                        subtitle: Text('Name : ' +
                            _order['data']['customer_name'].toString() +
                            ' \nEmail : ' +
                            _order['data']['customer_email'].toString() +
                            ' \nPhone : ' +
                            _order['data']['customer_phone'].toString() +
                            ''),
                        trailing: ElevatedButton(
                          onPressed: () => {
                            print('This is main id '),
                            print(widget.update_id),
                            (_order['data']['delivery_status'] == "delivered")
                                ? show_msg(
                                    'error', 'Delivered Already', context)
                                : _updateStatus(widget.update_id,
                                    user_id.toString(), 'delivered')
                          },
                          child:
                              (_order['data']['delivery_status'] == "delivered")
                                  ? Text('Delivered')
                                  : Text('Dispatch'),
                        )),
                  ),
                ),
                Container(
                  child: Card(
                    child: ListTile(
                      leading: Icon(Icons.supervised_user_circle),
                      title: Text("Supplier Info"),
                      subtitle: Text(
                          'Name : ' + _order['data']['supplier_name'] + ''),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    // shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _order['data']['items'].length,
                    itemBuilder: (BuildContext ctx, index) {
                      return InkWell(
                        onTap: () {},
                        child: Card(
                          child: ListTile(
                            leading: Icon(Icons.inventory_2),
                            title: Text(
                                _order['data']['items'][index]['product_name']),
                            subtitle: Text(_order['data']['items'][index]
                                ["product_barcode"]),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    decoration: BoxDecoration(
                        color: AppColors.ThemeColor,
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Invoice:',
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                            Container(
                              child: Text(
                                _order['data']['order_no'],
                                style: TextStyle(fontSize: 18),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Balance Amount:',
                              style: TextStyle(fontSize: 18),
                            ),
                            Text(_order['data']['balance'],
                                style: TextStyle(fontSize: 18))
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Amount:',
                                style: TextStyle(fontSize: 18)),
                            Text(_order['data']['grand_total'],
                                style: TextStyle(fontSize: 18))
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Card(
                  child: ListTile(
                    title: Text("Total"),
                    subtitle: Text('Total Items : ' +
                        _order['data']['items'].length.toString()),
                    trailing: ElevatedButton(
                      onPressed: () => {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentCollection(
                              customer: _order['data']['customer_id'],
                              inv_id: _order['data']['order_id'],
                              inv_no: _order['data']['order_no'],
                              balance_amount: _order['data']['balance'],
                            ),
                          ),
                        )
                      },
                      child: Text('Collect Payment'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  show_msg(status, message, context) {
    return AwesomeDialog(
      context: context,
      dialogType: (status == 'error') ? DialogType.error : DialogType.success,
      animType: AnimType.rightSlide,
      title: (status == 'error') ? 'Error' : 'Success',
      desc: message,
      // btnCancelOnPress: () {},
      btnOkOnPress: () {},
    )..show();
  }
}
