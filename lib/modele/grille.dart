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
    // A compléter
    return listeVoisines;
  }

  /// Assigne à chaque [Case] le nombre de mines présentes dans ses voisines
  void calculeNbMinesAutour() {
    // A Corriger
    for (int lig = 0; lig < taille; lig++) {
      for (int col = 0; col < taille; col++) {
        _grille[lig][col].nbMinesAutour = 0;
      }
    }
  }

  /// - Découvre récursivement toutes les cases voisines d'une case située à [coord]
  /// - La case située à [coord] doit être découverte
  void decouvrirVoisines(Coordonnees coord) {
    // A Compléter
  }

  /// Met à jour la Grille en fonction du [coup] joué
  void mettreAJour(Coup coup) {
    // A Compléter
  }

  /// Renvoie vrai si [Grille] ne comporte que des cases soit minées soit découvertes (mais pas les 2)
  bool isGagnee() {
    // A Corriger
    return false;
  }

  /// Renvoie vrai si [Grille] comporte au moins une case minée et découverte
  bool isPerdue() {
    // A Corriger
    return false;
  }

  /// Renvoie vrai si la partie est finie, gagnée ou perdue
  bool isFinie() {
    // A Corriger
    return false;
  }
}
