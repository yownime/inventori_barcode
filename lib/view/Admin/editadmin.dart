import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import '../../model/AdminModel.dart';
import '../../model/api.dart';
import '../../model/LevelModel.dart';

class EditAdmin extends StatefulWidget {
  final VoidCallback reload;
  final AdminModel model;
  EditAdmin(this.model, this.reload);
  @override
  State<EditAdmin> createState() => _EditAdminState();
}

class _EditAdminState extends State<EditAdmin> {
  FocusNode myFocusNode = new FocusNode();
  String? id_admin, nama, username, level;
  final _key = new GlobalKey<FormState>();
  TextEditingController? txtidAdmin, txtNamaAdmin, txtUsername;
  setup() async {
    txtUsername = TextEditingController(text: widget.model.username);
    txtNamaAdmin = TextEditingController(text: widget.model.nama);
    id_admin = widget.model.id_admin;
    level = widget.model.lvl; // Pastikan level diambil dari model
  }

  LevelModel? _currentLevel;
  final String? linkLevel = BaseUrl.urlDataLevel;
  Future<List<LevelModel>> _fetchLevel() async {
    var response = await http.get(Uri.parse(linkLevel.toString()));
    print('hasil: ' + response.statusCode.toString());
    if (response.statusCode == 200) {
      final items = json.decode(response.body).cast<Map<String, dynamic>>();
      List<LevelModel> listOfLevel = items.map<LevelModel>((json) {
        return LevelModel.fromJson(json);
      }).toList();
      return listOfLevel;
    } else {
      throw Exception('gagal');
    }
  }

  check() {
    final form = _key.currentState;
    if ((form as dynamic).validate()) {
      (form as dynamic).save();
      prosesUp();
    }
  }

  prosesUp() async {
    try {
      // Debug: Menampilkan data sebelum dikirim
      print("=== Debug: Data yang dikirim ===");
      print("id_admin: $id_admin");
      print("nama: $nama");
      print("username: $username");
      print("level: $level");

      final respon = await http.post(Uri.parse(BaseUrl.urlEditAdmin.toString()),
          body: {
            "id_admin": id_admin,
            "nama": nama,
            "username": username,
            "level": level
          });

      // Debug: Menampilkan response dari server
      print("=== Debug: Response dari server ===");
      print("Status code: ${respon.statusCode}");
      print("Body: ${respon.body}");

      if (respon.statusCode == 200) {
        final data = jsonDecode(respon.body);

        // Debug: Menampilkan data yang diterima setelah decoding
        print("=== Debug: Data decoded ===");
        print(data);

        int code = data['succes'];
        String pesan = data['message'];
        print("Code: $code, Pesan: $pesan");

        if (code == 1) {
          setState(() {
            widget.reload();
            Navigator.pop(context);
          });
        } else {
          // Debug: Menampilkan pesan error dari server
          print("Error: $pesan");
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Gagal mengedit admin: $pesan"),
            backgroundColor: Colors.red,
          ));
        }
      } else {
        print("Error: Server tidak merespons dengan benar.");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Gagal menghubungi server. Coba lagi nanti."),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      // Debug: Menangkap dan menampilkan error dari blok try
      print("=== Debug: Exception ===");
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Terjadi kesalahan: ${e.toString()}"),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    setup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(244, 244, 244, 1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(255, 41, 69, 91),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Text(
                "Edit Admin",
                style: TextStyle(color: Colors.white, fontSize: 20.0),
              ),
            )
          ],
        ),
      ),
      body: Form(
        key: _key,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: <Widget>[
            TextFormField(
              controller: txtNamaAdmin,
              validator: (e) {
                if (e!.isEmpty) {
                  return "Silahkan isi Nama";
                } else {
                  return null;
                }
              },
              onSaved: (e) => nama = e,
              decoration: InputDecoration(
                labelText: 'Nama Lengkap',
                labelStyle: TextStyle(
                    color: myFocusNode.hasFocus
                        ? Colors.blue
                        : Color.fromARGB(255, 32, 54, 70)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Color.fromARGB(255, 32, 54, 70)),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: txtUsername,
              validator: (e) {
                if (e!.isEmpty) {
                  return "Silahkan isi Username";
                } else {
                  return null;
                }
              },
              onSaved: (e) => username = e,
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(
                    color: myFocusNode.hasFocus
                        ? Colors.blue
                        : Color.fromARGB(255, 32, 54, 70)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Color.fromARGB(255, 32, 54, 70)),
                ),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            FutureBuilder<List<LevelModel>>(
              future: _fetchLevel(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<LevelModel>> snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                return Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                          style: BorderStyle.solid,
                          color: Color.fromARGB(255, 32, 54, 70),
                          width: 0.80),
                    ),
                    child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                      items: snapshot.data!
                          .map((listLevel) => DropdownMenuItem(
                                child: Text(listLevel.nama_level.toString()),
                                value: listLevel,
                              ))
                          .toList(),
                      onChanged: (LevelModel? value) {
                        setState(() {
                          _currentLevel = value;
                          level = _currentLevel!.id_level;
                        });
                      },
                      isExpanded: true,
                      hint: Text(level == null || level == widget.model.lvl
                          ? widget.model.lvl.toString()
                          : _currentLevel!.nama_level.toString()),
                    )));
              },
            ),
            SizedBox(
              height: 25,
            ),
            MaterialButton(
              color: Color.fromARGB(255, 41, 69, 91),
              onPressed: () {
                check();
              },
              child: Text(
                "Edit",
                style: TextStyle(color: Colors.white),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            )
          ],
        ),
      ),
    );
  }
}
