import 'dart:convert';

import 'package:flutter/material.dart';
import '../../model/LokasiModel.dart';
import 'package:http/http.dart' as http;
import '../../model/api.dart';

class Editlokasi extends StatefulWidget {
  final VoidCallback reload;
  final Lokasimodel model;
  Editlokasi(this.model, this.reload);

  @override
  State<Editlokasi> createState() => _EditlokasiState();
}

class _EditlokasiState extends State<Editlokasi> {
  //bussines logic
  FocusNode myFocusNode = new FocusNode();
  //buat variabel
  String? id_lokasi, lokasi;
  final formKey = GlobalKey<FormState>();
  TextEditingController? txtidlokasi, txtlokasi;

  //setup preview
  setup() {
    id_lokasi = widget.model.id_lokasi;
    txtlokasi = TextEditingController(text: widget.model.nama_lokasi);
  }

  //validasi form
  check() {
    final form = formKey.currentState;
    if ((form as dynamic).validate()) {
      (form as dynamic).save();
      ProsUp();
    }
  }

  ProsUp() async {
    try {
      final respon = await http.post(Uri.parse(BaseUrl.url.toString()),
          body: {"id_lokasi": id_lokasi, "nama_lokasi": lokasi});
      final data = jsonDecode(respon.body);
      print(data);
      int code = data['succes'];
      String pesan = data['message'];
      print(data);
      if (code == 1) {
        setState(() {
          widget.reload();
          Navigator.pop(context);
        });
      } else {
        print(pesan);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    setup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xff321EA5),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Text(
                "Edit Lokasi",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            )
          ],
        ),
      ),
      body: Form(
          key: formKey,
          child: ListView(
            padding: EdgeInsets.all(16),
            children: <Widget>[
              TextFormField(
                controller: txtlokasi,
                validator: (e) {
                  if (e!.isEmpty) {
                    return "silahkan tambahkan jenis";
                  } else {
                    return null;
                  }
                },
                onSaved: (e) => lokasi = e,
                decoration: InputDecoration(
                  labelText: "Lokasi Barang",
                  labelStyle: TextStyle(
                    color: myFocusNode.hasFocus ? Colors.blue : Colors.black,
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xff321EA5),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 25,
              ),
              MaterialButton(
                color: Color(0xff321EA5),
                onPressed: () {
                  check();
                },
                child: Text(
                  "Edit",
                  style: TextStyle(color: Colors.white),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              )
            ],
          )),
    );
  }
}
