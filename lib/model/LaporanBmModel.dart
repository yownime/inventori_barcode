class LaporanBmModel {
  String? id_barang_masuk;
  String? id_barang;
  String? nama_barang;
  String? nama_brand;
  String? jumlah_masuk;
  String? tgl_transaksi;
  String? keterangan;
  String? nama;
  LaporanBmModel(
      this.id_barang_masuk,
      this.id_barang,
      this.nama_barang,
      this.nama_brand,
      this.jumlah_masuk,
      this.tgl_transaksi,
      this.keterangan,
      this.nama);
  LaporanBmModel.fromJson(Map<String, dynamic> json) {
    id_barang_masuk = json['id_barang_masuk'];
    id_barang = json['id_barang'];
    nama_barang = json['nama_barang'];
    nama_brand = json['nama_brand'];
    jumlah_masuk = json['jumlah_masuk'];
    tgl_transaksi = json['tgl_transaksi'];
    keterangan = json['keterangan'];
    nama = json['nama'];
  }
}
