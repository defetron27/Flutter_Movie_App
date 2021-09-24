class TvShowMovieProductionCompaniesModel {
  final int id;
  final String logo_path;
  final String name;
  final String origin_country;

  TvShowMovieProductionCompaniesModel(
      {this.id, this.logo_path, this.name, this.origin_country});

  factory TvShowMovieProductionCompaniesModel.fromJson(Map<String, dynamic> json) {
    return TvShowMovieProductionCompaniesModel(
        id: json['id'],
        logo_path: json['logo_path'] == "" || json['logo_path'] == null ? json['logo_path'] :
            "http://image.tmdb.org/t/p/w780" + json['logo_path'],
        name: json['name'],
        origin_country: json['origin_country']);
  }
}
