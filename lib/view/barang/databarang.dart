import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import '../../loading.dart';
import 'dart:convert';
import '../../model/BarangModel.dart';
import '../../model/api.dart';
import 'DetailBarang.dart';
import 'EditBarang.dart';
import 'TambahBarang.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataBarang extends StatefulWidget {
  @override
  State<DataBarang> createState() => _DataBarangState();
}

class _DataBarangState extends State<DataBarang> {
  var loading = false;
  final list = [];
  String? LvlUsr;
  String searchQuery = ""; // Untuk menampung query pencarian
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
    final response = await http.get(Uri.parse(BaseUrl.urlDataBarang));
    if (response.contentLength == 2) {
    } else {
      final data = jsonDecode(response.body);
      data.forEach((api) {
        final ab = BarangModel(
            api['no'],
            api['id_barang'],
            api['barcode'],
            api['nama_barang'],
            api['nama_jenis'],
            api['nama_brand'],
            api['foto'],
            api['id_jenis'],
            api['id_brand'],
            api['lokasi']);
        list.add(ab);
      });
      setState(() {
        loading = false;
      });
    }
  }

  // Menambahkan fungsi pencarian
  Future<void> _searchData() async {
    if (searchQuery.isEmpty) {
      _lihatData(); // Jika pencarian kosong, tampilkan semua data
      return;
    }
    list.clear();
    setState(() {
      loading = true;
    });
    final response = await http.post(
      Uri.parse(BaseUrl.urlSearchBarang), // URL API untuk pencarian
      body: {
        'search': searchQuery,
      },
    );
    if (response.contentLength == 2) {
      setState(() {
        loading = false;
      });
      return;
    } else {
      final data = jsonDecode(response.body);
      data.forEach((api) {
        final ab = BarangModel(
            api['no'],
            api['id_barang'],
            api['barcode'],
            api['nama_barang'],
            api['nama_jenis'],
            api['nama_brand'],
            api['foto'],
            api['id_jenis'],
            api['id_brand'],
            api['lokasi']);
        list.add(ab);
      });
      setState(() {
        loading = false;
      });
    }
  }

  _proseshapus(String id) async {
    print("Menghapus barang dengan ID: $id"); // Debugging Log
    final response = await http.post(
      Uri.parse(BaseUrl.urlHapusBarang),
      body: {"id_barang": id},
    );

    print("Response Status Code: ${response.statusCode}"); // Debugging Log
    print("Response Body: ${response.body}"); // Debugging Log

    try {
      final data = jsonDecode(response.body);
      int value = data['success'];
      String pesan = data['message'];

      print("Response Success: $value, Message: $pesan"); // Debugging Log

      if (value == 1) {
        setState(() {
          _lihatData();
        });
      } else {
        print("Gagal menghapus: $pesan");
        dialogHapus(pesan);
      }
    } catch (e) {
      print("Error parsing response: $e");
      dialogHapus("Terjadi kesalahan dalam memproses data.");
    }
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
    // Mendapatkan ukuran layar
    final Size screenSize = MediaQuery.of(context).size;
    // Menghitung jumlah kolom berdasarkan lebar layar
    final int crossAxisCount = screenSize.width > 600 ? 3 : 2;
    // Menyesuaikan aspect ratio berdasarkan lebar layar
    final double aspectRatio = screenSize.width > 600 ? 0.95 : 0.82;

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
              automaticallyImplyLeading: false,
              backgroundColor: Color.fromARGB(255, 33, 92, 255),
              elevation: 0,
              title: Row(
                children: <Widget>[
                  Flexible(
                    flex:
                        3, // Diubah dari 2 ke 3 untuk memberi ruang lebih pada judul
                    child: Text(
                      "Data Barang",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize:
                            screenSize.width < 360 ? 18 : 20.5, // Perbesar font
                        fontWeight: FontWeight.w700, // Tebalkan font
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                      width: 26), // Perkecil jarak antara judul dan search bar
                  Flexible(
                    flex: 4, // Sesuaikan rasio flex
                    child: Container(
                      height: 36, // Perkecil tinggi container
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                          _searchData();
                        },
                        decoration: InputDecoration(
                          hintText: 'Cari Barang',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: screenSize.width < 360
                                ? 11
                                : 14.9, // Perkecil font
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Color(0xFF2E7D32),
                            size: 20, // Tambahkan ukuran icon
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 15, // Perkecil padding horizontal
                            vertical: 10, // Perkecil padding vertical
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => new TambahBarang(_lihatData)),
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Color.fromARGB(255, 55, 102, 255),
        elevation: 4,
      ),
      body: RefreshIndicator(
        onRefresh: _lihatData,
        key: _refresh,
        child: loading
            ? Loading()
            : // Pada bagian GridView.builder
            // Pada bagian GridView.builder
            GridView.builder(
                padding: EdgeInsets.all(screenSize.width * 0.03),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio:
                      screenSize.width > 600 ? 1.15 : 0.78, // Adjust ratio
                  crossAxisSpacing: screenSize.width * 0.02,
                  mainAxisSpacing: screenSize.width * 0.02,
                ),
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final x = list[i];
                  return Card(
                    elevation: 4,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Gambar (55% tinggi card)
                          Expanded(
                            flex: 55, // Changed from 3 to 55
                            child: ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20)),
                              child: Container(
                                width: double.infinity,
                                child: Image.network(
                                  BaseUrl.path + x.foto.toString(),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[200],
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey[400],
                                        size: 40,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),

                          // Konten Teks (45% tinggi card)
                          Expanded(
                            flex: 45, // Changed from 2 to 45
                            child: Container(
                              padding: EdgeInsets.all(8), // Reduced padding
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Bagian Teks
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          x.nama_barang.toString(),
                                          style: TextStyle(
                                            fontSize: screenSize.width < 360
                                                ? 12
                                                : 14, // Reduced font size
                                            fontWeight: FontWeight.w800,
                                            color: Color.fromARGB(
                                                255, 33, 92, 255),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 2), // Reduced spacing
                                        Row(
                                          children: [
                                            Icon(Icons.category,
                                                size: 12,
                                                color: Colors.grey[
                                                    600]), // Reduced icon size
                                            SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                x.nama_jenis.toString(),
                                                style: TextStyle(
                                                  fontSize: screenSize.width <
                                                          360
                                                      ? 10
                                                      : 11, // Reduced font size
                                                  color: Colors.grey[700],
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Bagian Tombol
                                  Container(
                                    height: 32, // Reduced height
                                    child: Wrap(
                                      spacing: 4,
                                      alignment: WrapAlignment.end,
                                      children: [
                                        _buildModernIconButton(
                                          icon: Icons.visibility,
                                          onPressed: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      DetailBarang(
                                                          x, _lihatData))),
                                          color:
                                              Color.fromARGB(255, 33, 92, 255),
                                          size: 16, // Reduced icon size
                                        ),
                                        if (LvlUsr == "1") ...[
                                          _buildModernIconButton(
                                            icon: Icons.edit,
                                            onPressed: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        EditBarang(
                                                            x, _lihatData))),
                                            color: Colors.orange,
                                            size: 16, // Reduced icon size
                                          ),
                                          _buildModernIconButton(
                                            icon: Icons.delete,
                                            onPressed: () =>
                                                _proseshapus(x.id_barang),
                                            color: Colors.red,
                                            size: 16, // Reduced icon size
                                          ),
                                        ],
                                      ],
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
                },
              ),
      ),
    );
  }

// Update _buildModernIconButton
  Widget _buildModernIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    double size = 20,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: size,
            color: color,
          ),
        ),
      ),
    );
  }
}
