library lexo_rank;

import '../utils/stringBuilder.dart';

import '../numeralSystems/lexoNumeralSystem36.dart';
import 'lexoRank/lexoDecimal.dart';
import 'lexoRank/lexoRankBucket.dart';

class LexoRank {
  static final NUMERAL_SYSTEM = LexoNumeralSystem36();
  static final ZERO_DECIMAL = LexoDecimal.parse('0', NUMERAL_SYSTEM);
  static final ONE_DECIMAL = LexoDecimal.parse('1', NUMERAL_SYSTEM);
  static final EIGHT_DECIMAL = LexoDecimal.parse('8', NUMERAL_SYSTEM);
  static final MIN_DECIMAL = ZERO_DECIMAL;
  static final MAX_DECIMAL =
  LexoDecimal.parse('1000000', NUMERAL_SYSTEM).subtract(ONE_DECIMAL);
  static final MID_DECIMAL = LexoRank.Between(MIN_DECIMAL, MAX_DECIMAL);
  static final INITIAL_MIN_DECIMAL =
  LexoDecimal.parse('100000', LexoRank.NUMERAL_SYSTEM);
  static final INITIAL_MAX_DECIMAL = LexoDecimal.parse(
      LexoRank.NUMERAL_SYSTEM.toChar(LexoRank.NUMERAL_SYSTEM.getBase() - 2) +
          '00000',
      LexoRank.NUMERAL_SYSTEM);

  static LexoRank min() {
    return LexoRank.from(LexoRankBucket.BUCKET_0, LexoRank.MIN_DECIMAL);
  }

  static LexoRank middle() {
    var minLexoRank = LexoRank.min();
    return minLexoRank.between(LexoRank.max(minLexoRank.bucket));
  }

  static LexoRank max(LexoRankBucket bucket) {
    return LexoRank.from(bucket, LexoRank.MAX_DECIMAL);
  }

  static LexoRank initial(LexoRankBucket bucket) {
    return identical(bucket, LexoRankBucket.BUCKET_0)
        ? LexoRank.from(bucket, LexoRank.INITIAL_MIN_DECIMAL)
        : LexoRank.from(bucket, LexoRank.INITIAL_MAX_DECIMAL);
  }

  static LexoDecimal Between(LexoDecimal oLeft, LexoDecimal oRight) {
    if (!identical(oLeft.getSystem().getBase(), oRight.getSystem().getBase())) {
      throw AssertionError('Expected same system');
    }
    var left = oLeft;
    var right = oRight;
    LexoDecimal nLeft;
    if (oLeft.getScale() < oRight.getScale()) {
      nLeft = oRight.setScale(oLeft.getScale(), false);
      if (oLeft.compareTo(nLeft) >= 0) {
        return LexoRank.mid(oLeft, oRight);
      }
      right = nLeft;
    }
    if (oLeft.getScale() > right.getScale()) {
      nLeft = oLeft.setScale(right.getScale(), true);
      if (nLeft.compareTo(right) >= 0) {
        return LexoRank.mid(oLeft, oRight);
      }
      left = nLeft;
    }
    LexoDecimal nRight;
    for (var scale = left.getScale(); scale > 0; right = nRight) {
      final nScale1 = scale - 1;
      final nLeft1 = left.setScale(nScale1, true);
      nRight = right.setScale(nScale1, false);
      final cmp = nLeft1.compareTo(nRight);
      if (identical(cmp, 0)) {
        return LexoRank.checkMid(oLeft, oRight, nLeft1);
      }
      if (nLeft1.compareTo(nRight) > 0) {
        break;
      }
      scale = nScale1;
      left = nLeft1;
    }
    var mid = LexoRank.middleInternal(oLeft, oRight, left, right);
    int nScale;
    for (var mScale = mid.getScale(); mScale > 0; mScale = nScale) {
      nScale = mScale - 1;
      final nMid = mid.setScale(nScale);
      if (oLeft.compareTo(nMid) >= 0 || nMid.compareTo(oRight) >= 0) {
        break;
      }
      mid = nMid;
    }
    return mid;
  }

  static LexoRank parse(String str) {
    final parts = str.split('|');
    final bucket = LexoRankBucket.from(parts[0]);
    final decimal = LexoDecimal.parse(parts[1], LexoRank.NUMERAL_SYSTEM);
    return LexoRank(bucket, decimal);
  }

  static LexoRank from(LexoRankBucket bucket, LexoDecimal decimal) {
    if (!identical(
        decimal.getSystem().getBase(), LexoRank.NUMERAL_SYSTEM.getBase())) {
      throw AssertionError('Expected different system');
    }
    return LexoRank(bucket, decimal);
  }

  static LexoDecimal middleInternal(LexoDecimal lbound, LexoDecimal rbound,
      LexoDecimal left, LexoDecimal right) {
    final mid = LexoRank.mid(left, right);
    return LexoRank.checkMid(lbound, rbound, mid);
  }

  static LexoDecimal checkMid(
      LexoDecimal lbound, LexoDecimal rbound, LexoDecimal mid) {
    if (lbound.compareTo(mid) >= 0) {
      return LexoRank.mid(lbound, rbound);
    }
    return mid.compareTo(rbound) >= 0 ? LexoRank.mid(lbound, rbound) : mid;
  }

  static LexoDecimal mid(LexoDecimal left, LexoDecimal right) {
    final sum = left.add(right);
    final mid = sum.multiply(LexoDecimal.half(left.getSystem()));
    final scale =
    left.getScale() > right.getScale() ? left.getScale() : right.getScale();
    if (mid.getScale() > scale) {
      final roundDown = mid.setScale(scale, false);
      if (roundDown.compareTo(left) > 0) {
        return roundDown;
      }
      final roundUp = mid.setScale(scale, true);
      if (roundUp.compareTo(right) < 0) {
        return roundUp;
      }
    }
    return mid;
  }

  static String formatDecimal(LexoDecimal decimal) {
    final formatVal = decimal.format();
    final val = StringBuilder(formatVal);
    var partialIndex =
    formatVal.indexOf(LexoRank.NUMERAL_SYSTEM.getRadixPointChar());
    final zero = LexoRank.NUMERAL_SYSTEM.toChar(0);
    if (partialIndex < 0) {
      partialIndex = formatVal.length;
      val.append(LexoRank.NUMERAL_SYSTEM.getRadixPointChar());
    }
    while (partialIndex < 6) {
      val.insert(0, zero);
      ++partialIndex;
    }
    while (identical(val.str[val.str.length - 1], zero)) {
      val.length = val.length - 1;
    }
    return val.toString();
  }

  late String value;
  late LexoRankBucket bucket;
  late LexoDecimal decimal;
  LexoRank(LexoRankBucket bucket, LexoDecimal decimal) {
    value = bucket.format() + '|' + LexoRank.formatDecimal(decimal);
    this.bucket = bucket;
    this.decimal = decimal;
  }

  LexoRank genPrev() {
    if (isMax()) {
      return LexoRank(bucket, LexoRank.INITIAL_MAX_DECIMAL);
    }
    final floorInteger = decimal.floor();
    final floorDecimal = LexoDecimal.from(floorInteger);
    var nextDecimal = floorDecimal.subtract(LexoRank.EIGHT_DECIMAL);
    if (nextDecimal.compareTo(LexoRank.MIN_DECIMAL) <= 0) {
      nextDecimal = LexoRank.Between(LexoRank.MIN_DECIMAL, decimal);
    }
    return LexoRank(bucket, nextDecimal);
  }

  LexoRank genNext() {
    if (isMin()) {
      return LexoRank(bucket, LexoRank.INITIAL_MIN_DECIMAL);
    }
    final ceilInteger = decimal.ceil();
    final ceilDecimal = LexoDecimal.from(ceilInteger);
    var nextDecimal = ceilDecimal.add(LexoRank.EIGHT_DECIMAL);
    if (nextDecimal.compareTo(LexoRank.MAX_DECIMAL) >= 0) {
      nextDecimal = LexoRank.Between(decimal, LexoRank.MAX_DECIMAL);
    }
    return LexoRank(bucket, nextDecimal);
  }

  LexoRank between(LexoRank other) {
    if (!bucket.equals(other.bucket)) {
      throw AssertionError('Between works only within the same bucket');
    }
    final cmp = decimal.compareTo(other.decimal);
    if (cmp > 0) {
      return LexoRank(bucket, LexoRank.Between(other.decimal, decimal));
    }
    if (identical(cmp, 0)) {
      throw AssertionError('Try to rank between issues with same rank this=' +
          toString() +
          ' other=' +
          other.toString() +
          ' this.decimal=' +
          decimal.toString() +
          ' other.decimal=' +
          other.decimal.toString());
    }
    return LexoRank(bucket, LexoRank.Between(decimal, other.decimal));
  }

  LexoRankBucket getBucket() {
    return bucket;
  }

  LexoDecimal getDecimal() {
    return decimal;
  }

  LexoRank inNextBucket() {
    return LexoRank.from(bucket.next(), decimal);
  }

  LexoRank inPrevBucket() {
    return LexoRank.from(bucket.prev(), decimal);
  }

  bool isMin() {
    return decimal.equals(LexoRank.MIN_DECIMAL);
  }

  bool isMax() {
    return decimal.equals(LexoRank.MAX_DECIMAL);
  }

  String format() {
    return value;
  }

  bool equals(LexoRank other) {
    if (identical(this, other)) {
      return true;
    }
    // if (!other) {
    //   return false;
    // }
    return identical(value, other.value);
  }

  @override
  String toString() {
    return value;
  }

  num compareTo(LexoRank other) {
    if (identical(this, other)) {
      return 0;
    }
    // if (!other) {
    //   return 1;
    // }
    return value.compareTo(other.value);
  }
}

