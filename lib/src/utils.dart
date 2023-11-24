
extension StringExtension on String {
  String capitalize() {
    if (this.isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

extension ListExtension<E, Id> on List<E> {
  bool containsBy(E e, Id Function(E e) by) {
    var mapListBy = map(by);
    return mapListBy.contains(by(e));
  }
}

int textSorter(String a, String b) => a.compareTo(b);
int numSorter(num a, num b) => a.compareTo(b);