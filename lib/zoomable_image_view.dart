import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ZoomableImageView extends StatefulWidget {
  final String heroTag;
  final int currentIndex;
  final List<String> imagesList;

  ZoomableImageView(
      {Key key,
      @required this.heroTag,
      @required this.currentIndex,
      @required this.imagesList})
      : super(key: key);

  _ZoomableImageViewState createState() =>
      _ZoomableImageViewState(heroTag, currentIndex, imagesList);
}

class _ZoomableImageViewState extends State<ZoomableImageView> {
  String _heroTag;
  int currentIndex;
  List<String> imagesList;

  _ZoomableImageViewState(this._heroTag, this.currentIndex, this.imagesList);

  PageController _pageController;

  @override
  void initState() {
    _pageController = PageController(initialPage: currentIndex);

    SystemChrome.setEnabledSystemUIOverlays([]);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: false,
      backgroundColor: Colors.black,
      body: Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: Center(
          child: PhotoViewGallery.builder(
            scrollPhysics: BouncingScrollPhysics(),
            pageController: _pageController,
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(imagesList[index]),
                heroTag: _heroTag,
                minScale: 0.4,
                maxScale: 5.0,
              );
            },
            itemCount: imagesList.length,
          ),
        ),
      ),
    );
  }
}
