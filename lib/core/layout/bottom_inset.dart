import 'package:flutter/material.dart';

/// Extra bottom space so tap targets stay above Android nav / home indicator /
/// gesture inset (uses [MediaQuery.viewPaddingOf], independent of scaffold padding).
double bottomInsetGap(BuildContext context, {double gap = 24}) =>
    gap + MediaQuery.viewPaddingOf(context).bottom;

/// Scroll padding so list/grid content clears the floating [BottomNavBar] pill.
double bottomNavScrollPadding(BuildContext context, {double gap = 16}) {
  const double navBarHeight = 60;
  const double navBarOuterPadding = 20;
  return gap + navBarOuterPadding + navBarHeight + MediaQuery.viewPaddingOf(context).bottom;
}
