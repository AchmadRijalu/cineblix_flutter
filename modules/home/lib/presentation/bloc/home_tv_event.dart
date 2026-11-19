part of '../presentation.dart';

sealed class HomeTvEvent extends Equatable {
  const HomeTvEvent();
  @override
  List<Object> get props => [];
}

final class HomeTvFetched extends HomeTvEvent {}
