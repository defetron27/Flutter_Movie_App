class TvShowNetworksModel {
  final String name;
  final int id;
  final String logo_path;
  final String origin_country;

  TvShowNetworksModel(
      {this.name, this.id, this.logo_path, this.origin_country});

  factory TvShowNetworksModel.fromJson(Map<String, dynamic> json) {
    return TvShowNetworksModel(
        name: json['name'],
        id: json['id'],
        logo_path: json['logo_path'] == "" || json['logo_path'] == null
            ? json['logo_path']
            : "http://image.tmdb.org/t/p/w780" + json['logo_path'],
        origin_country: json['origin_country']);
  }
}
