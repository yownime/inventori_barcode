import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inventori_bea/view/Transaksi.dart';
import 'package:inventori_bea/view/laporan/landingpagelaporan.dart';
import 'package:inventori_bea/view/laporan/laporanbarangkeluarpage.dart';
import 'package:inventori_bea/view/laporan/laporanbarangmasukpage.dart';
import 'package:inventori_bea/view/laporan/laporangabungan.dart';
import 'package:inventori_bea/view/lokasi/datalokasi.dart';
import '../model/CountData.dart';
import '../../model/api.dart';
import '../view/Admin/dataadmin.dart';
import '../view/Admin/profile.dart';
import '../view/barang/DataBarang.dart';
import '../view/barang_keluar/DataTransaksiBk.dart';
import '../view/barang_masuk/data_transaksi.dart';
import '../view/brand/DataBrand.dart';
import '../../view/jenis/DataJenis.dart';
import '../view/laporan/FormLaporan.dart';
import '../view/laporan/FormLbk.dart';
import '../view/stok/DataStok.dart';
import '../view/tujuan/DataTujuan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MenuPage extends StatefulWidget {
  final VoidCallback signOut;
  MenuPage(this.signOut);
  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  FocusNode myFocusNode = new FocusNode();
  String? IdUsr, LvlUsr, NamaUsr;
  bool _MDTileExpanded = false;
  bool _TsTileExpanded = false;
  bool _LpTileExpanded = false;
  getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      IdUsr = pref.getString("id");
      NamaUsr = pref.getString("nama");
      LvlUsr = pref.getString("level");
    });
  }

  signOut() {
    setState(() {
      widget.signOut();
    });
  }

  var loading = false;
  String jsCount = "0";
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
            jsCount = ex.first.stok;
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
    getPref();
    _countBR();
  }

  infoOut() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      headerAnimationLoop: true,
      animType: AnimType.bottomSlide,
      title: 'Ready to Leave?',
      reverseBtnOrder: true,
      btnOkText: 'Logout',
      btnOkOnPress: () {
        signOut();
      },
      btnCancelOnPress: () {},
      desc:
          'Select "Logout" below if you are ready to end your current session.',
    ).show();
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
              elevation: 0,
              backgroundColor: Color.fromARGB(255, 33, 92, 255),
              title: Text(
                'INVENTORI GUDANG',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              centerTitle: true,
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _countBR();
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Dashboard Overview",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 20),
                _buildStatisticCard(
                  title: "Total Barang Masuk",
                  value: jmCount,
                  icon: FontAwesomeIcons.boxOpen,
                  color: Color(0xFF4CAF50),
                  lightColor: Color(0xFFE8F5E9),
                ),
                SizedBox(height: 16),
                _buildStatisticCard(
                  title: "Total Barang Keluar",
                  value: jkCount,
                  icon: FontAwesomeIcons.truckRampBox,
                  color: Color(0xFFF44336),
                  lightColor: Color(0xFFFFEBEE),
                ),
                SizedBox(height: 16),
                _buildStatisticCard(
                  title: "Total Stok Barang",
                  value: jsCount,
                  icon: FontAwesomeIcons.boxesStacked,
                  color: Color(0xFF2196F3),
                  lightColor: Color(0xFFE3F2FD),
                ),
                SizedBox(height: 30),
                Text(
                  "Quick Actions",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildQuickActionCard(
                      title: "Data Barang",
                      icon: FontAwesomeIcons.boxArchive,
                      color: Color(0xFF9C27B0),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DataBarang()));
                      },
                    ),
                    _buildQuickActionCard(
                      title: "Transaksi",
                      icon: FontAwesomeIcons.rightLeft,
                      color: Color(0xFF009688),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    TransactionLandingPage()));
                      },
                    ),
                    _buildQuickActionCard(
                      title: "Laporan",
                      icon: FontAwesomeIcons.chartLine,
                      color: Color(0xFFFF9800),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LaporanLandingPage()));
                      },
                    ),
                    _buildQuickActionCard(
                      title: "Stock",
                      icon: FontAwesomeIcons.boxesPacking,
                      color: Color(0xFF607D8B),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DataStok()));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: _buildDrawer(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 33, 92, 255),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage("assets/logo.png"),
                  ),
                  SizedBox(height: 12),
                  Text(
                    NamaUsr.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    LvlUsr.toString() == "1" ? "Super Admin" : "Admin",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              icon: Icons.person,
              title: "Profile",
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Profil()));
              },
            ),
            Divider(),
            _buildExpandableDrawerItem(
              icon: FontAwesomeIcons.database,
              title: "Master Data",
              expanded: _MDTileExpanded,
              onExpansionChanged: (bool expanded) {
                setState(() => _MDTileExpanded = expanded);
              },
              children: [
                _buildDrawerSubItem(
                  title: "Data Jenis",
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Datajenis()));
                  },
                ),
                // ... other subitems
                _buildDrawerSubItem(
                  title: "Data Label",
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => DataBrand()));
                  },
                ),
                _buildDrawerSubItem(
                  title: "Data Lokasi",
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Datalokasi()));
                  },
                ),
                _buildDrawerSubItem(
                  title: "Data Tujuan",
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => DataTujuan()));
                  },
                ),
                _buildDrawerSubItem(
                  title: "Data Admin",
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => DataAdmin()));
                  },
                ),
              ],
            ),
            // ... other expandable items
            Divider(),
            _buildDrawerItem(
              icon: Icons.logout,
              title: "Logout",
              onTap: () => infoOut(),
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.black87),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? Colors.black87,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildExpandableDrawerItem({
    required IconData icon,
    required String title,
    required bool expanded,
    required Function(bool) onExpansionChanged,
    required List<Widget> children,
  }) {
    return Theme(
      data: ThemeData().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: FaIcon(
          icon,
          color: Color.fromARGB(255, 33, 92, 255),
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
          ),
        ),
        children: children,
        onExpansionChanged: onExpansionChanged,
        trailing: FaIcon(
          expanded
              ? FontAwesomeIcons.chevronDown
              : FontAwesomeIcons.chevronRight,
          size: 14,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _buildDrawerSubItem({
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.only(left: 72, right: 16),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildStatisticCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color lightColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: color, width: 4),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          value,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: lightColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: FaIcon(
                      icon,
                      size: 24,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: FaIcon(
                    icon,
                    size: 28,
                    color: color,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
