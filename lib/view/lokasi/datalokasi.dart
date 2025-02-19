import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:inventori_bea/loading.dart';
import 'package:inventori_bea/view/lokasi/editlokasi.dart';
import 'package:inventori_bea/view/lokasi/tambahlokasi.dart';
import '../../model/api.dart';
import 'dart:convert';
import '../../model/LokasiModel.dart';

class Datalokasi extends StatefulWidget {
  @override
  State<Datalokasi> createState() => _DatalokasiState();
}

class _DatalokasiState extends State<Datalokasi> {
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
    final response = await http.get(Uri.parse(BaseUrl.urlDataLokasi));
    if (response.contentLength == 2) {
    } else {
      final data = jsonDecode(response.body);
      data.forEach((api) {
        final ab = new Lokasimodel(api['id_lokasi'], api['nama_lokasi']);
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
    print("Menghapus ID: $id"); // Debugging untuk cek ID

    try {
      final response = await http.post(
        Uri.parse(BaseUrl.urlHapusLokasi),
        body: {"id_lokasi": id},
      );

      print("Response: ${response.body}"); // Debugging API Response

      final data = jsonDecode(response.body);
      print("Data dari API: $data"); // Debugging data API

      int value = data['succes'] ?? 0; // Pastikan tidak null
      String pesan = data['message'] ?? "Gagal menghapus";

      if (value == 1) {
        print("Berhasil menghapus lokasi.");
        _lihatData(); // Refresh list
      } else {
        print("Gagal menghapus lokasi: $pesan");
        dialogHapus(pesan);
      }
    } catch (e) {
      print("Error: ${e.toString()}"); // Debugging jika ada kesalahan
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
                "Data Lokasi Barang",
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
              MaterialPageRoute(builder: ((context) => Tambahlokasi())));
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
                                    x.nama_lokasi.toString(),
                                  ),
                                  trailing: Wrap(
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        Editlokasi(
                                                            x, _lihatData)));
                                          },
                                          icon: Icon(Icons.edit)),
                                      IconButton(
                                          onPressed: () {
                                            ProsesHapus(x.id_lokasi);
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
