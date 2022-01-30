class StringBuilder {
  String str = '';

  StringBuilder(String str) {
    this.str = str;
  }
  int get length {
    return str.length;
  }

  set length(int value) {
    str = str.substring(0, value);
  }

  StringBuilder append(String str) {
    this.str = this.str + str;
    return this;
  }

  StringBuilder remove(int startIndex, int length) {
    str =
        str.substring(0, startIndex) + str.substring(startIndex + length);
    return this;
  }

  StringBuilder insert(int index, String value) {
    str = str.substring(0, index) + value + str.substring(index);
    return this;
  }

  @override
  String toString() {
    return str;
  }
}
//export default StringBuilder;
