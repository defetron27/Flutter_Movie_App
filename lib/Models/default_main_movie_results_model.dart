class DefaultMainMovieResultsModel {
  final bool adult;
  final String backdrop_path;
  final List<int> genres;
  final int id;
  final String original_language;
  final String original_title;
  final String overview;
  final String poster_path;
  final String release_date;
  final String title;
  final bool video;
  final double vote_average;
  final int vote_count;
  final double popularity;

  DefaultMainMovieResultsModel(
      {this.adult,
      this.backdrop_path,
      this.genres,
      this.id,
      this.original_language,
      this.original_title,
      this.overview,
      this.poster_path,
      this.release_date,
      this.title,
      this.video,
      this.vote_average,
      this.vote_count,
      this.popularity});

  factory DefaultMainMovieResultsModel.fromJson(Map<String, dynamic> json) {
    var genresList = json['genre_ids'];
    return DefaultMainMovieResultsModel(
      adult: json['adult'],
      backdrop_path:
          json['backdrop_path'] == "" || json['backdrop_path'] == null
              ? ""
              : "http://image.tmdb.org/t/p/w780" + json['backdrop_path'],
      genres: genresList == null ? [] : List<int>.from(genresList),
      id: json['id'],
      original_language: json['original_language'],
      original_title: json['original_title'],
      overview: json['overview'],
      poster_path: json['poster_path'] == "" || json['poster_path'] == null
          ? ""
          : "http://image.tmdb.org/t/p/w780" + json['poster_path'],
      release_date: json['release_date'],
      title: json['title'],
      video: json['video'],
      vote_average: json['vote_average'].toDouble(),
      vote_count: json['vote_count'],
      popularity: json['popularity'],
    );
  }
}
