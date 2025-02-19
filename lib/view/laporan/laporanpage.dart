import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../model/TanggalModel.dart';
import '../../model/LaporanBmModel.dart';
import '../../model/api.dart';
import 'package:url_launcher/url_launcher.dart';

class LaporanPage extends StatefulWidget {
  final TanggalModel tanggalModel;
  LaporanPage({Key? key, required this.tanggalModel}) : super(key: key);
  @override
  State<LaporanPage> createState() =>
      _LaporanPageState(tanggalModel: tanggalModel);
}

class _LaporanPageState extends State<LaporanPage> {
  late TanggalModel tanggalModel;
  _LaporanPageState({required this.tanggalModel}) : super();
  var loading = false;
  final list = [];
  Future<void>? _launched;
  late Uri _urlpdf = Uri.parse(BaseUrl.urlBmPdf +
      this.tanggalModel.tgl1.toString() +
      "&&t2=" +
      this.tanggalModel.tgl2.toString());
  late Uri _urlcsv = Uri.parse(BaseUrl.urlBmCsv +
      this.tanggalModel.tgl1.toString() +
      "&&t2=" +
      this.tanggalModel.tgl2.toString());
  final GlobalKey<RefreshIndicatorState> _refresh =
      GlobalKey<RefreshIndicatorState>();

  getPref() async {
    _lihatData();
  }

  Future<void> _lihatData() async {
    list.clear();
    setState(() {
      loading = true;
    });

    final response = await http.get(Uri.parse(BaseUrl.urlLaporanBm +
        this.tanggalModel.tgl1.toString() +
        "&&tgl2=" +
        this.tanggalModel.tgl2.toString()));

    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}'); // Cek body response

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      try {
        final data = jsonDecode(response.body);
        data.forEach((api) {
          final ab = LaporanBmModel(
            api['id_barang_masuk'],
            api['id_barang'],
            api['nama_barang'],
            api['nama_brand'],
            api['jumlah_masuk'],
            api['tgl_transaksi'],
            api['keterangan'],
            api['nama'],
          );
          list.add(ab);
        });
        setState(() {
          loading = false;
        });
      } catch (e) {
        print("Error decoding JSON: $e");
        setState(() {
          loading = false;
        });
      }
    } else {
      print("Response is empty or status code is not 200.");
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(255, 41, 69, 91),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Text(
                "Periode " +
                    this.tanggalModel.tgl1.toString().substring(0, 10) +
                    " s/d " +
                    this.tanggalModel.tgl2.toString().substring(0, 10),
                style: TextStyle(color: Colors.white, fontSize: 16.0),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => setState(() {
              _launched = _launchInBrowser(_urlpdf);
            }),
            child: FaIcon(FontAwesomeIcons.filePdf),
            backgroundColor: Color.fromARGB(255, 204, 0, 0),
          ),
          SizedBox(
            width: 20,
          ),
          FloatingActionButton(
            onPressed: () => setState(() {
              _launched = _launchInBrowser(_urlcsv);
            }),
            child: FaIcon(FontAwesomeIcons.fileCsv),
            backgroundColor: Color.fromARGB(255, 0, 128, 0),
          ),
        ],
      ),
      body: RefreshIndicator(
          onRefresh: _lihatData,
          key: _refresh,
          child: loading
              ? Center(
                  child: Text("Data Kosong"),
                )
              : ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final x = list[i];
                    return Container(
                      margin: EdgeInsets.only(top: 10, left: 20, right: 20),
                      child: Card(
                        color: const Color.fromARGB(255, 250, 248, 246),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Table(
                              defaultVerticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              children: <TableRow>[
                                TableRow(children: <Widget>[
                                  ListTile(title: Text("Kode Barang Masuk")),
                                  ListTile(
                                      title: Text(
                                    x.id_barang_masuk.toString(),
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal),
                                  )),
                                ]),
                                TableRow(children: <Widget>[
                                  ListTile(title: Text("Kode Barang")),
                                  ListTile(
                                      title: Text(
                                    x.id_barang.toString(),
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal),
                                  )),
                                ]),
                                TableRow(children: <Widget>[
                                  ListTile(title: Text("Nama Barang")),
                                  ListTile(
                                      title: Text(
                                    x.nama_barang.toString() +
                                        "( " +
                                        x.nama_brand.toString() +
                                        " )",
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal),
                                  )),
                                ]),
                                TableRow(children: <Widget>[
                                  ListTile(title: Text("Jumlah Masuk")),
                                  ListTile(
                                      title: Text(
                                    x.jumlah_masuk.toString(),
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal),
                                  )),
                                ]),
                                TableRow(children: <Widget>[
                                  ListTile(title: Text("Tgl Masuk")),
                                  ListTile(
                                      title: Text(
                                    x.tgl_transaksi.toString(),
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal),
                                  )),
                                ]),
                                TableRow(children: <Widget>[
                                  ListTile(title: Text("Keterangan")),
                                  ListTile(
                                      title: Text(
                                    x.keterangan.toString(),
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal),
                                  )),
                                ]),
                                TableRow(children: <Widget>[
                                  ListTile(title: Text("User Input")),
                                  ListTile(
                                      title: Text(
                                    x.nama.toString(),
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal),
                                  )),
                                ]),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )),
    );
  }
}
