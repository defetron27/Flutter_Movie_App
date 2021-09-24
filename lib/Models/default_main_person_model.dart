

import 'default_main_person_results_model.dart';

class DefaultMainPersonModel {
  final int page;
  final int total_results;
  final int total_pages;

  final List<DefaultMainPersonResultsModel> results;

  DefaultMainPersonModel(
      {this.page, this.total_results, this.total_pages, this.results});

  factory DefaultMainPersonModel.fromJson(Map<String, dynamic> json) {
    var popularResultsList = json['results'] as List;

    return DefaultMainPersonModel(
        page: json['page'],
        total_results: json['total_results'],
        total_pages: json['total_pages'],
        results: popularResultsList
            .map((i) => DefaultMainPersonResultsModel.fromJson(i))
            .toList());
  }
}
