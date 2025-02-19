import 'package:flutter/material.dart';
import 'package:inventori_bea/model/api.dart';
import 'package:inventori_bea/model/jenismodel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

class Editjenis extends StatefulWidget {
  final VoidCallback reload;
  final JenisModel model;
  Editjenis(this.model, this.reload);

  @override
  State<Editjenis> createState() => _EditjenisState();
}

class _EditjenisState extends State<Editjenis> {
  //bussines logic
  FocusNode myFocusNode = new FocusNode();
  String? id_jenis, jenis;
  final formKey = GlobalKey<FormState>();
  TextEditingController? txtidJenis, txtJenis;
  setup() {
    id_jenis = widget.model.id_jenis;
    txtJenis = TextEditingController(text: widget.model.nama_jenis);
  }

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
          body: {"id_jenis": id_jenis, "jenis": jenis});
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

  //end bussines logic
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
                "Edit Jenis",
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
                controller: txtJenis,
                validator: (e) {
                  if (e!.isEmpty) {
                    return "silahkan tambahkan jenis";
                  } else {
                    return null;
                  }
                },
                onSaved: (e) => jenis = e,
                decoration: InputDecoration(
                  labelText: "Jenis Barang",
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
