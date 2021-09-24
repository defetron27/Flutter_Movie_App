class TvShowSeasonsModel {
  final String air_date;
  final int episode_count;
  final int id;
  final String name;
  final String overview;
  final String poster_path;
  final int season_number;

  TvShowSeasonsModel({
    this.air_date,
    this.episode_count,
    this.id,
    this.name,
    this.overview,
    this.poster_path,
    this.season_number,
  });

  factory TvShowSeasonsModel.fromJson(Map<String, dynamic> json) {
    return TvShowSeasonsModel(
        air_date: json['air_date'],
        episode_count: json['episode_count'],
        id: json['id'],
        name: json['name'],
        overview: json['overview'],
        poster_path: json['poster_path'] == "" || json['poster_path'] == null
            ? json['poster_path']
            : "http://image.tmdb.org/t/p/w500" + json['poster_path'],
        season_number: json['season_number']);
  }
}
