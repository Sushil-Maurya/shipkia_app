import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_platform.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    this.title,
    this.bottomNavigationBar,
    this.drawer,
    this.scaffoldKey,
    super.key,
  });

  final Widget body;
  final String? title;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  Widget build(BuildContext context) {
    if (AppPlatform.isCupertino && drawer == null) {
      final page = CupertinoPageScaffold(
        navigationBar: title == null
            ? null
            : CupertinoNavigationBar(middle: Text(title!)),
        child: SafeArea(top: title == null, child: body),
      );

      if (bottomNavigationBar == null) return page;
      return Column(
        children: [
          Expanded(child: page),
          bottomNavigationBar!,
        ],
      );
    }

    return Scaffold(
      key: scaffoldKey,
      appBar: title == null ? null : AppBar(title: Text(title!)),
      drawer: drawer,
      bottomNavigationBar: bottomNavigationBar,
      body: body,
    );
  }
}
