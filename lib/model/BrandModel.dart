class BrandModel {
  String? no;
  String? id_brand;
  String? nama_brand;
  BrandModel(this.no, this.id_brand, this.nama_brand);
  BrandModel.fromJson(Map<String, dynamic> json) {
    no = json['no'];
    id_brand = json['id_brand'];
    nama_brand = json['nama_brand'];
  }
}