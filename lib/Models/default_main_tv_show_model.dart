import 'default_main_tv_show_results_model.dart';

class DefaultMainTvShowModel {
  final int page;
  final int total_results;
  final int total_pages;

  final List<DefaultMainTvShowResultsModel> results;

  DefaultMainTvShowModel(
      {this.page, this.total_results, this.total_pages, this.results});

  factory DefaultMainTvShowModel.fromJson(Map<String, dynamic> json) {
    var popularResultsList = json['results'] as List;

    return DefaultMainTvShowModel(
        page: json['page'],
        total_results: json['total_results'],
        total_pages: json['total_pages'],
        results: popularResultsList
            .map((i) => DefaultMainTvShowResultsModel.fromJson(i))
            .toList());
  }
}
