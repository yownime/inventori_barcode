import 'package:flutter/material.dart';
import 'package:inventori_bea/view/laporan/laporanbarangkeluarpage.dart';
import 'package:inventori_bea/view/laporan/laporanbarangmasukpage.dart';
import 'package:inventori_bea/view/laporan/laporangabungan.dart';
import '../../model/CountData.dart';
import '../../model/api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LaporanLandingPage extends StatefulWidget {
  const LaporanLandingPage({Key? key}) : super(key: key);

  @override
  State<LaporanLandingPage> createState() => _LaporanLandingPageState();
}

class _LaporanLandingPageState extends State<LaporanLandingPage> {
  var loading = false;
  String jmCount = "0";
  String jkCount = "0";
  final ex = List<CountData>.empty(growable: true);

  Future<void> _countBR() async {
    setState(() {
      loading = true;
    });
    ex.clear();

    try {
      final response = await http.get(Uri.parse(BaseUrl.urlCount));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        data.forEach((api) {
          final exp = CountData(api['stok']?.toString() ?? "0",
              api['jm']?.toString() ?? "0", api['jk']?.toString() ?? "0");
          ex.add(exp);
        });

        if (ex.isNotEmpty) {
          setState(() {
            jmCount = ex.first.jm;
            jkCount = ex.first.jk;
          });
        }
      }
    } catch (e) {
      print("Error fetching data: $e");
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _countBR();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(180),
        child: Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 33, 92, 255),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.assessment_outlined,
                          color: Colors.white, size: 28),
                      SizedBox(width: 12),
                      Text(
                        "Laporan Overview",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time, color: Colors.white70),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "2025-02-03 02:52:46",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Laporan Page",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Statistik Transaksi",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      "Barang Masuk",
                      //terapkan disini countnya
                      jmCount,
                      Color(0xFF2196F3),
                      Icons.download_rounded,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      "Barang Keluar",
                      //terapkan disini countnya
                      jkCount,
                      Color(0xFFE53935),
                      Icons.upload_rounded,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),
              Text(
                "Jenis Laporan",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),
              _buildReportCard(
                context,
                title: "Laporan Barang Masuk",
                subtitle: "Lihat detail transaksi barang masuk",
                icon: Icons.download_rounded,
                color: Color(0xFF2196F3),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LaporanBarangMasukPage()),
                ),
              ),
              SizedBox(height: 16),
              _buildReportCard(
                context,
                title: "Laporan Barang Keluar",
                subtitle: "Lihat detail transaksi barang keluar",
                icon: Icons.upload_rounded,
                color: Color(0xFFE53935),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LaporanBarangKeluarPage()),
                ),
              ),
              SizedBox(height: 16),
              _buildReportCard(
                context,
                title: "Semua Transaksi",
                subtitle: "Lihat seluruh riwayat transaksi",
                icon: Icons.assessment_outlined,
                color: Color(0xFF4CAF50),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LaporanGabunganPage()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: color,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
