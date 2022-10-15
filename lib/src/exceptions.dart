/// Default exception class, throw from ethereum.request call
class Web3EthereumException implements Exception {
  final int code;
  final String message;
  final dynamic data;

  Web3EthereumException({
    required this.code,
    required this.message,
    required this.data,
  });

  @override
  String toString() {
    return 'Web3EthereumException(code: $code, message: $message, data: $data);';
  }
}
