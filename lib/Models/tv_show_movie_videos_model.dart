
import 'tv_show_movie_videos_results_model.dart';

class TvShowMovieVideosModel {
  final int id;
  final List<TvShowMovieVideosResultsModel> results;

  TvShowMovieVideosModel({this.id, this.results});

  factory TvShowMovieVideosModel.fromJson(Map<String, dynamic> json) {
    var videosList = json['results'] as List;

    return TvShowMovieVideosModel(
        id: json['id'],
        results:
            videosList.map((i) => TvShowMovieVideosResultsModel.fromJson(i)).toList());
  }
}
