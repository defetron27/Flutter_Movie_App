import './youtube_video_details_page_info_model.dart';
import './youtube_video_details_items_model.dart';

class YoutubeVideoDetailsModel {
  final String kind;
  final String etag;

  final YoutubeVideoDetailsPageInfoModel pageInfo;

  final List<YoutubeVideoDetailsItemsModel> items;

  YoutubeVideoDetailsModel({this.kind, this.etag, this.pageInfo, this.items});

  factory YoutubeVideoDetailsModel.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List;

    return YoutubeVideoDetailsModel(
        kind: json['kind'],
        etag: json['etag'],
        pageInfo: YoutubeVideoDetailsPageInfoModel.fromJson(json['pageInfo']),
        items: itemsList
            .map((i) => YoutubeVideoDetailsItemsModel.fromJson(i))
            .toList());
  }
}
