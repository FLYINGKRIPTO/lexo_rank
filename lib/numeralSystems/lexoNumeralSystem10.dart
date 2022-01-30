
import 'lexoNumeralSystem.dart';

class LexoNumeralSystem10 implements LexoNumeralSystem {
  @override
  int getBase() {
    return 10;
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
    return '.';
  }

  @override
  int toDigit(String ch) {
    if (ch.codeUnitAt(0) >= '0'.codeUnitAt(0) && ch.codeUnitAt(0) <= '9'.codeUnitAt(0)) {
      return ch.codeUnitAt(0) - 48;
    }
    throw AssertionError('Not valid digit: ' + ch);
  }

  @override
  String toChar(int digit) {
    return String.fromCharCode(digit + 48);
  }
}
