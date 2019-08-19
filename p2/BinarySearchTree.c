/* ========================================================================= *
* BinarySearchTree
* ========================================================================= */

#include "BinarySearchTree.h"
#include <stdlib.h> // malloc, free
#include "LinkedList.h"

//------------------------------------------Structures de données--------------------------------------------------------//

/* ------------------------------------------------------------------------- *
* Structure de donnée représentant un noeud de l'arbre binaire de recherche
*
* key		Entier contenant la clef du noeud
* value		La valeur associée au noeud  = data
* left		Le fils gauche du noeud
* right		Le fils droit du noeud
* ------------------------------------------------------------------------- */
typedef struct node_t {	
	const void* key; // la latitude par ex
	const void* value; // la ville par ex
	struct node_t* left;
	struct node_t* right;
}Node; 


/* ------------------------------------------------------------------------- *
* Structure de donnée représentant un arbre binaire de recherche
*
* root				Pointeur vers le noeud racine de l'arbre
* nbreElements		Entier représentant le nombre d'éléments que contient l'arbre
* compare			Une fonction de comparaison
* ------------------------------------------------------------------------- */
struct tree_t {
	Node* root; 
	size_t nbreElements;
	int (*compare)(const void*, const void*);
};

//---------------------------------------------Prototypes----------------------------------------------------------------//

static Node* create_node(const void* data, const void* key);
static Node* tree_maxKey(Node* x);
static Node* tree_minKey(Node* x);
static void freeSubBST(Node* root, bool freeContent);
static void getInSubRange(const BinarySearchTree* bst, Node* node, const void* keyMin, const void* keyMax, LinkedList* ll);


//----------------------------------------Fonctions static---------------------------------------------------------------//

/* ------------------------------------------------------------------------- *
* Crée un noeud en lui associant une clef, une valeur
*
* ARGUMENTS	
* value		La valeur associée au noeud
* key		La clef du nouveau noeud
*
* RETOURNE
* newNode	Le noeud créé contenant les informations fournies en entrée. NULL en cas d'erreur
* ------------------------------------------------------------------------- */
static Node* create_node(const void* value, const void* key) {
	Node* newNode = malloc(sizeof(Node)); //(Node*)malloc
	
	if (newNode == NULL)
		return NULL;
	newNode->key = key;
	newNode->value = value;
	newNode->left = NULL;
	newNode->right = NULL;

	return newNode;
}


/* ------------------------------------------------------------------------- *
* Trouve le noeud avec la plus grande clef de l'arbre
*
* ARGUMENTS
* x			Pointeur vers la racine de l'abre dans lequel on cherche
*
* RETOURNE
* x			Pointeur vers le noeud ayant la plus grande clef
* ------------------------------------------------------------------------- */
static Node* tree_maxKey(Node* x) {
    while (x->right != NULL)
		x = x->right;
	return x;
}


/* ------------------------------------------------------------------------- *
* Trouve le noeud avec la plus petite clef de l'arbre
*
* ARGUMENTS
* x			Pointeur vers la racine de l'arbre dans lequel on cherche
*
* RETOURNE
* x			Pointeur vers le noeud ayant la plus petite clef
* ------------------------------------------------------------------------- */
static Node* tree_minKey(Node* x) {
	while (x->left != NULL)
		x = x->left;
	return x;
}


/* ------------------------------------------------------------------------- *
* Libère l'espace mémoire récursivement occupé par le/les sous-arbre(s) d'un noeud donné
*
* ARGUMENTS
* root			Un pointeur vers le noeud racine du/d'un des sous-arbre(s) qu'il faut supprimer
* freeContent	Valeur booléenne pour la suppression du contenu
*
* RETOURNE
* /		
* ------------------------------------------------------------------------- */
static void freeSubBST(Node* root, bool freeContent) {

	// Node* cursor = root;
	if (root != NULL) {
		// On continue s'il existe encore un sous-abre
		if (root->left != NULL)
			freeSubBST(root->left, freeContent);
		if (root->right != NULL)
			freeSubBST(root->right, freeContent);

		if (freeContent == true) { // opération supplémentaire à effectuer
			if (root->value != NULL && root->key != NULL) {
				free((void*)root->value); // typecasting, exception pour suppression
				free((void*)root->key);
			}
		}
		free(root);
	}
}


/* ------------------------------------------------------------------------- *
* Rajoute récursivement dans la liste liée ll les éléments compris entre keyMin et keyMax dans le bst
*
* ARGUMENTS
* bst			Un pointeur valide vers l'arbre binaire de recherche
* node			Un pointeur vers le noeud racine du/des sous-arbre(s) qu'il faut supprimer
* keyMin		Borne inférieure de l'intervalle de recherche
* keyMax		Borne supérieure de l'intervalle de recherche
* ll			Un pointeur valide vers une liste liée
*
* RETOURNE
* /
* ------------------------------------------------------------------------- */
static void getInSubRange(const BinarySearchTree* bst, Node* node, const void* keyMin, const void* keyMax, LinkedList* ll) {
	if (node != NULL && ll != NULL) {
		if (bst->compare(keyMin, node->key) < 0)
			getInSubRange(bst, node->left, keyMin, keyMax, ll);

		if ((bst->compare(keyMin, node->key) <= 0 && (bst->compare(keyMax, node->key) >= 0))) {
			if (insertInLinkedList(ll, node->value) == false)
				freeLinkedList(ll, false);
		}

		if ((bst->compare(node->key, keyMax) <= 0))
			getInSubRange(bst, node->right, keyMin, keyMax, ll);
	}
}

// --------------------------------------------Fonctions principales-----------------------------------------------------//

BinarySearchTree* newBST(int comparison_fn_t(const void *, const void *)) {
		BinarySearchTree* bst = malloc(sizeof(BinarySearchTree));
		if (bst == NULL)
			return NULL;

		bst->root = NULL;
		bst->nbreElements = 0;
		bst->compare = (comparison_fn_t); //Appel:  &comparison_fn_t 

		return bst;
}


void freeBST(BinarySearchTree* bst, bool freeContent) {

	if (bst != NULL && bst->nbreElements == 0) { // arbre avait été créé mais pas utilisé
		free(bst);
	}
	else if (bst != NULL && bst->root != NULL) { // arbre a été utilisé au min 1X
		if (bst->root->left != NULL)
			freeSubBST(bst->root->left, freeContent); // c'est un type noeud désormais

		if (bst->root->right != NULL)
			freeSubBST(bst->root->right, freeContent);

		free(bst->root);
	}
}


size_t sizeOfBST(const BinarySearchTree* bst) {
	if (bst == NULL)
		return 0;
	return bst->nbreElements;
}


bool insertInBST(BinarySearchTree* bst, const void* key, const void* value) {
		
		if (bst == NULL || key == NULL || value == NULL)
			return NULL;

		Node* cursor = bst->root;
		Node* prev = NULL;

		Node* newNode = create_node(value, key);
		if (newNode == NULL)
			return false;

		while (cursor != NULL) { // tant que l'on est pas au bout de l'arbre
		
			prev = cursor;
			// Si le noeud existe déjà (déjà une valeur attribuée)
			if (bst->compare(newNode->key, cursor->key) < 0)
				cursor = cursor->left;
			else // Plus petit ou égal -> va à droite
				cursor = cursor->right;
		}
		
		if (prev == NULL) {
			// L'arbre était vide
			bst->root = newNode;
		}
		// M.a.j. des structures
		else if (bst->compare(newNode->key,prev->key) < 0)
			prev->left = newNode;
		else
			prev->right = newNode;

		bst->nbreElements++;
		return true;
}


const void* searchBST(BinarySearchTree* bst, const void* key) {
	if (bst->root == NULL || key == NULL)
		return NULL;

	Node* cursor = bst->root;

	// De root jusqu'à la fin:
	while (cursor != NULL && cursor->key != key) {
		if (bst->compare(key, cursor->key) < 0)
			cursor = cursor->left;
		else
			cursor = cursor->right;
	}
	// Si on a pas trouvé
	if (cursor == NULL)
		return NULL;
	// Si on a trouvé
	return cursor->value;
}

LinkedList* getInRange(const BinarySearchTree* bst, void* keyMin, void* keyMax) {
	
	if (bst == NULL || bst->root == NULL) // arbre non-créé ou sans noeud avec de l'information
		return NULL;

	// Initialisation
	Node* node_minKey = tree_minKey(bst->root);
	Node* node_maxKey = tree_maxKey(bst->root);

	if(bst->compare(keyMin,node_maxKey->key) > 0 || bst->compare(keyMax,node_minKey->key) < 0) {
		// Hors interval admissible, retourne liste vide
		return newLinkedList();
	}
	
	else
    {
		LinkedList* ll = newLinkedList();
		// Vérification dans getInSubRange mais autant déjà vérifier ici
		if (ll == NULL)
			return NULL;

		getInSubRange(bst, bst->root, keyMin, keyMax, ll);
		if (ll == NULL)
			return NULL;
		
		return ll;
	}
}
