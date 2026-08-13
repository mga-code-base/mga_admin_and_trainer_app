import 'package:flutter/material.dart';

/// Keeps [child] alive when used inside a [TabBarView] (or any other widget
/// that lazily disposes offstage children), so scroll position and form
/// state in a tab aren't lost when the user switches away and back.
/// Extracted from signup_admin_tabs_screen.dart, where it was originally a
/// private helper — it's generic enough to be reused by any tabbed screen.
class KeepAliveWrapper extends StatefulWidget {
  final Widget child;
  const KeepAliveWrapper({super.key, required this.child});

  @override
  State<KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
