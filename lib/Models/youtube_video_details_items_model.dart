import './youtube_video_details_items_content_details_model.dart';

class YoutubeVideoDetailsItemsModel
{
  final String kind;
  final String etag;
  final String id;

  final YoutubeVideoDetailsItemsContentDetailsModel contentDetails;

  YoutubeVideoDetailsItemsModel({this.kind, this.etag, this.id, this.contentDetails});

  factory YoutubeVideoDetailsItemsModel.fromJson(Map<String, dynamic> json)
  {
    return YoutubeVideoDetailsItemsModel(kind: json['kind'], etag: json['etag'], id: json['id'], contentDetails: YoutubeVideoDetailsItemsContentDetailsModel.fromJson(json['contentDetails']));
  }
}