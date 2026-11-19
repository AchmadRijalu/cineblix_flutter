part of '../presentation.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object> get props => [];
}

final class HomeFetched extends HomeEvent {}
