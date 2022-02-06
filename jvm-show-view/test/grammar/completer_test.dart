
import 'dart:async';

void main() {
  t();
  int? a = null;
  t(a);
  var aa = _MyAsyncCompleter<int>();
  aa.complete();
  aa.complete(null);

  var bb = MyCompleter<int>();
  bb.complete();
  bb.complete(null);

  var cc = Completer<int>();
  cc.complete();
  cc.complete(null);
}

abstract class MyCompleter<T> {
  factory MyCompleter() => new _MyAsyncCompleter<T>();
  void complete([FutureOr<T>? value]);
}

abstract class _MyCompleter<T> implements MyCompleter<T> {
  @override
  void complete([FutureOr<T>? value]);
}

class _MyAsyncCompleter<T> extends _MyCompleter<T> {
  @override
  void complete([FutureOr<T>? value]) {
    print('complete');
    //var dd = value == null ? value as dynamic : value;
  }
}

void t<T>([FutureOr<T>? value]) {
  print('hello');
}
