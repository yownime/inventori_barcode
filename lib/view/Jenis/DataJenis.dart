import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:inventori_bea/loading.dart';
import 'dart:convert';
import 'package:inventori_bea/model/JenisModel.dart';
import 'package:inventori_bea/model/api.dart';
import 'package:http/http.dart' as http;
import 'package:inventori_bea/view/Jenis/editjenis.dart';
import 'package:inventori_bea/view/Jenis/tambahjenis.dart';

class Datajenis extends StatefulWidget {
  @override
  State<Datajenis> createState() => _DatajenisState();
}

class _DatajenisState extends State<Datajenis> {
  // buat loading
  var loading = false;
  final list = [];
  final GlobalKey<RefreshIndicatorState> _refresh =
      GlobalKey<RefreshIndicatorState>();

  //buat preferensi
  getPref() async {
    _lihatData();
  }

  //buat tarik data dari api & model
  Future<void> _lihatData() async {
    list.clear();
    setState(() {
      loading = true;
    });
    final response = await http.get(Uri.parse(BaseUrl.urlDataJenis));
    if (response.contentLength == 2) {
    } else {
      final data = jsonDecode(response.body);
      data.forEach((api) {
        final ab = new JenisModel(api['id_jenis'], api['nama_jenis']);
        list.add(ab);
      });
      setState(() {
        loading = false;
      });
    }
  }

  //delete section
  //Proses hapus
  ProsesHapus(String id) async {
    final response = await http
        .post(Uri.parse(BaseUrl.urlHapusJenis), body: {"id_jenis": id});
    final data = jsonDecode(response.body);
    int value = data['succes'];
    String pesan = data['message'];
    if (value == 1) {
      setState(() {
        _lihatData();
      });
    } else {
      print(pesan);
      dialogHapus(pesan);
    }
  }

  dialogHapus(String pesan) {
    AwesomeDialog(
      dismissOnTouchOutside: false,
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.rightSlide,
      title: 'Peringatan',
      desc: pesan,
      btnOkOnPress: () {},
      btnOkIcon: Icons.cancel,
      btnOkColor: Colors.red,
    ).show();
  }

  //buat nangkep stream data
  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appbar and features
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xff18396B),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Text(
                "Data Jenis Barang",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
          Navigator.push(context,
              MaterialPageRoute(builder: ((context) => Tambahjenis())));
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Color(0xff18396B),
      ),

      //body start
      body:
          // konsumsi data
          RefreshIndicator(
              onRefresh: _lihatData,
              key: _refresh,
              child: loading
                  ? Loading()

                  //list view
                  : ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, i) {
                        final x = list[i];
                        return

                            // Start Styling the container for jenis
                            Container(
                          margin: EdgeInsets.only(top: 10, left: 20, right: 20),
                          child: Card(
                            color: const Color.fromARGB(255, 250, 248, 246),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ListTile(
                                  title: Text(
                                    x.nama_jenis.toString(),
                                  ),
                                  trailing: Wrap(
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        Editjenis(
                                                            x, _lihatData)));
                                          },
                                          icon: Icon(Icons.edit)),
                                      IconButton(
                                          onPressed: () {
                                            ProsesHapus(x.id_jenis);
                                          },
                                          icon: Icon(Icons.delete)),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    )),
    );
  }
}
