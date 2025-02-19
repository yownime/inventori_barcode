import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:inventori_bea/view/barang/databarang.dart';
import 'package:inventori_bea/view/barang/tambahbarang.dart';
import '../../model/BarangModel.dart';
import '../../model/api.dart';
import '../barang_masuk/keranjang_bm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class TambahKbm extends StatefulWidget {
  @override
  State<TambahKbm> createState() => _TambahKbmState();
}

class _TambahKbmState extends State<TambahKbm> {
  FocusNode JmFocusNode = new FocusNode();
  String? IdAdm, Barang, Jumlah;

  // Mengambil ID Admin dari SharedPreferences
  getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      IdAdm = pref.getString("id");
    });
  }

  final _key = new GlobalKey<FormState>();
  BarangModel? _currentBR;
  final String? inkBR = BaseUrl.urlDataBarang;

  // Fetch data barang dari API
  Future<List<BarangModel>> _fetchBR() async {
    try {
      var response = await http.get(Uri.parse(inkBR.toString()));
      print('Response Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final items = json.decode(response.body).cast<Map<String, dynamic>>();
        List<BarangModel> listOfBR = items.map<BarangModel>((json) {
          return BarangModel.fromJson(json);
        }).toList();
        return listOfBR;
      } else {
        print('Error: ${response.body}');
        throw Exception('gagal');
      }
    } catch (e) {
      print('Error fetching barang: $e');
      rethrow;
    }
  }

  // Menampilkan dialog sukses
  dialogSukses(String pesan) {
    AwesomeDialog(
      context: context,
      animType: AnimType.leftSlide,
      headerAnimationLoop: false,
      dialogType: DialogType.success,
      showCloseIcon: true,
      title: 'Sukses',
      desc: pesan,
      btnOkOnPress: () {
        Navigator.pop(context);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => new KeranjangBm()));
      },
      btnOkIcon: Icons.check_circle,
      onDismissCallback: (type) {
        debugPrint('Dialog dismissed from callback: $type');
      },
    ).show();
  }

  // Fungsi pemindaian barcode
  Future<void> scanBarcode() async {
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancel', true, ScanMode.BARCODE);

    if (barcodeScanRes != '-1') {
      setState(() {
        // Mengambil barcode yang dipindai dan cari barang berdasarkan barcode
        Barang = barcodeScanRes;
        debugPrint('Scanned Barcode: $Barang');
        // Mencari barang berdasarkan barcode
        _fetchBarangByBarcode(Barang!);
      });
    }
  }

  // Mencari barang berdasarkan barcode
  Future<void> _fetchBarangByBarcode(String barcode) async {
    try {
      var response =
          await http.get(Uri.parse(inkBR.toString() + "?barcode=$barcode"));
      print('Response Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final items = json.decode(response.body).cast<Map<String, dynamic>>();
        // Di dalam fungsi _fetchBarangByBarcode(), pada blok if (items.isNotEmpty)
        if (items.isNotEmpty) {
          // Kode ketika barang ditemukan
          setState(() {
            _currentBR = BarangModel.fromJson(items[0]);
            Barang = _currentBR!.id_barang;
          });

          // Optional: Tampilkan notifikasi barang ditemukan
          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.leftSlide,
            title: 'Barang Ditemukan',
            desc: '${_currentBR!.nama_barang} (${_currentBR!.nama_brand})',
            btnOkOnPress: () {},
          ).show();
        } else {
          AwesomeDialog(
            context: context,
            animType: AnimType.leftSlide,
            headerAnimationLoop: false,
            dialogType: DialogType.error,
            showCloseIcon: false,
            title: 'Barang Tidak Ditemukan',
            desc:
                'Barang dengan barcode $barcode belum terdaftar. Silahkan daftarkan terlebih dahulu.',
            btnCancelOnPress: () {},
            btnCancelText: 'Tutup',
            btnOkText: 'Tambah',
            btnOkOnPress: () {
              // Navigasi ke halaman tambah barang dengan membawa barcode
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DataBarang(),
                ),
              );
            },
          ).show();
        }
      } else {
        print('Error: ${response.body}');
        throw Exception('gagal');
      }
    } catch (e) {
      print('Error fetching barang by barcode: $e');
    }
  }

  // Memeriksa form dan melakukan simpan
  check() {
    final form = _key.currentState;
    if (form != null && form.validate()) {
      form.save();
      debugPrint('Form validated and saved');
      debugPrint('Barang: $Barang, Jumlah: $Jumlah, IdAdmin: $IdAdm');
      Simpan();
    } else {
      debugPrint('Form not valid');
    }
  }

  // Fungsi untuk menyimpan data
  Simpan() async {
    if (Barang == null || Jumlah == null || IdAdm == null) {
      debugPrint('Data tidak boleh kosong');
      return;
    }

    try {
      debugPrint('Sending request to save data...');
      final response = await http.post(
        Uri.parse(BaseUrl.urlInputCBM.toString()),
        body: {"barang": Barang, "jumlah": Jumlah, "id": IdAdm},
      );
      final data = jsonDecode(response.body);
      debugPrint('Response data: $data');

      int code = data['success'];
      String pesan = data['message'];
      debugPrint('Response success code: $code, message: $pesan');

      if (code == 1) {
        setState(() {
          dialogSukses(pesan);
        });
      } else {
        debugPrint('Error: $pesan');
      }
    } catch (e) {
      debugPrint('Error during saving data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color.fromARGB(255, 33, 92, 255);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: primaryColor,
        title: Center(
          child: Text(
            "Tambah Barang Masuk",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
            Form(
              key: _key,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label untuk Dropdown
                    Text(
                      "Pilih Barang",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    // Dropdown Barang (tetap sama)
                    FutureBuilder<List<BarangModel>>(
                      future: _fetchBR(),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<BarangModel>> snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: primaryColor,
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Text('Error fetching barang');
                        }

                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<BarangModel>(
                              items: snapshot.data!
                                  .map(
                                      (listBR) => DropdownMenuItem<BarangModel>(
                                            child: Text(
                                                '${listBR.nama_barang} (${listBR.nama_brand})'),
                                            value: listBR,
                                          ))
                                  .toList(),
                              onChanged: (BarangModel? value) {
                                setState(() {
                                  _currentBR = value;
                                  Barang = _currentBR?.id_barang;
                                });
                              },
                              isExpanded: true,
                              hint: Text(
                                Barang == null
                                    ? "Pilih Barang"
                                    : '${_currentBR != null ? _currentBR!.nama_barang : "Barang tidak ditemukan"} (${_currentBR != null ? _currentBR!.nama_brand : ""})',
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 24),
                    // Tombol Scan Barcode
                    Container(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: scanBarcode,
                        icon: Icon(Icons.qr_code_scanner),
                        label: Text(
                          'Scan Barcode',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          iconColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    // Label untuk Input Jumlah
                    Text(
                      "Jumlah Barang",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    // Input Jumlah
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        validator: (e) {
                          if ((e as dynamic).isEmpty) {
                            return "Silahkan isi Jumlah";
                          }
                          return null;
                        },
                        onSaved: (e) => Jumlah = e,
                        focusNode: JmFocusNode,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
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
                          hintText: "Masukkan jumlah barang",
                          prefixIcon: Icon(Icons.numbers, color: Colors.black),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                    // Tombol Simpan
                    Container(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: check,
                        icon: Icon(Icons.save, color: Colors.white),
                        label: Text(
                          'Simpan Transaksi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          iconColor: primaryColor,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
