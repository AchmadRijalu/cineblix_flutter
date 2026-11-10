import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/entities.dart';
import '../../domain/use_cases/use_cases.dart';
import '../../injection.dart';
import '../tv_detail/tv_detail.dart';
import '../widgets/widgets.dart';

part 'bloc/search_bloc.dart';
part 'bloc/search_event.dart';
part 'bloc/search_state.dart';
part 'search_page.dart';
