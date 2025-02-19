class BarangModel {
  String? no;
  String? id_barang;
  String? barcode;
  String? nama_barang;
  String? nama_jenis;
  String? nama_brand;
  String? foto;
  String? id_jenis;
  String? id_brand;
  String? lokasi;
  BarangModel(
      this.no,
      this.id_barang,
      this.barcode,
      this.nama_barang,
      this.nama_jenis,
      this.nama_brand,
      this.foto,
      this.id_jenis,
      this.id_brand,
      this.lokasi);
      
  BarangModel.fromJson(Map<String, dynamic> json) {
    no = json['no'];
    id_barang = json['id_barang'];
    barcode = json['barcode'];
    nama_barang = json['nama_barang'];
    id_jenis = json['id_jenis'];
    nama_jenis = json['nama_jenis'];
    id_brand = json['id_brand'];
    nama_brand = json['nama_brand'];
    lokasi = json['nama_lokasi'];
    foto = json['foto'];
  }
}
