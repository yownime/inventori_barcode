import 'package:flutter/material.dart';
import 'package:inventori_bea/tes.dart';
import 'package:inventori_bea/view/Admin/dataadmin.dart';
import 'package:inventori_bea/view/Admin/profile.dart';
import 'package:inventori_bea/view/barang/databarang.dart';
import 'package:inventori_bea/view/barang/tambahbarang.dart';
import 'package:inventori_bea/view/barang_masuk/data_transaksi.dart';
import 'package:inventori_bea/view/laporan/landingpagelaporan.dart';
import 'package:inventori_bea/view/laporan/laporanbarangmasukpage.dart';
import 'package:inventori_bea/view/laporan/laporanbarangkeluarpage.dart';
import 'package:inventori_bea/view/laporan/formlaporan.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Import untuk inisialisasi data lokal
import 'package:inventori_bea/view/laporan/formlbk.dart';
import 'package:inventori_bea/view/laporan/laporanbk.dart';
import 'package:inventori_bea/view/laporan/laporangabungan.dart';
import 'package:inventori_bea/view/laporan/laporanpage.dart';
import 'package:inventori_bea/view/loginpage.dart';
import 'package:inventori_bea/view/lokasi/datalokasi.dart';
import 'package:inventori_bea/view/menupage.dart';
import 'package:inventori_bea/view/stok/datastok.dart';

void main() async {
  // Inisialisasi data lokal
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('en_US', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Login(),
    );
  }
}
