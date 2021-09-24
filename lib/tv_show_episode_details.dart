import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'Models/tv_show_cast_and_crew_cast_model.dart';
import 'Models/tv_show_cast_and_crew_crew_model.dart';
import 'Models/tv_show_episode_cast_and_crew_model.dart';
import 'Models/tv_show_episode_images_model.dart';
import 'Models/tv_show_movie_videos_model.dart';
import 'Models/tv_show_movie_videos_results_model.dart';
import 'Models/tv_show_season_details_episode_guest_stars_model.dart';
import 'Models/tv_show_season_details_episodes_model.dart';
import 'Models/youtube_video_details_items_content_details_model.dart';
import 'Models/youtube_video_details_model.dart';

import 'Utils/LoadingBarIndicator.dart';
import 'Utils/NewPageTransition.dart';

import 'person_details.dart';
import 'youtube_video_player_page.dart';
import 'zoomable_image_view.dart';

class TvShowEpisodeDetails extends StatefulWidget {
  final int tvShowId;
  final TvShowSeasonDetailsEpisodesModel tvSeasonDetailsEpisodesModel;

  TvShowEpisodeDetails(
      {Key key,
      @required this.tvShowId,
      @required this.tvSeasonDetailsEpisodesModel})
      : super(key: key);

  _TvShowEpisodeDetailsState createState() =>
      _TvShowEpisodeDetailsState(tvShowId, tvSeasonDetailsEpisodesModel);
}

class _TvShowEpisodeDetailsState extends State<TvShowEpisodeDetails> {
  MediaQueryData mediaQueryData;

  double screenWidth;
  double screenHeight;

  int _tvShowId;
  TvShowSeasonDetailsEpisodesModel tvShowSeasonDetailsEpisodesModel;

  TvShowMovieVideosModel tvShowEpisodeVideosModel;
  List<TvShowMovieVideosResultsModel> tvShowEpisodeVideosResultsList;

  var tvShowEpisodeCastAndCrewCastList = List<TvShowCastAndCrewCastModel>();
  var tvShowEpisodeCastAndCrewCrewList = List<TvShowCastAndCrewCrewModel>();
  var tvShowEpisodeGuestStarsList =
      List<TvShowSeasonDetailsEpisodeGuestStarsModel>();

  var tvShowEpisodeYoutubeVideosResults = List<TvShowMovieVideosResultsModel>();
  var youtubeVideosDurationsList = List<String>();

  TvShowEpisodeImagesModel tvShowEpisodeImagesModel;
  var tvShowEpisodeImagesStillsList = List<String>();

  _TvShowEpisodeDetailsState(
      this._tvShowId, this.tvShowSeasonDetailsEpisodesModel);

  Future fetchTvEpisodeCastAndCrew() async {
    final response = await http.get(
        Uri.encodeFull(
            'https://api.themoviedb.org/3/tv/$_tvShowId/season/${tvShowSeasonDetailsEpisodesModel.season_number}/episode/${tvShowSeasonDetailsEpisodesModel.episode_number}/credits?api_key=63e2f7bc00c513994d63c9be541a08d1'),
        headers: {"Accept": "application/json"});
    if (this.mounted) {
      setState(() {
        TvShowEpisodeCastAndCrewModel tvShowEpisodeCastAndCrewModel =
            TvShowEpisodeCastAndCrewModel.fromJson(json.decode(response.body));
        tvShowEpisodeCastAndCrewCastList = tvShowEpisodeCastAndCrewModel.cast;
        tvShowEpisodeCastAndCrewCrewList = tvShowEpisodeCastAndCrewModel.crew;
        tvShowEpisodeGuestStarsList = tvShowEpisodeCastAndCrewModel.guest_stars;
      });
    }
  }

  Future fetchTvEpisodeVideos() async {
    final response = await http.get(
        Uri.encodeFull(
            'https://api.themoviedb.org/3/tv/$_tvShowId/season/${tvShowSeasonDetailsEpisodesModel.season_number}/episode/${tvShowSeasonDetailsEpisodesModel.episode_number}/videos?api_key=63e2f7bc00c513994d63c9be541a08d1'),
        headers: {"Accept": "application/json"});
    if (this.mounted) {
      setState(() {
        tvShowEpisodeVideosModel =
            TvShowMovieVideosModel.fromJson(json.decode(response.body));
        tvShowEpisodeVideosResultsList = tvShowEpisodeVideosModel.results;

        for (var i in tvShowEpisodeVideosResultsList) {
          if (i.site == "YouTube") {
            tvShowEpisodeYoutubeVideosResults.add(i);
          }
        }
        if (tvShowEpisodeYoutubeVideosResults != null &&
            tvShowEpisodeYoutubeVideosResults.length > 0) {
          fetchYoutubeVideoDetails(tvShowEpisodeYoutubeVideosResults);
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

    setState(() {
      youtubeVideosDurationsList = durationsList;
    });
  }

  Future fetchTvEpisodeImages() async {
    final response = await http.get(
        Uri.encodeFull(
            'https://api.themoviedb.org/3/tv/$_tvShowId/season/${tvShowSeasonDetailsEpisodesModel.season_number}/episode/${tvShowSeasonDetailsEpisodesModel.episode_number}/images?api_key=63e2f7bc00c513994d63c9be541a08d1'),
        headers: {"Accept": "application/json"});
    if (this.mounted) {
      setState(() {
        tvShowEpisodeImagesModel =
            TvShowEpisodeImagesModel.fromJson(json.decode(response.body));
        tvShowEpisodeImagesStillsList =
            tvShowEpisodeImagesModel.stills.map((i) => i.file_path).toList();
      });
    }
  }

  ScrollController scrollController;

  double offset = 0.0;

  PageController castPageController = PageController();
  double castCurrentPage = 0.0;

  PageController crewPageController = PageController();
  double crewCurrentPage = 0.0;

  PageController guestStarsPageController = PageController();
  double guestStarsCurrentPage = 0.0;

  PageController videosPageController = PageController();
  double videosCurrentPage = 0.0;

  PageController stillsPageController = PageController();
  double stillsCurrentPage = 0.0;

  @override
  void initState() {
    super.initState();

    this.fetchTvEpisodeCastAndCrew();
    // this.fetchTvEpisodeVideos();
    this.fetchTvEpisodeImages();

    scrollController = ScrollController()..addListener(_scrollListener);

    castPageController.addListener(() {
      setState(() {
        castCurrentPage = castPageController.page;
      });
    });

    crewPageController.addListener(() {
      setState(() {
        crewCurrentPage = crewPageController.page;
      });
    });

    guestStarsPageController.addListener(() {
      setState(() {
        guestStarsCurrentPage = guestStarsPageController.page;
      });
    });

    videosPageController.addListener(() {
      setState(() {
        videosCurrentPage = videosPageController.page;
      });
    });

    stillsPageController.addListener(() {
      setState(() {
        stillsCurrentPage = stillsPageController.page;
      });
    });
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  _scrollListener() {
    if (this.mounted) {
      if (scrollController.hasClients) {
        setState(() {
          offset = scrollController.offset;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    mediaQueryData = MediaQuery.of(context);

    screenWidth = mediaQueryData.size.width;
    screenHeight = mediaQueryData.size.height;

    var _colors = List<Color>();

    _colors.add(Colors.green);
    _colors.add(Colors.blue);
    _colors.add(Colors.yellow);
    _colors.add(Colors.purple);
    _colors.add(Colors.deepOrange);

    return Scaffold(
      backgroundColor: Colors.white,
      body: tvShowSeasonDetailsEpisodesModel == null
          ? Container(
              color: Colors.white,
              child: Center(
                child: LoadingBarIndicator(
                  numberOfBars: 5,
                  colors: _colors,
                  barSpacing: 5.0,
                  beginTweenValue: 20.0,
                  endTweenValue: 30.0,
                ),
              ),
            )
          : CustomScrollView(
              controller: scrollController,
              slivers: <Widget>[
                SliverAppBar(
                  leading: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 17,
                  ),
                  expandedHeight: 470,
                  pinned: true,
                  floating: false,
                  snap: false,
                  backgroundColor: Colors.green[200],
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text(
                      tvShowSeasonDetailsEpisodesModel.season_number == null ||
                              tvShowSeasonDetailsEpisodesModel.episode_number ==
                                  null
                          ? ""
                          : "S0" +
                              tvShowSeasonDetailsEpisodesModel.season_number
                                  .toString() +
                              "E0" +
                              tvShowSeasonDetailsEpisodesModel.episode_number
                                  .toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "ConcertOne-Regular",
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    background: tvShowSeasonDetailsEpisodesModel.still_path ==
                                null ||
                            tvShowSeasonDetailsEpisodesModel.still_path == ""
                        ? Container(
                            color: Colors.grey,
                            child: Center(
                              child: Icon(Icons.tv,
                                  size: 80, color: Colors.grey[100],),
                            ),
                          )
                        : Container(
                            child: Image.network(
                              tvShowSeasonDetailsEpisodesModel.still_path,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: tvShowSeasonDetailsEpisodesModel.vote_average == null
                      ? Container()
                      : Container(
                          color: Colors.grey[200],
                          child: Column(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(
                                    top: 20.0,
                                    left: 10.0,
                                    right: 10.0,
                                    bottom: 10.0),
                                child: Text(
                                  "Average Rating : " +
                                      tvShowSeasonDetailsEpisodesModel
                                          .vote_average
                                          .floor()
                                          .toString() +
                                      "/10",
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.fade,
                                  style: TextStyle(
                                    fontFamily: "ConcertOne-Regular",
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Container(
                                height: 0.5,
                                margin: EdgeInsets.only(top: 10.0),
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(color: Colors.black),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                SliverToBoxAdapter(
                  child: tvShowSeasonDetailsEpisodesModel.name == "" ||
                          tvShowSeasonDetailsEpisodesModel.vote_average == null
                      ? Container()
                      : Container(
                          color: Colors.grey[100].withOpacity(0.7),
                          child: Column(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(
                                    top: 20.0,
                                    left: 10.0,
                                    right: 10.0,
                                    bottom: 10.0),
                                child: Text(
                                  tvShowSeasonDetailsEpisodesModel.name,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.fade,
                                  style: TextStyle(
                                    fontFamily: "ConcertOne-Regular",
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Container(
                                height: 1,
                                margin: EdgeInsets.only(top: 10.0),
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(color: Colors.black),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Container(
                        padding: EdgeInsets.only(
                          left: 15.0,
                          right: 15.0,
                          top: 15.0,
                          bottom: 10.0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              child: Text(
                                "Released Date : ",
                                textAlign: TextAlign.start,
                                textDirection: TextDirection.ltr,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  fontFamily: "CantoraOne-Regular",
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                child: Text(
                                  tvShowSeasonDetailsEpisodesModel.air_date,
                                  textAlign: TextAlign.start,
                                  textDirection: TextDirection.ltr,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      tvShowSeasonDetailsEpisodesModel.overview == "" ||
                              tvShowSeasonDetailsEpisodesModel == null
                          ? Container()
                          : Container(
                              margin: EdgeInsets.only(
                                left: 15.0,
                                right: 15.0,
                                top: 5.0,
                              ),
                              child: Text(
                                "Overview",
                                textAlign: TextAlign.start,
                                textDirection: TextDirection.ltr,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w100,
                                  fontSize: 16,
                                  fontFamily: "ConcertOne-Regular",
                                ),
                              ),
                            ),
                      tvShowSeasonDetailsEpisodesModel.overview == "" ||
                              tvShowSeasonDetailsEpisodesModel == null
                          ? Container()
                          : Container(
                              margin: EdgeInsets.only(
                                left: 10.0,
                                right: 10.0,
                                bottom: 10.0,
                              ),
                              padding: EdgeInsets.all(10.0),
                              child: Text(
                                tvShowSeasonDetailsEpisodesModel.overview,
                                textAlign: TextAlign.start,
                                textDirection: TextDirection.ltr,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                      Container(
                        height: 0.5,
                        margin: EdgeInsets.only(bottom: 0.0),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(color: Colors.black),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SliverList(
                  delegate: tvShowEpisodeCastAndCrewCastList.length == 0 ||
                          tvShowEpisodeCastAndCrewCastList == null
                      ? SliverChildListDelegate([])
                      : SliverChildListDelegate(
                          [
                            Container(
                              margin: EdgeInsets.only(
                                left: 15.0,
                                right: 15.0,
                                top: 15.0,
                              ),
                              child: Text(
                                "Cast",
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.ltr,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w100,
                                  fontSize: 16,
                                  fontFamily: "ConcertOne-Regular",
                                ),
                              ),
                            ),
                            Container(
                              height: 330.0,
                              margin: EdgeInsets.only(
                                top: 10.0,
                              ),
                              child: PageView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: BouncingScrollPhysics(),
                                controller: castPageController,
                                itemCount:
                                    tvShowEpisodeCastAndCrewCastList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  if (index == castCurrentPage.floor()) {
                                    return Transform.scale(
                                      scale: (1.0 - (castCurrentPage - index)),
                                      child: buildThreeLayerListItems(
                                        tvShowEpisodeCastAndCrewCastList[index]
                                            .profile_path,
                                        tvShowEpisodeCastAndCrewCastList[index]
                                            .name,
                                        tvShowEpisodeCastAndCrewCastList[index]
                                            .character,
                                        tvShowEpisodeCastAndCrewCastList[index]
                                            .credit_id
                                            .toString(),
                                        tvShowEpisodeCastAndCrewCastList[index]
                                            .id,
                                        "cast",
                                      ),
                                    );
                                  } else if (index ==
                                      castCurrentPage.floor() + 1) {
                                    return Transform.scale(
                                      scale: (1.0 + (castCurrentPage - index)),
                                      child: buildThreeLayerListItems(
                                        tvShowEpisodeCastAndCrewCastList[index]
                                            .profile_path,
                                        tvShowEpisodeCastAndCrewCastList[index]
                                            .name,
                                        tvShowEpisodeCastAndCrewCastList[index]
                                            .character,
                                        tvShowEpisodeCastAndCrewCastList[index]
                                            .credit_id
                                            .toString(),
                                        tvShowEpisodeCastAndCrewCastList[index]
                                            .id,
                                        "cast",
                                      ),
                                    );
                                  } else {
                                    return buildThreeLayerListItems(
                                      tvShowEpisodeCastAndCrewCastList[index]
                                          .profile_path,
                                      tvShowEpisodeCastAndCrewCastList[index]
                                          .name,
                                      tvShowEpisodeCastAndCrewCastList[index]
                                          .character,
                                      tvShowEpisodeCastAndCrewCastList[index]
                                          .credit_id
                                          .toString(),
                                      tvShowEpisodeCastAndCrewCastList[index]
                                          .id,
                                      "cast",
                                    );
                                  }
                                },
                              ),
                            ),
                            Container(
                              height: 0.5,
                              margin: EdgeInsets.only(bottom: 0.0),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(color: Colors.black),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
                SliverList(
                  delegate: tvShowEpisodeCastAndCrewCrewList.length == 0 ||
                          tvShowEpisodeCastAndCrewCrewList == null
                      ? SliverChildListDelegate([])
                      : SliverChildListDelegate(
                          [
                            Container(
                              margin: EdgeInsets.only(
                                left: 15.0,
                                right: 15.0,
                                top: 15.0,
                              ),
                              child: Text(
                                "Crew",
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.ltr,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w100,
                                  fontSize: 16,
                                  fontFamily: "ConcertOne-Regular",
                                ),
                              ),
                            ),
                            Container(
                              height: 330.0,
                              margin: EdgeInsets.only(
                                top: 10.0,
                              ),
                              child: PageView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: BouncingScrollPhysics(),
                                controller: crewPageController,
                                itemCount:
                                    tvShowEpisodeCastAndCrewCrewList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  if (index == crewCurrentPage.floor()) {
                                    return Transform.scale(
                                      scale: (1.0 - (crewCurrentPage - index)),
                                      child: buildThreeLayerListItems(
                                        tvShowEpisodeCastAndCrewCrewList[index]
                                            .profile_path,
                                        tvShowEpisodeCastAndCrewCrewList[index]
                                            .name,
                                        tvShowEpisodeCastAndCrewCrewList[index]
                                            .department,
                                        tvShowEpisodeCastAndCrewCrewList[index]
                                            .credit_id
                                            .toString(),
                                        tvShowEpisodeCastAndCrewCrewList[index]
                                            .id,
                                        "crew",
                                      ),
                                    );
                                  } else if (index ==
                                      crewCurrentPage.floor() + 1) {
                                    return Transform.scale(
                                      scale: (1.0 + (crewCurrentPage - index)),
                                      child: buildThreeLayerListItems(
                                        tvShowEpisodeCastAndCrewCrewList[index]
                                            .profile_path,
                                        tvShowEpisodeCastAndCrewCrewList[index]
                                            .name,
                                        tvShowEpisodeCastAndCrewCrewList[index]
                                            .department,
                                        tvShowEpisodeCastAndCrewCrewList[index]
                                            .credit_id
                                            .toString(),
                                        tvShowEpisodeCastAndCrewCrewList[index]
                                            .id,
                                        "crew",
                                      ),
                                    );
                                  } else {
                                    return buildThreeLayerListItems(
                                      tvShowEpisodeCastAndCrewCrewList[index]
                                          .profile_path,
                                      tvShowEpisodeCastAndCrewCrewList[index]
                                          .name,
                                      tvShowEpisodeCastAndCrewCrewList[index]
                                          .department,
                                      tvShowEpisodeCastAndCrewCrewList[index]
                                          .credit_id
                                          .toString(),
                                      tvShowEpisodeCastAndCrewCrewList[index]
                                          .id,
                                      "crew",
                                    );
                                  }
                                },
                              ),
                            ),
                            Container(
                              height: 0.5,
                              margin: EdgeInsets.only(bottom: 0.0),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(color: Colors.black),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
                SliverList(
                  delegate: tvShowEpisodeGuestStarsList.length == 0 ||
                          tvShowEpisodeGuestStarsList == null
                      ? SliverChildListDelegate([])
                      : SliverChildListDelegate(
                          [
                            Container(
                              margin: EdgeInsets.only(
                                left: 15.0,
                                right: 15.0,
                                top: 15.0,
                              ),
                              child: Text(
                                "Guest Stars",
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.ltr,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w100,
                                  fontSize: 16,
                                  fontFamily: "ConcertOne-Regular",
                                ),
                              ),
                            ),
                            Container(
                              height: 330.0,
                              margin: EdgeInsets.only(
                                top: 10.0,
                              ),
                              child: PageView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: BouncingScrollPhysics(),
                                controller: guestStarsPageController,
                                itemCount: tvShowEpisodeGuestStarsList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  if (index == guestStarsCurrentPage.floor()) {
                                    return Transform.scale(
                                      scale: (1.0 -
                                          (guestStarsCurrentPage - index)),
                                      child: buildThreeLayerListItems(
                                        tvShowEpisodeGuestStarsList[index]
                                            .profile_path,
                                        tvShowEpisodeGuestStarsList[index].name,
                                        tvShowEpisodeGuestStarsList[index]
                                            .character,
                                        tvShowEpisodeGuestStarsList[index]
                                            .credit_id
                                            .toString(),
                                        tvShowEpisodeGuestStarsList[index].id,
                                        "guestStars",
                                      ),
                                    );
                                  } else if (index ==
                                      guestStarsCurrentPage.floor() + 1) {
                                    return Transform.scale(
                                      scale: (1.0 +
                                          (guestStarsCurrentPage - index)),
                                      child: buildThreeLayerListItems(
                                        tvShowEpisodeGuestStarsList[index]
                                            .profile_path,
                                        tvShowEpisodeGuestStarsList[index].name,
                                        tvShowEpisodeGuestStarsList[index]
                                            .character,
                                        tvShowEpisodeGuestStarsList[index]
                                            .credit_id
                                            .toString(),
                                        tvShowEpisodeGuestStarsList[index].id,
                                        "guestStars",
                                      ),
                                    );
                                  } else {
                                    return buildThreeLayerListItems(
                                      tvShowEpisodeGuestStarsList[index]
                                          .profile_path,
                                      tvShowEpisodeGuestStarsList[index].name,
                                      tvShowEpisodeGuestStarsList[index]
                                          .character,
                                      tvShowEpisodeGuestStarsList[index]
                                          .credit_id
                                          .toString(),
                                      tvShowEpisodeGuestStarsList[index].id,
                                      "guestStars",
                                    );
                                  }
                                },
                              ),
                            ),
                            Container(
                              height: 0.5,
                              margin: EdgeInsets.only(bottom: 0.0),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(color: Colors.black),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Container(
                        margin: EdgeInsets.only(
                          left: 15.0,
                          right: 15.0,
                          top: 15.0,
                        ),
                        child: Text(
                          "Videos",
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w100,
                            fontSize: 16,
                            fontFamily: "ConcertOne-Regular",
                          ),
                        ),
                      ),
                      Container(
                        height: 1 / (16 / 9) * screenWidth,
                        margin: EdgeInsets.only(
                          top: 10.0,
                          bottom: 10.0,
                        ),
                        child: PageView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: BouncingScrollPhysics(),
                          controller: videosPageController,
                          itemCount: tvShowEpisodeYoutubeVideosResults.length,
                          itemBuilder: (BuildContext context, int index) {
                            if (tvShowEpisodeYoutubeVideosResults[index].key ==
                                    null ||
                                youtubeVideosDurationsList.length <= 0 ||
                                youtubeVideosDurationsList[index] == null) {
                              return Container();
                            } else {
                              String key =
                                  tvShowEpisodeYoutubeVideosResults[index].key;

                              String duration =
                                  youtubeVideosDurationsList[index];

                              if (index == videosCurrentPage.floor()) {
                                return Transform.scale(
                                  scale: (1.0 - (videosCurrentPage - index)),
                                  child: buildVideosListItems(
                                    tvShowEpisodeYoutubeVideosResults[index],
                                    key,
                                    duration,
                                  ),
                                );
                              } else if (index ==
                                  videosCurrentPage.floor() + 1) {
                                return Transform.scale(
                                  scale: (1.0 + (videosCurrentPage - index)),
                                  child: buildVideosListItems(
                                    tvShowEpisodeYoutubeVideosResults[index],
                                    key,
                                    duration,
                                  ),
                                );
                              } else {
                                return buildVideosListItems(
                                  tvShowEpisodeYoutubeVideosResults[index],
                                  key,
                                  duration,
                                );
                              }
                            }
                          },
                        ),
                      ),
                      Container(
                        height: 0.5,
                        margin: EdgeInsets.only(bottom: 0.0),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(color: Colors.black),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SliverList(
                  delegate: tvShowEpisodeImagesStillsList.length == 0 ||
                          tvShowEpisodeImagesStillsList == null
                      ? SliverChildListDelegate([])
                      : SliverChildListDelegate(
                          [
                            Container(
                              margin: EdgeInsets.only(
                                left: 15.0,
                                right: 15.0,
                                top: 15.0,
                              ),
                              child: Text(
                                "Stills",
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.ltr,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w100,
                                  fontSize: 16,
                                  fontFamily: "ConcertOne-Regular",
                                ),
                              ),
                            ),
                            Container(
                              height: 250.0,
                              margin: EdgeInsets.only(
                                top: 10.0,
                              ),
                              child: PageView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: BouncingScrollPhysics(),
                                controller: stillsPageController,
                                itemCount: tvShowEpisodeImagesStillsList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  if (index == stillsCurrentPage.floor()) {
                                    return Transform.scale(
                                      scale:
                                          (1.0 - (stillsCurrentPage - index)),
                                      child: buildImageListItems(
                                        tvShowEpisodeImagesStillsList[index],
                                        index,
                                        tvShowEpisodeImagesStillsList,
                                      ),
                                    );
                                  } else if (index ==
                                      stillsCurrentPage.floor() + 1) {
                                    return Transform.scale(
                                      scale:
                                          (1.0 + (stillsCurrentPage - index)),
                                      child: buildImageListItems(
                                        tvShowEpisodeImagesStillsList[index],
                                        index,
                                        tvShowEpisodeImagesStillsList,
                                      ),
                                    );
                                  } else {
                                    return buildImageListItems(
                                      tvShowEpisodeImagesStillsList[index],
                                      index,
                                      tvShowEpisodeImagesStillsList,
                                    );
                                  }
                                },
                              ),
                            ),
                            Container(
                              height: 0.5,
                              margin: EdgeInsets.only(bottom: 0.0),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(color: Colors.black),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
    );
  }

  Widget buildThreeLayerListItems(
    String imageUrl,
    String name,
    String subTitle,
    String heroId,
    int sendId,
    String type,
  ) {
    String sub = "";

    if (type == "cast" || type == "guestStars") {
      sub = "Character : ";
    } else if (type == "crew") {
      sub = "Department : ";
    } else {
      sub = "";
    }

    return GestureDetector(
      onTap: () {
        if (type == "cast" || type == "crew" || type == "guestStars") {
          Navigator.push(
              context,
              NewPageTransition(
                  widget: PersonDetails(
                personId: sendId,
              )));
        }
      },
      child: Container(
        margin: EdgeInsets.only(
          left: 10.0,
          right: 15.0,
          top: 10.0,
          bottom: 15.0,
        ),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 4.0,
              spreadRadius: 1.0,
            ),
          ],
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        child: Column(
          children: <Widget>[
            imageUrl == null
                ? Container(
                    height: 200,
                    width: screenWidth - 20,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.person,
                        color: Colors.grey[100],
                        size: 80,
                      ),
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0)),
                    child: Image.network(
                      imageUrl,
                      height: 200,
                      width: screenWidth - 20,
                      fit: BoxFit.cover,
                    ),
                  ),
            name == "" || name == null
                ? Container()
                : Container(
                    height: 35,
                    width: screenWidth - 20,
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.1)
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        name,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.fade,
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          color: Colors.black,
                          fontSize: 18,
                          fontFamily: 'CantoraOne-Regular',
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                  ),
            subTitle == "" || subTitle == null
                ? Container()
                : Container(
                    height: 0.5,
                    margin: EdgeInsets.only(bottom: 0.0),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(color: Colors.black),
                      ],
                    ),
                  ),
            subTitle == "" || subTitle == null
                ? Container()
                : Container(
                    alignment: Alignment.center,
                    height: 59,
                    width: screenWidth - 20,
                    padding: EdgeInsets.only(
                      top: 10.0,
                      left: 5.0,
                      right: 5.0,
                      bottom: 5.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          sub,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                            decoration: TextDecoration.none,
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'CantoraOne-Regular',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          subTitle,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                            decoration: TextDecoration.none,
                            color: Colors.black,
                            fontSize: 15,
                            fontFamily: 'CantoraOne-Regular',
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

  Widget buildVideosListItems(
      TvShowMovieVideosResultsModel tvYoutubeVideosResults,
      String key,
      String duration) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            NewPageTransition(
                widget: YoutubeVideoPlayerPage(
                    id: _tvShowId,
                    playingVideoDetails: tvYoutubeVideosResults)));
      },
      child: Container(
        margin: EdgeInsets.only(
          left: 10.0,
          right: 10.0,
          top: 10.0,
          bottom: 15.0,
        ),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 4.0,
              spreadRadius: 1.0,
            ),
          ],
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        child: Stack(
          children: <Widget>[
            Container(
              height: 1 / (16 / 9) * screenWidth,
              width: screenWidth,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                child: Hero(
                    tag: key,
                    child: Image.network(
                      "https://i3.ytimg.com/vi/$key/sddefault.jpg",
                      fit: BoxFit.cover,
                    )),
              ),
            ),
            Container(
              height: 240,
              width: screenWidth - 10,
              child: Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  padding: EdgeInsets.all(7.0),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(2.0),
                        bottomRight: Radius.circular(10.0)),
                  ),
                  child: Text(
                    duration,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildImageListItems(
      String imageUrl, int _currentIndex, List<String> _imagesList) {
    return imageUrl == null
        ? Container()
        : GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ZoomableImageView(
                          heroTag: imageUrl,
                          currentIndex: _currentIndex,
                          imagesList: _imagesList,
                        )),
              );
            },
            child: Container(
              margin: EdgeInsets.only(
                left: 10.0,
                right: 15.0,
                top: 10.0,
                bottom: 15.0,
              ),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 4.0,
                    spreadRadius: 1.0,
                  ),
                ],
                border: Border.all(width: 0.0),
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
              child: Hero(
                tag: imageUrl,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  child: Image.network(
                    imageUrl,
                    width: screenWidth - 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          );
  }
}
