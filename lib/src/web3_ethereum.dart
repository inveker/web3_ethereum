import 'dart:async';

import 'package:js/js.dart';
import 'package:js/js_util.dart';
import 'package:web3_ethereum/src/exceptions.dart';

part 'ethereum_js.dart';
part 'utils.dart';

/// Facade to ethereum JavaScript object
class Web3Ethereum {
  /// If the [ethereum] object is present, then the user has a web3 wallet
  static bool get isInstalled => _ethereumJs != null && (_ethereumJs!.isMetaMask ?? false);

  /// Getting an ethereum object.
  /// Use it only after getting true from Web3Ethereum.isSupported
  _EthereumJs get _ethereum => isInstalled ? _ethereumJs! : (throw Exception('Web3Ethereum not supported on this platform'));

  /// Controller that dispatches events when the accountsChanged event fires
  final StreamController<List<String>> _accountChangedController = StreamController.broadcast();

  /// Controller that dispatches events when the chainChanged event fires
  final StreamController<int> _chainChangedController = StreamController.broadcast();

  /// Broadcast stream from accountsChanged events
  Stream<List<String>> get accountChangedStream => _accountChangedController.stream;

  /// Broadcast stream from chainChanged events
  Stream<int> get chainChangedStream => _chainChangedController.stream;

  /// Constructor
  Web3Ethereum() {
    // Init event handlers
    if(isInstalled) {
      _ethereum.on('accountsChanged', (List<String> accounts) {
        _accountChangedController.add(accounts);
      });
      _ethereum.on('chainChanged', (int chainId) {
        _chainChangedController.add(chainId);
      });
    }
  }

  /// Call ethereum.request(args)
  /// Processes input parameters by casting them to vanilla JavaScript entities
  Future<T> request<T>(String method, {List? params}) async {
    try {
      return await promiseToFuture<T>(_ethereum.request(_RequestArguments(
        method: method,
        params: _parseDartParamsToJs(params ?? []),
      )));
    } catch(e) {
      final error = e as _RequestError;
      throw Web3EthereumException(
        code: error.code,
        message: error.message,
        data: error.data,
      );
    }
  }

  /// Gets the id of the current chain
  /// returns [chainId]
  Future<int> getChainId() async {
    return int.parse((await request('eth_chainId')).toString());
  }

  /// Sends a request to connect to the wallet
  /// returns [accounts]
  /// If the client is not connected, a wallet pop-up window will open asking you to confirm the connection
  /// If the client is already connected, the function will simply return a list of addresses
  Future<List<String>> connect() async {
    final accounts = await request<List<dynamic>>('eth_requestAccounts');
    return accounts.cast<String>();
  }

  /// Gets a list of available wallet addresses
  /// returns [accounts]
  Future<List<String>> getAccounts() async {
    final accounts = await request<List<dynamic>>('eth_accounts');
    return accounts.cast<String>();
  }

  /// Checks if the client is connected to the wallet
  Future<bool> isConnected() async {
    final accounts = await getAccounts();
    return accounts.isNotEmpty;
  }
}
