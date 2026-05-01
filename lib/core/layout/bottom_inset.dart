import 'package:flutter/material.dart';

/// Extra bottom space so tap targets stay above Android nav / home indicator /
/// gesture inset (uses [MediaQuery.viewPaddingOf], independent of scaffold padding).
double bottomInsetGap(BuildContext context, {double gap = 24}) =>
    gap + MediaQuery.viewPaddingOf(context).bottom;
