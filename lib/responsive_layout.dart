import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {

  final Widget webScreenLayout;
  final Widget mobileScreenLayout;

  const ResponsiveLayout(   //constructor
      {
        Key? key,
        required this.mobileScreenLayout,
        required this.webScreenLayout,
      }
      ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context,constraints)
            {
              if(constraints.maxWidth>600)
                {
                  return webScreenLayout;
                }
              return mobileScreenLayout;
            },
    );
  }
}
