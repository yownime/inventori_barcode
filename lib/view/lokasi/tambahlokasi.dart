import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:inventori_bea/view/lokasi/datalokasi.dart';
import 'dart:convert';
import '../../model/api.dart';

class Tambahlokasi extends StatefulWidget {
  @override
  State<Tambahlokasi> createState() => _TambahlokasiState();
}

class _TambahlokasiState extends State<Tambahlokasi> {
  FocusNode myFocusNode = new FocusNode();
  String? lokasi;
  final formKey = GlobalKey<FormState>();
  check() {
    final form = formKey.currentState;
    if ((form! as dynamic).validate()) {
      (form as dynamic).save();
      simpanLokasi();
    }
  }

  simpanLokasi() async {
    try {
      final response = await http.post(
          Uri.parse(BaseUrl.urlTambahLokasi.toString()),
          body: {"lokasi": lokasi});
      final data = jsonDecode(response.body);
      print(data);
      int code = data['succes'];
      String pesan = data['message'];
      print(data);
      if (code == 1) {
        setState(() {
          Navigator.pop(context);
          Navigator.push(
              context, MaterialPageRoute(builder: ((context) => Datalokasi())));
        });
      } else {
        print(pesan);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(244, 255, 255, 255),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xff18396B),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Text(
                "Tambah Lokasi Barang",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ],
        ),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: <Widget>[
            TextFormField(
              validator: (e) {
                if ((e as dynamic).isEmpty) {
                  return "Lokasi tidak boleh kosong";
                }
                return null;
              },
              onSaved: (e) => lokasi = e,
              decoration: InputDecoration(
                labelText: "Lokasi Barang",
                labelStyle: TextStyle(
                    color: myFocusNode.hasFocus ? Colors.blue : Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: const Color.fromARGB(255, 1, 94, 170))),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            MaterialButton(
              color: Color(0xff18396B),
              //customize size button
              minWidth: double.infinity,
              height: 45,

              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              onPressed: () {
                check();
              },
              child: Text(
                "Simpan",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
