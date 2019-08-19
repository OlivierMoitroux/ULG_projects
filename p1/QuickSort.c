/* ========================================================================= *
* Impl�mentation de QuickSort
* ========================================================================= */

#include <stddef.h>
#include "Sort.h"


static void swap(int*, int, int);
static int partition(int*, int, int);
static void quickSort(int*, int, int);


/* ------------------------------------------------------------------------- *
* Fonction principale
* ------------------------------------------------------------------------- */

void sort(int* array, size_t length) {

	if (!array)
		return;

	quickSort(array, 0, (int)length - 1);
}


/* ------------------------------------------------------------------------- *
* Appel r�cursif du tri : Diviser pour r�gner
* ------------------------------------------------------------------------- */

static void quickSort(int* array, int debut, int fin) {

	if (debut < fin) {
		// Diviser
		int indicePivot = partition(array, debut, fin);
		// R�gner
		quickSort(array, debut, indicePivot - 1);
		quickSort(array, indicePivot + 1, fin);
	}
	// Tableau de longueur nulle :
	return;
}


/* ------------------------------------------------------------------------- *
* S�pare le tableau en 2 sous-tableau
* ------------------------------------------------------------------------- */

static int partition(int* array, int debut, int fin) {

	int droite = debut;
	int gauche = debut - 1;
	const int PIVOT = array[fin];

	/* ------------------------------------------------------------------------- *
	* array[fin] est le pivot
	*
	* array[debut...gauche] contient des �l�ments <= au pivot
	*
	* array[gauche+1...droite-1] contient des �l�ments > que le pivot
	*
	* array[droite...gauche-1] est la partie du tableau non encore examin�e
	* ------------------------------------------------------------------------- */
	
	// Boucle while, plus clair
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
* Echange 2 �l�ments d'un tableau
* ------------------------------------------------------------------------- */

static void swap(int* array, int indice1, int indice2) {

	int tmp = array[indice1];
	array[indice1] = array[indice2];
	array[indice2] = tmp;
}
