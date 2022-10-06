import 'dart:convert';

import 'package:js/js.dart';
import 'package:js/js_util.dart';
import 'package:web3_ethereum/src/exceptions.dart';
import 'package:web3_ethereum/src/wallet_types.dart';

part 'ethereum_js.dart';
part 'utils.dart';

/// Facade to ethereum JavaScript object
class Web3Ethereum {
  /// If the [ethereum] object is present, then the user has a web3 wallet
  static bool get isSupported => _ethereumJs != null;

  /// Default constructor
  /// If the ethereum object is not available on the page, it will throw an exception
  Web3Ethereum() {
    if(!isSupported) {
      throw Exception('ethereum not found on page');
    }
  }

  /// Getting an ethereum object.
  /// Use it only after getting true from Web3Ethereum.isSupported
  _EthereumJs get _ethereum => _ethereumJs!;

  /// Call ethereum.request(args)
  /// Processes input parameters by casting them to vanilla JavaScript entities
  Future<T> request<T>(String method, {List? params}) async {
    try {
      return await promiseToFuture<T>(_ethereum.request(_RequestArguments(
        method: method,
        params: _parseDartParamsToJs(params ?? []),
      )));
    } catch(error) {
      final parsedError = _ParsedError(error as _RequestError);
      throw Web3EthereumException(
        code: parsedError.code,
        message: parsedError.message,
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

  /// Asks the ethereum object what type of wallet
  /// retruns [walletType]
  Web3EthereumWalletTypes getWalletType() {
    if (_ethereum.isMetaMask ?? false) return Web3EthereumWalletTypes.metamask;
    if (_ethereum.isCoinbaseWallet ?? false) return Web3EthereumWalletTypes.coinbase;
    return Web3EthereumWalletTypes.undefined;
  }
}
