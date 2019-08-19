/* ========================================================================= *
* FindCities2BST.c
* ========================================================================= */

#include<string.h>
#include"BinarySearchTree.h"
#include"City.h"
#include"LinkedList.h"
#include"findCities.h"
#include"intersect.h"

/* ------------------------------------------------------------------------- *
* Compare des réels
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

/* ------------------------------------------------------------------------- *
* Compare des villes en vérifiant leur nom, leur latitude et leur longiture
*
* ARGUMENTS
* a		Un pointeur vers la première ville
* b		Un pointeur ves la seconde ville
*
* RETOURNE
* Un entier tel que
* comparison_cities(cityA, cityB) = 0    <=> cityA = cityB
*
* ------------------------------------------------------------------------- */
static int compare_cities(const void* a, const void* b) {
	const City* cityA = (const City*)a;
	const City* cityB = (const City*)b;
	// Autant tout vérifier
    int compare_name = strcmp(cityA->name, cityB->name);
	if (compare_name != 0)
        return compare_name;
    
    int compare_lat = compare_doubles(&cityA->latitude, &cityB->latitude);
    if(compare_lat != 0)
       return compare_lat;
    
    int compare_long = compare_doubles(&cityA->longitude, &cityB->longitude);
    if(compare_long != 0)
        return compare_long;
    return 0;
}

LinkedList* findCities(LinkedList* cities,
	double latitudeMin,
	double latitudeMax,
	double longitudeMin,
	double longitudeMax) {

	// 1° Stocker les villes dans deux arbres binaires de recherche:

	// Création de l'arbre qui retiendra les latitudes
	BinarySearchTree* treeLat = newBST(&compare_doubles);
	if (!treeLat)
		return NULL;

	// Création de l'arbre qui retiendra les longitudes
	BinarySearchTree* treeLong = newBST(&compare_doubles);
	if (!treeLong)
		return NULL;

	// Remplissage des arbres
	LLNode* curr = cities->head;
	bool error = false;
	const City* city;
	while (!error && curr != NULL) {
		city = (const City*)curr->value;
		error = error ||
			!insertInBST(treeLat, &(city->latitude), (curr->value)) ||
			!insertInBST(treeLong, &(city->longitude), (curr->value)); 
		curr = curr->next;
	}
	if (error) {
		freeBST(treeLat, false);
		freeBST(treeLong, false);
		return NULL;
	}
	
	// 2° Recherche de l'ensemble des villes comprises entre deux latitudes

	LinkedList* filtered_lat = newLinkedList();
	if (!filtered_lat) {
		freeBST(treeLat, false);
		freeBST(treeLong, false);
		return NULL;
	}

	filtered_lat = getInRange(treeLat, &latitudeMin, &latitudeMax);
	if (!filtered_lat) {
		freeBST(treeLat, false);
		freeBST(treeLong, false);
		freeLinkedList(filtered_lat, false);
		return NULL;
	}

	// 3° Recherche de l'ensemble des villes comprises entre deux longitudes
	LinkedList* filtered_long = newLinkedList();
	if (!filtered_long) {
		freeBST(treeLat, false);
		freeBST(treeLong, false);
		freeLinkedList(filtered_lat, false);
		return NULL;
	}

	filtered_long = getInRange(treeLong, &longitudeMin, &longitudeMax);
	if (!filtered_long) {
		freeBST(treeLat, false);
		freeBST(treeLong, false);
		freeLinkedList(filtered_lat, false);
		freeLinkedList(filtered_long, false);
		return NULL;
	}

	// 4° Calculer l'intersection des deux structures

	LinkedList* filtered = newLinkedList();
	if (!filtered) {
		freeBST(treeLat, false);
		freeBST(treeLong, false);
		freeLinkedList(filtered_lat, false);
		freeLinkedList(filtered_long, false);
		return NULL;
	}

	filtered = intersect(filtered_lat, filtered_long, &compare_cities);
		if (!filtered) {
			freeBST(treeLat, false);
			freeBST(treeLong, false);
			freeLinkedList(filtered_lat, false);
			freeLinkedList(filtered_long, false);
			return NULL;
		}
		freeBST(treeLat, false);
		freeBST(treeLong, false);
		freeLinkedList(filtered_lat, false);
		freeLinkedList(filtered_long, false);
	return filtered;
}
