part of '../home.dart';

sealed class HomeTvState extends Equatable {
  const HomeTvState();
  @override
  List<Object> get props => [];
}

final class HomeTvInitial extends HomeTvState {}

final class HomeTvLoading extends HomeTvState {}

final class HomeTvLoaded extends HomeTvState {
  final List<Tv> onTheAir;
  final List<Tv> popular;
  final List<Tv> topRated;

  const HomeTvLoaded({
    required this.onTheAir,
    required this.popular,
    required this.topRated,
  });

  @override
  List<Object> get props => [onTheAir, popular, topRated];
}

final class HomeTvError extends HomeTvState {
  final String message;
  const HomeTvError(this.message);
  @override
  List<Object> get props => [message];
}
