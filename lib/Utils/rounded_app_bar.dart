import 'package:flutter/material.dart';

class RoundedAppBar extends StatelessWidget implements PreferredSizeWidget {

  double topRadius = 0.0;
  double bottomRadius = 100.0;

  RoundedAppBar(this.topRadius, this.bottomRadius)
  {
    this.topRadius = topRadius;
    this.bottomRadius = bottomRadius;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: preferredSize,
      child: LayoutBuilder(builder: (context, constraint) {
        return ClipRRect(
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(100.0),bottomRight: Radius.circular(100.0)),
          child: Container(
            color: Colors.yellow,
          ),
        );
      }),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60.0);
}
