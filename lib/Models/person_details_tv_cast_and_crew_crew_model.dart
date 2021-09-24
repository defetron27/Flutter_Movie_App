class PersonDetailsTvCastAndCrewCrewModel {
  final int id;
  final String department;
  final String original_language;
  final int episode_count;
  final String job;
  final String overview;
  final List<String> origin_country;
  final String original_name;
  final List<int> genre_ids;
  final String name;
  final String first_air_date;
  final String backdrop_path;
  final double popularity;
  final int vote_count;
  final double vote_average;
  final String poster_path;
  final String credit_id;

  PersonDetailsTvCastAndCrewCrewModel(
      {this.id,
      this.department,
      this.original_language,
      this.episode_count,
      this.job,
      this.overview,
      this.origin_country,
      this.original_name,
      this.genre_ids,
      this.name,
      this.first_air_date,
      this.backdrop_path,
      this.popularity,
      this.vote_count,
      this.vote_average,
      this.poster_path,
      this.credit_id});

  factory PersonDetailsTvCastAndCrewCrewModel.fromJson(
      Map<String, dynamic> json) {
    var genreIdsList = json['genre_ids'];
    var originCountry = json['origin_country'];
    return PersonDetailsTvCastAndCrewCrewModel(
      id: json['id'],
      department: json['department'],
      original_language: json['original_language'],
      episode_count: json['episode_count'],
      job: json['job'],
      overview: json['overview'],
      origin_country: List<String>.from(originCountry),
      original_name: json['original_name'],
      genre_ids: List<int>.from(genreIdsList),
      name: json['json'],
      first_air_date: json['first_air_date'],
      backdrop_path: json['backdrop_path'] == null
          ? json['backdrop_path']
          : "http://image.tmdb.org/t/p/w780" + json['backdrop_path'],
      popularity: json['popularity'],
      vote_count: json['vote_count'],
      vote_average: json['vote_average'].toDouble(),
      poster_path: json['poster_path'] == null
          ? json['poster_path']
          : "http://image.tmdb.org/t/p/w780" + json['poster_path'],
      credit_id: json['credit_id'],
    );
  }
}
