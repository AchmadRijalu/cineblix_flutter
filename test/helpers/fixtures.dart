Map<String, dynamic> movieList(String prefix, {int totalPages = 1}) => {
  'page': 1,
  'total_pages': totalPages,
  'results': [
    for (var i = 1; i <= 3; i++)
      {
        'id': i,
        'title': '$prefix $i',
        'overview': '$prefix overview $i',
        'poster_path': null,
      },
  ],
};

Map<String, dynamic> tvList(String prefix, {int totalPages = 1}) => {
  'page': 1,
  'total_pages': totalPages,
  'results': [
    for (var i = 1; i <= 3; i++)
      {
        'id': i,
        'name': '$prefix $i',
        'overview': '$prefix overview $i',
        'poster_path': null,
        'vote_average': 7.5,
      },
  ],
};

const movieDetailJson = {
  'id': 1,
  'title': 'Inception',
  'overview': 'Dreams within dreams.',
  'poster_path': null,
  'release_date': '2010-07-16',
  'runtime': 148,
  'vote_average': 8.4,
  'genres': [
    {'id': 28, 'name': 'Action'},
  ],
};

const tvDetailJson = {
  'id': 1,
  'name': 'Dark',
  'overview': 'Time travel in Winden.',
  'poster_path': null,
  'vote_average': 8.4,
  'genres': [
    {'id': 18, 'name': 'Drama'},
  ],
  'number_of_seasons': 3,
  'first_air_date': '2017-12-01',
  'seasons': [
    {
      'season_number': 1,
      'name': 'Season 1',
      'episode_count': 10,
      'poster_path': null,
      'air_date': '2017-12-01',
    },
  ],
};

const seasonJson = {
  'season_number': 1,
  'name': 'Season 1',
  'overview': 'A child goes missing.',
  'poster_path': null,
  'episodes': [
    {
      'episode_number': 1,
      'name': 'Secrets',
      'overview': 'Mikkel disappears.',
      'still_path': null,
      'air_date': '2017-12-01',
      'runtime': 51,
      'vote_average': 8.1,
    },
  ],
};

const searchJson = {
  'results': [
    {
      'id': 1,
      'name': 'Dark',
      'overview': 'Time travel in Winden.',
      'poster_path': null,
      'vote_average': 8.4,
    },
  ],
};

final Map<String, (int, Object)> allRoutes = {
  '/movie/now_playing': (200, movieList('Now')),
  '/movie/popular': (200, movieList('Pop', totalPages: 2)),
  '/movie/top_rated': (200, movieList('Top')),
  '/movie/1': (200, movieDetailJson),
  '/movie/1/recommendations': (200, movieList('Rec')),
  '/tv/on_the_air': (200, tvList('Air')),
  '/tv/popular': (200, tvList('TvPop', totalPages: 2)),
  '/tv/top_rated': (200, tvList('TvTop')),
  '/tv/1': (200, tvDetailJson),
  '/tv/1/recommendations': (200, {'results': <Object>[]}),
  '/tv/1/season/1': (200, seasonJson),
  '/search/tv': (200, searchJson),
};
