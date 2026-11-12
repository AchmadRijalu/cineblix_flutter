import 'package:core/core.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  test('palette colors', () {
    expect(whiteColor, const Color(0xffFFFFFF));
    expect(blackColor, const Color(0xff14193F));
    expect(primaryColor, const Color(0xff2563EB));
    expect(redColor, const Color(0xffF52828));
    expect([
      greyColor,
      lightBackgroundColor,
      darkBackgroundColor,
      primaryDarkColor,
      greenColor,
    ], everyElement(isA<Color>()));
  });

  test('text styles use their palette color', () {
    expect(blackTextStyle.color, blackColor);
    expect(whiteTextStyle.color, whiteColor);
    expect(greyTextStyle.color, greyColor);
    expect(primaryDarkTextStyle.color, primaryDarkColor);
  });

  test('font weights', () {
    expect(
      [light, regular, medium, semiBold, bold, extraBold, black],
      [
        FontWeight.w300,
        FontWeight.w400,
        FontWeight.w500,
        FontWeight.w600,
        FontWeight.w700,
        FontWeight.w800,
        FontWeight.w900,
      ],
    );
  });
}
