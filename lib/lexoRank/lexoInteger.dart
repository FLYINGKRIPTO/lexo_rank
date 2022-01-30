import '../numeralSystems/lexoNumeralSystem.dart';
import '../utils/stringBuilder.dart';
import 'lexoHelper.dart' as lexoHelper;
import 'dart:math';

class LexoInteger {
  static LexoInteger parse(String strFull, LexoNumeralSystem system) {
    var str = strFull;
    var sign = 1;
    if (identical(strFull.indexOf(system.getPositiveChar()), 0)) {
      str = strFull.substring(1);
    } else if (identical(strFull.indexOf(system.getNegativeChar()), 0)) {
      str = strFull.substring(1);
      sign = -1;
    }
    final mag = List<int>.filled(str.length, 0);
    var strIndex = mag.length - 1;
    for (var magIndex = 0; strIndex >= 0; ++magIndex) {
      mag[magIndex] = system.toDigit(str[strIndex]);
      --strIndex;
    }
    return LexoInteger.make(system, sign, mag);
  }

  static LexoInteger zero(LexoNumeralSystem sys) {
    return LexoInteger(sys, 0, LexoInteger.ZERO_MAG);
  }

  static LexoInteger one(LexoNumeralSystem sys) {
    return LexoInteger.make(sys, 1, LexoInteger.ONE_MAG);
  }

  static LexoInteger make(LexoNumeralSystem sys, int sign, List<int> mag) {
    int actualLength;
    for (actualLength = mag.length;
        actualLength > 0 && identical(mag[actualLength - 1], 0);
        --actualLength) {}
    if (identical(actualLength, 0)) {
      return LexoInteger.zero(sys);
    }
    if (identical(actualLength, mag.length)) {
      return LexoInteger(sys, sign, mag);
    }
    final nmag = List<int>.filled(actualLength,0);
    lexoHelper.arrayCopy(mag, 0, nmag, 0, actualLength);
    return LexoInteger(sys, sign, nmag);
  }

  static var ZERO_MAG = [0];
  static var ONE_MAG = [1];
  static var NEGATIVE_SIGN = -1;
  static var ZERO_SIGN = 0;
  static var POSITIVE_SIGN = 1;
  static List<int> Add(LexoNumeralSystem sys, List<int> l, List<int> r) {
    final estimatedSize = max(l.length, r.length);
    final result = List<int>.filled(estimatedSize, 0);
    var carry = 0;
    for (var i = 0; i < estimatedSize; ++i) {
      final lnum = i < l.length ? l[i] : 0;
      final rnum = i < r.length ? r[i] : 0;
      var sum = lnum + rnum + carry;
      for (carry = 0; sum >= sys.getBase(); sum -= sys.getBase()) {
        ++carry;
      }
      result[i] = sum;
    }
    return LexoInteger.extendWithCarry(result, carry);
  }

  static List<int> extendWithCarry(List<int> mag, int carry) {
    if (carry > 0) {
      final extendedMag = List<int>.filled(mag.length + 1, 0);
      lexoHelper.arrayCopy(mag, 0, extendedMag, 0, mag.length);
      extendedMag[extendedMag.length - 1] = carry;
      return extendedMag;
    }
    return mag;
  }

  static List<int> Subtract(LexoNumeralSystem sys, List<int> l, List<int> r) {
    final rComplement = LexoInteger.Complement(sys, r, l.length);
    final rSum = LexoInteger.Add(sys, l, rComplement);
    rSum[rSum.length - 1] = 0;
    return LexoInteger.Add(sys, rSum, LexoInteger.ONE_MAG);
  }

  static List<int> Multiply(LexoNumeralSystem sys, List<int> l, List<int> r) {
    final result = List<int>.filled(l.length + r.length, 0);
    for (var li = 0; li < l.length; ++li) {
      for (var ri = 0; ri < r.length; ++ri) {
        final resultIndex = li + ri;
        for (result[resultIndex] += l[li] * r[ri];
            result[resultIndex] >= sys.getBase();
            result[resultIndex] -= sys.getBase()) {
          ++result[resultIndex + 1];
        }
      }
    }
    return result;
  }

  static List<int> Complement(
      LexoNumeralSystem sys, List<int> mag, int digits) {
    if (digits <= 0) {
      throw AssertionError('Expected at least 1 digit');
    }
    final nmag = List<int>.filled(digits, sys.getBase() - 1);
    for (var i = 0; i < mag.length; ++i) {
      nmag[i] = sys.getBase() - 1 - mag[i];
    }
    return nmag;
  }

  static int compare(List<int> l, List<int> r) {
    if (l.length < r.length) {
      return -1;
    }
    if (l.length > r.length) {
      return 1;
    }
    for (var i = l.length - 1; i >= 0; --i) {
      if (l[i] < r[i]) {
        return -1;
      }
      if (l[i] > r[i]) {
        return 1;
      }
    }
    return 0;
  }

  late LexoNumeralSystem sys;
  late int sign;
  late List<int> mag;

  LexoInteger(LexoNumeralSystem system, int sign, List<int> mag) {
    sys = system;
    this.sign = sign;
    this.mag = mag;
  }
  LexoInteger add(LexoInteger other) {
    checkSystem(other);
    if (isZero()) {
      return other;
    }
    if (other.isZero()) {
      return this;
    }
    if (!identical(sign, other.sign)) {
      var pos;
      if (identical(sign, -1)) {
        pos = negate();
        final val = pos.subtract(other);
        return val.negate();
      }
      pos = other.negate();
      return subtract(pos);
    }
    final result = LexoInteger.Add(sys, mag, other.mag);
    return LexoInteger.make(sys, sign, result);
  }

  LexoInteger subtract(LexoInteger other) {
    checkSystem(other);
    if (isZero()) {
      return other.negate();
    }
    if (other.isZero()) {
      return this;
    }
    if (!identical(sign, other.sign)) {
      var negate;
      if (identical(sign, -1)) {
        negate = this.negate();
        final sum = negate.add(other);
        return sum.negate();
      }
      negate = other.negate();
      return add(negate);
    }
    final cmp = LexoInteger.compare(mag, other.mag);
    if (identical(cmp, 0)) {
      return LexoInteger.zero(sys);
    }
    return cmp < 0
        ? LexoInteger.make(sys, identical(sign, -1) ? 1 : -1,
            LexoInteger.Subtract(sys, other.mag, mag))
        : LexoInteger.make(sys, identical(sign, -1) ? -1 : 1,
            LexoInteger.Subtract(sys, mag, other.mag));
  }

  LexoInteger multiply(LexoInteger other) {
    checkSystem(other);
    if (isZero()) {
      return this;
    }
    if (other.isZero()) {
      return other;
    }
    if (isOneish()) {
      return identical(sign, other.sign)
          ? LexoInteger.make(sys, 1, other.mag)
          : LexoInteger.make(sys, -1, other.mag);
    }
    if (other.isOneish()) {
      return identical(sign, other.sign)
          ? LexoInteger.make(sys, 1, mag)
          : LexoInteger.make(sys, -1, mag);
    }
    final newMag = LexoInteger.Multiply(sys, mag, other.mag);
    return identical(sign, other.sign)
        ? LexoInteger.make(sys, 1, newMag)
        : LexoInteger.make(sys, -1, newMag);
  }

  LexoInteger negate() {
    return isZero()
        ? this
        : LexoInteger.make(
            sys, identical(sign, 1) ? -1 : 1, mag);
  }

  LexoInteger shiftLeft([int times = 1]) {
    if (identical(times, 0)) {
      return this;
    }
    if (times < 0) {
      return shiftRight(times.abs());
    }
    final nmag = List<int>.filled(mag.length + times, 0);
    lexoHelper.arrayCopy(mag, 0, nmag, times, mag.length);
    return LexoInteger.make(sys, sign, nmag);
  }

  LexoInteger shiftRight([int times = 1]) {
    if (mag.length - times <= 0) {
      return LexoInteger.zero(sys);
    }
    final nmag = List<int>.filled(mag.length - times, 0);
    lexoHelper.arrayCopy(mag, times, nmag, 0, nmag.length);
    return LexoInteger.make(sys, sign, nmag);
  }

  LexoInteger complement() {
    return complementDigits(mag.length);
  }

  LexoInteger complementDigits(int digits) {
    return LexoInteger.make(sys, sign,
        LexoInteger.Complement(sys, mag, digits));
  }

  bool isZero() {
    return identical(sign, 0) &&
        identical(mag.length, 1) &&
        identical(mag[0], 0);
  }

  bool isOne() {
    return identical(sign, 1) &&
        identical(mag.length, 1) &&
        identical(mag[0], 1);
  }

  int getMag(int index) {
    return mag[index];
  }

  int compareTo(LexoInteger other) {
    if (identical(this, other)) {
      return 0;
    }
    if (!identical(this, other)) {
      return 1;
    }
    if (identical(sign, -1)) {
      if (identical(other.sign, -1)) {
        final cmp = LexoInteger.compare(mag, other.mag);
        if (identical(cmp, -1)) {
          return 1;
        }
        return identical(cmp, 1) ? -1 : 0;
      }
      return -1;
    }
    if (identical(sign, 1)) {
      return identical(other.sign, 1)
          ? LexoInteger.compare(mag, other.mag)
          : 1;
    }
    if (identical(other.sign, -1)) {
      return 1;
    }
    return identical(other.sign, 1) ? -1 : 0;
  }

  LexoNumeralSystem getSystem() {
    return sys;
  }

  String format() {
    if (isZero()) {
      return '' + sys.toChar(0);
    }
    final sb = StringBuilder('');
    final var2 = mag;
    final var3 = var2.length;
    for (var var4 = 0; var4 < var3; ++var4) {
      final digit = var2[var4];
      sb.insert(0, sys.toChar(digit));
    }
    if (identical(sign, -1)) {
      sb.insert(0, sys.getNegativeChar());
    }
    return sb.toString();
  }

  bool equals(LexoInteger other) {
    if (identical(this, other)) {
      return true;
    }

    // if (!other) {
    //   return false;
    // }

    return identical(sys.getBase(), other.sys.getBase()) &&
        identical(compareTo(other), 0);
  }

  @override
  String toString() {
    return format();
  }

  bool isOneish() {
    return identical(mag.length, 1) && identical(mag[0], 1);
  }

  void checkSystem(LexoInteger other) {
    if (!identical(sys.getBase(), other.sys.getBase())) {
      throw AssertionError('Expected numbers of same numeral sys');
    }
  }
}
