/* ========================================================================= *
* Implémentation de HeapSort
* ========================================================================= */

#include <stddef.h>
#include "Sort.h"

static void makeHeap(int*, int);
static void maxHeapify(int*, int, int);
static void swap(int*, int, int);

/* ------------------------------------------------------------------------- *
* Fonction principale
* ------------------------------------------------------------------------- */

void sort(int* array, size_t length) {

	if (!array)
		return;

	const int SIZEARRAY = (int)length;

	makeHeap(array, SIZEARRAY);

	// Extrait un élément du tas (un par un)
	for (int heapSize = SIZEARRAY - 1; heapSize >= 0; heapSize--) {

		// Bouger la racine à la fin
		swap(array, heapSize, 0);

		// Restaurer la propriété de tas sur le tas réduit
		maxHeapify(array, 0, heapSize);
	}
}

/* ------------------------------------------------------------------------- *
* Construction du tas (réarrangement du tableau)
* ------------------------------------------------------------------------- */

static void makeHeap(int* array, int SIZEARRAY) {

	int i;
	for (i = SIZEARRAY / 2 - 1; i >= 0; i--) { 
		maxHeapify(array, i, SIZEARRAY);
	}
}

/* ------------------------------------------------------------------------- *
* Restaure la propriété de tas d'un sous-arbre "enracinné" au noeud n°i (appelé root)
* ------------------------------------------------------------------------- */

static void maxHeapify(int* array, int root, int heapSize) {

	int largest = root;  // Initialise largest à root
	int left = 2 * root + 1;  // left = 2*i + 1
	int right = 2 * root + 2;  // right = 2*i + 2

	// Si fils gauche > root
	if (left < heapSize && array[left] > array[largest])
		largest = left;
	// else largest = root;

	// Si fils droit > largest jusque là
	if (right < heapSize && array[right] > array[largest])
		largest = right;

	// Si largest n'est pas la racine (root)
	if (largest != root) {
		swap(array, root, largest);

		// Restaure la propriété de tas
		maxHeapify(array, largest, heapSize);
	}
}


/* ------------------------------------------------------------------------- *
* Echange 2 elements d'un tableau
* ------------------------------------------------------------------------- */

static void swap(int* array, int indice1, int indice2) {

	int tmp = array[indice1];
	array[indice1] = array[indice2];
	array[indice2] = tmp;
}
