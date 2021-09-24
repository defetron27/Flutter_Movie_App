import 'package:flutter/widgets.dart';

class NewPageTransition extends PageRouteBuilder {
  final Widget widget;

  NewPageTransition({this.widget})
      : super(
            pageBuilder: (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) {
              return widget;
            },
            transitionDuration: Duration(milliseconds: 400),
            transitionsBuilder: ((BuildContext context,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
                Widget child) {
              Animation<Offset> custom =
                  Tween<Offset>(begin: Offset(0.0, 1.0), end: Offset(0.0, 0.0))
                      .animate(animation);

              return SlideTransition(
                position: custom,
                child: child,
              );
            }));
}
