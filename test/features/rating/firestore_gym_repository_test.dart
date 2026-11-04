import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_gym/core/errors/app_failure.dart';
import 'package:good_gym/core/errors/result.dart';
import 'package:good_gym/core/pagination/paged_result.dart';
import 'package:good_gym/features/rating/data/firestore_gym_repository.dart';
import 'package:good_gym/features/rating/domain/gym.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late FirestoreGymRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = FirestoreGymRepository(firestore, () => 'creator');
  });

  Future<List<String>> search(String query, {int limit = 20}) async {
    final result = await repository.searchGyms(query: query, limit: limit);
    return (result as Success<PagedResult<Gym>>).value.items
        .map((gym) => gym.name)
        .toList();
  }

  test(
    'creates a gym with trimmed text and the current user as creator',
    () async {
      final result = await repository.createGym(
        name: ' Iron Gym ',
        city: 'Kyiv',
      );

      final gym = (result as Success<Gym>).value;
      expect(gym.name, 'Iron Gym');
      expect(gym.creatorId, 'creator');
      final stored = (await firestore.doc('gyms/${gym.id}').get()).data()!;
      expect(stored['nameLower'], 'iron gym');
    },
  );

  test('rejects too short names before writing', () async {
    final result = await repository.createGym(name: 'I', city: 'Kyiv');

    expect((result as Failure<Gym>).failure, AppFailure.invalidInput);
    expect((await firestore.collection('gyms').get()).docs, isEmpty);
  });

  test(
    'searches by case-insensitive name prefix in alphabetical order',
    () async {
      for (final name in ['Steel Club', 'Iron Gym', 'iron temple', 'Alpha']) {
        await repository.createGym(name: name, city: 'Kyiv');
      }

      expect(await search('IRON'), ['Iron Gym', 'iron temple']);
      expect(await search(''), [
        'Alpha',
        'Iron Gym',
        'iron temple',
        'Steel Club',
      ]);
    },
  );

  test('pages through results with a cursor', () async {
    for (final name in ['Alpha', 'Bravo', 'Charlie']) {
      await repository.createGym(name: name, city: 'Kyiv');
    }

    final first = await repository.searchGyms(query: '', limit: 2);
    final page = (first as Success<PagedResult<Gym>>).value;
    expect(page.items.map((gym) => gym.name), ['Alpha', 'Bravo']);
    expect(page.hasMore, isTrue);

    final second = await repository.searchGyms(
      query: '',
      limit: 2,
      cursor: page.nextCursor,
    );
    final next = (second as Success<PagedResult<Gym>>).value;
    expect(next.items.map((gym) => gym.name), ['Charlie']);
    expect(next.hasMore, isFalse);
  });
}
