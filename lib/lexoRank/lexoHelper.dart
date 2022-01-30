void arrayCopy(
    sourceArray, sourceIndex, destinationArray, destinationIndex, length) {
  var destination = destinationIndex;
  final finalLength = sourceIndex + length;
  for (var i = sourceIndex; i < finalLength; i++) {
    destinationArray[destination] = sourceArray[i];
    ++destination;
  }
}
