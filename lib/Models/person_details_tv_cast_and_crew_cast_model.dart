class PersonDetailsTvCastAndCrewCastModel {
  final String credit_id;
  final String original_name;
  final int id;
  final List<int> genre_ids;
  final String character;
  final String name;
  final String poster_path;
  final int vote_count;
  final double vote_average;
  final double popularity;
  final int episode_count;
  final String original_language;
  final String first_ait_date;
  final String backdrop_path;
  final String overview;
  final List<String> origin_country;

  PersonDetailsTvCastAndCrewCastModel(
      {this.credit_id,
      this.original_name,
      this.id,
      this.genre_ids,
      this.character,
      this.name,
      this.poster_path,
      this.vote_count,
      this.vote_average,
      this.popularity,
      this.episode_count,
      this.original_language,
      this.first_ait_date,
      this.backdrop_path,
      this.overview,
      this.origin_country});

  factory PersonDetailsTvCastAndCrewCastModel.fromJson(
      Map<String, dynamic> json) {
             var genreIdsList = json['genre_ids'];
        var originCountry = json['origin_country'];
    return PersonDetailsTvCastAndCrewCastModel(
      credit_id: json['credit_id'],
      original_name: json['original_name'],
      id: json['id'],
      genre_ids:  List<int>.from(genreIdsList),
      character: json['character'],
      name: json['name'],
      poster_path: json['poster_path'] == null
          ? json['poster_path']
          : "http://image.tmdb.org/t/p/w780" + json['poster_path'],
      vote_count: json['vote_count'],
      vote_average: json['vote_average'].toDouble(),
      popularity: json['popularity'],
      episode_count: json['episode_count'],
      original_language: json['original_language'],
      first_ait_date: json['first_ait_date'],
      backdrop_path: json['backdrop_path'] == null
          ? json['backdrop_path']
          : "http://image.tmdb.org/t/p/w780" + json['backdrop_path'],
      overview: json['overview'],
      origin_country:  List<String>.from(originCountry),
    );
  }
}
