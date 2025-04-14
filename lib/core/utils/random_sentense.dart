import 'dart:math';

import 'package:alarm_from_hell/core/constants/key_sentenses.dart';

class RandomSentense {
  static String getRandomSentense() {
    final int randomIndex = Random().nextInt(KeySentenses.keySentenses.length);
    return KeySentenses.keySentenses[randomIndex];
  }
}
