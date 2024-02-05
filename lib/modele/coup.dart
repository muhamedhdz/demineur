import 'package:tp01/modele/case.dart';

/// [Action] qu'on peut jouer sur une [Case]
enum Action { decouvrir, marquer }

/// [Coup] joué
class Coup {
  Coordonnees coordonnees;
  Action action;

  Coup(int lig, int col, this.action)
      : coordonnees = (ligne: lig, colonne: col);
}
