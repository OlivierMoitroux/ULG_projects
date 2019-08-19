/* ========================================================================= *
* FindCitiesZBST.c
* ========================================================================= */

#include<stdlib.h>
#include"BinarySearchTree.h"
#include"City.h"
#include"LinkedList.h"
#include"findCities.h"
#include"zscore.h"

/* ------------------------------------------------------------------------- *
* Compare des entiers uint64_t, indépendant du système)
*
* ARGUMENTS
* a		Un pointeur vers le premier entier
* b		Un pointeur ves le second entier
*
* RETOURNE
* Un entier tel que :
*
* comparison_ints(a, b) < 0    <=> a < b
* comparison_ints(a, b) = 0    <=> a == b
* comparison_ints(a, b) > 0    <=> a > b
*
* ------------------------------------------------------------------------- */
static int compare_uint64_t(const void* a, const void* b) {
	const uint64_t* a_ = (const uint64_t*)a;
	const uint64_t* b_ = (const uint64_t*)b;
	return (*a_ > *b_) - (*a_ < *b_);
}

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

	BinarySearchTree* tree = newBST(&compare_uint64_t);
	if (!tree)
		return NULL;

	// 1° Création arbre binaire avec pour clef le résultat de zEncode()

	LLNode* curr = cities->head;
	bool error = false;
	LinkedList* Zlist = newLinkedList();
    if (!Zlist) {
        freeBST(tree, false);
        return NULL;
    }
    uint64_t* Ztmp;
	const City* city;

	while (!error && curr != NULL) {
		city = (const City*)curr->value;
        Ztmp = malloc(sizeof(uint64_t));
        if (!Ztmp) {
            freeBST(tree, false);
            freeLinkedList(Zlist, true);
            return NULL;
        }
		*Ztmp = zEncode(city->latitude, city->longitude);
		error = error || !insertInLinkedList(Zlist, Ztmp) || !insertInBST(tree, Ztmp, curr->value);
		curr = curr->next;
	}
	if (error) {
        freeLinkedList(Zlist, true);
		freeBST(tree, false);
		return NULL;
	}

	// 2° Recherche de toutes les villes dont les clés sont comprises entre zEncode(lat_min, long_min)
	// et zEncode(lat_max, long_max)

	LinkedList* notFiltered = newLinkedList();
	if (!notFiltered) {
        freeLinkedList(Zlist, true);
		freeBST(tree, false);
		return NULL;
	}

	uint64_t Z_min = zEncode(latitudeMin, longitudeMin);
	uint64_t Z_max = zEncode(latitudeMax, longitudeMax);

	notFiltered = getInRange(tree,&Z_min, &Z_max);
	if (!notFiltered) {
        freeLinkedList(Zlist, true);
		freeBST(tree, false);
		freeLinkedList(notFiltered, false);
		return NULL;
	}

	// 3° Filtrer la liste liée pour ne garder que les bonnes villes

	LinkedList* filtered = newLinkedList();
	if (!filtered) {
        freeLinkedList(Zlist, true);
		freeBST(tree, false);
		freeLinkedList(notFiltered, false);
		return NULL;
	}
	// City* city;
	for (LLNode* cursor = notFiltered->head; cursor != NULL; cursor = cursor->next) {
		city = (const City*)cursor->value;
		if (compare_doubles(&city->longitude, &longitudeMin) >= 0 &&
			compare_doubles(&city->longitude, &longitudeMax) <= 0 &&
            compare_doubles(&city->latitude, &latitudeMin) >= 0 &&
            compare_doubles(&city->latitude, &latitudeMax) <= 0) {

			if (insertInLinkedList(filtered, cursor->value) == false) {
                freeLinkedList(Zlist, true);
				freeBST(tree, false);
				freeLinkedList(notFiltered, false);
				freeLinkedList(filtered, false);
				return NULL;
			}
		}
	}
    freeLinkedList(Zlist, true);
	freeBST(tree, false);
	freeLinkedList(notFiltered, false);
	return filtered;
}
