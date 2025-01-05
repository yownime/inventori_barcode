import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:inventori_bea/homepage.dart';
import 'package:http/http.dart' as http;

class AddProduct extends StatefulWidget {
  AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stockController = TextEditingController();
  final _imageController = TextEditingController();
  Future saveProduct() async {
    final response =
        await http.post(Uri.parse('http://192.168.1.6/api/products'), body: {
      'name': _nameController.text,
      'description': _descriptionController.text,
      'price': _priceController.text,
      'stock': _stockController.text,
      'image_url': _imageController.text,
    });

    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Masukkan nama produk';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Name',
              ),
            ),
            TextFormField(
              controller: _priceController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Masukkan Harga';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Price',
              ),
            ),
            TextFormField(
              controller: _descriptionController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Masukkan Deskripsi';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Description',
              ),
            ),
            TextFormField(
              controller: _stockController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Masukkan Jumlah Stock';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Stock',
              ),
            ),
            TextFormField(
              controller: _imageController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Masukkan URL Gambar';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Image',
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Save data
                    // TODO: Save data to database
                    saveProduct();
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Homepage()));
                  }
                },
                child: Text('Save')),
          ],
        ),
      ),
    );
  }
}
