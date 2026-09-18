import 'package:flutter_test/flutter_test.dart';
import 'package:ilwyrm/data/enums.dart';

void main() {
  final start = DateTime(2024, 1, 10);
  final finish = DateTime(2024, 2, 20);
  final today = DateTime(2026, 9, 17);

  test('À lire : aucune date, même si des dates existaient', () {
    final d = datesForShelf(BookShelf.toRead,
        currentStart: start, currentFinish: finish, now: today);
    expect(d.start, isNull);
    expect(d.finish, isNull);
  });

  test('En cours : date de début conservée, date de fin effacée', () {
    final d = datesForShelf(BookShelf.reading,
        currentStart: start, currentFinish: finish, now: today);
    expect(d.start, start);
    expect(d.finish, isNull);
  });

  test('En cours sans date de début : défaut = aujourd\'hui', () {
    final d = datesForShelf(BookShelf.reading, now: today);
    expect(d.start, today);
    expect(d.finish, isNull);
  });

  test('Lu : début + fin conservés', () {
    final d = datesForShelf(BookShelf.read,
        currentStart: start, currentFinish: finish, now: today);
    expect(d.start, start);
    expect(d.finish, finish);
  });

  test('Lu sans dates : début = fin = aujourd\'hui', () {
    final d = datesForShelf(BookShelf.read, now: today);
    expect(d.start, today);
    expect(d.finish, today);
  });

  test('Lu avec seulement une date de fin : début = fin', () {
    final d = datesForShelf(BookShelf.read, currentFinish: finish, now: today);
    expect(d.start, finish);
    expect(d.finish, finish);
  });

  test('Lu : fin antérieure au début est corrigée (fin = début)', () {
    final d = datesForShelf(BookShelf.read,
        currentStart: finish, currentFinish: start, now: today);
    expect(d.start, finish);
    expect(d.finish, finish);
  });

  test('helpers usesStartDate / usesFinishDate', () {
    expect(BookShelf.toRead.usesStartDate, isFalse);
    expect(BookShelf.toRead.usesFinishDate, isFalse);
    expect(BookShelf.reading.usesStartDate, isTrue);
    expect(BookShelf.reading.usesFinishDate, isFalse);
    expect(BookShelf.read.usesStartDate, isTrue);
    expect(BookShelf.read.usesFinishDate, isTrue);
  });
}
