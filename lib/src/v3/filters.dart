import 'package:flutter/material.dart';
import 'package:x_table/x_table.dart';

sealed class Filter<E> extends ChangeNotifier{

  final E benchmark;
  final E? target;

  Filter(this.benchmark, this.target);


  void clear();

  set benchmark(E v) {
    benchmark = v;
    notifyListeners();
  }

}


class OptionsFilter<E> extends Filter<List<E>> {

  OptionsFilter(super.benchmark, super.target);

  @override
  List<E> get target => super.target as List<E>;

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
