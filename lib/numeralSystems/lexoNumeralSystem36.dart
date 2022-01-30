import 'lexoNumeralSystem.dart';

class LexoNumeralSystem36 implements LexoNumeralSystem {
  var DIGITS = '0123456789abcdefghijklmnopqrstuvwxyz'.split('');
  @override
  int getBase() {
    return 36;
  }

  @override
  String getPositiveChar() {
    return '+';
  }

  @override
  String getNegativeChar() {
    return '-';
  }

  @override
  String getRadixPointChar() {
    return ':';
  }

  @override
  int toDigit(String ch) {
    if (ch.codeUnitAt(0) >= '0'.codeUnitAt(0) && ch.codeUnitAt(0) <= '9'.codeUnitAt(0)) {
      return ch.codeUnitAt(0) - 48;
    }
    if (ch.codeUnitAt(0) >= 'a'.codeUnitAt(0) && ch.codeUnitAt(0) <= 'z'.codeUnitAt(0)) {
      return ch.codeUnitAt(0) - 97 + 10;
    }
    throw AssertionError('Not valid digit: ' + ch);
  }

  @override
  String toChar(int digit) {
    return DIGITS[digit];
  }
}
