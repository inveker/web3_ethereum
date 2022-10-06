part of 'web3_ethereum.dart';

/// Converts request parameters from darts language to vanilla javascript
/// List destruction is used to convert to JavaScript Array
Object _parseDartParamsToJs(List<dynamic> params) {
  return [
    ...params.where(_nullToUndefinedFilter).map((param) {
      if (param is Map) return _mapToJSObj(param);
      if (param is List) return [...param.where(_nullToUndefinedFilter)];
      return param;
    })
  ];
}

/// Creates a vanilla literal JavaScript object from a Dart Map
/// And removes empty fields
Object _mapToJSObj(Map<dynamic, dynamic> a) {
  var object = newObject();
  a.forEach((k, v) {
    var key = k;
    var value = v;
    if (_nullToUndefinedFilter(value)) {
      setProperty(object, key, value);
    }
  });
  return object;
}

/// Used to remove null values from query arguments
/// because JavaScript expects undefined, not null for undeclared value.
bool _nullToUndefinedFilter(dynamic item) {
  return item != null;
}

/// Convert JS object to Dart object to avoid type error.
class _ParsedError {
  final int code;
  final String message;

  _ParsedError._({
    required this.code,
    required this.message,
  });

  factory _ParsedError(_RequestError error) {
    final matches = RegExp(r'\{.*\}').firstMatch(error.message);
    final group = matches?.group(0);

    if(group == null) {
      return _ParsedError._(
        code: error.code,
        message: error.message,
      );
    } else {
      final result = json.decode(group);
      print(error.message);
      print(result);
      if (result['value']?['data']?['code'] == null || result['value']?['data']?['message'] == null) {
        throw Exception('Web3Ethereum: _parseErrorMessagefailure');
      }
      return _ParsedError._(
        code: result['value']['data']['code']!,
        message: result['value']['data']['message']!,
      );
    }
  }
}
