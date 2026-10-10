/// Base for every domain error in PureTube. UI layers catch this
/// to turn failures into user-facing messages.
abstract class PureTubeException implements Exception {
  String get message;
}

class NetworkException extends PureTubeException {
  @override
  final String message;
  NetworkException(
      [this.message =
          'No internet connection. Check your network and retry.']);
}

class ExtractorException extends PureTubeException {
  @override
  final String message;
  ExtractorException(this.message);
}

class UnplayableVideoException extends PureTubeException {
  final String videoId;
  @override
  final String message;
  UnplayableVideoException(this.videoId, this.message);
}
