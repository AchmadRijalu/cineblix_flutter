part of '../see_more.dart';

sealed class SeeMoreEvent extends Equatable {
  const SeeMoreEvent();
  @override
  List<Object> get props => [];
}

final class SeeMoreFetched extends SeeMoreEvent {}

final class SeeMoreNextPageRequested extends SeeMoreEvent {}
