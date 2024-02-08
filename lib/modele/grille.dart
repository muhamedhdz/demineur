import 'dart:math';
import 'package:tp01/modele/case.dart';
import 'package:tp01/modele/coup.dart';

/// [Grille] de démineur
class Grille {
  /// Dimension de la grille carrée : [taille]x[taille]
  final int taille;

  /// Nombre de mines présentes dans la grille
  final int nbMines;

  /// Attribut privé (_), liste composée [taille] listes de chacune [taille] cases
  final List<List<Case>> _grille = [];

  /// Construit une [Grille] comportant [taille] lignes, [taille] colonnes et [nbMines] mines
  Grille({required this.taille, required this.nbMines}) {
    int nbCasesACreer = nbCases; // Le nombre de cases qu'il reste à créer
    int nbMinesAPoser = nbMines; // Le nombre de mines qu'il reste à poser
    Random generateur = Random(); // Générateur de nombres aléatoires
    // Pour chaque ligne de la grille
    for (int lig = 0; lig < taille; lig++) {
      // On va ajouter à la grille une nouvelle Ligne (liste de 'cases')
      List<Case> uneLigne = []; //
      for (int col = 0; col < taille; col++) {
        // S'il reste nBMinesAPoser dans nbCasesACreer, la probabilité de miner est nbMinesAPoser/nbCasesACreer
        // Donc on tire un nombre aléatoire a dans [1..nbCasesACreer] et on pose une mine si a <= nbMinesAposer
        bool isMinee = generateur.nextInt(nbCasesACreer) < nbMinesAPoser;
        if (isMinee) nbMinesAPoser--; // une mine de moins à poser
        uneLigne.add(Case(isMinee)); // On ajoute une nouvelle case à la ligne
        nbCasesACreer--; // Une case de moins à créer
      }
      // On ajoute la nouvelle ligne à la grille
      _grille.add(uneLigne);
    }
    // Les cases étant créées et les mines posées, on calcule pour chaque case le 'nombre de mines autour'
    calculeNbMinesAutour();
  }

  /// Getter qui retourne le nombre de cases
  int get nbCases => taille * taille;

  /// Retourne la [Case] de la [Grille] située à [coord]
  Case getCase(Coordonnees coord) {
    return _grille[coord.ligne][coord.colonne];
  }

  /// Retourne la liste des [Coordonnees] des voisines de la case située à [coord]
List<Coordonnees> getVoisines(Coordonnees coord) {
  List<Coordonnees> listeVoisines = [];

  // Directions possibles autour d'une case
  List<List<int>> directions = [
    [-1, -1], [-1, 0], [-1, 1],
    [0, -1], /* [0, 0], */ [0, 1],
    [1, -1], [1, 0], [1, 1],
  ];

  for (List<int> direction in directions) {
    int voisinLigne = coord.ligne + direction[0];
    int voisinColonne = coord.colonne + direction[1];
    if (voisinLigne >= 0 && voisinLigne < taille && voisinColonne >= 0 && voisinColonne < taille) {
      Coordonnees coord = (ligne: voisinLigne, colonne: voisinColonne);
      listeVoisines.add(coord);
    }
  }
  //print(listeVoisines);
  return listeVoisines;
}

  /// Assigne à chaque [Case] le nombre de mines présentes dans ses voisines
  void calculeNbMinesAutour() {
  //recupérer getVoisines, pour chaque coordonnées, vérifiée si est minee, si oui incrémenter nbMinesAutour
    for (int i = 0; i < taille; i++){
      for (int j = 0; j < taille; j++){
        Coordonnees coord = (ligne: i, colonne: j);
        int nbMinesAutour = 0;
        for (int k = 0; k < getVoisines(coord).length; k++){
          if (getCase(getVoisines(coord)[k]).minee){
            nbMinesAutour++;
          }
        }
        getCase(coord).nbMinesAutour = nbMinesAutour;
      }
    }
  }

  /// - Découvre récursivement toutes les cases voisines d'une case située à [coord]
  /// - La case située à [coord] doit être découverte
  /// - Recursivement, on découvre les voisines de chaque voisine non minée et non découverte
void decouvrirVoisines(Coordonnees coord) {
  Case caseActuelle = getCase(coord);
  if (caseActuelle.etat == Etat.decouverte || caseActuelle.minee) {
    return;
  }

  caseActuelle.decouvrir();
  if (caseActuelle.nbMinesAutour == 0) {
    List<Coordonnees> voisines = getVoisines(coord);
    for (Coordonnees voisin in voisines) {
      Case caseVoisine = getCase(voisin);
      if (caseVoisine.etat != Etat.decouverte && !caseVoisine.minee) {
        decouvrirVoisines(voisin); // Appel récursif
      }
    }
  } else {
  caseActuelle.decouvrir();
  }

}





  /// Met à jour la Grille en fonction du [coup] joué
void mettreAJour(Coup coup) {
  Case caseSelectionnee = getCase(coup.coordonnees);
  if (coup.action == Action.marquer) {
    if (caseSelectionnee.etat == Etat.marquee) {
      caseSelectionnee.etat = Etat.couverte;
    } else if (caseSelectionnee.etat == Etat.couverte) {
      caseSelectionnee.etat = Etat.marquee;
    }
  } else if (coup.action == Action.decouvrir) {
    if (caseSelectionnee.minee) {
      caseSelectionnee.decouvrir();
      print("BOUM ! VOUS AVEZ PERDU !");
      //Stopper la partie
      return;
    } else {
      // Découvrir la case sélectionnée.
      caseSelectionnee.decouvrir();
      // Initier la découverte des voisins seulement si la case n'a pas de mines autour.
      if (caseSelectionnee.nbMinesAutour == 0) {
        List<Coordonnees> voisines = getVoisines(coup.coordonnees);
        for (Coordonnees voisin in voisines) {
          Case caseVoisine = getCase(voisin);
          // Propager la découverte aux voisins non découverts et non minés.
          if (caseVoisine.etat != Etat.decouverte && !caseVoisine.minee) {
            decouvrirVoisines(voisin);
          }
        }
      }
    }
  }
}



  /// Renvoie vrai si [Grille] ne comporte que des cases soit minées soit découvertes (mais pas les 2)
  bool isGagnee() {
    if (isPerdue() == false){
      for (int i = 0; i < taille; i++){
        for (int j = 0; j < taille; j++){
          if (getCase((ligne: i, colonne: j)).minee == false && getCase((ligne: i, colonne: j)).etat != Etat.decouverte){
            return false;
          }
        }
      }
      return true;
    }
    return false;
  }

  /// Renvoie vrai si [Grille] comporte au moins une case minée et découverte
  bool isPerdue() {
    for (int i = 0; i < taille; i++){
      for (int j = 0; j < taille; j++){
        if (getCase((ligne: i, colonne: j)).minee == true && getCase((ligne: i, colonne: j)).etat == Etat.decouverte){
          return true;
        }
      }
    }
    return false;
  }

  /// Renvoie vrai si la partie est finie, gagnée ou perdue
  bool isFinie() {
    if (isGagnee() == true || isPerdue() == true){
      return true;
    } else {
      return false;
    }
  }
}
