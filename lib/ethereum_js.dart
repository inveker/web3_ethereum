part of web3_ethereum;

/// getter JavaScript global object [ethereum]
@JS('ethereum')
external _EthereumJs? get _ethereumJs;

/// Class describing the available properties and methods of the [ethereum] object
@JS()
class _EthereumJs {
  external bool? get isMetaMask;

  external bool? get isCoinbaseWallet;

  external Object request(_RequestArguments args);
}

/// ethereum.request(args) method arguments
@JS()
@anonymous
class _RequestArguments {
  external factory _RequestArguments({required String method, Object? params});

  external String get method;

  external Object? get params;
}