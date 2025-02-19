class LaporanGabunganModel {
  String? tipe; // "Masuk" atau "Keluar"
  String? id_transaksi;
  String? id_barang;
  String? nama_barang;
  String? nama_brand;
  String? jumlah;
  String? tgl_transaksi;
  String? keterangan;
  String? nama;

  LaporanGabunganModel(
      this.tipe,
      this.id_transaksi,
      this.id_barang,
      this.nama_barang,
      this.nama_brand,
      this.jumlah,
      this.tgl_transaksi,
      this.keterangan,
      this.nama);

  LaporanGabunganModel.fromJson(Map<String, dynamic> json) {
    tipe = json['tipe']; // Menyimpan jenis transaksi ("Masuk" atau "Keluar")
    id_transaksi = json['id_transaksi'];
    id_barang = json['id_barang'];
    nama_barang = json['nama_barang'];
    nama_brand = json['nama_brand'];
    jumlah = json['jumlah'];
    tgl_transaksi = json['tgl_transaksi'];
    keterangan = json['keterangan'];
    nama = json['nama'];
  }

  Map<String, dynamic> toJson() {
    return {
      'tipe': tipe,
      'id_transaksi': id_transaksi,
      'id_barang': id_barang,
      'nama_barang': nama_barang,
      'nama_brand': nama_brand,
      'jumlah': jumlah,
      'tgl_transaksi': tgl_transaksi,
      'keterangan': keterangan,
      'nama': nama,
    };
  }
}
