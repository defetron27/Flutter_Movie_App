class DefaultMainTvShowResultsModel {
  final String original_name;
  final int id;
  final String name;
  final double popularity;
  final int vote_count;
  final double vote_average;
  final String first_air_date;
  final String poster_path;

  final List<int> genre_ids;

  final String original_language;
  final String backdrop_path;
  final String overview;

  final List<String> origin_country;

  DefaultMainTvShowResultsModel(
      {this.original_name,
      this.id,
      this.name,
      this.popularity,
      this.vote_count,
      this.vote_average,
      this.first_air_date,
      this.poster_path,
      this.genre_ids,
      this.original_language,
      this.backdrop_path,
      this.overview,
      this.origin_country});

  factory DefaultMainTvShowResultsModel.fromJson(Map<String, dynamic> json) {
    var genreIdsList = json['genre_ids'];
    var originCountryList = json['origin_country'];

    return DefaultMainTvShowResultsModel(
        original_name: json['original_name'],
        id: json['id'],
        name: json['name'],
        popularity: json['popularity'],
        vote_count: json['vote_count'],
        vote_average: json['vote_average'] == null
            ? json['vote_average']
            : json['vote_average'].toDouble(),
        first_air_date: json['first_air_date'],
        poster_path: json['poster_path'] == "" || json['poster_path'] == null
            ? json['poster_path']
            : "http://image.tmdb.org/t/p/w500" + json['poster_path'],
        genre_ids: genreIdsList == null ? [] : List<int>.from(genreIdsList),
        original_language: json['original_language'],
        backdrop_path:
            json['backdrop_path'] == "" || json['backdrop_path'] == null
                ? json['backdrop_path']
                : "http://image.tmdb.org/t/p/w500" + json['backdrop_path'],
        overview: json['overview'],
        origin_country: originCountryList == null
            ? []
            : List<String>.from(originCountryList));
  }
}
