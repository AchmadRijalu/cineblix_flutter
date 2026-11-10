# TV Series Detail, Search & Watchlist Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add TV series support: a detail page (poster, title, rating, synopsis, recommendations), title search through the TMDB API, and a watchlist stored locally that survives app restarts.

**Architecture:** There are three new modules, each structured like the existing Home, DetailMovie and SeeMore modules: TvDetail, Search and Watchlist. Each module gets its own data source, repository, usecases, Bloc and page, and its files are added as `part`s of the existing layer libraries. The watchlist is stored in SQLite through a `DatabaseHelper` in `lib/Data/DB/`. The new pages are reached from two icons added to the Home AppBar (search and watchlist).

**Tech Stack:** Flutter, `flutter_bloc` (Bloc with events), `fpdart` `Either`, `dio`, `get_it`, `equatable`. New: `sqflite`, `bloc_concurrency`, and dev-only `sqflite_common_ffi`.

**Spec:** the user's requirements, copied verbatim (Indonesian):

> * Aplikasi harus menampilkan detail TV Series berdasarkan item yang dipilih.
>    * Halaman detail menampilkan poster, judul, rating, dan sinopsis.
>    * Halaman detail menampilkan rekomendasi TV series lainnya.
> * Terdapat fitur untuk mencari judul TV Series.
>    * Fitur pencarian berdasarkan judul dengan memanfaatkan API (bukan filtering secara lokal).
> * Kriteria 4: Watchlist — Menambahkan daftar TV series yang ingin ditonton ke dalam suatu daftar yang disimpan secara lokal. Daftar watchlist harus tetap bertahan meskipun aplikasi ditutup dan dibuka kembali.

In English: the detail page shows poster, title, rating and synopsis, plus recommended TV series. Search by title must go through the API, not filter a local list. The watchlist is stored locally and must survive the app being closed and reopened.

## Global Constraints

- **Library pattern:** every layer or module is one library file that lists its files with `part`. Part files start with `part of '…';` and have **no imports**. Any import goes in the library file. The libraries are `Common/commons.dart`, `Domain/Entities/entities.dart`, `Data/Model/models.dart`, `Data/DataSources/data_sources.dart`, `Data/Repositories/repositories.dart`, `Domain/UseCases/usecases.dart`, `Presentation/Widgets/widgets.dart`, and one per Presentation module.
- **Folders per module:**
  - `Data/Repositories/<Module>Repository/`
  - `Domain/UseCases/<Module>/`
  - `Presentation/<Module>/`, with the Bloc in `bloc/`
- **State management:** use Bloc with events, not Cubit. Events and states are `sealed` classes that extend `Equatable`. Views render state with an exhaustive `switch`.
- **Error handling:** every repository returns `Either<Failure, T>` through `guard()` in `Common/failure.dart`.
- **Dependency injection:** register everything in `lib/injection.dart`. Blocs use `registerFactory`, everything else uses `registerLazySingleton`.
- **TMDB access:** use the Dio from `createDio()`. The API key comes from `env.json`. Endpoints:
  - `/tv/{id}`
  - `/tv/{id}/recommendations`
  - `/search/tv?query=`
- **Dependencies:** add only `sqflite`, `bloc_concurrency`, and the dev dependency `sqflite_common_ffi`.
- **Tests:** use hand-written fakes, not mockito or mocktail. Shared fakes go in `test/helpers/`.
- **No commits:** the project is **not a git repo**. Each task ends with `flutter analyze` and its tests instead of a commit. If you run `git init` first, commit after each task.

## Review Focus

1. **Search query with spaces, `&` or non-ASCII characters**, e.g. `Tom & Jerry`, must be sent intact and URL-encoded. Pinned in Task 5 (`searchTv sends the raw query…`).
2. **Blank or whitespace-only query** must not call the API and must return to the initial state. Pinned in Task 5.
3. **Fast re-search:** a slow earlier response must not overwrite results for a newer query. Pinned in Task 5 (`restartable()` plus a test).
4. **Show with null poster, null overview, missing `vote_average` or missing genres** must still render, with no crash or "null" text. Pinned in Task 1 (model tests) and Task 4 (view fallbacks).
5. **Watchlist edge cases:** adding the same show twice must keep one row, and data must persist across a database close and reopen (the stand-in for an app restart). Pinned in Task 3.

---

### Task 1: TV entities and models

**Files:**
- Create: `lib/Domain/Entities/tv.dart`, `lib/Domain/Entities/tv_detail.dart` (parts of `entities.dart`)
- Create: `lib/Data/Model/tv_model.dart`, `lib/Data/Model/tv_detail_model.dart` (parts of `models.dart`)
- Modify: `lib/Domain/Entities/entities.dart`, `lib/Data/Model/models.dart`, to add the `part` lines
- Test: `test/tv_model_test.dart`

**Interfaces:**
- Produces:
```dart
class Tv extends Equatable {
  const Tv({required int id, required String name, String? overview, String? posterPath, double voteAverage = 0});
}
class TvDetail extends Equatable {
  const TvDetail({required int id, required String name, required String overview, required String? posterPath,
    required double voteAverage, required List<String> genres, required int numberOfSeasons, required String firstAirDate});
}
class TvModel {
  factory TvModel.fromJson(Map<String, dynamic> json);   // keys: id, name, overview, poster_path, vote_average
  Tv toEntity();
  static List<TvModel> listFromJson(Map<String, dynamic> json); // reads json['results']
}
class TvDetailModel {
  const TvDetailModel(Map<String, dynamic> json);
  TvDetail toEntity(); // missing fields -> '', [], 0; vote_average num -> double
}
```

- [ ] **Step 1: Write failing tests** in `test/tv_model_test.dart`:
```dart
test('TvModel parses a result with null poster/overview and no vote_average', () {
  expect(TvModel.fromJson({'id': 1, 'name': 'Dark', 'overview': null, 'poster_path': null}).toEntity(),
      const Tv(id: 1, name: 'Dark'));
});
test('TvDetailModel maps genres, seasons and int vote_average', () {
  final d = TvDetailModel({'id': 1, 'name': 'Dark', 'overview': 'x', 'poster_path': '/p.jpg', 'vote_average': 8,
    'genres': [{'id': 18, 'name': 'Drama'}], 'number_of_seasons': 3, 'first_air_date': '2017-12-01'}).toEntity();
  expect(d.voteAverage, 8.0);
  expect(d.genres, ['Drama']);
  expect(d.numberOfSeasons, 3);
});
test('TvDetailModel tolerates missing optional fields', () {
  expect(const TvDetailModel({'id': 1, 'name': 'Dark'}).toEntity(), const TvDetail(id: 1, name: 'Dark', overview: '',
      posterPath: null, voteAverage: 0, genres: [], numberOfSeasons: 0, firstAirDate: ''));
});
test('TvModel.listFromJson reads results', () {
  expect(TvModel.listFromJson({'results': [{'id': 2, 'name': '1899'}]}).single.toEntity().id, 2);
});
```
- [ ] **Step 2:** Run `flutter test test/tv_model_test.dart`. Expected: compile errors (types not defined).
- [ ] **Step 3:** Implement the four classes above. Follow the existing `MovieModel` and `MovieDetailModel`.
- [ ] **Step 4:** Run `flutter test test/tv_model_test.dart && flutter analyze`. Expected: all pass, no issues.

---

### Task 2: TV Detail data and domain

**Files:**
- Create: `lib/Data/DataSources/tv_detail_remote_data_source.dart`
- Create: `lib/Data/Repositories/TvDetailRepository/tv_detail_repository.dart`, `tv_detail_repository_impl.dart`
- Create: `lib/Domain/UseCases/TvDetail/get_tv_detail.dart`, `get_tv_recommendations.dart`
- Create: `test/helpers/fake_dio.dart`
- Modify: the `part` lists in `data_sources.dart`, `repositories.dart` and `usecases.dart`; `lib/injection.dart`
- Test: `test/tv_detail_repository_test.dart`

**Interfaces:**
- Consumes: `TvModel`, `TvDetailModel`, `Tv`, `TvDetail` (Task 1)
- Produces:
```dart
class TvDetailRemoteDataSource { TvDetailRemoteDataSource(Dio dio);
  Future<TvDetailModel> detail(int id);              // GET /tv/$id
  Future<List<TvModel>> recommendations(int id); }   // GET /tv/$id/recommendations
abstract class TvDetailRepository {
  Future<Either<Failure, TvDetail>> getTvDetail(int id);
  Future<Either<Failure, List<Tv>>> getTvRecommendations(int id); }
class GetTvDetail { GetTvDetail(TvDetailRepository r); Future<Either<Failure, TvDetail>> call(int id); }
class GetTvRecommendations { GetTvRecommendations(TvDetailRepository r); Future<Either<Failure, List<Tv>>> call(int id); }
// test/helpers/fake_dio.dart
Dio fakeDio(Map<String, (int, Object)> routes, {List<RequestOptions>? log});
```
`fakeDio` builds `Dio(BaseOptions(baseUrl: 'https://test'))` with a custom `HttpClientAdapter`. The adapter appends each `RequestOptions` to `log` and looks up `options.path` in `routes`. On a match it responds with that `(status, jsonBody)` and the header `content-type: application/json`. On no match it responds `404 {"status_message": "not found"}`.

- [ ] **Step 1: Write failing tests:**
```dart
test('getTvDetail calls /tv/{id} and maps to entity', () async {
  final log = <RequestOptions>[];
  final repo = TvDetailRepositoryImpl(TvDetailRemoteDataSource(fakeDio({'/tv/1': (200, {'id': 1, 'name': 'Dark'})}, log: log)));
  expect((await repo.getTvDetail(1)).getOrElse((_) => throw 'fail').name, 'Dark');
  expect(log.single.path, '/tv/1');
});
test('getTvRecommendations calls /tv/{id}/recommendations', () async {
  final repo = TvDetailRepositoryImpl(TvDetailRemoteDataSource(fakeDio({'/tv/1/recommendations': (200, {'results': [{'id': 2, 'name': '1899'}]})})));
  expect((await repo.getTvRecommendations(1)).getOrElse((_) => []), [const Tv(id: 2, name: '1899')]);
});
test('HTTP error becomes ServerFailure carrying TMDB status_message', () async {
  final repo = TvDetailRepositoryImpl(TvDetailRemoteDataSource(fakeDio({})));
  expect(await repo.getTvDetail(99), const Left<Failure, TvDetail>(ServerFailure('not found')));
});
```
- [ ] **Step 2:** Run `flutter test test/tv_detail_repository_test.dart`. Expected: compile errors.
- [ ] **Step 3:** Implement the data source, repository and usecases. Use `guard()` as `DetailMovieRepositoryImpl` does. Register them in `injection.dart` under a `// TV Detail` comment.
- [ ] **Step 4:** Run `flutter test test/tv_detail_repository_test.dart && flutter analyze`. Expected: pass.

---

### Task 3: Watchlist storage and domain

**Files:**
- Run: `flutter pub add sqflite` and `flutter pub add --dev sqflite_common_ffi`
- Create: `lib/Data/DB/database_helper.dart`. Add it as a part of `data_sources.dart` (`part '../DB/database_helper.dart';`) and add `import 'package:sqflite/sqflite.dart';` to that library.
- Create: `lib/Data/Model/watchlist_table.dart` (part of `models.dart`)
- Create: `lib/Data/Repositories/WatchlistRepository/watchlist_repository.dart`, `watchlist_repository_impl.dart`
- Create: `lib/Domain/UseCases/Watchlist/save_watchlist.dart`, `remove_watchlist.dart`, `get_watchlist_status.dart`, `get_watchlist_tv.dart`
- Modify: `lib/Common/failure.dart`. Add `class DatabaseFailure extends Failure`, and make `guard()` also catch sqflite `DatabaseException` and return `DatabaseFailure(e.toString())`. Add the sqflite import to `commons.dart`.
- Modify: the `part` lists, `injection.dart`
- Test: `test/watchlist_storage_test.dart`

**Interfaces:**
- Consumes: `Tv`, `TvDetail` (Task 1)
- Produces:
```dart
class DatabaseHelper {
  DatabaseHelper({DatabaseFactory? factory, String? path}); // defaults: sqflite databaseFactory, '${await getDatabasesPath()}/cineblix.db'
  Future<void> insert(WatchlistTable tv);   // ConflictAlgorithm.replace
  Future<void> remove(int id);
  Future<bool> contains(int id);
  Future<List<WatchlistTable>> all();       // ORDER BY addedAt DESC
  Future<void> close();
}
// table watchlist(id INTEGER PRIMARY KEY, name TEXT NOT NULL, overview TEXT, posterPath TEXT, voteAverage REAL NOT NULL, addedAt INTEGER NOT NULL)
class WatchlistTable {
  factory WatchlistTable.fromEntity(TvDetail tv);  // addedAt = DateTime.now().millisecondsSinceEpoch
  factory WatchlistTable.fromMap(Map<String, Object?> map);
  Map<String, Object?> toMap();
  Tv toEntity();
}
abstract class WatchlistRepository {
  Future<Either<Failure, String>> saveWatchlist(TvDetail tv);   // Right('Added to Watchlist')
  Future<Either<Failure, String>> removeWatchlist(int id);      // Right('Removed from Watchlist')
  Future<bool> isAddedToWatchlist(int id);
  Future<Either<Failure, List<Tv>>> getWatchlist();
}
class SaveWatchlist { Future<Either<Failure, String>> call(TvDetail tv); }
class RemoveWatchlist { Future<Either<Failure, String>> call(int id); }
class GetWatchlistStatus { Future<bool> call(int id); }
class GetWatchlistTv { Future<Either<Failure, List<Tv>>> call(); }
```
`WatchlistRepositoryImpl(DatabaseHelper db)` uses the helper directly, with no separate local data source class.

- [ ] **Step 1: Write failing tests.** Use `setUpAll(sqfliteFfiInit)`. Create each helper with `DatabaseHelper(factory: databaseFactoryFfi, path: '${Directory.systemTemp.createTempSync().path}/w.db')`. Define `dark = TvDetail(id: 1, name: 'Dark', …)`.
```dart
test('watchlist survives closing and reopening the database', () async {
  final a = DatabaseHelper(factory: databaseFactoryFfi, path: path);
  await a.insert(WatchlistTable.fromEntity(dark)); await a.close();
  final b = DatabaseHelper(factory: databaseFactoryFfi, path: path);
  expect(await b.contains(1), isTrue);
  expect((await b.all()).single.toEntity().name, 'Dark');
});
test('adding the same show twice keeps one row', ...);           // insert dark x2 -> all().length == 1
test('remove deletes; removing a missing id is a no-op', ...);    // remove(1) -> contains false; remove(42) does not throw
test('all() returns newest first', ...);                          // insert id 1 then id 2 -> ids [2, 1]
test('repository save/remove return messages and update status', () async {
  final repo = WatchlistRepositoryImpl(helper);
  expect(await repo.saveWatchlist(dark), const Right<Failure, String>('Added to Watchlist'));
  expect(await repo.isAddedToWatchlist(1), isTrue);
  expect(await repo.removeWatchlist(1), const Right<Failure, String>('Removed from Watchlist'));
  expect(await repo.isAddedToWatchlist(1), isFalse);
});
```
- [ ] **Step 2:** Run `flutter test test/watchlist_storage_test.dart`. Expected: compile errors.
- [ ] **Step 3:** Implement everything above. The helper opens its database once, lazily, using a cached `Future<Database>`. Register `DatabaseHelper()` as a lazy singleton.
- [ ] **Step 4:** Run `flutter test test/watchlist_storage_test.dart && flutter analyze`. Expected: pass.

---

### Task 4: TV Detail page (poster, title, rating, synopsis, recommendations, watchlist button)

**Files:**
- Create: `lib/Presentation/TvDetail/tv_detail.dart` (library), `bloc/tv_detail_bloc.dart`, `bloc/tv_detail_event.dart`, `bloc/tv_detail_state.dart`, `tv_detail_view.dart`
- Modify: `lib/Presentation/Widgets/movie_card.dart`. Rename it to `poster_card.dart` with `PosterCard({required String? posterPath, required VoidCallback onTap, double width = 100})`. Update the 3 call sites (`home_view.dart`, `detail_movie_view.dart`, `see_more_movie_tile.dart`) to pass `movie.posterPath`.
- Modify: `injection.dart`
- Create: `test/helpers/fakes.dart`, with in-memory `FakeTvDetailRepository` and `FakeWatchlistRepository`
- Test: `test/tv_detail_bloc_test.dart`

**Interfaces:**
- Consumes: the Task 2 usecases and the Task 3 `GetWatchlistStatus`, `SaveWatchlist` and `RemoveWatchlist`
- Produces:
```dart
sealed class TvDetailEvent; final class TvDetailFetched(int id); final class TvDetailWatchlistToggled();
sealed class TvDetailState; TvDetailInitial; TvDetailLoading; TvDetailError(String message);
final class TvDetailLoaded(TvDetail tv, List<Tv> recommendations, bool isAddedToWatchlist, {String watchlistMessage = ''});
class TvDetailBloc(GetTvDetail, GetTvRecommendations, GetWatchlistStatus, SaveWatchlist, RemoveWatchlist);
class TvDetailView extends StatelessWidget { const TvDetailView({super.key, required int id}); }
```
Bloc rules:
- **Fetch:** run detail, recommendations and status together with `.wait`. A failed detail emits `TvDetailError`. Failed recommendations become `[]`.
- **Toggle:** ignore it unless the state is `TvDetailLoaded`. Call save or remove depending on the current flag.
  - On `Right`, flip the flag and set `watchlistMessage`.
  - On `Left`, keep the flag and set `watchlistMessage` to `failure.message`.

View:
- Poster via `PosterCard`. If `posterPath` is null, the card shows an icon placeholder.
- Title, then `★ ${voteAverage.toStringAsFixed(1)}`, then genres and season count.
- Synopsis. If it is empty, show `No synopsis available.`
- A watchlist `FilledButton.icon`: `Icons.check` with "In Watchlist", or `Icons.add` with "Watchlist".
- A horizontal list of recommendations. Tapping one opens it with `Navigator.pushReplacement(TvDetailView)`.
- A `BlocListener` shows a SnackBar when `watchlistMessage` changes and is non-empty.

- [ ] **Step 1: Write failing bloc tests:**
```dart
test('fetch emits Loading then Loaded with recommendations and status', ...)
  // expect stream: [TvDetailLoading(), TvDetailLoaded(dark, [show1899], false)]
test('recommendations failure still shows the show', ...)   // -> TvDetailLoaded(dark, [], false)
test('detail failure emits Error with the failure message', ...) // -> TvDetailError('not found')
test('toggle adds then removes with messages', ...)
  // -> isAddedToWatchlist true, 'Added to Watchlist'; then false, 'Removed from Watchlist'
test('toggle failure keeps the flag and reports the error', ...)
  // FakeWatchlistRepository(failSave: DatabaseFailure('disk full')) -> isAddedToWatchlist false, watchlistMessage 'disk full'
```
- [ ] **Step 2:** Run `flutter test test/tv_detail_bloc_test.dart`. Expected: compile errors.
- [ ] **Step 3:** Implement the bloc, view, `PosterCard` rename and DI (`registerFactory(() => TvDetailBloc(...))`).
- [ ] **Step 4:** Run `flutter test && flutter analyze`. Expected: all pass, including the existing movie tests after the rename.

---

### Task 5: Search TV series by title (API)

**Files:**
- Run: `flutter pub add bloc_concurrency`
- Create: `lib/Data/DataSources/search_remote_data_source.dart`
- Create: `lib/Data/Repositories/SearchRepository/search_repository.dart`, `search_repository_impl.dart`
- Create: `lib/Domain/UseCases/Search/search_tv.dart`
- Create: `lib/Presentation/Search/search.dart` (library), `bloc/search_bloc.dart`, `bloc/search_event.dart`, `bloc/search_state.dart`, `search_page.dart`
- Create: `lib/Presentation/Widgets/poster_tile.dart` (part of `widgets.dart`)
- Modify: the `part` lists, `injection.dart`
- Test: `test/search_test.dart`

**Interfaces:**
- Consumes: `TvModel` and `Tv` (Task 1), `fakeDio` (Task 2), `TvDetailView` (Task 4)
- Produces:
```dart
class SearchRemoteDataSource { Future<List<TvModel>> searchTv(String query); } // GET /search/tv, queryParameters: {'query': query}
abstract class SearchRepository { Future<Either<Failure, List<Tv>>> searchTv(String query); }
class SearchTv { Future<Either<Failure, List<Tv>>> call(String query); }
sealed class SearchEvent; final class SearchQueryChanged(String query);
sealed class SearchState; SearchInitial; SearchLoading; SearchLoaded(List<Tv> results); SearchEmpty(String query); SearchError(String message);
class SearchBloc(SearchTv); // on<SearchQueryChanged>(_onQuery, transformer: restartable())
class SearchPage extends StatelessWidget { const SearchPage({super.key}); }
class PosterTile extends StatelessWidget {
  const PosterTile({super.key, required String? posterPath, required String title, required String subtitle, required VoidCallback onTap});
}
```
Bloc rules:
- Trim the query first. If it is blank, emit `SearchInitial` and do not call the API.
- Otherwise emit `Loading`, then `Loaded`, `Empty(query)` or `Error`.

Page:
- An autofocused `TextField` with `textInputAction: TextInputAction.search`. `onSubmitted` dispatches `SearchQueryChanged`.
- Show results as a list of `PosterTile`s, with `★ rating` and the overview in the subtitle.
- Tapping a result pushes `TvDetailView(id:)`.
- The empty state says `No TV series found for "<query>"`.

- [ ] **Step 1: Write failing tests:**
```dart
test('searchTv sends the raw query to /search/tv, URL-encoded', () async {
  final log = <RequestOptions>[];
  final ds = SearchRemoteDataSource(fakeDio({'/search/tv': (200, {'results': [{'id': 1, 'name': 'Tom & Jerry'}]})}, log: log));
  expect((await ds.searchTv('Tom & Jerry')).single.name, 'Tom & Jerry');
  expect(log.single.path, '/search/tv');
  expect(log.single.uri.queryParameters['query'], 'Tom & Jerry');
  expect(log.single.uri.query, contains('query=Tom+%26+Jerry'));
});
test('blank query returns to Initial without calling the API', ...)  // add '   ' -> state SearchInitial, fake.calls isEmpty
test('query is trimmed before calling the API', ...)                // add '  dark ' -> fake.calls == ['dark']
test('results emit Loading then Loaded', ...)
test('no results emit SearchEmpty(query)', ...)
test('API failure emits SearchError', ...)
test('a slower earlier query cannot overwrite a newer one', ...)
  // fake: 'a' resolves after 50ms with [tvA], 'ab' resolves immediately with [tvAB]
  // add 'a' then 'ab'; after 100ms bloc.state == SearchLoaded([tvAB])
```
- [ ] **Step 2:** Run `flutter test test/search_test.dart`. Expected: compile errors.
- [ ] **Step 3:** Implement everything above and register it in `injection.dart`.
- [ ] **Step 4:** Run `flutter test test/search_test.dart && flutter analyze`. Expected: pass.

---

### Task 6: Watchlist page and Home entry points

**Files:**
- Create: `lib/Presentation/Favorites/favorites.dart` (library; it uses the existing empty `Favorites` folder), `bloc/watchlist_bloc.dart`, `bloc/watchlist_event.dart`, `bloc/watchlist_state.dart`, `watchlist_page.dart`
- Modify: `lib/Presentation/Home/home_view.dart`. Add AppBar `actions`: `Icons.search` pushes `SearchPage()`, and `Icons.bookmark` pushes `WatchlistPage()`. Add both module imports to `home.dart`.
- Modify: `injection.dart`
- Test: `test/watchlist_bloc_test.dart`

**Interfaces:**
- Consumes: `GetWatchlistTv` (Task 3), `TvDetailView` (Task 4), `PosterTile` (Task 5), `FakeWatchlistRepository` (Task 4)
- Produces:
```dart
sealed class WatchlistEvent; final class WatchlistFetched();
sealed class WatchlistState; WatchlistInitial; WatchlistLoading; WatchlistLoaded(List<Tv> items); WatchlistError(String message);
class WatchlistBloc(GetWatchlistTv);
class WatchlistPage extends StatelessWidget { const WatchlistPage({super.key}); }
```
Page:
- `BlocProvider` creates the bloc and dispatches `WatchlistFetched()`.
- An empty list shows `Your watchlist is empty`.
- Tapping a tile runs `await Navigator.push(… TvDetailView(id:))` and then dispatches `WatchlistFetched()`, so a show removed on the detail page disappears when you come back.

- [ ] **Step 1: Write failing tests:**
```dart
test('fetch emits Loading then Loaded with stored shows', ...)  // fake holds [dark] -> WatchlistLoaded([darkTv])
test('empty watchlist emits Loaded([])', ...)
test('storage failure emits WatchlistError', ...)               // fake getWatchlist -> Left(DatabaseFailure('x'))
```
- [ ] **Step 2:** Run `flutter test test/watchlist_bloc_test.dart`. Expected: compile errors.
- [ ] **Step 3:** Implement the bloc, page, Home actions and DI.
- [ ] **Step 4:** Run `flutter test && flutter analyze`. Expected: everything passes.
- [ ] **Step 5: Manual check on a device.** Run `flutter run --dart-define-from-file=env.json`.
  1. Search `Dark` and open the result. Confirm the poster, title, ★ rating and synopsis appear, along with the recommendations.
  2. Tap Watchlist and confirm the SnackBar says "Added to Watchlist".
  3. Fully kill the app and relaunch it. Open the Watchlist page and confirm Dark is listed.
  4. Open Dark, remove it, and go back. Confirm the list is empty.
