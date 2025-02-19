import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import '../../model/TanggalModel.dart';
import '../../controller/datepicker.dart';
import 'LaporanPage.dart';

class FormLaporan extends StatefulWidget {
  const FormLaporan({Key? key}) : super(key: key);

  @override
  State<FormLaporan> createState() => _FormLaporanState();
}

class _FormLaporanState extends State<FormLaporan> {
  final _key = GlobalKey<FormState>();
  send() {
    TanggalModel tanggalModel = TanggalModel("$tgl1", "$tgl2");
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => LaporanPage(tanggalModel: tanggalModel)));
  }

  String? pilihTanggal, labelText;
  DateTime tgl1 = DateTime.now();
  final TextStyle valueStyle = TextStyle(fontSize: 16.0);
  Future<Null> _selctedDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: tgl1,
        firstDate: DateTime(1990),
        lastDate: DateTime(2099));
    if (picked != null && picked != tgl1) {
      setState(() {
        tgl1 = picked;
        pilihTanggal = DateFormat.yMd().format(tgl1);
      });
    } else {}
  }

  String? Tanggal2, labelText2;
  DateTime tgl2 = new DateTime.now();
  final TextStyle valueStyle2 = TextStyle(fontSize: 16.0);
  Future<Null> _selctedDate2(BuildContext context) async {
    final DateTime? picked2 = await showDatePicker(
        context: context,
        initialDate: tgl2,
        firstDate: DateTime(1990),
        lastDate: DateTime(2099));
    if (picked2 != null && picked2 != tgl2) {
      setState(() {
        tgl2 = picked2;
        Tanggal2 = new DateFormat.yMd().format(tgl2);
      });
    } else {}
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(244, 244, 244, 1),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color.fromARGB(255, 41, 69, 91),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                child: Text(
                  "Form Laporan Barang Masuk",
                  style: TextStyle(color: Colors.white, fontSize: 20.0),
                ),
              )
            ],
          ),
        ),
        body: Form(
          key: _key,
          child: ListView(
            padding: EdgeInsets.all(16.0),
            children: <Widget>[
              DateDropDown(
                labelText: "Dari",
                valueText: new DateFormat.yMd().format(tgl1),
                valueStyle: valueStyle,
                onPressed: () {
                  _selctedDate(context);
                },
              ),
              SizedBox(
                height: 20,
              ),
              DateDropDown(
                labelText: "Sampai",
                valueText: new DateFormat.yMd().format(tgl2),
                valueStyle: valueStyle2,
                onPressed: () {
                  _selctedDate2(context);
                },
              ),
              SizedBox(
                height: 25,
              ),
              MaterialButton(
                color: Color.fromARGB(255, 41, 69, 91),
                onPressed: () {
                  send();
                },
                child: Text(
                  "Laporan",
                  style: TextStyle(color: Colors.white),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              )
            ],
          ),
        ));
  }
}
