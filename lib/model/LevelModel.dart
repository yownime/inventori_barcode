class LevelModel {
  String? id_level;
  String? nama_level;
  LevelModel(this.id_level, this.nama_level);
  LevelModel.fromJson(Map<String, dynamic> json) {
    id_level = json['id_level'];
    nama_level = json['lvl'];
  }
}
