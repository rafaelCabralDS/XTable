import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:x_table/x_table.dart';

enum LogicOperator {and, or}


sealed class Filter<E> extends ChangeNotifier with EquatableMixin {

  static const DEFAULT_KEY = "filterKey";
  /// Add a flag to tell the controller if updates on the target value should run the query
  /// in the same moment or wait to call applyFilters manually later
  final bool sync;
  final LogicOperator union;
  final String key;

  bool get isActive;

  Filter({
    this.key = DEFAULT_KEY,
    required this.union,
    this.sync = false,
  });

  Filter<E> copy();

  bool isIn(E input);
  void clear();
}

class OptionsFilter<E> extends Filter<E> {

  final List<E> selectedOptions;
  final List<E> options;

  OptionsFilter({
    super.key,
    required this.options,
    super.union = LogicOperator.and,
    super.sync = false,
    List<E> initialTarget = const []})
      : selectedOptions = List.from(initialTarget);

  @override
  bool isIn(E input) {
    if (selectedOptions.isEmpty) return true;
    return selectedOptions.contains(input);
  }

  @override
  bool get isActive => selectedOptions.isNotEmpty;

  void add(E e) {
    selectedOptions.add(e);
    notifyListeners();
  }

  void remove(E e) {
    selectedOptions.remove(e);
    notifyListeners();
  }

  @override
  void clear() {
    selectedOptions.clear();
    notifyListeners();
  }

  @override
  OptionsFilter<E> copy() => OptionsFilter<E>(
    union: union,
    options: options,
    sync: sync,
    initialTarget: selectedOptions,
  );

  @override
  List<Object?> get props => [union, options, sync, selectedOptions];

}

class TextQueryFilter extends Filter<String?> {

  TextQueryFilter({
    super.key,
    required super.union,
    super.sync = true
  });

  String? _target;

  set target(String? value) {
    _target = value;
    notifyListeners();
  }

  @override
  bool get isActive => false;

  @override
  void clear() {
    _target=null;
    notifyListeners();
  }

  @override
  bool isIn(String? input) {
    if (input == null || input.isEmpty) return false;
    if (_target == null || _target!.isEmpty) return true;

    return input.toLowerCase().startsWith(_target!.toLowerCase());
  }

  @override
  TextQueryFilter copy() => TextQueryFilter(
      union: union,
      sync: sync,
  );

  @override
  List<Object?> get props => [union, sync, _target];


}


sealed class FilterWrapper<T, F extends Filter> extends Filter<T> {

  final dynamic Function(T) map;
  final F _child;

  FilterWrapper(this._child, {
    required this.map,
    super.union = LogicOperator.and,
    super.sync = false,
    super.key,
  }) : super() {
    if (sync && !_child.hasListeners) {
      _child.addListener(() => notifyListeners());
    }
  }

  @override
  bool isIn(T input) {
    return _child.isIn(map(input));
  }

  @override
  void clear() {
    _child.clear();
  }

  @override
  List<Object?> get props => [..._child.props, map];

}

/*
class ElementTextQueryFilter<T> extends FilterWrapper<T, TextQueryFilter> {

  ElementTextQueryFilter({
    super.key,
    super.sync = true,
    super.union = LogicOperator.or,
    required super.map
  }) : super(TextQueryFilter(union: LogicOperator.or, sync: sync));

  String? get _target => _child._target;

  set target(String? value) {
    _child._target = value;
    notifyListeners();
  }

  @override
  // TODO: implement isActive
  bool get isActive => throw UnimplementedError();

  @override
  ElementTextQueryFilter<T> copy() => ElementTextQueryFilter<T>(
    map: map,
    union: union,
    sync: sync,
  );

}

 */

class ElementOptionsFilter<T,E> extends FilterWrapper<T, OptionsFilter<E>> {

  ElementOptionsFilter({
    required List<E> options,
    required super.map,
    List<E> selectedOptions = const [],
    super.union = LogicOperator.and,
    super.sync = false,
    super.key,
  }) : super(OptionsFilter(
      options: options,
      initialTarget: selectedOptions
  ));

  List<E> get selectedOptions => _child.selectedOptions;
  List<E> get options => _child.options;

  @override
  bool get isActive => selectedOptions.isNotEmpty;

  void add(E e) {
    _child.selectedOptions.add(e);
    notifyListeners();
  }

  void remove(E e) {
    _child.selectedOptions.remove(e);
    notifyListeners();
  }


  @override
  ElementOptionsFilter<T,E> copy() => ElementOptionsFilter(
      options: _child.options,
      selectedOptions: _child.selectedOptions,
      map: map,
      key: key,
      sync: sync,
      union: union,
  );

}




class ElementTextGroupFilter<T> extends Filter<T> {

  final List<String?> Function(T) values;
  late final TextQueryFilter _child;

  ElementTextGroupFilter({
    required this.values,
    super.union = LogicOperator.and,
    super.sync = false,
    super.key,
  }) : super() {
    _child = TextQueryFilter(union: union);
    if (sync && !_child.hasListeners) {
      _child.addListener(() => notifyListeners());
    }
  }

  @override
  bool get isActive => false;

  set target(String? value) {
    _child.target = value;
    notifyListeners();
  }
  String? get target => _child._target;

  @override
  bool isIn(T input) {
    for (var v in values(input)) {
      if (_child.isIn(v)) return true;
    }
    return false;
  }

  @override
  void clear() {
    _child.clear();
  }

  @override
  List<Object?> get props => [..._child.props, values];

  @override
  Filter<T> copy() {
    // TODO: implement copy
    throw UnimplementedError();
  }




}








