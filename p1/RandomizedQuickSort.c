/* ========================================================================= *
* Implémentation de QuickSort avec pivot aléatoire
* ========================================================================= */

#include <stddef.h>
#include "Sort.h"
#include <stdlib.h>

static void swap(int*, int, int);
static void quickSort(int*, int, int);
static int randomizedPartition(int*, int, int);

/* ------------------------------------------------------------------------- *
* Fonction principale
* ------------------------------------------------------------------------- */

void sort(int* array, size_t length) {

	if (!array)
		return;

	quickSort(array, 0, (int)length - 1);
}

/* ------------------------------------------------------------------------- *
* Appel récursif du tri : Diviser pour régner
* ------------------------------------------------------------------------- */

static void quickSort(int* array, int debut, int fin) {

	if (debut < fin) {
		// Diviser
		int indicePivot = randomizedPartition(array, debut, fin);
		// Régner
		quickSort(array, debut, indicePivot - 1);
		quickSort(array, indicePivot + 1, fin);
	}
	// Tableau de longueur nulle :
	return;
}

/* ------------------------------------------------------------------------- *
* Sépare le tableau en 2 sous-tableau
* ------------------------------------------------------------------------- */

static int randomizedPartition(int* array, int debut, int fin) {
	
	// Indice aléatoire entre début et fin
	int i = rand() % (fin - debut + 1) + debut; // debut <= i <= fin
	swap(array, fin, i);

	// partition(A,p,r):

	int droite = debut;
	int gauche = debut - 1;
	const int PIVOT = array[fin];

	/* ------------------------------------------------------------------------- *
	* array[fin] est le pivot
	*
	* array[debut...gauche] contient des éléments <= au pivot
	*
	* array[gauche+1...droite-1] contient des éléments > que le pivot
	*
	* array[droite...gauche-1] est la partie du tableau non encore examinée
	* ------------------------------------------------------------------------- */

	while (droite  < fin) {
		if (array[droite] <= PIVOT) {
			gauche = gauche + 1;
			swap(array, gauche, droite);
		}
		droite++;
	}
	swap(array, gauche + 1, fin);
	return gauche + 1;
}

/* ------------------------------------------------------------------------- *
* Echange 2 éléments d'un tableau
* ------------------------------------------------------------------------- */

static void swap(int* array, int indice1, int indice2) {

	int tmp = array[indice1];
	array[indice1] = array[indice2];
	array[indice2] = tmp;
}
