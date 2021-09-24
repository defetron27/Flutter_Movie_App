class YoutubeVideoDetailsItemsContentDetailsModel
{
  final String duration;
  final String dimension;
  final String definition;
  final String caption;
  final bool licensedContent;
  final String projection;

  YoutubeVideoDetailsItemsContentDetailsModel({this.duration, this.dimension, this.definition, this.caption, this.licensedContent, this.projection});

  factory YoutubeVideoDetailsItemsContentDetailsModel.fromJson(Map<String,dynamic> json)
  {
    return YoutubeVideoDetailsItemsContentDetailsModel(duration: json['duration'], dimension: json['dimension'], definition: json['definition'], caption: json['caption'], licensedContent: json['licensedContent'], projection: json['projection']);
  }
}