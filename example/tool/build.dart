import 'package:build_runner/build_runner.dart';
import 'package:build_config/build_config.dart';
import 'dart:isolate';
import 'package:firestore_orm/firestore_orm_builder.dart';

final _builders = [
  apply(
      'firestore_orm|firestore_orm', [firestoreOrmBuilder], toRoot(),
      hideOutput: false,
      defaultGenerateFor:
      const InputSet(include: const ['lib/author.dart']))
];
void main(List<String> args, [SendPort sendPort]) {
  print("This is a main function yo");
  runBuild(args, sendPort);
}

void runBuild(List<String> args, [SendPort sendPort]) async {
  args = ['build'];
  var result = await run(args, _builders);
  sendPort?.send(result);
}
