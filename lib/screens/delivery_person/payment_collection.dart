import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
// import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:linear/screens/delivery_person/dp_dashboard.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../helpers/api.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../snackbar.dart';

class PaymentCollection extends StatefulWidget {
  final customer;
  final inv_id;
  final inv_no;
  final balance_amount;
  const PaymentCollection({
    Key? key,
    this.inv_id,
    this.inv_no,
    this.customer,
    this.balance_amount,
  }) : super(key: key);

  @override
  _PaymentCollectionState createState() => _PaymentCollectionState();
}

class _PaymentCollectionState extends State<PaymentCollection> {
  File? image;
  String localpath = '';
  final _picker = ImagePicker();
  bool load = false;
  bool _saving = false;

  String? customer_id = '';
  String? retailer_id = '';
  String? created_by = '';

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _date_so = TextEditingController();
  final TextEditingController _invoice_controller = TextEditingController();
  final TextEditingController _cheque_controller = TextEditingController();
  final TextEditingController _amount_controller = TextEditingController();
  final TextEditingController _notes_controller = TextEditingController();
  final TextEditingController _balance_amount_controller =
      TextEditingController();

  List _invoices = [];
  String _selected_invoice = '';
  List<String> periorty = [
    'Cash',
    'Online Transfer',
    'Payorder',
    'Cheque',
    'Others'
  ];
  var _selectedperirort;

  Future<void> _fetchInvoice(customer_id) async {
    setState(() {
      _saving = true;
    });
    var res = await api.get_due_invoice(customer_id.toString());
    if (res['code_status'] == true) {
      setState(() {
        _saving = false;
      });
      setState(
        () {
          _invoices = res['invoices'];
        },
      );
    }
    // print(res);
  }

  Future getImage() async {
    final pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile != null) {
      setState(() {
        localpath = pickedFile.path;
        load = true;
      });
    } else {
      setState(() {
        localpath = "";
      });
      print('no image selected');
    }
  }

  Future sendImage(
    String apiUrl,
    String imagePath,
    String sale_id,
    String customer_id,
    String paid_by,
    String cheque_no,
    String amount,
    String created_by,
    String note,
  ) async {
    try {
      setState(() {
        _saving = true;
      });
      var request = http.MultipartRequest(
        "POST",
        Uri.parse(apiUrl),
      );
      print('Sale ID $sale_id');
      print('Customer ID $customer_id');
      print('Paid BY $paid_by');
      print('Cheaque No $cheque_no');
      print('Amount $amount');
      print('Created by $created_by');
      print('Note $note');
      request.fields['secret_key'] = 'jfds3=jsldf38&r923m-cjowscdlsdfi03';
      request.fields['sale_id'] = sale_id.toString();
      request.fields['customer_id'] = customer_id.toString();
      request.fields['paid_by'] = paid_by.toString();
      request.fields['cheque_no'] = cheque_no.toString();
      request.fields['amount'] = amount.toString();
      request.fields['created_by'] = created_by.toString();
      request.fields['note'] = note.toString();
      if (imagePath != '') {
        request.files
            .add(await http.MultipartFile.fromPath('attachment', (imagePath)));
      }
      await request.send().then((value) async {
        var result = await value.stream.bytesToString();
        var res = jsonDecode(result);
        setState(() {
          _saving = false;
        });
        if (res['code_status']) {
          showInSnackBar('Payment Saved Successfully');
          Navigator.pop(context);
        } else {
          showInSnackBar(res['message'], color: Colors.red);
        }
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    if (widget.inv_id != null) {
      _invoice_controller.text = widget.inv_no;
      _selected_invoice = widget.inv_id;
      _balance_amount_controller.text = widget.balance_amount;
      _amount_controller.text = widget.balance_amount;
    }
    getdata();
  }

  @override
  Widget build(BuildContext context) {
    if (_invoices.isEmpty) {
      _fetchInvoice(retailer_id.toString());
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Image(
          height: 60,
          fit: BoxFit.contain,
          image: AssetImage(
            'assets/images/distrho_logo.png',
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: ModalProgressHUD(
          inAsyncCall: _saving,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  // decoration: BoxDecoration(
                  //   image: DecorationImage(
                  //       image: AssetImage(
                  //         'assets/images/screen_bg.jpg',
                  //       ),
                  //       fit: BoxFit.cover),
                  // ),
                  child: Container(
                    width: MediaQuery.of(context).size.width - 50,
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: SizedBox(
                            width: double.infinity,
                            height: 80,
                            child: TextFormField(
                              controller: _date_so,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: "Enter Date",
                                border:
                                    OutlineInputBorder(), //label text of field
                              ),
                              // initialValue: DateTime.now(),
                              onChanged: (value) {
                                // subject = value;
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Date Is Required";
                                }
                                return null;
                              },
                              readOnly: true,
                              onTap: () async {
                                DateTime? pickeddate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                );
                                if (pickeddate != null) {
                                  setState(
                                    () {
                                      _date_so.text = DateFormat('yyyy-MM-dd')
                                          .format(pickeddate);
                                    },
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: SizedBox(
                            width: double.infinity,
                            height: 80,
                            child: TextFormField(
                              controller: _invoice_controller,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: "Against Invoice",
                                border:
                                    OutlineInputBorder(), //label text of field
                              ),
                              onChanged: (value) {
                                // subject = value;
                              },
                              readOnly: true,
                              onTap: () => {
                                (widget.inv_id == null)
                                    ? showMaterialModalBottomSheet(
                                        context: context,
                                        backgroundColor: Colors.white,
                                        builder: (context) => Scaffold(
                                          appBar: AppBar(
                                            leading: IconButton(
                                              icon: Icon(Icons.arrow_back,
                                                  color: Colors.black),
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                            ),
                                          ),
                                          body: SingleChildScrollView(
                                            child: Container(
                                              child: Center(
                                                child: ListView.builder(
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  shrinkWrap: true,
                                                  itemCount: _invoices.length,
                                                  itemBuilder:
                                                      (BuildContext ctx,
                                                          index) {
                                                    return InkWell(
                                                      onTap: () {
                                                        if (_invoices[index][
                                                                'reference_no'] !=
                                                            null) {
                                                          setState(() {
                                                            _invoice_controller
                                                                .text = _invoices[
                                                                        index][
                                                                    'reference_no']
                                                                .toString();

                                                            _amount_controller
                                                                .text = _invoices[
                                                                        index]
                                                                    ['balance']
                                                                .toString();

                                                            _balance_amount_controller
                                                                .text = _invoices[
                                                                        index]
                                                                    ['balance']
                                                                .toString();

                                                            _selected_invoice =
                                                                _invoices[index]
                                                                    ['id'];
                                                            // customer = _customer[index]['id']!;
                                                          });
                                                        }
                                                        Navigator.pop(context);
                                                      },
                                                      child: Card(
                                                        child: ListTile(
                                                          leading: Icon(Icons
                                                              .inventory_2),
                                                          title: Text(_invoices[
                                                                  index]
                                                              ['reference_no']),
                                                          subtitle: Text('PKR. ' +
                                                              _invoices[index]
                                                                  ["balance"]),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : print('asdas'),
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Select Invoice";
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: SizedBox(
                            width: double.infinity,
                            height: 80,
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              readOnly: true,
                              controller: _balance_amount_controller,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: "Balance Amount",
                                border:
                                    OutlineInputBorder(), //label text of field
                              ),
                              onChanged: (value) {
                                // subject = value;
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Balance Amount Is Required";
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: SizedBox(
                            width: double.infinity,
                            height: 80,
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              controller: _amount_controller,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: "Amount",
                                border:
                                    OutlineInputBorder(), //label text of field
                              ),
                              onChanged: (value) {
                                // subject = value;
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Amount Is Required";
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          height: 80,
                          width: MediaQuery.of(context).size.width - 40,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(width: 0.5),
                              borderRadius: BorderRadius.circular(3)),
                          child: DropdownButtonFormField(
                            isExpanded: true,
                            hint: Text('Please choose Payment Type'),
                            value: _selectedperirort,
                            onChanged: (newValue) {
                              setState(() {
                                _selectedperirort = newValue;
                              });
                            },
                            items: periorty.map((location) {
                              return DropdownMenuItem(
                                value: location,
                                child: Text(location),
                              );
                            }).toList(),
                            validator: (value) =>
                                value == null ? 'Priority required' : null,
                            icon: Icon(Icons.arrow_drop_down),
                            iconSize: 42,
                          ),
                        ),
                        (_selectedperirort == 'Cheque')
                            ? Column(
                                children: [
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18),
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: 80,
                                      child: TextFormField(
                                        controller: _cheque_controller,
                                        keyboardType: TextInputType.multiline,
                                        maxLines: null,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          labelText: "Cheaque No",
                                          border:
                                              OutlineInputBorder(), //label text of field
                                        ),
                                        onChanged: (value) {
                                          // message = value;
                                        },
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return "Cheaque No Is Required";
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 2,
                                  ),
                                ],
                              )
                            : SizedBox(
                                height: 20,
                              ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: SizedBox(
                            width: double.infinity,
                            height: 70,
                            child: TextFormField(
                              controller: _notes_controller,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: "Note",
                                border:
                                    OutlineInputBorder(), //label text of field
                              ),
                              onChanged: (value) {
                                // message = value;
                              },
                              validator: (value) {
                                // if (value!.isEmpty) {
                                //   return "Note Is Required";
                                // }
                                // return null;
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                          width: 350,
                          child: ElevatedButton(
                            onPressed: () => {getImage()},
                            child: Text('Upload Image'),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          child: (load == false)
                              ? SizedBox()
                              : Image.file(
                                  File(localpath).absolute,
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            // Selected Invoice is Sale id
                            print(
                                'Selected Invoice ${_selected_invoice.toString()}');
                            print('Retailer ID ${retailer_id.toString()}');
                            print(
                                'Selected per rirot ${_selectedperirort.toString()}');
                            print('Cheaque ${_cheque_controller.text}');
                            print('Amount ${_amount_controller.text}');
                            print('Created BY ${created_by.toString()}');
                            print('Notes ${_notes_controller.text}');
                            if (this._formKey.currentState!.validate()) {
                              this._formKey.currentState!.save();
                              // uploadImage();
                              var res = await sendImage(
                                'https://orah.distrho.com/api/mobileapp/paymentcollections/create',
                                localpath,
                                _selected_invoice.toString(),
                                retailer_id.toString(),
                                _selectedperirort.toString(),
                                _cheque_controller.text,
                                _amount_controller.text,
                                created_by.toString(),
                                _notes_controller.text,
                              );

                              // var res = await api.create_payment_w_o_image(
                              //   _selected_invoice.toString(),
                              //   retailer_id.toString(),
                              //   _selectedperirort.toString(),
                              //   _cheque_controller.text,
                              //   _amount_controller.text,
                              //   created_by.toString(),
                              //   _notes_controller.text,
                              // );
                              // if (res['code_status'] == true) {
                              //   setState(() {
                              //     _saving = true;
                              //   });
                              //   AwesomeDialog(
                              //     context: context,
                              //     dialogType: DialogType.success,
                              //     animType: AnimType.rightSlide,
                              //     title: 'Success',
                              //     desc: 'Payment Add Successfullyy',
                              //     // btnCancelOnPress: () {},
                              //     btnOkOnPress: () {},
                              //   )..show();
                              // } else {
                              //   setState(() {
                              //     _saving = false;
                              //   });
                              //   AwesomeDialog(
                              //     context: context,
                              //     dialogType: DialogType.error,
                              //     animType: AnimType.rightSlide,
                              //     title: 'Error',
                              //     desc: res['message'],
                              //     // btnCancelOnPress: () {},
                              //     btnOkOnPress: () {},
                              //   )..show();
                              // }
                            }
                          },
                          child: Text('Add Payment'),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void getdata() async {
    final prefs = await SharedPreferences.getInstance();
    created_by = prefs.getString('user_id');
    customer_id = prefs.getString('customer_visit_id');
    retailer_id = prefs.getString('retailer_visit_id');
    setState(() {});
  }
}
