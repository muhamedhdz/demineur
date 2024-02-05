import 'dart:io';
import 'package:tp01/interface/console_ui.dart';
import 'package:tp01/modele/coup.dart';
import 'package:tp01/modele/grille.dart';

/// Déroulement d'une partie de démineur sur la console
void main(List<String> arguments) async {
  // Saisie des paramètres : taille et nombre de mines (délai pour choisir)
  ParametresGrille params = await saisirParametres();
  // Initialisation de la grille
  Grille laGrille = Grille(taille: params.taille, nbMines: params.nbMines);
  // Pour tester/déboguer : on affiche tout de suite la solution
  afficher(laGrille, montrerSolution: true); // à commenter pour jouer vraiment
  // Déroulement d'une partie
  do {
    afficher(laGrille);
    Coup coup = await saisirCoup(laGrille.taille);
    laGrille.mettreAJour(coup);
    afficherResultat(laGrille);
  } while (!laGrille.isFinie());
  // A la fin on affiche la solution
  afficher(laGrille, montrerSolution: true);
  exit(0);
}
