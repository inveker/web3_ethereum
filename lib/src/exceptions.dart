/// Default exception class, throw from ethereum.request call
class Web3EthereumException implements Exception {
  final int code;
  final String message;

  Web3EthereumException({
    required this.code,
    required this.message,
  });

  @override
  String toString() {
    return 'Web3EthereumException(code: $code, message: $message);';
  }
}
