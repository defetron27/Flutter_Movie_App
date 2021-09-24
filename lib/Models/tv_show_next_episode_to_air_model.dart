class TvShowNextEpisodeToAirModel {
  final String air_date;
  final int episode_number;
  final int id;
  final String name;
  final String overview;
  final String production_code;
  final int season_number;
  final int show_id;
  final String still_path;
  final double vote_average;
  final int vote_count;

  TvShowNextEpisodeToAirModel(
      {this.air_date,
      this.episode_number,
      this.id,
      this.name,
      this.overview,
      this.production_code,
      this.season_number,
      this.show_id,
      this.still_path,
      this.vote_average,
      this.vote_count});

  factory TvShowNextEpisodeToAirModel.fromJson(Map<String, dynamic> json) {
    return TvShowNextEpisodeToAirModel(
        air_date: json['air_date'],
        episode_number: json['episode_number'],
        id: json['id'],
        name: json['name'],
        overview: json['overview'],
        production_code: json['production_code'],
        season_number: json['season_number'],
        show_id: json['show_id'],
        still_path: json['still_path'] == "" || json['still_path'] == null
            ? json['still_path']
            : "http://image.tmdb.org/t/p/w780" + json['still_path'],
        vote_average: json['vote_average'].toDouble(),
        vote_count: json['vote_count']);
  }
}
