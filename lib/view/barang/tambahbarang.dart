import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import '../../model/JenisModel.dart';
import '../../model/BrandModel.dart';
import '../../model/LokasiModel.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import '../../model/api.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class TambahBarang extends StatefulWidget {
  final VoidCallback reload;
  TambahBarang(
    this.reload,
  );

  @override
  State<TambahBarang> createState() => _TambahBarangState();
}

class _TambahBarangState extends State<TambahBarang> {
  FocusNode myFocusNode = FocusNode();
  FocusNode myFocusNodebarcode = FocusNode();
  String? barang, jenisB, brandB, lokasiB;
  final _key = GlobalKey<FormState>();
  final TextEditingController barcodeController =
      TextEditingController(); // Controller untuk barcode
  final TextEditingController barangController =
      TextEditingController(); // Controller untuk nama barang
  File? _imageFile;
  final image_picker = ImagePicker();

  Future<File> compressImage(File file) async {
    final bytes = await file.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image != null) {
      img.Image resizedImage = img.copyResize(image, width: 800);
      final directory = await getTemporaryDirectory();
      final compressedFile =
          File('${directory.path}/${path.basename(file.path)}_compressed.jpg');
      return compressedFile
          .writeAsBytes(img.encodeJpg(resizedImage, quality: 85));
    }

    return file;
  }

  Future<void> scanBarcode() async {
    try {
      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);

      if (!mounted) return;
      setState(() {
        barcodeController.text = barcodeScanRes; // Update nilai pada controller
      });
      print('Barcode yang dipindai: $barcodeScanRes'); // Log barcode
    } on PlatformException {
      print('Failed to get platform version.');
    }
  }

  _pilihGallery() async {
    final image = await image_picker.getImage(
        source: ImageSource.gallery, maxHeight: 1920.0, maxWidth: 1080);
    setState(() {
      if (image != null) {
        _imageFile = File(image.path);
        Navigator.pop(context);
        print('Gambar dipilih dari gallery: ${image.path}');
      }
    });
  }

  _pilihCamera() async {
    final image = await image_picker.getImage(
        source: ImageSource.camera, maxHeight: 1920.0, maxWidth: 1080);
    setState(() {
      if (image != null) {
        _imageFile = File(image.path);
        Navigator.pop(context);
        print('Gambar dipilih dari kamera: ${image.path}');
      }
    });
  }

  JenisModel? _currentJenis;
  final String? linkJenis = BaseUrl.urlDataJenis;
  Future<List<JenisModel>> _fetchJenis() async {
    try {
      var response = await http.get(Uri.parse(linkJenis.toString()));
      if (response.statusCode == 200) {
        final items = json.decode(response.body).cast<Map<String, dynamic>>();
        print('Data jenis diterima: $items'); // Log data jenis
        return items.map<JenisModel>((json) {
          return JenisModel.fromJson(json);
        }).toList();
      } else {
        throw Exception('Gagal mendapatkan data jenis');
      }
    } catch (e) {
      print('Error saat fetch data jenis: $e');
      throw e;
    }
  }

  Lokasimodel? _currentLokasi;
  final String? linkLokasi = BaseUrl.urlDataLokasi;
  Future<List<Lokasimodel>> _fetchLokasi() async {
    try {
      var response = await http.get(Uri.parse(linkLokasi.toString()));
      if (response.statusCode == 200) {
        final items = json.decode(response.body).cast<Map<String, dynamic>>();
        print('Data lokasi diterima: $items'); // Log data lokasi
        return items.map<Lokasimodel>((json) {
          return Lokasimodel.fromJson(json);
        }).toList();
      } else {
        throw Exception('Gagal mendapatkan data lokasi');
      }
    } catch (e) {
      print('Error saat fetch data lokasi: $e');
      throw e;
    }
  }

  BrandModel? _currentBrand;
  final String? linkBrand = BaseUrl.urlDataBrand;
  Future<List<BrandModel>> _fetchBrand() async {
    try {
      var response = await http.get(Uri.parse(linkBrand.toString()));
      if (response.statusCode == 200) {
        final items = json.decode(response.body).cast<Map<String, dynamic>>();
        print('Data brand diterima: $items'); // Log data brand
        return items.map<BrandModel>((json) {
          return BrandModel.fromJson(json);
        }).toList();
      } else {
        throw Exception('Gagal mendapatkan data brand');
      }
    } catch (e) {
      print('Error saat fetch data brand: $e');
      throw e;
    }
  }

  check() {
    final form = _key.currentState;
    if ((form as dynamic).validate()) {
      form?.save();
      print('Form berhasil disimpan, lanjut ke Simpan()'); // Log form save
      Simpan();
    } else {
      print('Form tidak valid, periksa input'); // Log jika form tidak valid
    }
  }

  Simpan() async {
    try {
      if (_imageFile == null) {
        print('Gambar belum dipilih'); // Log jika gambar belum dipilih
        return;
      }

      File? compressedFile = await compressImage(_imageFile!);
      var stream = http.ByteStream(Stream.castFrom(compressedFile.openRead()));
      var length = await compressedFile.length();
      var uri = Uri.parse(BaseUrl.urlTambahBarang);

      var request = http.MultipartRequest("POST", uri);
      request.fields['barcode'] =
          barcodeController.text; // Ambil nilai dari controller
      request.fields['nama'] = barang!;
      request.fields['brand'] = brandB!;
      request.fields['jenis'] = jenisB!;
      request.fields['lokasi'] = lokasiB!; // Pass lokasiB to API
      request.files.add(http.MultipartFile("foto", stream, length,
          filename: path.basename(compressedFile.path)));

      print('Mengirim data ke API...');
      print('Barcode: ${barcodeController.text}');
      print('Nama Barang: $barang');
      print('Brand: $brandB');
      print('Jenis: $jenisB');
      print('Lokasi: $lokasiB');
      print('Foto: ${path.basename(compressedFile.path)}');

      var respon = await request.send();

      if (respon.statusCode == 200) {
        final responseString = await respon.stream.bytesToString();
        print('Data berhasil disimpan');
        print('Response body: $responseString'); // Debug response body
        if (this.mounted) {
          setState(() {
            widget.reload();
            Navigator.pop(context);
          });
        }
      } else {
        print(
            'Terjadi kesalahan saat menyimpan data. Status Code: ${respon.statusCode}');
        final responseString = await respon.stream.bytesToString();
        print('Response error: $responseString'); // Debug response error body
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  dialogFileFoto() {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: ListView(
              padding: EdgeInsets.all(16.0),
              shrinkWrap: true,
              children: <Widget>[
                Center(
                  child: Column(
                    children: [
                      Text(
                        "Upload Foto",
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 25),
                      Text("Silahkan Pilih Sumber File"),
                    ],
                  ),
                ),
                SizedBox(height: 50.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    InkWell(
                        onTap: () {
                          _pilihCamera();
                        },
                        child: FaIcon(
                          FontAwesomeIcons.camera,
                          size: 50,
                        )),
                    SizedBox(width: 100.0),
                    InkWell(
                        onTap: () {
                          _pilihGallery();
                        },
                        child: FaIcon(
                          FontAwesomeIcons.images,
                          size: 50,
                        )),
                  ],
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    var placeholder = Container(
      width: double.infinity,
      height: 200.0, // Increased height for better visibility
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[300]!, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.camera_viewfinder,
            size: 80,
            color: Color.fromARGB(255, 41, 69, 91),
          ),
          SizedBox(height: 10),
          Text(
            "Tambah Foto",
            style: TextStyle(
              color: Color.fromARGB(255, 41, 69, 91),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Colors.grey[50], // Lighter background
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
              automaticallyImplyLeading: false,
              backgroundColor: Color.fromARGB(
                  255, 33, 92, 255), // Warna hijau material design
              // Atau bisa menggunakan Colors.green[800]
              // Atau jika ingin warna hijau custom: Color.fromARGB(255, 46, 125, 50),
              elevation: 0,
              title: Text(
                "Tambah Barang",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
            ),
          ),
        ),
      ),

      body: Form(
        key: _key,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 27.0),
          children: <Widget>[
            Text(
              "Foto Barang",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 41, 69, 91),
              ),
            ),
            SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                width: double.infinity,
                height: 200.0,
                child: InkWell(
                  onTap: dialogFileFoto,
                  borderRadius: BorderRadius.circular(15),
                  child: _imageFile == null
                      ? placeholder
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        ),
                ),
              ),
            ),
            SizedBox(height: 24),
            // Barcode Field
            TextFormField(
              controller: barcodeController,
              validator: (e) {
                if ((e as dynamic).isEmpty) {
                  return "Silahkan isi barcode barang";
                }
                return null;
              },
              focusNode: myFocusNodebarcode,
              decoration: InputDecoration(
                labelText: 'Barcode Barang',
                labelStyle: TextStyle(color: Color.fromARGB(255, 41, 69, 91)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: Color.fromARGB(255, 41, 69, 91), width: 1.5),
                ),
                prefixIcon:
                    Icon(Icons.qr_code, color: Color.fromARGB(255, 41, 69, 91)),
                suffixIcon: Container(
                  margin: EdgeInsets.only(right: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        scanBarcode();
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 255, 128, 24),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.qr_code_scanner,
                                color: Colors.white, size: 20),
                            SizedBox(width: 4),
                            Text(
                              'Scan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            // Nama Barang Field
            TextFormField(
              controller: barangController,
              validator: (e) {
                if ((e as dynamic).isEmpty) {
                  return "Silahkan isi nama barang";
                }
                return null;
              },
              onSaved: (e) => barang = e,
              focusNode: myFocusNode,
              decoration: InputDecoration(
                labelText: 'Nama Barang',
                labelStyle: TextStyle(color: Color.fromARGB(255, 41, 69, 91)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: Color.fromARGB(255, 41, 69, 91), width: 1.5),
                ),
                prefixIcon: Icon(Icons.inventory_2_outlined,
                    color: Color.fromARGB(255, 41, 69, 91)),
              ),
            ),
            SizedBox(height: 30.0),

            FutureBuilder<List<JenisModel>>(
              future: _fetchJenis(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<JenisModel>> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      color:
                          Color(0xFF2E7D32), // Menyesuaikan dengan warna AppBar
                    ),
                  );
                }

                List<JenisModel> jenisList = snapshot.data!;

                List<DropdownMenuItem<JenisModel>> dropdownItems = jenisList
                    .map((listJenis) => DropdownMenuItem(
                          child: Text(
                            listJenis.nama_jenis.toString(),
                            style: TextStyle(
                              color: Color(0xFF2E7D32),
                              fontSize: 14,
                            ),
                          ),
                          value: listJenis,
                        ))
                    .toSet()
                    .toList();

                return DropdownButtonFormField<JenisModel>(
                  value:
                      jenisList.contains(_currentJenis) ? _currentJenis : null,
                  items: dropdownItems,
                  onChanged: (JenisModel? value) {
                    setState(() {
                      _currentJenis = value;
                      jenisB = _currentJenis?.id_jenis;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Jenis Barang',
                    labelStyle: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(
                      Icons.category_outlined,
                      color: Color(0xFF2E7D32),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Color(0xFF2E7D32),
                        width: 1.5,
                      ),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  icon: Icon(
                    Icons.arrow_drop_down_circle,
                    color: Color(0xFF2E7D32),
                  ),
                  dropdownColor: Colors.white,
                  hint: Text(
                    jenisB == null
                        ? "Pilih Jenis"
                        : _currentJenis!.nama_jenis.toString(),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  isExpanded: true,
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
            SizedBox(height: 20.0),
            FutureBuilder<List<Lokasimodel>>(
              future: _fetchLokasi(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<Lokasimodel>> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF2E7D32),
                    ),
                  );
                }

                List<Lokasimodel> lokasiList = snapshot.data!;
                List<Lokasimodel> uniqueLokasiList = [];
                Set<String> seenIds = Set<String>();

                for (var lokasi in lokasiList) {
                  if (!seenIds.contains(lokasi.id_lokasi)) {
                    uniqueLokasiList.add(lokasi);
                    seenIds.add(lokasi.id_lokasi!);
                  }
                }

                List<DropdownMenuItem<Lokasimodel>> dropdownItems =
                    uniqueLokasiList
                        .map((listLokasi) => DropdownMenuItem(
                              child: Text(
                                listLokasi.nama_lokasi.toString(),
                                style: TextStyle(
                                  color: Color(0xFF2E7D32),
                                  fontSize: 14,
                                ),
                              ),
                              value: listLokasi,
                            ))
                        .toSet()
                        .toList();

                return DropdownButtonFormField<Lokasimodel>(
                  value: uniqueLokasiList.contains(_currentLokasi)
                      ? _currentLokasi
                      : null,
                  items: dropdownItems,
                  onChanged: (Lokasimodel? value) {
                    setState(() {
                      _currentLokasi = value;
                      lokasiB = _currentLokasi?.id_lokasi;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Lokasi Barang',
                    labelStyle: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(
                      Icons.location_on_outlined, // Icon lokasi
                      color: Color(0xFF2E7D32),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Color(0xFF2E7D32),
                        width: 1.5,
                      ),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  icon: Icon(
                    Icons.arrow_drop_down_circle,
                    color: Color(0xFF2E7D32),
                  ),
                  dropdownColor: Colors.white,
                  hint: Text(
                    lokasiB == null
                        ? "Pilih Lokasi"
                        : _currentLokasi!.nama_lokasi.toString(),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  isExpanded: true,
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
            SizedBox(height: 20.0),
            FutureBuilder<List<BrandModel>>(
              future: _fetchBrand(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<BrandModel>> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF2E7D32),
                    ),
                  );
                }

                List<BrandModel> brandList = snapshot.data!;

                List<DropdownMenuItem<BrandModel>> dropdownItems = brandList
                    .map((listBrand) => DropdownMenuItem(
                          child: Text(
                            listBrand.nama_brand.toString(),
                            style: TextStyle(
                              color: Color(0xFF2E7D32),
                              fontSize: 14,
                            ),
                          ),
                          value: listBrand,
                        ))
                    .toSet()
                    .toList();

                return DropdownButtonFormField<BrandModel>(
                  value:
                      brandList.contains(_currentBrand) ? _currentBrand : null,
                  items: dropdownItems,
                  onChanged: (BrandModel? value) {
                    setState(() {
                      _currentBrand = value;
                      brandB = _currentBrand?.id_brand;
                    });
                  },
                  decoration: InputDecoration(
                    labelText:
                        'Label Barang', // Changed from 'label barang' to be more specific
                    labelStyle: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(
                      Icons.branding_watermark_outlined, // Icon untuk brand
                      color: Color(0xFF2E7D32),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Color(0xFF2E7D32),
                        width: 1.5,
                      ),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  icon: Icon(
                    Icons.arrow_drop_down_circle,
                    color: Color(0xFF2E7D32),
                  ),
                  dropdownColor: Colors.white,
                  hint: Text(
                    brandB == null
                        ? "Pilih Label"
                        : _currentBrand!.nama_brand
                            .toString(), // Changed "Pilih Jenis" to "Pilih Brand"
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  isExpanded: true,
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),

            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: check,
              style: ElevatedButton.styleFrom(
                iconColor: Color.fromARGB(255, 41, 69, 91),
                backgroundColor: Color.fromARGB(255, 33, 92, 255),
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                "Simpan Barang",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
