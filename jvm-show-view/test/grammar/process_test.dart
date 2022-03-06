
import 'dart:io';

Future<void> main() async {

  // final directory = await getApplicationDocumentsDirectory();
  //
  // print(directory.path);

  var result = await Process.run('pwd', ['-L']);

  print(result.pid);
  print(result.stdout);
  print(result.stderr);
}