import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart'; // Tambahkan package ini untuk animasi
import 'package:glassmorphism/glassmorphism.dart';
import 'package:inventori_bea/view/barang_keluar/DataTransaksiBk.dart';
import 'package:inventori_bea/view/barang_keluar/tambahkbk.dart';
import 'package:inventori_bea/view/barang_masuk/data_transaksi.dart'; // Tambahkan package ini untuk efek glass

class TransactionLandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background dengan gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 33, 92, 255),
                  Color.fromARGB(255, 50, 214, 255),
                ],
              ),
            ),
          ),
          // Pattern overlay
          Opacity(
            opacity: 0.1,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/pattern.png'), // Tambahkan pattern image
                  repeat: ImageRepeat.repeat,
                ),
              ),
            ),
          ),
          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Header
                FadeInDown(
                  duration: Duration(milliseconds: 800),
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          'Transaksi',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Pilih jenis transaksi yang ingin dilakukan',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Barang Masuk Card
                          FadeInLeft(
                            duration: Duration(milliseconds: 800),
                            child: _buildTransactionCard(
                              context,
                              title: 'Barang Masuk',
                              subtitle: 'Catat barang yang masuk ke inventori',
                              icon: Icons.input_rounded,
                              onTap: () {
                                // Navigate to Barang Masuk page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DataTransaksi(),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 24),
                          // Barang Keluar Card
                          FadeInRight(
                            duration: Duration(milliseconds: 800),
                            child: _buildTransactionCard(
                              context,
                              title: 'Barang Keluar',
                              subtitle:
                                  'Catat barang yang keluar dari inventori',
                              icon: Icons.output_rounded,
                              isExitCard: true,
                              onTap: () {
                                // Navigate to Barang Keluar page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DataTransaksiBk(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Bottom text with current date and user
                FadeInUp(
                  duration: Duration(milliseconds: 800),
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: GlassmorphicContainer(
                      width: double.infinity,
                      height: 80,
                      borderRadius: 20,
                      blur: 20,
                      alignment: Alignment.center,
                      border: 2,
                      linearGradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.05),
                        ],
                      ),
                      borderGradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.5),
                          Colors.white.withOpacity(0.2),
                        ],
                      ),
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '2025-02-03 02:32:18 UTC',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'SILAHKAN TAMBAHKAN TRANSAKSI',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isExitCard = false,
  }) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 140,
      borderRadius: 20,
      blur: 20,
      alignment: Alignment.center,
      border: 2,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          isExitCard
              ? Colors.red.withOpacity(0.1)
              : Colors.green.withOpacity(0.1),
          isExitCard
              ? Colors.red.withOpacity(0.05)
              : Colors.green.withOpacity(0.05),
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.5),
          Colors.white.withOpacity(0.2),
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
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isExitCard
                        ? Colors.red.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
