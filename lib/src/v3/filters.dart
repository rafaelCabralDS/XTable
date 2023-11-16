import 'package:flutter/material.dart';
import 'package:x_table/x_table.dart';

enum FilterUnion {and, or}

sealed class Filter<E> extends ChangeNotifier{

  /// Add a flag to tell the controller if updates on the target value should run the query
  /// in the same moment or wait to call applyFilters manually later
  final bool sync;

  final FilterUnion union;


  Filter({
    required this.union,
    this.sync = false
  });

  bool isIn(E input);
  void clear();
}

class OptionsFilter<E> extends Filter<E> {

  final List<E> target = [];
  final List<E> benchmark;

  OptionsFilter({
    required super.union,
    required this.benchmark,
    super.sync = false,
    List<E> initialTarget = const []});

  @override
  bool isIn(E input) {
    if (target.isEmpty) return true;
    return target.contains(input);
  }

  void add(E e) {
    target.add(e);
    notifyListeners();
  }

  void remove(E e) {
    target.remove(e);
    notifyListeners();
  }

  @override
  void clear() {
    target.clear();
    notifyListeners();
  }

}


class TextQueryFilter extends Filter<String?> {

  TextQueryFilter({
    required super.union,
    super.sync = true});
  String? _target;

  set target(String? value) {
    _target = value;
    notifyListeners();
  }

  @override
  void clear() {
    _target=null;
    notifyListeners();
  }

  @override
  bool isIn(String? input) {
    print(input);
    print(_target);
    if (input == null || input.isEmpty) return false;
    if (_target == null || _target!.isEmpty) return true;
    return input.toLowerCase().startsWith(_target!.toLowerCase());
  }


}

/*

class OneToManyFilter<T,E> extends Filter<T, List<Filter<T,E>>> {

  @override
  final List<Filter<T,E>> target;

  OneToManyFilter({required super.mapper, required this.target});

  @override
  get benchmark => throw UnimplementedError();

  @override
  List<T> filter(List<T> input) {

    final List<List<T>> queries = [];
    for (var _filter in target) {
      queries.add(_filter.filter(input));
    }
    return queries.expand((element) => element).toSet().toList();
  }




}

 */


