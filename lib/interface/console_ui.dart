import 'dart:io';
import 'dart:async';
import 'package:tp01/modele/case.dart';
import 'package:tp01/modele/coup.dart';
import 'package:tp01/modele/grille.dart';
// Les éléments importés devront être préfixés par stdin_async (as)
import 'package:tp01/interface/stdin_async.dart';

// Tailles MIN et MAX de la grille
const tailleMin = 2;
const tailleMax = 10;
// Caractère affiché selon l'état de la case
const caseVide = ' ';
const caseMinee = 'B';
const caseMarquee = 'M';
const caseCouverte = '*';
// Délai maximum pour répondre (en secondes)
const delaiMax = 10;

/// Record pour représenter la taille d'une grille et son nombre de mines
typedef ParametresGrille = ({int taille, int nbMines});

/// Saisie asynchrone sur [stdin] de la taille et du nombre de mines
/// - Si pas de saisie au bout de [delaiMax], on utilise des valeurs par défaut
/// - Le résultat est renvoyé sous forme de record
Future<ParametresGrille> saisirParametres() async {
  stdout.writeln("vous avez $delaiMax secondes pour répondre.");
  // saisir la taille
  int taille;
  do {
    stdout.write("Taille de la grille [$tailleMin..$tailleMax] : ");
    try {
      String reponse = await saisirLigneAvecDelai(
          delai: delaiMax, valeurApresDelai: "$tailleMax");
      taille = int.parse(reponse);
    } catch (e) {
      taille = 0;
    }
  } while (taille < tailleMin || taille > tailleMax);
  // saisir le nombre de mines
  int nbMines;
  do {
    stdout.write("\nNombre de mines     [1..${taille * taille - 1}] : ");
    try {
      String reponse = await saisirLigneAvecDelai(
          delai: delaiMax, valeurApresDelai: "$taille");
      nbMines = int.parse(reponse);
    } catch (e) {
      nbMines = 0;
    }
  } while (nbMines < 1 || nbMines > taille * taille - 1);
  // On affiche les valeurs saisies (ou obtenues par défaut)
  stdout.write("\nTaille de la grille : $taille - Nombre de mines : $nbMines");
  return (taille: taille, nbMines: nbMines); // On retourne un record
}

/// - Saisie asynchrone sur [stdin] du coup d'un joueur :
/// - deux entiers ligne,colonne compris entre 0 et taille-1
/// - un caractère pour l'action : d (découvrir) ou m (marquer)
Future<Coup> saisirCoup(int taille) async {
  int ligne, colonne;
  String action;
  stdout.writeln();
  do {
    stdout.write("Quelle ligne jouez-vous   [0..${taille - 1}] : ");
    try {
      ligne = int.parse(await saisirLigne());
    } catch (e) {
      ligne = -1;
    }
  } while (ligne < 0 || ligne >= taille);
  do {
    stdout.write("Quelle colonne jouez-vous [0..${taille - 1}] : ");
    try {
      colonne = int.parse(await saisirLigne());
    } catch (e) {
      colonne = -1;
    }
  } while (colonne < 0 || colonne >= taille);
  do {
    stdout.write("Quelle action jouez-vous  [d|m]  : ");
    action = (await saisirLigne()).toLowerCase();
  } while (action != 'd' && action != 'm');
  return Coup(ligne, colonne,
      (action == 'd' || action == 'D') ? Action.decouvrir : Action.marquer);
}

/// - Affiche sur [stdout] la [grille]
/// - Montrant la solution si [montrerSolution]
void afficher(Grille grille, {bool montrerSolution = false}) {
  stdout.writeln();
  afficherNumeroColonnes(grille.taille);
  afficheLigneSeparatrice(grille.taille);
  for (int ligne = 0; ligne < grille.taille; ligne++) {
    stdout.write("$ligne ");
    for (int colonne = 0; colonne < grille.taille; colonne++) {
      stdout.write('|');
      // On récupère la case en coordonnée {ligne,colonne} et on l'affiche
      Case laCase = grille.getCase((ligne: ligne, colonne: colonne));
      if (montrerSolution) {
        afficherSolution(laCase);
      } else {
        afficherJeu(laCase);
      }
    }
    stdout.writeln('|');
    afficheLigneSeparatrice(grille.taille);
  }
}

/// Affiche le résultat selon l'état de la [grille] après un coup joué
void afficherResultat(Grille grille) {
  if (grille.isPerdue()) {
    stdout.writeln("\nBOUM ! VOUS AVEZ PERDU !");
  } else {
    if (grille.isGagnee()) {
      stdout.writeln("\nBRAVO ! VOUS AVEZ GAGNE !");
    } else {
      stdout.writeln("\nIl faut continuer à déminer...");
    }
  }
}

/// Affiche sur [stdout] les numéros de colonne entre 0 et [taille]
void afficherNumeroColonnes(int taille) {
  // afficher les numéros de colonne
  stdout.write("  ");
  for (int colonne = 0; colonne < taille; colonne++) {
    stdout.write(' $colonne');
  }
  stdout.writeln();
}

/// Affiche sur [stdout] une ligne séparatrice de longueur [taille] entre deux lignes de la grille
void afficheLigneSeparatrice(int taille) {
// afficher ligne séparatrice horizontale
  stdout.write("  ");
  for (int colonne = 0; colonne < taille; colonne++) {
    stdout.write("+-");
  }
  stdout.writeln("+");
}

/// Affiche [laCase] sur [stdout] en mode "jeu" (cache le contenu si non découverte)
void afficherJeu(Case laCase) {
  // Afficher le contenu d'une case en mode "jeu"
  switch (laCase.etat) {
    case Etat.couverte:
      stdout.write(caseCouverte);
      break;
    case Etat.marquee:
      stdout.write(caseMarquee);
      break;
    case Etat.decouverte:
      if (laCase.nbMinesAutour > 0) {
        stdout.write(laCase.nbMinesAutour);
      } else {
        stdout.write(caseVide);
      }
  }
}

/// Affiche [laCase] sur [stdout] en mode "solution" (montre les bombes)
void afficherSolution(Case laCase) {
  // Afficher le contenu d'une case en mode "solution"
  if (laCase.minee) {
    stdout.write(caseMinee);
  } else if (laCase.nbMinesAutour > 0) {
    stdout.write(laCase.nbMinesAutour);
  } else {
    stdout.write(caseVide);
  }
}
