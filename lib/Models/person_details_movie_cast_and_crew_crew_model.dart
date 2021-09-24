class PersonDetailsMovieCastAndCrewCrewModel {
  final int id;
  final String department;
  final String original_language;
  final String original_title;
  final String job;
  final String overview;
  final int vote_count;
  final bool video;
  final String poster_path;
  final String backdrop_path;
  final String title;
  final double popularity;
  final List<int> genre_ids;
  final double vote_average;
  final bool adult;
  final String release_date;
  final String credit_id;

  PersonDetailsMovieCastAndCrewCrewModel(
      {this.id,
      this.department,
      this.original_language,
      this.original_title,
      this.job,
      this.overview,
      this.vote_count,
      this.video,
      this.poster_path,
      this.backdrop_path,
      this.title,
      this.popularity,
      this.genre_ids,
      this.vote_average,
      this.adult,
      this.release_date,
      this.credit_id});

  factory PersonDetailsMovieCastAndCrewCrewModel.fromJson(
      Map<String, dynamic> json) {
             var genreIdsList = json['genre_ids'];
    return PersonDetailsMovieCastAndCrewCrewModel(
      id: json['id'],
      department: json['department'],
      original_language: json['original_language'],
      original_title: json['original_title'],
      job: json['job'],
      overview: json['overview'],
      vote_count: json['vote_count'],
      video: json['video'],
      poster_path: json['poster_path'] == null
          ? json['poster_path']
          : "http://image.tmdb.org/t/p/w780" + json['poster_path'],
      backdrop_path: json['backdrop_path'] == null
          ? json['backdrop_path']
          : "http://image.tmdb.org/t/p/w780" + json['backdrop_path'],
      title: json['title'],
      popularity: json['popularity'],
      genre_ids:  List<int>.from(genreIdsList),
      vote_average: json['vote_average'].toDouble(),
      adult: json['adult'],
      release_date: json['release_date'],
      credit_id: json['credit_id'],
    );
  }
}
