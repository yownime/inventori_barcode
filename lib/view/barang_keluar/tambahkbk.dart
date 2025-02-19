import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:inventori_bea/view/barang/databarang.dart';
import '../../model/BarangModel.dart';
import '../../model/api.dart';
import '../../model/StockModel.dart';
import 'dart:ui';
import 'keranjangbk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class TambahKbk extends StatefulWidget {
  @override
  State<TambahKbk> createState() => _TambahKbkState();
}

class _TambahKbkState extends State<TambahKbk> {
  FocusNode JmFocusNode = FocusNode();
  String? IdAdm, Barang, Jumlah;
  BarangModel? _selectedBarang;
  final _key = GlobalKey<FormState>();
  List<BarangModel> _barangList = [];
  StokModel? _currentStock;
  bool _isLoadingStock = false;

  @override
  void initState() {
    super.initState();
    getPref();
    _fetchBarang();
  }

  getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      IdAdm = pref.getString("id");
    });
  }

  Future<void> _fetchBarang() async {
    try {
      var response =
          await http.get(Uri.parse(BaseUrl.urlDataBarang.toString()));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          _barangList = data.map((e) => BarangModel.fromJson(e)).toList();
        });
      }
    } catch (e) {
      print("Error load barang: $e");
    }
  }

  Future<void> _fetchStock(String idBarang) async {
    setState(() => _isLoadingStock = true);
    try {
      final response = await http
          .get(Uri.parse("${BaseUrl.urlDataStok}?id_barang=$idBarang"));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          setState(() => _currentStock = StokModel.fromJson(data[0]));
        }
      }
    } catch (e) {
      print("Error fetching stock: $e");
    } finally {
      setState(() => _isLoadingStock = false);
    }
  }

  Future<void> scanBarcode() async {
    String barcode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Batal', true, ScanMode.BARCODE);

    if (barcode != '-1') {
      _findBarangByBarcode(barcode);
    }
  }

  void _findBarangByBarcode(String barcode) {
    try {
      BarangModel foundBarang = _barangList.firstWhere(
        (br) => br.barcode == barcode,
      );

      setState(() => _selectedBarang = foundBarang);
      _fetchStock(foundBarang.id_barang!);
    } catch (e) {
      _showBarangNotFoundDialog(barcode);
    }
  }

  void _validateForm() {
    if (_key.currentState!.validate()) {
      _key.currentState!.save();
      if (_currentStock == null) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          title: 'Peringatan',
          desc: 'Silahkan tunggu data stok selesai dimuat',
        ).show();
        return;
      }
      _checkStock();
    }
  }

  void _checkStock() {
    int stok = int.tryParse(_currentStock!.stok ?? '0') ?? 0;
    int jumlah = int.tryParse(Jumlah ?? '0') ?? 0;

    if (jumlah > stok) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: 'Stok Tidak Cukup',
        desc: 'Stok tersedia: $stok',
      ).show();
    } else {
      _simpanTransaksi();
    }
  }

  Future<void> _simpanTransaksi() async {
    try {
      final response = await http.post(
        Uri.parse(BaseUrl.urlInputCBK.toString()),
        body: {
          "barang": _selectedBarang!.id_barang,
          "jumlah": Jumlah,
          "id": IdAdm,
          "stok_sebelum": _currentStock!.stok.toString()
        },
      );

      final data = jsonDecode(response.body);
      if (data['success'] == 1) {
        _showSuccessDialog(data['message']);
      } else {
        throw Exception(data['message']);
      }
    } catch (e) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: 'Gagal',
        desc: e.toString(),
      ).show();
    }
  }

  void _showSuccessDialog(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      title: 'Sukses',
      desc: message,
      btnOkOnPress: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => KeranjangBK()),
        );
      },
    ).show();
  }

  void _showBarangNotFoundDialog(String barcode) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      title: 'Barang Tidak Ditemukan',
      desc: 'Barcode $barcode tidak terdaftar',
      btnOkText: 'Daftarkan',
      btnCancelText: 'Tutup',
      btnOkOnPress: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DataBarang(),
            settings: RouteSettings(arguments: {'barcode': barcode}),
          ),
        );
      },
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color.fromARGB(255, 0, 0, 0);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 33, 92, 255),
        title: const Text(
          "Tambah Barang Keluar",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.topCenter,
            colors: [
              primaryColor.withOpacity(0.05),
              Colors.grey[50]!,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _key,
            child: ListView(
              children: [
                Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Detail Barang",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<BarangModel>(
                          value: _selectedBarang,
                          decoration: InputDecoration(
                            labelText: 'Pilih Barang',
                            labelStyle: TextStyle(color: primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: primaryColor),
                            ),
                            prefixIcon:
                                Icon(Icons.inventory, color: primaryColor),
                          ),
                          items: _barangList
                              .map((br) => DropdownMenuItem(
                                    value: br,
                                    child: Text(br.nama_barang ?? ''),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedBarang = value;
                              _currentStock = null;
                            });
                            if (value?.id_barang != null) {
                              _fetchStock(value!.id_barang!);
                            }
                          },
                          validator: (value) =>
                              value == null ? 'Pilih barang' : null,
                        ),
                        SizedBox(height: 16),
                        if (_isLoadingStock)
                          Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(primaryColor),
                            ),
                          ),
                        if (_currentStock != null && !_isLoadingStock)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: primaryColor.withOpacity(0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 20,
                                  color: primaryColor,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Stok Tersedia: ${_currentStock!.stok}',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Scan & Input",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: scanBarcode,
                          icon: Icon(
                            Icons.qr_code_scanner,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Scan Barcode',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 37, 70, 255),
                            iconColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            elevation: 0,
                          ),
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Jumlah Keluar',
                            labelStyle: TextStyle(color: primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: primaryColor),
                            ),
                            prefixIcon:
                                Icon(Icons.numbers, color: primaryColor),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Isi jumlah';
                            if (int.tryParse(value!) == null)
                              return 'Harus angka';
                            if (int.parse(value) <= 0) return 'Minimal 1';
                            return null;
                          },
                          onSaved: (value) => Jumlah = value,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _validateForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 33, 92, 255),
                    iconColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save),
                      SizedBox(width: 8),
                      Text(
                        'Simpan Transaksi',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
