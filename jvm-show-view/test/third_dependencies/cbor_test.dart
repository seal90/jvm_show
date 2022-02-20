

import 'package:cbor/cbor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  var a = cbor.encode(const CborSmallInt(43008));
  print(a);
  var aa = cbor.decode(a);
  if(aa is CborSmallInt) {
    print(aa.toInt());
  }

  test('{1:2,3:4}', () {
    final encoded = cbor.encode(CborMap({
      CborSmallInt(1): CborSmallInt(2),
      CborSmallInt(3): CborSmallInt(4),
    }));
    expect(encoded, [0xa2, 0x01, 0x02, 0x03, 0x04]);
  });

  final value = CborValue([
    [1, 2, 3], // Writes an array
    CborBytes([0x00]), // Writes a byte string
    67.89,
    10,
    // You can encode maps with any value encodable as CBOR as key.
    {
      1: 'one',
      2: 'two',
    },
    'hello',

    // Indefinite length string
    CborEncodeIndefiniteLengthString([
      'hello',
      ' ',
      'world',
    ]),
  ]);

  final bytes = cbor.encode(value);

  final _ = cbor.decode(bytes);

  // Pretty print
  print(cborPrettyPrint(bytes));

  // Print json
  print(const CborJsonEncoder().convert(value));

  var entity = CborTestEntity();
  entity.name = "hea";
  entity.age = 15;


}

class CborTestEntity {
  String? name;
  int? age;
  int? classNum;


}