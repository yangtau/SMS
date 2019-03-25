import 'package:test/test.dart';

printMap({Map m = const {}}) {
  m.entries.forEach(print);
  print(m.entries);
}

main(List<String> args) {
  test('test', () {
    print([].join(','));
    printMap();
  });
}
