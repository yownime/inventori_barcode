import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

// Import model dan API Anda
import '../../model/LaporanGabunganModel.dart';
import '../../model/api.dart';
import '../../controller/datepicker.dart'; // Widget DateDropDown untuk memilih tanggal

class LaporanGabunganPage extends StatefulWidget {
  const LaporanGabunganPage({Key? key}) : super(key: key);

  @override
  State<LaporanGabunganPage> createState() => _LaporanGabunganPageState();
}

class _LaporanGabunganPageState extends State<LaporanGabunganPage> {
  final _formKey = GlobalKey<FormState>();

  DateTime tgl1 = DateTime.now();
  DateTime tgl2 = DateTime.now();

  String? pilihTanggal1;
  String? pilihTanggal2;

  bool loading = false;
  List<LaporanGabunganModel> list = [];

  Uri get _urlpdf => Uri.parse(BaseUrl.urlgabunganPdf +
      DateFormat('yyyy-MM-dd').format(tgl1) +
      "&&t2=" +
      DateFormat('yyyy-MM-dd').format(tgl2));

  Uri get _urlcsv => Uri.parse(BaseUrl.urlgabunganCsv +
      DateFormat('yyyy-MM-dd').format(tgl1) +
      "&&t2=" +
      DateFormat('yyyy-MM-dd').format(tgl2));

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

  Future<void> _lihatData() async {
    list.clear();
    setState(() {
      loading = true;
    });

    final response = await http.get(Uri.parse(BaseUrl.urlgabungan +
        DateFormat('yyyy-MM-dd').format(tgl1) +
        "&&tgl2=" +
        DateFormat('yyyy-MM-dd').format(tgl2)));

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      try {
        final data = jsonDecode(response.body);
        data.forEach((api) {
          final laporan = LaporanGabunganModel.fromJson(api);
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
              backgroundColor: Color.fromARGB(255, 33, 92, 255),
              elevation: 0,
              title: Text(
                "Laporan Gabungan",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              actions: [
                _buildExportButton(
                  icon: FontAwesomeIcons.filePdf,
                  color: Colors.red[400]!,
                  onTap: () => _launchInBrowser(_urlpdf),
                ),
                _buildExportButton(
                  icon: FontAwesomeIcons.fileCsv,
                  color: Colors.blue[700]!,
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
                    Text(
                      "Pilih Periode Laporan",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
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
                          backgroundColor: Color.fromARGB(255, 33, 92, 255),
                          iconColor: Color.fromARGB(255, 255, 255, 255),
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
                                color: Colors.white,
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
                    color: Color.fromARGB(255, 33, 92, 255),
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
                            _buildTransactionCard(list[i]),
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
            Icon(
              Icons.calendar_today,
              color: Color.fromARGB(255, 33, 92, 255),
            ),
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
        color: Color.fromARGB(255, 33, 92, 255).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Color.fromARGB(255, 33, 92, 255).withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.date_range,
            size: 18,
            color: Color.fromARGB(255, 33, 92, 255),
          ),
          SizedBox(width: 8),
          Text(
            "${DateFormat.yMd().format(tgl1)} - ${DateFormat.yMd().format(tgl2)}",
            style: TextStyle(
              color: Color.fromARGB(255, 33, 92, 255),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(LaporanGabunganModel data) {
    final isIncoming = data.tipe == "Masuk";
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isIncoming ? Colors.blue[100]! : Colors.red[100]!,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isIncoming ? Colors.blue[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isIncoming ? Icons.arrow_downward : Icons.arrow_upward,
                    color: isIncoming ? Colors.blue : Colors.red,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${data.nama_barang} (${data.nama_brand})",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Jumlah: ${data.jumlah}",
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTransactionInfo(
                  icon: Icons.person_outline,
                  label: "User",
                  value: data.nama ?? "-",
                ),
                _buildTransactionInfo(
                  icon: Icons.access_time,
                  label: "Tanggal",
                  value: data.tgl_transaksi ?? "-",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 4),
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
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
