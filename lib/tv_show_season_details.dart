import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'Models/tv_show_cast_and_crew_cast_model.dart';
import 'Models/tv_show_cast_and_crew_crew_model.dart';
import 'Models/tv_show_cast_and_crew_model.dart';
import 'Models/tv_show_movie_videos_model.dart';
import 'Models/tv_show_movie_videos_results_model.dart';
import 'Models/tv_show_season_details_episodes_model.dart';
import 'Models/tv_show_season_details_model.dart';
import 'Models/tv_show_season_images_model.dart';
import 'Models/youtube_video_details_items_content_details_model.dart';
import 'Models/youtube_video_details_model.dart';
import 'Utils/LoadingBarIndicator.dart';
import 'Utils/NewPageTransition.dart';
import 'person_details.dart';
import 'tv_show_episode_details.dart';
import 'youtube_video_player_page.dart';
import 'zoomable_image_view.dart';

class TvShowSeasonDetails extends StatefulWidget {
  final int tvShowId;
  final int tvShowSeasonNumber;

  TvShowSeasonDetails(
      {Key key, @required this.tvShowId, @required this.tvShowSeasonNumber})
      : super(key: key);

  _TvShowSeasonDetailsState createState() =>
      _TvShowSeasonDetailsState(tvShowId, tvShowSeasonNumber);
}

class _TvShowSeasonDetailsState extends State<TvShowSeasonDetails> {
  MediaQueryData mediaQueryData;

  double screenWidth;
  double screenHeight;

  int _tvShowId;
  int _tvShowSeasonNumber;

  _TvShowSeasonDetailsState(this._tvShowId, this._tvShowSeasonNumber);

  TvShowSeasonDetailsModel tvShowSeasonDetailsModel;
  List<TvShowSeasonDetailsEpisodesModel> tvShowSeasonDetailsEpisodesModelList;

  List<TvShowCastAndCrewCastModel> tvShowSeasonCastAndCrewCastList;
  List<TvShowCastAndCrewCrewModel> tvShowSeasonCastAndCrewCrewList;

  TvShowMovieVideosModel tvSeasonVideosModel;
  List<TvShowMovieVideosResultsModel> tvSeasonVideosResultsList;

  var tvSeasonYoutubeVideosResults = List<TvShowMovieVideosResultsModel>();
  var youtubeVideosDurationsList = List<String>();

  TvShowSeasonImagesModel tvSeasonImagesModel;
  var tvSeasonImagesPostersList = List<String>();

  Future fetchTvSeasonDetails() async {
    final response = await http.get(
        Uri.encodeFull(
            'https://api.themoviedb.org/3/tv/$_tvShowId/season/$_tvShowSeasonNumber?api_key=63e2f7bc00c513994d63c9be541a08d1'),
        headers: {"Accept": "application/json"});
    if (this.mounted) {
      setState(() {
        tvShowSeasonDetailsModel =
            TvShowSeasonDetailsModel.fromJson(json.decode(response.body));

        tvShowSeasonDetailsEpisodesModelList =
            tvShowSeasonDetailsModel.episodes;
      });
    }
  }

  Future fetchTvSeasonCastAndCrew() async {
    final response = await http.get(
        Uri.encodeFull(
            'https://api.themoviedb.org/3/tv/$_tvShowId/season/$_tvShowSeasonNumber/credits?api_key=63e2f7bc00c513994d63c9be541a08d1'),
        headers: {"Accept": "application/json"});
    if (this.mounted) {
      setState(() {
        TvShowCastAndCrewModel tvShowCastAndCrewModel =
            TvShowCastAndCrewModel.fromJson(json.decode(response.body));
        tvShowSeasonCastAndCrewCastList = tvShowCastAndCrewModel.cast;
        tvShowSeasonCastAndCrewCrewList = tvShowCastAndCrewModel.crew;
      });
    }
  }

  Future fetchTvSeasonVideos() async {
    final response = await http.get(
        Uri.encodeFull(
            'https://api.themoviedb.org/3/tv/$_tvShowId/season/$_tvShowSeasonNumber/videos?api_key=63e2f7bc00c513994d63c9be541a08d1'),
        headers: {"Accept": "application/json"});
    if (this.mounted) {
      setState(() {
        tvSeasonVideosModel =
            TvShowMovieVideosModel.fromJson(json.decode(response.body));
        tvSeasonVideosResultsList = tvSeasonVideosModel.results;

        for (var i in tvSeasonVideosResultsList) {
          if (i.site == "YouTube") {
            tvSeasonYoutubeVideosResults.add(i);
          }
        }
        if (tvSeasonYoutubeVideosResults != null &&
            tvSeasonYoutubeVideosResults.length > 0) {
          fetchYoutubeVideoDetails(tvSeasonYoutubeVideosResults);
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

  Future fetchTvSeasonImages() async {
    final response = await http.get(
        Uri.encodeFull(
            'https://api.themoviedb.org/3/tv/$_tvShowId/season/$_tvShowSeasonNumber/images?api_key=63e2f7bc00c513994d63c9be541a08d1'),
        headers: {"Accept": "application/json"});
    if (this.mounted) {
      setState(() {
        tvSeasonImagesModel =
            TvShowSeasonImagesModel.fromJson(json.decode(response.body));
        tvSeasonImagesPostersList =
            tvSeasonImagesModel.posters.map((i) => i.file_path).toList();
      });
    }
  }

  ScrollController scrollController;

  double offset = 0.0;

  PageController castPageController = PageController();
  double castCurrentPage = 0.0;

  PageController crewPageController = PageController();
  double crewCurrentPage = 0.0;

  PageController episodesPageController = PageController();
  double episodesCurrentPage = 0.0;

  PageController videosPageController = PageController();
  double videosCurrentPage = 0.0;

  PageController postersPageController = PageController();
  double postersCurrentPage = 0.0;

  @override
  void initState() {
    super.initState();
    this.fetchTvSeasonDetails();
    this.fetchTvSeasonCastAndCrew();
    // this.fetchTvSeasonVideos();
    this.fetchTvSeasonImages();

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

    videosPageController.addListener(() {
      setState(() {
        videosCurrentPage = videosPageController.page;
      });
    });

    postersPageController.addListener(() {
      setState(() {
        postersCurrentPage = postersPageController.page;
      });
    });

    episodesPageController.addListener(() {
      setState(() {
        episodesCurrentPage = episodesPageController.page;
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
      body: tvShowSeasonDetailsModel == null
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
                  title: Text(tvShowSeasonDetailsModel.season_number == null
                      ? ""
                      : "Season " +
                          tvShowSeasonDetailsModel.season_number.toString()),
                  backgroundColor: Colors.green[200],
                  flexibleSpace: FlexibleSpaceBar(
                    background: tvShowSeasonDetailsModel.poster_path == null ||
                            tvShowSeasonDetailsModel.poster_path == ""
                        ? Container(
                            color: Colors.grey,
                            child: Center(
                              child: Icon(
                                Icons.tv,
                                size: 80,
                                color: Colors.grey[100],
                              ),
                            ),
                          )
                        : Container(
                            child: Image.network(
                              tvShowSeasonDetailsModel.poster_path,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: tvShowSeasonDetailsModel.air_date == "" ||
                          tvShowSeasonDetailsModel.air_date == null
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
                                  "Realesed Date : " +
                                      tvShowSeasonDetailsModel.air_date,
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
                SliverList(
                  delegate: tvShowSeasonDetailsModel.overview == "" ||
                          tvShowSeasonDetailsModel == null
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
                            Container(
                              margin: EdgeInsets.only(
                                left: 10.0,
                                right: 10.0,
                                bottom: 10.0,
                              ),
                              padding: EdgeInsets.all(10.0),
                              child: Text(
                                tvShowSeasonDetailsModel.overview,
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
                  delegate: tvShowSeasonCastAndCrewCastList.length == 0 ||
                          tvShowSeasonCastAndCrewCastList == null
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
                                    tvShowSeasonCastAndCrewCastList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  if (index == castCurrentPage.floor()) {
                                    return Transform.scale(
                                      scale: (1.0 - (castCurrentPage - index)),
                                      child: buildCastAndCrewListItems(
                                        tvShowSeasonCastAndCrewCastList[index]
                                            .profile_path,
                                        tvShowSeasonCastAndCrewCastList[index]
                                            .name,
                                        tvShowSeasonCastAndCrewCastList[index]
                                            .character,
                                        tvShowSeasonCastAndCrewCastList[index]
                                            .credit_id
                                            .toString(),
                                        tvShowSeasonCastAndCrewCastList[index]
                                            .id,
                                        "cast",
                                      ),
                                    );
                                  } else if (index ==
                                      castCurrentPage.floor() + 1) {
                                    return Transform.scale(
                                      scale: (1.0 + (castCurrentPage - index)),
                                      child: buildCastAndCrewListItems(
                                        tvShowSeasonCastAndCrewCastList[index]
                                            .profile_path,
                                        tvShowSeasonCastAndCrewCastList[index]
                                            .name,
                                        tvShowSeasonCastAndCrewCastList[index]
                                            .character,
                                        tvShowSeasonCastAndCrewCastList[index]
                                            .credit_id
                                            .toString(),
                                        tvShowSeasonCastAndCrewCastList[index]
                                            .id,
                                        "cast",
                                      ),
                                    );
                                  } else {
                                    return buildCastAndCrewListItems(
                                      tvShowSeasonCastAndCrewCastList[index]
                                          .profile_path,
                                      tvShowSeasonCastAndCrewCastList[index]
                                          .name,
                                      tvShowSeasonCastAndCrewCastList[index]
                                          .character,
                                      tvShowSeasonCastAndCrewCastList[index]
                                          .credit_id
                                          .toString(),
                                      tvShowSeasonCastAndCrewCastList[index].id,
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
                  delegate: tvShowSeasonCastAndCrewCrewList.length == 0 ||
                          tvShowSeasonCastAndCrewCrewList == null
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
                                    tvShowSeasonCastAndCrewCrewList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  if (index == crewCurrentPage.floor()) {
                                    return Transform.scale(
                                      scale: (1.0 - (crewCurrentPage - index)),
                                      child: buildCastAndCrewListItems(
                                        tvShowSeasonCastAndCrewCrewList[index]
                                            .profile_path,
                                        tvShowSeasonCastAndCrewCrewList[index]
                                            .name,
                                        tvShowSeasonCastAndCrewCrewList[index]
                                            .department,
                                        tvShowSeasonCastAndCrewCrewList[index]
                                            .credit_id
                                            .toString(),
                                        tvShowSeasonCastAndCrewCrewList[index]
                                            .id,
                                        "crew",
                                      ),
                                    );
                                  } else if (index ==
                                      crewCurrentPage.floor() + 1) {
                                    return Transform.scale(
                                      scale: (1.0 + (crewCurrentPage - index)),
                                      child: buildCastAndCrewListItems(
                                        tvShowSeasonCastAndCrewCrewList[index]
                                            .profile_path,
                                        tvShowSeasonCastAndCrewCrewList[index]
                                            .name,
                                        tvShowSeasonCastAndCrewCrewList[index]
                                            .department,
                                        tvShowSeasonCastAndCrewCrewList[index]
                                            .credit_id
                                            .toString(),
                                        tvShowSeasonCastAndCrewCrewList[index]
                                            .id,
                                        "crew",
                                      ),
                                    );
                                  } else {
                                    return buildCastAndCrewListItems(
                                      tvShowSeasonCastAndCrewCrewList[index]
                                          .profile_path,
                                      tvShowSeasonCastAndCrewCrewList[index]
                                          .name,
                                      tvShowSeasonCastAndCrewCrewList[index]
                                          .department,
                                      tvShowSeasonCastAndCrewCrewList[index]
                                          .credit_id
                                          .toString(),
                                      tvShowSeasonCastAndCrewCrewList[index].id,
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
                          itemCount: tvSeasonYoutubeVideosResults.length,
                          itemBuilder: (BuildContext context, int index) {
                            if (tvSeasonYoutubeVideosResults[index].key ==
                                    null ||
                                youtubeVideosDurationsList.length <= 0 ||
                                youtubeVideosDurationsList[index] == null) {
                              return Container();
                            } else {
                              String key =
                                  tvSeasonYoutubeVideosResults[index].key;

                              String duration =
                                  youtubeVideosDurationsList[index];

                              if (index == videosCurrentPage.floor()) {
                                return Transform.scale(
                                  scale: (1.0 - (videosCurrentPage - index)),
                                  child: buildVideosListItems(
                                    tvSeasonYoutubeVideosResults[index],
                                    key,
                                    duration,
                                  ),
                                );
                              } else if (index ==
                                  videosCurrentPage.floor() + 1) {
                                return Transform.scale(
                                  scale: (1.0 + (videosCurrentPage - index)),
                                  child: buildVideosListItems(
                                    tvSeasonYoutubeVideosResults[index],
                                    key,
                                    duration,
                                  ),
                                );
                              } else {
                                return buildVideosListItems(
                                  tvSeasonYoutubeVideosResults[index],
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
                  delegate: tvSeasonImagesPostersList.length == 0 ||
                          tvSeasonImagesPostersList == null
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
                                "Posters",
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
                                controller: postersPageController,
                                itemCount: tvSeasonImagesPostersList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  if (index == postersCurrentPage.floor()) {
                                    return Transform.scale(
                                      scale:
                                          (1.0 - (postersCurrentPage - index)),
                                      child: buildImageListItems(
                                        tvSeasonImagesPostersList[index],
                                        index,
                                        tvSeasonImagesPostersList,
                                      ),
                                    );
                                  } else if (index ==
                                      postersCurrentPage.floor() + 1) {
                                    return Transform.scale(
                                      scale:
                                          (1.0 + (postersCurrentPage - index)),
                                      child: buildImageListItems(
                                        tvSeasonImagesPostersList[index],
                                        index,
                                        tvSeasonImagesPostersList,
                                      ),
                                    );
                                  } else {
                                    return buildImageListItems(
                                      tvSeasonImagesPostersList[index],
                                      index,
                                      tvSeasonImagesPostersList,
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
                  delegate: tvShowSeasonDetailsEpisodesModelList.length == 0 ||
                          tvShowSeasonDetailsEpisodesModelList == null
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
                                "Episodes",
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
                                controller: episodesPageController,
                                itemCount:
                                    tvShowSeasonDetailsEpisodesModelList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  if (index == episodesCurrentPage.floor()) {
                                    return Transform.scale(
                                      scale:
                                          (1.0 - (episodesCurrentPage - index)),
                                      child: buildEpisodeListItems(
                                        tvShowSeasonDetailsEpisodesModelList[
                                                index]
                                            .still_path,
                                        tvShowSeasonDetailsEpisodesModelList[
                                                index]
                                            .name,
                                        tvShowSeasonDetailsEpisodesModelList[
                                                index]
                                            .episode_number
                                            .toString(),
                                        tvShowSeasonDetailsEpisodesModelList[
                                                index]
                                            .id
                                            .toString(),
                                        tvShowSeasonDetailsEpisodesModelList[
                                            index],
                                      ),
                                    );
                                  } else if (index ==
                                      episodesCurrentPage.floor() + 1) {
                                    return Transform.scale(
                                      scale:
                                          (1.0 + (episodesCurrentPage - index)),
                                      child: buildEpisodeListItems(
                                        tvShowSeasonDetailsEpisodesModelList[
                                                index]
                                            .still_path,
                                        tvShowSeasonDetailsEpisodesModelList[
                                                index]
                                            .name,
                                        tvShowSeasonDetailsEpisodesModelList[
                                                index]
                                            .episode_number
                                            .toString(),
                                        tvShowSeasonDetailsEpisodesModelList[
                                                index]
                                            .id
                                            .toString(),
                                        tvShowSeasonDetailsEpisodesModelList[
                                            index],
                                      ),
                                    );
                                  } else {
                                    return buildEpisodeListItems(
                                      tvShowSeasonDetailsEpisodesModelList[
                                              index]
                                          .still_path,
                                      tvShowSeasonDetailsEpisodesModelList[
                                              index]
                                          .name,
                                      tvShowSeasonDetailsEpisodesModelList[
                                              index]
                                          .episode_number
                                          .toString(),
                                      tvShowSeasonDetailsEpisodesModelList[
                                              index]
                                          .id
                                          .toString(),
                                      tvShowSeasonDetailsEpisodesModelList[
                                          index],
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

  Widget buildCastAndCrewListItems(
    String imageUrl,
    String name,
    String subTitle,
    String heroId,
    int sendId,
    String type,
  ) {
    String sub = "";

    if (type == "cast") {
      sub = "Character : ";
    } else if (type == "crew") {
      sub = "Department : ";
    } else {
      sub = "";
    }
    return GestureDetector(
      onTap: () {
        if (type == "cast" || type == "crew") {
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
      TvShowMovieVideosResultsModel tvSeasonYoutubeVideosResults,
      String key,
      String duration) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            NewPageTransition(
                widget: YoutubeVideoPlayerPage(
                    id: _tvShowId,
                    playingVideoDetails: tvSeasonYoutubeVideosResults)));
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

  Widget buildEpisodeListItems(
      String imageUrl,
      String name,
      String subTitle,
      String heroId,
      TvShowSeasonDetailsEpisodesModel _tvSeasonDetailsEpisodesModel) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            NewPageTransition(
                widget: TvShowEpisodeDetails(
                    tvShowId: _tvShowId,
                    tvSeasonDetailsEpisodesModel:
                        _tvSeasonDetailsEpisodesModel)));
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
                        Icons.tv,
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
                          "Episode - ",
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
