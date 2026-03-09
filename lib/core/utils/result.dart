class Result<T> {
  const Result._({this.data, this.errorMessage});

  final T? data;
  final String? errorMessage;

  bool get isSuccess => data != null;

  factory Result.success(T data) => Result._(data: data);

  factory Result.failure(String message) => Result._(errorMessage: message);
}
