import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Un flux de lignes provenant [stdin] qui peut être écouté de façon asynchrone
Stream<String> _stdinLineStreamBroadcaster = stdin
    .transform(utf8.decoder)
    .transform(const LineSplitter())
    .asBroadcastStream();

/// Lit une ligne sur [stdin] de façon asynchrone
Future<String> saisirLigne() async {
  var lineCompleter = Completer<String>();
  var listener = _stdinLineStreamBroadcaster.listen((line) {
    if (!lineCompleter.isCompleted) {
      lineCompleter.complete(line);
    }
  });
  return lineCompleter.future.then((line) {
    listener.cancel();
    return line;
  }).whenComplete(() => listener.pause());
}

/// - Saisie d'une ligne sur [stdin]
/// - Si au bout de [delai] secondes rien n'a été tapé, renvoie [timeOutValue]
Future<String> saisirLigneAvecDelai(
    {required int delai, required String valeurApresDelai}) async {
  return await saisirLigne().timeout(Duration(seconds: delai), onTimeout: () {
    return valeurApresDelai;
  });
}
