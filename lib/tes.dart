import 'package:flutter/material.dart';
import '../../model/api.dart';
import '../../model/CountData.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Tes extends StatefulWidget {
  const Tes({super.key});

  @override
  State<Tes> createState() => _TesState();
}

class _TesState extends State<Tes> {
  var loading = false;
  String Stl = "0";
  String Sbm = "0";
  String Sbk = "0";
  final ex = List<CountData>.empty(growable: true);
  _countBR() async {
    setState(() {
      loading = true;
    });
    ex.clear();
    final response = await http.get(Uri.parse(BaseUrl.urlCount));
    final data = jsonDecode(response.body);
    data.forEach((api) {
      final exp = new CountData(api['stok'], api['jm'], api['jk']);
      ex.add(exp);
      setState(() {
        Stl = exp.stok.toString();
        Sbm = exp.jm.toString();
        Sbk = exp.jk.toString();
      });
    });
    setState(() {
      _countBR();
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _countBR();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ListTile(
            title: Text("Total Barang Masuk",
                style: TextStyle(color: Color.fromARGB(255, 23, 33, 41))),
            subtitle: Sbm == "null"
                ? Text("0",
                    style: TextStyle(
                        color: Color.fromARGB(255, 23, 33, 41),
                        fontSize: 20,
                        fontWeight: FontWeight.bold))
                : Text(Sbm,
                    style: TextStyle(
                        color: Color.fromARGB(255, 23, 33, 41),
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
            trailing: FaIcon(FontAwesomeIcons.box, size: 40),
          ),
        ],
      ),
    );
  }
}
