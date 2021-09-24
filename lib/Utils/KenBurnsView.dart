import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class KenBurns extends StatefulWidget {
  final String url;
  final int duration;
  final double width;
  final double height;

  KenBurns({
    Key key,
    @required this.url,
    @required this.duration,
    @required this.width,
    @required this.height,
  }) : super(
          key: key,
        );

  @override
  _KenBurnsState createState() => _KenBurnsState(url, duration, width, height);
}

class _KenBurnsState extends State<KenBurns> with TickerProviderStateMixin {
  String url;
  int duration;
  double width;
  double height;

  _KenBurnsState(String url, int duration, double width, double height) {
    this.url = url;
    this.duration = duration;
    this.width = width;
    this.height = height;
  }

  AnimationController _controller;

  double size = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: duration));
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.value < 0.5) {
            size = _controller.value;
          }
          return Container(
            width: 400,
            height: 400,
            child: Stack(
              children: <Widget>[
                Positioned(
                  left: -300.0 * _controller.value,
                  top: -100.0 * _controller.value,
                  child: Container(
                    width: width,
                    height: height,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                          url,
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration:
                          BoxDecoration(color: Colors.black.withOpacity(0.5)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
