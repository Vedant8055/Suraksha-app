import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suraksha_women_safety_app/localization/localized_display_name.dart';

void main() {
  test('keeps Latin name in English', () {
    expect(
      LocalizedDisplayName.forLocale('Vedant', const Locale('en')),
      'Vedant',
    );
  });

  test('transliterates Vedant for Hindi and Marathi', () {
    expect(
      LocalizedDisplayName.forLocale('Vedant', const Locale('hi')),
      'वेदांत',
    );
    expect(
      LocalizedDisplayName.forLocale('Vedant', const Locale('mr')),
      'वेदांत',
    );
  });

  test('transliterates multi-word names', () {
    expect(
      LocalizedDisplayName.forLocale('Vedant Kulkarni', const Locale('hi')),
      'वेदांत कुलकर्णी',
    );
  });

  test('leaves Devanagari names unchanged', () {
    expect(
      LocalizedDisplayName.forLocale('वेदांत', const Locale('hi')),
      'वेदांत',
    );
  });
}
