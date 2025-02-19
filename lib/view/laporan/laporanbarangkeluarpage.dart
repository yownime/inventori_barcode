import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

// Pastikan model dan API Anda sudah tersedia
import '../../model/TanggalModel.dart';
import '../../model/LaporanBkModel.dart';
import '../../model/api.dart';
import '../../controller/datepicker.dart'; // Widget DateDropDown harus sudah ada

class LaporanBarangKeluarPage extends StatefulWidget {
  const LaporanBarangKeluarPage({Key? key}) : super(key: key);

  @override
  State<LaporanBarangKeluarPage> createState() =>
      _LaporanBarangKeluarPageState();
}

class _LaporanBarangKeluarPageState extends State<LaporanBarangKeluarPage> {
  final _formKey = GlobalKey<FormState>();

  // Inisialisasi tanggal awal dan akhir
  DateTime tgl1 = DateTime.now();
  DateTime tgl2 = DateTime.now();

  // Variabel untuk menampilkan tanggal dalam format tertentu di form
  String? pilihTanggal1;
  String? pilihTanggal2;

  // Variabel untuk loading data dan menyimpan list laporan
  bool loading = false;
  List<dynamic> list = [];

  // URL untuk file PDF dan CSV (sesuaikan dengan API Anda)
  Uri get _urlpdf => Uri.parse(BaseUrl.urlBkPdf +
      DateFormat('yyyy-MM-dd').format(tgl1) +
      "&&t2=" +
      DateFormat('yyyy-MM-dd').format(tgl2));
  Uri get _urlcsv => Uri.parse(BaseUrl.urlBkCsv +
      DateFormat('yyyy-MM-dd').format(tgl1) +
      "&&t2=" +
      DateFormat('yyyy-MM-dd').format(tgl2));

  // Fungsi memilih tanggal awal
  Future<void> _selectDate1(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: tgl1,
      firstDate: DateTime(1990),
      lastDate: DateTime(2099),
    );
    if (picked != null && picked != tgl1) {
      setState(() {
        tgl1 = picked;
        pilihTanggal1 = DateFormat.yMd().format(tgl1);
      });
    }
  }

  // Fungsi memilih tanggal akhir
  Future<void> _selectDate2(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: tgl2,
      firstDate: DateTime(1990),
      lastDate: DateTime(2099),
    );
    if (picked != null && picked != tgl2) {
      setState(() {
        tgl2 = picked;
        pilihTanggal2 = DateFormat.yMd().format(tgl2);
      });
    }
  }

  // Fungsi untuk mengambil data laporan barang keluar sesuai periode yang dipilih
  Future<void> _lihatData() async {
    list.clear();
    setState(() {
      loading = true;
    });

    final response = await http.get(Uri.parse(BaseUrl.urlLaporanBk +
        DateFormat('yyyy-MM-dd').format(tgl1) +
        "&&tgl2=" +
        DateFormat('yyyy-MM-dd').format(tgl2)));

    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      try {
        final data = jsonDecode(response.body);
        data.forEach((api) {
          final laporan = LaporanBkModel(
            api['id_barang_keluar'],
            api['id_barang'],
            api['nama_barang'],
            api['nama_brand'],
            api['jumlah_keluar'],
            api['tgl_transaksi'],
            api['keterangan'],
            api['nama'],
          );
          list.add(laporan);
        });
      } catch (e) {
        print("Error decoding JSON: $e");
      }
    } else {
      print("Response kosong atau status code bukan 200.");
    }

    setState(() {
      loading = false;
    });
  }

  // Fungsi untuk membuka URL (PDF/CSV) di browser eksternal
  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
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
              backgroundColor:
                  Color(0xFFE53935), // Red color for outgoing items
              elevation: 0,
              title: Row(
                children: [
                  Text(
                    "Laporan Keluar",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              actions: [
                _buildExportButton(
                  icon: FontAwesomeIcons.filePdf,
                  color: Colors.red[400]!,
                  onTap: () => _launchInBrowser(_urlpdf),
                ),
                _buildExportButton(
                  icon: FontAwesomeIcons.fileCsv,
                  color: Colors.green[600]!,
                  onTap: () => _launchInBrowser(_urlcsv),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.date_range_rounded,
                          color: Color(0xFFE53935),
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Pilih Periode Laporan",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    _buildDatePicker(
                      label: "Dari Tanggal",
                      value: pilihTanggal1 ?? DateFormat.yMd().format(tgl1),
                      onTap: () => _selectDate1(context),
                    ),
                    SizedBox(height: 16),
                    _buildDatePicker(
                      label: "Sampai Tanggal",
                      value: pilihTanggal2 ?? DateFormat.yMd().format(tgl2),
                      onTap: () => _selectDate2(context),
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _lihatData,
                        style: ElevatedButton.styleFrom(
                          iconColor: Color(0xFFE53935),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search),
                            SizedBox(width: 8),
                            Text(
                              "Tampilkan Laporan",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (loading)
                Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFE53935),
                  ),
                )
              else if (list.isNotEmpty)
                Container(
                  margin: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPeriodBadge(),
                      SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: list.length,
                        itemBuilder: (context, i) =>
                            _buildTransactionCard(list[i], i),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExportButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Icon(icon, color: color, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Color(0xFFE53935)),
            SizedBox(width: 12),
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
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFFE53935).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Color(0xFFE53935).withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.date_range,
            size: 18,
            color: Color(0xFFE53935),
          ),
          SizedBox(width: 8),
          Text(
            "${DateFormat.yMd().format(tgl1)} - ${DateFormat.yMd().format(tgl2)}",
            style: TextStyle(
              color: Color(0xFFE53935),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(dynamic data, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 2,
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFFE53935).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.output_rounded,
                      color: Color(0xFFE53935),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "#${data.id_barang_keluar}",
                          style: TextStyle(
                            color: Color(0xFFE53935),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "${data.nama_barang} (${data.nama_brand})",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFFE53935).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${data.jumlah_keluar} items",
                      style: TextStyle(
                        color: Color(0xFFE53935),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  _buildInfoItem(
                    icon: Icons.inventory_2_outlined,
                    label: "Kode Barang",
                    value: data.id_barang,
                  ),
                  SizedBox(width: 24),
                  _buildInfoItem(
                    icon: Icons.access_time_outlined,
                    label: "Tanggal",
                    value: data.tgl_transaksi,
                  ),
                ],
              ),
              if (data.keterangan != null &&
                  data.keterangan.toString().isNotEmpty)
                Column(
                  children: [
                    SizedBox(height: 12),
                    Row(
                      children: [
                        _buildInfoItem(
                          icon: Icons.note_outlined,
                          label: "Keterangan",
                          value: data.keterangan,
                        ),
                      ],
                    ),
                  ],
                ),
              SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoItem(
                    icon: Icons.person_outline,
                    label: "User Input",
                    value: data.nama,
                  ),
                ],
              ),
            ],
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
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
          SizedBox(width: 4),
          Expanded(
            child: Column(
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
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
