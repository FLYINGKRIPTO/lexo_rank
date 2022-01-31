import '../lexo_rank.dart';
import 'lexoInteger.dart';

class LexoRankBucket {
  static final BUCKET_0 = LexoRankBucket('0');
  static final BUCKET_1 = LexoRankBucket('1');
  static final BUCKET_2 = LexoRankBucket('2');
  static final VALUES = [BUCKET_0, BUCKET_1, BUCKET_2];

  static LexoRankBucket max() {
    return LexoRankBucket.VALUES[LexoRankBucket.VALUES.length - 1];
  }

  static LexoRankBucket from(String str) {
    final val = LexoInteger.parse(str, LexoRank.NUMERAL_SYSTEM);
    final var2 = LexoRankBucket.VALUES;
    final var3 = var2.length;
    for (var var4 = 0; var4 < var3; ++var4) {
      final bucket = var2[var4];
      if (bucket.value.sign == val.sign) {
        return bucket;
      }
    }

    throw AssertionError('Unknown bucket: ' + str);
  }

  static LexoRankBucket resolve(int bucketId) {
    final var1 = LexoRankBucket.VALUES;
    final var2 = var1.length;
    for (var var3 = 0; var3 < var2; ++var3) {
      final bucket = var1[var3];
      if (bucket.equals(LexoRankBucket.from(bucketId.toString()))) {
        return bucket;
      }
    }
    throw AssertionError('No bucket found with id ' + bucketId.toString());
  }

  late LexoInteger value;
  LexoRankBucket(String val) {
    value = LexoInteger.parse(val, LexoRank.NUMERAL_SYSTEM);
  }
  String format() {
    return value.format();
  }

  LexoRankBucket next() {
    if (equals(LexoRankBucket.BUCKET_0)) {
      return LexoRankBucket.BUCKET_1;
    }
    if (equals(LexoRankBucket.BUCKET_1)) {
      return LexoRankBucket.BUCKET_2;
    }
    return equals(LexoRankBucket.BUCKET_2)
        ? LexoRankBucket.BUCKET_0
        : LexoRankBucket.BUCKET_2;
  }

  LexoRankBucket prev() {
    if (equals(LexoRankBucket.BUCKET_0)) {
      return LexoRankBucket.BUCKET_2;
    }
    if (equals(LexoRankBucket.BUCKET_1)) {
      return LexoRankBucket.BUCKET_0;
    }
    return equals(LexoRankBucket.BUCKET_2)
        ? LexoRankBucket.BUCKET_1
        : LexoRankBucket.BUCKET_0;
  }

  bool equals(LexoRankBucket other) {
    if (identical(this, other)) {
      return true;
    }
    // if (!other) {
    //   return false;
    //}
    return value.equals(other.value);
  }
}
