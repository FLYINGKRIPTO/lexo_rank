import '../numeralSystems/lexoNumeralSystem.dart';
import '../utils/stringBuilder.dart';
import 'lexoInteger.dart';

class LexoDecimal {
  static LexoDecimal half(LexoNumeralSystem sys) {
    final mid = (sys.getBase() / 2).round() | 0;
    return LexoDecimal.make(LexoInteger.make(sys, 1, [mid]), 1);
  }

  static LexoDecimal parse(String str, LexoNumeralSystem system) {
    final partialIndex = str.indexOf(system.getRadixPointChar());
    if (!identical(str.lastIndexOf(system.getRadixPointChar()), partialIndex)) {
      throw AssertionError('More than one ' + system.getRadixPointChar());
    }
    if (partialIndex < 0) {
      return LexoDecimal.make(LexoInteger.parse(str, system), 0);
    }
    final intStr =
        str.substring(0, partialIndex) + str.substring(partialIndex + 1);
    return LexoDecimal.make(
        LexoInteger.parse(intStr, system), str.length - 1 - partialIndex);
  }

  static LexoDecimal from(LexoInteger integer) {
    return LexoDecimal.make(integer, 0);
  }

  static LexoDecimal make(LexoInteger integer, int sig) {
    if (integer.isZero()) {
      return LexoDecimal(integer, 0);
    }
    var zeroCount = 0;
    for (var i = 0; i < sig && identical(integer.getMag(i), 0); ++i) {
      ++zeroCount;
    }
    final newInteger = integer.shiftRight(zeroCount);
    final newSig = sig - zeroCount;
    return LexoDecimal(newInteger, newSig);
  }

  late LexoInteger mag;
  late int sig;
  LexoDecimal(LexoInteger mag, int sig) {
    this.mag = mag;
    this.sig = sig;
  }
  LexoNumeralSystem getSystem() {
    return mag.getSystem();
  }

  LexoDecimal add(LexoDecimal other) {
    var tmag = mag;
    var tsig = sig;
    var omag = other.mag;
    num osig;
    for (osig = other.sig; tsig < osig; ++tsig) {
      tmag = tmag.shiftLeft();
    }
    while (tsig > osig) {
      omag = omag.shiftLeft();
      ++osig;
    }
    return LexoDecimal.make(tmag.add(omag), tsig);
  }

  LexoDecimal subtract(LexoDecimal other) {
    var thisMag = mag;
    var thisSig = sig;
    var otherMag = other.mag;
    num otherSig;
    for (otherSig = other.sig; thisSig < otherSig; ++thisSig) {
      thisMag = thisMag.shiftLeft();
    }
    while (thisSig > otherSig) {
      otherMag = otherMag.shiftLeft();
      ++otherSig;
    }
    return LexoDecimal.make(thisMag.subtract(otherMag), thisSig);
  }

  LexoDecimal multiply(LexoDecimal other) {
    return LexoDecimal.make(mag.multiply(other.mag), sig + other.sig);
  }

  LexoInteger floor() {
    return mag.shiftRight(sig);
  }

  LexoInteger ceil() {
    if (isExact()) {
      return mag;
    }
    final f = floor();
    return f.add(LexoInteger.one(f.getSystem()));
  }

  bool isExact() {
    if (identical(sig, 0)) {
      return true;
    }
    for (var i = 0; i < sig; ++i) {
      if (!identical(mag.getMag(i), 0)) {
        return false;
      }
    }
    return true;
  }

  int getScale() {
    return sig;
  }

  LexoDecimal setScale(int nsig, [bool ceiling = false]) {
    if (nsig >= sig) {
      return this;
    }
    if (nsig < 0) {
      nsig = 0;
    }
    final diff = sig - nsig;
    var nmag = mag.shiftRight(diff);
    if (ceiling) {
      nmag = nmag.add(LexoInteger.one(nmag.getSystem()));
    }
    return LexoDecimal.make(nmag, nsig);
  }

  int compareTo(LexoDecimal other) {
    if (identical(this, other)) {
      return 0;
    }
    // if (!other) {
    //   return 1;
    // }
    var tMag = mag;
    var oMag = other.mag;
    if (sig > other.sig) {
      oMag = oMag.shiftLeft(sig - other.sig);
    } else if (sig < other.sig) {
      tMag = tMag.shiftLeft(other.sig - sig);
    }
    return tMag.compareTo(oMag);
  }

  String format() {
    final intStr = mag.format();
    if (identical(sig, 0)) {
      return intStr;
    }
    final sb = StringBuilder(intStr);
    final head = sb.str[0];
    final specialHead = identical(head, mag.getSystem().getPositiveChar()) ||
        identical(head, mag.getSystem().getNegativeChar());
    if (specialHead) {
      sb.remove(0, 1);
    }
    while (sb.length < sig + 1) {
      sb.insert(0, mag.getSystem().toChar(0));
    }
    sb.insert(sb.length - sig, mag.getSystem().getRadixPointChar());
    if (identical(sb.length - sig, 0)) {
      sb.insert(0, mag.getSystem().toChar(0));
    }
    if (specialHead) {
      sb.insert(0, head);
    }
    return sb.toString();
  }

  bool equals(LexoDecimal other) {
    if (identical(this, other)) {
      return true;
    }
    // if (!other) {
    //   return false;
    // }
    return mag.equals(other.mag) && identical(sig, other.sig);
  }

  @override
  String toString() {
    return format();
  }
}
