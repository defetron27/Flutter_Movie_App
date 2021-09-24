class TvShowMovieVideosResultsModel {
  final String id;
  final String iso_639_1;
  final String iso_3166_1;
  final String key;
  final String name;
  final String site;
  final int size;
  final String type;

  TvShowMovieVideosResultsModel(
      {this.id,
      this.iso_639_1,
      this.iso_3166_1,
      this.key,
      this.name,
      this.site,
      this.size,
      this.type});

  factory TvShowMovieVideosResultsModel.fromJson(Map<String, dynamic> json) {
    return TvShowMovieVideosResultsModel(
        id: json['id'],
        iso_639_1: json['iso_639_1'],
        iso_3166_1: json['iso_3166_1'],
        key: json['key'],
        name: json['name'],
        site: json['site'],
        size: json['size'],
        type: json['type']);
  }
}
