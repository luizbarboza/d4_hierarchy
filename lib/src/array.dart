List<T> shuffle<T>(List<T> array, num Function() random) {
  int m = array.length;
  T t;
  int i;

  while (m != 0) {
    i = (random() * m--).toInt();
    t = array[m];
    array[m] = array[i];
    array[i] = t;
  }

  return array;
}
