import 'package:about/about.dart';
import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:search/search.dart';

import '../../domain/entities/entities.dart';
import '../../domain/use_cases/use_cases.dart';
import '../detail_movie/detail_movie.dart';
import '../favorites/favorites.dart';
import '../see_more/see_more.dart';
import '../tv_detail/tv_detail.dart';

part 'bloc/home_bloc.dart';
part 'bloc/home_event.dart';
part 'bloc/home_state.dart';
part 'bloc/home_tv_bloc.dart';
part 'bloc/home_tv_event.dart';
part 'bloc/home_tv_state.dart';
part 'home_view.dart';
