import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final String url = 'http://192.168.1.5/api/products';

  Future getProducts() async {
    var response = await http.get(Uri.parse(url));
    print(json.decode(response.body));
    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    getProducts();
    return Scaffold(
      body: Center(
        child: FutureBuilder(
            future: getProducts(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data["data"].length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    snapshot.data["data"][index]['name'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Rp ${snapshot.data["data"][index]['price']}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    snapshot.data["data"][index]['description'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.inventory,
                                          size: 16, color: Colors.blue[800]),
                                      SizedBox(width: 4),
                                      Text(
                                        'Stok: ${snapshot.data["data"][index]['stock']}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.blue[800],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  height: 150,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Container(
                                              padding: EdgeInsets.only(
                                                  top: 6,
                                                  right: 10,
                                                  left: 10,
                                                  bottom: 6),
                                              decoration: BoxDecoration(
                                                color: Colors.blue[800],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text('edit',
                                                  style: TextStyle(
                                                      color: Colors.white))),
                                          Container(
                                              padding: EdgeInsets.only(
                                                  top: 6,
                                                  right: 10,
                                                  left: 10,
                                                  bottom: 6),
                                              decoration: BoxDecoration(
                                                color: const Color.fromARGB(
                                                    255, 192, 21, 21),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text('delete',
                                                  style: TextStyle(
                                                      color: Colors.white))),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Image.network(
                                        snapshot.data["data"][index]
                                            ['image_url'],
                                        fit: BoxFit.contain,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else {
                return Text('Data Tidak Tersedia');
              }
            }),
      ),
    );
  }
}
