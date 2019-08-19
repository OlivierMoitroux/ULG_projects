/* ========================================================================= *
 * intersect.c
 * ========================================================================= */
#include"LinkedList.h"
#include"City.h"
#include"intersect.h"
#include"BinarySearchTree.h"

// /!\ `a` and `b` peuvent avoir des adresses mémoires différents mais tout de même représenter la même ville

LinkedList* intersect(const LinkedList* listA, const LinkedList* listB,
                      int comparison_fn_t(const void *, const void *)) {
    
    BinarySearchTree* tree = newBST(comparison_fn_t);
    if (!tree)
        return NULL;
    
    // On "stocke" la liste chaînée A dans un arbre pour diminuer la complexité
    for (LLNode* cursorA = listA->head; cursorA != NULL; cursorA = cursorA->next) {
        if (insertInBST(tree, cursorA->value, cursorA->value) == false) {
            freeBST(tree, false);
            return NULL;
        }
    }
    
    LinkedList* intersection = newLinkedList();
    if (intersection == NULL) {
        freeBST(tree, false);
        return NULL;
    }
    
    
    const void* searchResult;
    
    for (LLNode* cursorB = listB->head; cursorB != NULL; cursorB = cursorB->next) {
        searchResult = searchBST(tree, cursorB->value);
        if (searchResult != NULL) {
            if (insertInLinkedList(intersection, searchResult) == false) {
                freeBST(tree, false);
                freeLinkedList(intersection, false);
                return NULL;
            }
        }
    }
    return intersection;
}
