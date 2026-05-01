String toUrduNumerals(int value) {
  const List<String> urduDigits = <String>[
    '٠',
    '١',
    '٢',
    '٣',
    '٤',
    '٥',
    '٦',
    '٧',
    '٨',
    '٩',
  ];

  if (value == 0) return urduDigits[0];

  final bool isNegative = value < 0;
  final String ascii = value.abs().toString();
  final String mapped = ascii
      .split('')
      .map((String ch) => urduDigits[int.parse(ch)])
      .join();

  return isNegative ? '-$mapped' : mapped;
}
