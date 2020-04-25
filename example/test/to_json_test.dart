import 'package:example/author.dart';
import 'package:example/book.dart';
import 'package:example/publisher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Outputs deep to JSON structure', () async {
    Map<String, dynamic> output = conanDoyle.toJson();
    expectNoObjectsInJson(output);
  });
}

void expectNoObjectsInJson(Map<String, dynamic> json) {
  for (var key in json.keys) {
    dynamic value = json[key];
    if (forbiddenTypes.contains(value.runtimeType)) {
      fail("Type ${value.runtimeType} not converted to Json. Value was: ${value.toString()}");
    }
    else if (value is Map<String, dynamic>) {
      expectNoObjectsInJson(value);
    }
    else if (value is List<Map<String, dynamic>>) {
      for (Map<String, dynamic> item in value) {
        expectNoObjectsInJson(item);
      }
    }
  }
}

List<Type> forbiddenTypes = [Author, Book, Publisher];

Author conanDoyle = Author()
  ..name = "Sir Arthur Conan Doyle"
  ..age = 128
  ..firstBook = sInS
  ..books = [sInS, sOf4];

Author janeAusten = Author()
  ..name = "Jane Austen"
  ..age = 134
  ..firstBook = pAndP
  ..books = [pAndP, sAndS, emma];

Book get pAndP => Book()
    ..genre = "Romance"
    ..title = "Pride and Prejudice"
    ..publishedYear = 1894
    ..publisher = harperCollins;

Book get emma => Book()
    ..genre = "Romance"
    ..title = "Emma"
    ..publishedYear = 1893
    ..publisher = penguin;

Book get sAndS => Book()
    ..genre = "Romance"
    ..title = "Sense and Sensibility"
    ..publisher = penguin;

Book get sInS => Book()
    ..genre = "Crime"
    ..title = "A Study in Scarlet"
    ..publishedYear = 1888
    ..publisher = harperCollins;

Book get sOf4 => Book()
    ..genre = "Crime"
    ..title = "The Sign of Four"
    ..publishedYear = 1890
    ..publisher = harperCollins;

Publisher get penguin => Publisher()
    ..name = "Penguin House"
    ..address = "North Pole";

Publisher get harperCollins => Publisher()
    ..name = "Harper Collins"
    ..address = "123 Church Grove, Gatwick, London"
    ..phoneNumber = "01234567";

