class Lokasimodel {
  String? id_lokasi;
  String? nama_lokasi;

  Lokasimodel(this.id_lokasi, this.nama_lokasi);

  Lokasimodel.fromJson(Map<String, dynamic> json) {
    id_lokasi = json['id_lokasi'];
    nama_lokasi = json['nama_lokasi'];
  }
}
