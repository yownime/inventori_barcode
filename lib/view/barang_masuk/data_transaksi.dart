import 'package:flutter/material.dart';
import '../../model/api.dart';
import '../../model/TransaksiMasukModel.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import '../../loading.dart';
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'detail_transaksi.dart';
import 'keranjang_bm.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataTransaksi extends StatefulWidget {
  @override
  State<DataTransaksi> createState() => _DataTransaksiState();
}

class _DataTransaksiState extends State<DataTransaksi> {
  var loading = false;
  String? LvlUsr;
  final list = [];
  final GlobalKey<RefreshIndicatorState> _refresh =
      GlobalKey<RefreshIndicatorState>();
  getPref() async {
    _lihatData();
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      LvlUsr = pref.getString("level");
    });
  }

  Future<void> _lihatData() async {
    list.clear();
    setState(() {
      loading = true;
    });
    final response = await http.get(Uri.parse(BaseUrl.urlTransaksiBM));
    if (response.contentLength == 2) {
    } else {
      final data = jsonDecode(response.body);
      data.forEach((api) {
        final ab = new TransaksiMasukModel(api['id_transaksi'], api['tujuan'],
            api['total_item'], api['tgl_transaksi'], api['keterangan']);
        list.add(ab);
      });
      setState(() {
        loading = false;
      });
    }
  }

  _proseshapus(String id) async {
    final response =
        await http.post(Uri.parse(BaseUrl.urlHapusBM), body: {"id": id});
    final data = jsonDecode(response.body);
    int value = data['success'];
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

  alertHapus(String id) {
    AwesomeDialog(
      dismissOnTouchOutside: false,
      context: context,
      dialogType: DialogType.warning,
      headerAnimationLoop: false,
      animType: AnimType.topSlide,
      showCloseIcon: true,
      closeIcon: const Icon(Icons.close_fullscreen_outlined),
      title: 'WARNING!!',
      desc:
          'Menghapus data ini akan mengembalikan stok seperti sebelum barang ini di input, Yakin Hapus??',
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        _proseshapus(id);
      },
    ).show();
  }

  dialogHapus(String pesan) {
    AwesomeDialog(
      dismissOnTouchOutside: false,
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.rightSlide,
      headerAnimationLoop: false,
      title: 'ERROR',
      desc: pesan,
      btnOkOnPress: () {},
      btnOkIcon: Icons.cancel,
      btnOkColor: Colors.red,
    ).show();
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            child: AppBar(
              automaticallyImplyLeading: true,
              backgroundColor: Color(0xFF2E7D32),
              elevation: 0,
              title: Text(
                "Transaksi Barang Masuk",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              actions: [
                Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    backgroundColor: Colors.white24,
                    child: Text(
                      "${list.length}",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => KeranjangBm()),
          );
        },
        icon: Icon(
          Icons.add_shopping_cart,
          color: Colors.white,
        ),
        label: Text(
          "Tambah Transaksi",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF2E7D32),
        elevation: 4,
      ),
      body: RefreshIndicator(
        onRefresh: _lihatData,
        key: _refresh,
        child: loading
            ? Loading()
            : list.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final x = list[i];
                      return _buildTransactionCard(x);
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            "Belum ada transaksi",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(TransaksiMasukModel x) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DetailTransaksi(x, _lihatData),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFF2E7D32).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      x.id_transaksi.toString(),
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetailTransaksi(x, _lihatData),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.visibility_outlined,
                          color: Color(0xFF2E7D32),
                        ),
                        tooltip: "Lihat Detail",
                      ),
                      if (LvlUsr == "1") ...[
                        IconButton(
                          onPressed: () =>
                              alertHapus(x.id_transaksi.toString()),
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.red[400],
                          ),
                          tooltip: "Hapus Transaksi",
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  _buildInfoItem(
                    icon: Icons.inventory_2_outlined,
                    label: "Total Item",
                    value: x.total_item.toString(),
                  ),
                  SizedBox(width: 24),
                  _buildInfoItem(
                    icon: Icons.location_on_outlined,
                    label: "Tujuan",
                    value: x.tujuan.toString(),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildInfoItem(
                icon: Icons.access_time_outlined,
                label: "Tanggal Transaksi",
                value: x.tgl_transaksi.toString(),
              ),
              if (x.keterangan != null && x.keterangan != "") ...[
                ...[
                  SizedBox(height: 12),
                  _buildInfoItem(
                    icon: Icons.notes_outlined,
                    label: "Keterangan",
                    value: x.keterangan.toString(),
                  ),
                ],
              ],
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
        ),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
