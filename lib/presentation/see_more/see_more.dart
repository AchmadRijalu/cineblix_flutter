import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/entities.dart';
import '../../domain/use_cases/use_cases.dart';
import '../../injection.dart';
import '../detail_movie/detail_movie.dart';
import '../tv_detail/tv_detail.dart';

part 'bloc/see_more_bloc.dart';
part 'bloc/see_more_event.dart';
part 'bloc/see_more_state.dart';
part 'see_more_page.dart';
part 'widgets/see_more_tile.dart';
