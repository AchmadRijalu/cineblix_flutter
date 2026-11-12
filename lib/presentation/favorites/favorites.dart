import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/entities.dart';
import '../../domain/use_cases/use_cases.dart';
import '../../injection.dart';
import '../detail_movie/detail_movie.dart';
import '../tv_detail/tv_detail.dart';

part 'bloc/watchlist_bloc.dart';
part 'bloc/watchlist_event.dart';
part 'bloc/watchlist_state.dart';
part 'watchlist_page.dart';
