/* ========================================================================= *
* FindCities1BST.c
* ========================================================================= */

#include"BinarySearchTree.h"
#include"City.h"
#include"LinkedList.h"
#include "findCities.h"


/* ------------------------------------------------------------------------- *
* Compare des réels (double)
*
* ARGUMENTS
* a		Un pointeur vers le premier réel
* b		Un pointeur ves le second réel
*
* RETOURNE
* Un entier
*
* comparison_doubles(a, b) < 0    <=> a < b
* comparison_doubles(a, b) = 0    <=> a == b
* comparison_doubles(a, b) > 0    <=> a > b
*
* ------------------------------------------------------------------------- */
static int compare_doubles(const void* a, const void* b) {
	const double* a_ = (const double*)a;
	const double* b_ = (const double*)b;
	return (*a_ > *b_) - (*a_ < *b_);
}


LinkedList* findCities(LinkedList* cities,
	double latitudeMin,
	double latitudeMax,
	double longitudeMin,
	double longitudeMax) {

	// 1° Stocker les villes en utilisant la latitude comme clé

	BinarySearchTree* tree = newBST(&compare_doubles);
	if (!tree)
		return NULL;

	LLNode* curr = cities->head; 
	bool error = false;
	const City* city;
	while (!error && curr != NULL) {
		city = (const City*)curr->value;
		error = error || !insertInBST(tree, &(city->latitude), (curr->value));
		curr = curr->next;
	}
	if (error) {
		freeBST(tree, false);
		return NULL;
	}

	// 2° rechercher toutes les villes comprises entre 2 latitudes

	LinkedList* notFiltered = newLinkedList();
	if (!notFiltered) {
		freeBST(tree, false);
		return NULL;
	}

	notFiltered = getInRange(tree, &latitudeMin, &latitudeMax);
	if (!notFiltered) {
		freeBST(tree, false);
		freeLinkedList(notFiltered, false);
		return NULL;
	}

	// 3° filtrer la liste liée pour ne garder que les villes comprises entre deux longitudes
	// copie sélective dans une nouvelle liste

	LinkedList* filtered = newLinkedList();
	if (!filtered) {
		freeBST(tree, false);
		freeLinkedList(notFiltered, false);
		return NULL;
	}

	for (LLNode* cursor = notFiltered->head; cursor != NULL; cursor = cursor->next) {
		city = (const City*)cursor->value;
		if (compare_doubles(&city->longitude, &longitudeMin) >= 0 &&
			compare_doubles(&city->longitude, &longitudeMax) <= 0) {

			if (insertInLinkedList(filtered, cursor->value) == false) {
				freeBST(tree, false);
				freeLinkedList(notFiltered, false);
				freeLinkedList(filtered, false);
				return NULL;
			}
		}
	}
	freeBST(tree, false);
	freeLinkedList(notFiltered, false);

	return filtered;
}
