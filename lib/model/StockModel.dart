class StokModel {
  String? no;
  String? id_barang;
  String? barcode;
  String? nama_barang;
  String? nama_jenis;
  String? nama_brand;
  String? stok;
  String? foto;
  String? nama_lokasi; // ➜ Tambahkan lokasi di sini

  StokModel(this.no, this.id_barang, this.barcode, this.nama_barang,
      this.nama_jenis, this.nama_brand, this.stok, this.foto, this.nama_lokasi);

  StokModel.fromJson(Map<String, dynamic> json) {
    no = json['no'];
    id_barang = json['id_barang'];
    barcode = json['barcode'];
    nama_barang = json['nama_barang'];
    nama_jenis = json['nama_jenis'];
    nama_brand = json['nama_brand'];
    stok = json['stok'];
    foto = json['foto'];
    nama_lokasi = json['nama_lokasi']; // ➜ Ambil data lokasi dari JSON
  }
}
