/* ========================================================================= *
* Implémentation de GSort
* ========================================================================= */

#include <stddef.h>
#include "Sort.h"


static void swap(int*, int, int);
static void GSort(int*, int, int);

/* ------------------------------------------------------------------------- *
* Fonction principale
* ------------------------------------------------------------------------- */

void sort(int* array, size_t length) {

	if (!array)
		return;

	GSort(array, 0, (int)length-1); 
}

static void GSort(int* array, int debut, int fin) {
	
	if (debut >= fin)
		return;

	GSort(array, debut, fin - 1);
	if (array[fin - 1] > array[fin]) {
		swap(array, fin, fin - 1);
		GSort(array, debut, fin - 1);
	}
}

/* ------------------------------------------------------------------------- *
* Echange 2 éléments d'un tableau
* ------------------------------------------------------------------------- */

static void swap(int* array, int indice1, int indice2) {

	int tmp = array[indice1];
	array[indice1] = array[indice2];
	array[indice2] = tmp;
}