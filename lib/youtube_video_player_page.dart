import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:youtube_player/youtube_player.dart';

import 'Models/tv_show_movie_videos_model.dart';
import 'Models/tv_show_movie_videos_results_model.dart';
import 'Models/youtube_video_details_items_content_details_model.dart';
import 'Models/youtube_video_details_model.dart';

import 'Utils/NewPageTransition.dart';

class YoutubeVideoPlayerPage extends StatefulWidget {
  final int id;
  final TvShowMovieVideosResultsModel playingVideoDetails;

  YoutubeVideoPlayerPage(
      {Key key, @required this.id, @required this.playingVideoDetails})
      : super(key: key);

  _YoutubeVideoPlayerPageState createState() =>
      _YoutubeVideoPlayerPageState(id, playingVideoDetails);
}

class _YoutubeVideoPlayerPageState extends State<YoutubeVideoPlayerPage> {
  MediaQueryData mediaQueryData;

  double screenWidth;
  double screenHeight;

  double listItemsWidth = 0.0;
  double listItemsHeight = 0.0;

  int id;

  TvShowMovieVideosResultsModel playingVideoDetails;

  var upNextYoutubeVideosResults = List<TvShowMovieVideosResultsModel>();
  var youtubeVideosDurationsList = List<String>();

  VideoPlayerController controller;

  _YoutubeVideoPlayerPageState(
      int id, TvShowMovieVideosResultsModel playingVideoDetails) {
    this.id = id;
    this.playingVideoDetails = playingVideoDetails;
  }

  Future fetchTvShowVideos() async {
    final response = await http.get(
        Uri.encodeFull(
            'https://api.themoviedb.org/3/tv/$id/videos?api_key=63e2f7bc00c513994d63c9be541a08d1'),
        headers: {"Accept": "application/json"});
    if (this.mounted) {
      setState(() {
        TvShowMovieVideosModel tvShowVideosModel =
            TvShowMovieVideosModel.fromJson(json.decode(response.body));
        List<TvShowMovieVideosResultsModel> tvYoutubeVideosResults =
            tvShowVideosModel.results;

        for (var i in tvYoutubeVideosResults) {
          if (i.site == "YouTube" && i.key != playingVideoDetails.key) {
            upNextYoutubeVideosResults.add(i);
          }
        }
        if (upNextYoutubeVideosResults != null &&
            upNextYoutubeVideosResults.length > 0) {
          fetchYoutubeVideoDetails(upNextYoutubeVideosResults);
        }
      });
    }
  }

  Future fetchYoutubeVideoDetails(
      List<TvShowMovieVideosResultsModel> tvYoutubeVideosResults) async {
    var durationsList = List<String>();

    for (var youtubeVideos in tvYoutubeVideosResults) {
      String videoId = youtubeVideos.key;

      final response = await http.get(
          Uri.encodeFull(
              'https://www.googleapis.com/youtube/v3/videos?id=$videoId&part=contentDetails&key=AIzaSyCXqUoaOT7iCNxSHkPSi-Q2l1F18ii0eG8'),
          headers: {"Accept": "application/json"});

      YoutubeVideoDetailsModel youtubeVideoDetailsModel =
          YoutubeVideoDetailsModel.fromJson(json.decode(response.body));

      YoutubeVideoDetailsItemsContentDetailsModel detailsModel =
          youtubeVideoDetailsModel.items[0].contentDetails;

      String detailsDuration = detailsModel.duration.toLowerCase().substring(2);

      var hours = detailsDuration.split("h");

      var minutes =
          hours.length == 2 ? hours[1].split("m") : hours[0].split("m");

      var seconds =
          minutes.length == 2 ? minutes[1].split("s") : minutes[0].split("s");

      String durationHours = hours.length == 2 ? hours[0] + ":" : "";

      String durationMinutes = minutes.length == 2 ? minutes[0] + ":" : "";

      durationsList.add(durationHours + durationMinutes + seconds[0]);
    }

    if (this.mounted) {
      setState(() {
        youtubeVideosDurationsList = durationsList;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    fetchTvShowVideos();
  }

  @override
  Widget build(BuildContext context) {
    mediaQueryData = MediaQuery.of(context);

    screenWidth = mediaQueryData.size.width;
    screenHeight = mediaQueryData.size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        left: true,
        right: true,
        top: true,
        bottom: true,
        child: Column(
          children: <Widget>[
            Hero(
              tag: playingVideoDetails.key,
              child: YoutubePlayer(
                  source: playingVideoDetails.key,
                  context: context,
                  quality: YoutubeQuality.HIGH,
                  showThumbnail: true,
                  loop: false,
                  autoPlay: true,
                  controlsTimeOut: Duration(seconds: 4),
                  aspectRatio: 16 / 9,
                  showVideoProgressbar: false,
                  startFullScreen: false,
                  reactToOrientationChange: true,
                  playerMode: YoutubePlayerMode.DEFAULT,
                  hideShareButton: true,
                  controlsActiveBackgroundOverlay: false,
                  callbackController: (_controller) {
                    controller = _controller;
                  }),
            ),
            Expanded(
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Container(
                          width: screenWidth,
                          padding: EdgeInsets.all(15.0),
                          child: Text(
                            playingVideoDetails.name,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w100,
                              fontFamily: "ConcertOne-Regular",
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(15.0),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.all(5.0),
                                      child: GestureDetector(
                                        child: Icon(
                                          Icons.thumb_up,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "1M",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.w100,
                                        fontFamily: "ConcertOne-Regular",
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.all(5.0),
                                      child: GestureDetector(
                                        child: Icon(
                                          Icons.thumb_down,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "1M",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.w100,
                                        fontFamily: "ConcertOne-Regular",
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.all(5.0),
                                      child: GestureDetector(
                                        child: Icon(
                                          Icons.favorite,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "1M",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.w100,
                                        fontFamily: "ConcertOne-Regular",
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          color: Colors.grey,
                          height: 1,
                          margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                        ),
                        Container(
                          width: screenWidth,
                          padding: EdgeInsets.only(
                              left: 15.0, right: 10.0, bottom: 10.0),
                          child: Text(
                            "Up Next",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  upNextYoutubeVideosResults == null ||
                          upNextYoutubeVideosResults.length <= 0
                      ? SliverList(
                          delegate: SliverChildListDelegate([Container()]))
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext builder, int index) {
                              if (upNextYoutubeVideosResults[index].key ==
                                      null ||
                                  youtubeVideosDurationsList.length <= 0 ||
                                  youtubeVideosDurationsList[index] == null) {
                                return Container();
                              } else {
                                String key =
                                    upNextYoutubeVideosResults[index].key;
                                String duration =
                                    youtubeVideosDurationsList[index];

                                String name = "";

                                if (upNextYoutubeVideosResults[index]
                                        .name
                                        .length >
                                    50) {
                                  String subName =
                                      upNextYoutubeVideosResults[index]
                                          .name
                                          .substring(0, 50);
                                  name = subName + "...";
                                } else {
                                  name = upNextYoutubeVideosResults[index].name;
                                }

                                listItemsWidth = screenWidth;
                                listItemsHeight = 1 / (16 / 9) * 140.0;
                                return GestureDetector(
                                  onTap: () {
                                    controller.pause();
                                    Navigator.push(
                                        context,
                                        NewPageTransition(
                                            widget: YoutubeVideoPlayerPage(
                                                id: id,
                                                playingVideoDetails:
                                                    upNextYoutubeVideosResults[
                                                        index])));
                                  },
                                  child: AnimatedContainer(
                                    duration: Duration(seconds: 2),
                                    padding: EdgeInsets.only(
                                        left: 12.0, right: 10.0, bottom: 5.0),
                                    child: Card(
                                      borderOnForeground: false,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Stack(
                                            children: <Widget>[
                                              Container(
                                                width: 140,
                                                height: listItemsHeight,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  5.0),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  5.0)),
                                                  child: Image.network(
                                                    "https://i3.ytimg.com/vi/$key/sddefault.jpg",
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: 140,
                                                height: listItemsHeight,
                                                child: Align(
                                                  alignment:
                                                      Alignment.bottomRight,
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.all(5.0),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(
                                                                2.0),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      duration,
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Expanded(
                                            child: Container(
                                              width: 140,
                                              height: listItemsHeight,
                                              padding: EdgeInsets.all(10.0),
                                              child: Text(
                                                name,
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                            childCount: upNextYoutubeVideosResults.length,
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
