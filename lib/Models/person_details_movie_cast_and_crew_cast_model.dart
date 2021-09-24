class PersonDetailsMovieCastAndCrewCastModel {
  final String character;
  final String credit_id;
  final String poster_path;
  final int id;
  final bool video;
  final int vote_count;
  final bool adult;
  final String backdrop_path;
  final List<int> genre_ids;
  final String original_language;
  final String original_title;
  final double popularity;
  final String title;
  final double vote_average;
  final String overview;
  final String release_date;

  PersonDetailsMovieCastAndCrewCastModel(
      {this.character,
      this.credit_id,
      this.poster_path,
      this.id,
      this.video,
      this.vote_count,
      this.adult,
      this.backdrop_path,
      this.genre_ids,
      this.original_language,
      this.original_title,
      this.popularity,
      this.title,
      this.vote_average,
      this.overview,
      this.release_date});

  factory PersonDetailsMovieCastAndCrewCastModel.fromJson(
      Map<String, dynamic> json) {

           var genreIdsList = json['genre_ids'];
    return PersonDetailsMovieCastAndCrewCastModel(
      character: json['character'],
      credit_id: json['credit_id'],
      poster_path: json['poster_path'] == null
          ? json['poster_path']
          : "http://image.tmdb.org/t/p/w780" + json['poster_path'],
      id: json['id'],
      video: json['video'],
      vote_count: json['vote_count'],
      adult: json['adult'],
      backdrop_path: json['backdrop_path'] == null
          ? json['backdrop_path']
          : "http://image.tmdb.org/t/p/w780" + json['backdrop_path'],
      genre_ids: List<int>.from(genreIdsList),
      original_language: json['original_language'],
      original_title: json['original_title'],
      popularity: json['popularity'].toDouble(),
      title: json['title'],
      vote_average: json['vote_average'].toDouble(),
      overview: json['overview'],
      release_date: json['release_date'],
    );
  }
}
