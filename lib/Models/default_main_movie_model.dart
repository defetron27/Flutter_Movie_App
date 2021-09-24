import 'default_main_movie_results_model.dart';

class DefaultMainMovieModel {
  final int page;
  final int total_results;
  final int total_pages;

  final List<DefaultMainMovieResultsModel> results;

  DefaultMainMovieModel(
      {this.page, this.total_results, this.total_pages, this.results});

  factory DefaultMainMovieModel.fromJson(Map<String, dynamic> json) {
    var popularResultsList = json['results'] as List;

    return DefaultMainMovieModel(
        page: json['page'],
        total_results: json['total_results'],
        total_pages: json['total_pages'],
        results: popularResultsList
            .map((i) => DefaultMainMovieResultsModel.fromJson(i))
            .toList());
  }
}
