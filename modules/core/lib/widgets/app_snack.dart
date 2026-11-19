part of 'widgets.dart';

void showAppSnack(
  BuildContext context,
  String message, {
  bool isError = false,
}) => Snackify.show(
  context: context,
  type: isError ? SnackType.error : SnackType.success,
  title: Text(isError ? 'Failed' : 'Success'),
  subtitle: Text(message),
);
