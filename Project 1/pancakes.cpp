
#include <vector>
#include <algorithm>        // max_element() - copy() - is_sorted()
#include <utility>          // pair<>
#include <iostream>         // Debugging - display to screen
#include <stdexcept>        // domain_error
#include <set>              // openSet
#include <unordered_map>    // closedSet
#include <iterator>         // distance()
#include <map>              // pathRecorder_type

#include"pancakes.hpp"

using namespace std;
typedef stack_type::size_type sz_type;
typedef pair<stack_type, vector<sz_type> > pQEl_type;
typedef multiset<pair<stack_type, vector<sz_type> >, bool(*)(const pQEl_type& , const pQEl_type& )> pQ_type;
typedef unordered_multimap<sz_type, stack_type> closedSet_type;
typedef map<vector<sz_type>, vector<sz_type> > pathRecorder_type;

/** ------------------------------------------------------------------------- *
 * Flips the pancake (integer) "*pivot"  to the bottom of the pancake stack and
 *  add the sequence of flips to be performed for this operation to "flips"
 *
 * PARAMETERS
 * pancakes     The vector of integers (the stack of pancakes) to sort
 * flips        The sequence of flips that have already been performed
 * pivot        The pancake we need to put at the bottom of the stack of pancakes
 *
 * RETURN
 * /
 * ------------------------------------------------------------------------- */
static void flip(stack_type& pancakes, flip_type& flips, const stack_type::iterator pivot,
                  const stack_type::iterator last){

    // Exception should not occur but good practice.
    if(pivot >= pancakes.end()){
        throw domain_error("Flip out of range");
    }

    if(pancakes.size() == 0) // good practise
        throw domain_error("Can't flip an empty stack of pancakes");

    // ex : [1,4,2,0,3] , pivot = pancakes.begin() + 1
    if(pancakes.begin() != pivot){
        reverse(pancakes.begin(), pivot + 1);
        flips.push_back(std::distance(pancakes.begin(), pivot));
    }
    // [4,1,2,0,3]
    reverse(pancakes.begin(), last);
    flips.push_back(std::distance(pancakes.begin(), last) - 1);

    return; // [3,0,2,1,4]
}

/** ------------------------------------------------------------------------- *
 * Sorts a vector of integers (a stack of pancakes) by prefix reversal only.
 *
 * PARAMETERS
 * pancakes     The vector of integers (the stack of pancakes) to sort
 * flips        The sequence of flips that needs to be performed to achieve this goal
 *
 * RETURN
 * /
 *
 * ------------------------------------------------------------------------- */
void simple_pancake_sort(const stack_type& originalPancakes, flip_type& flips){

    if(originalPancakes.size() < 2)
        return; // trivial case

    // No need to check if pancakes are different, the algorithm will work anyway

    // copy the original stack (const) into a non-const vector :
    stack_type pancakes(originalPancakes);

    stack_type::iterator currMax, last;

    for(last = pancakes.end();
        last != pancakes.begin() && !is_sorted(pancakes.begin(), pancakes.end());
         --last){

        currMax = max_element(pancakes.begin(), last);

        if(currMax == pancakes.end() - 1){
            continue; // no flip needed for this iteration
        }
        try{flip(pancakes, flips, currMax, last);}
        catch(exception &e){cerr << "Error while flipping : " << e.what() << endl; return;};
    }
    return;
}

/*
*  ==============================================================================================================
*  ####################################   A* ALGORITHM   ########################################################
*  ==============================================================================================================
*/

/** ------------------------------------------------------------------------- *
 * Generates a Unique IDentifier  that stores all the required informations about
 * a child (NB: 2 identical stacks (vector<int>) won't get the same UID !)
 *
 * PARAMETERS
 * totCost     total cost = real cost + estimated end cost
 * rCost       The number of integers (pancakes) that have already been flipped
 * flipIndex   The index at which the "spatula" has been placed to get to this stack
 *
 * RETURN
 * UID         A vector<sz_type>. Use get_X(UID) to get the "X" information
 *
 * ------------------------------------------------------------------------- */
static std::vector<sz_type> make_UID(const sz_type totCost, const sz_type rCost,
                                     const sz_type flipIndex){
    vector<sz_type> UID = {totCost, rCost, flipIndex};
    return UID;
}

static sz_type get_totCost(const vector<sz_type>& UID){
    return UID[0];
}

static sz_type get_rCost(const vector<sz_type>& UID){
    return UID[1];
}

static sz_type get_flipIndex(const vector<sz_type>& UID){
    return UID[2];
}


/** Predicate function for "openSet", our priority queue */
static bool compare_totCost(const pQEl_type& lhs, const pQEl_type& rhs){
    return get_totCost(lhs.second) < get_totCost(rhs.second);
}

/** ------------------------------------------------------------------------- *
 * Hash function : generates an ID that allows "fast search" in a container.
 * Basically, comparing sz_type is much faster that comparing vectors. This hash
 * improves speed compared to the naive solution i*v[i];i={0,..., n} (less collisions)
 *
 * PARAMETERS
 * v     The stack_type that will be given is own ID
 *
 * RETURN
 * ID    sz_type identifier
 *
 * NB : 2 identical vectors will have the same ID but UNFORTUNATELY, two
 *      identical IDs don't mean that their stack were identical !
 * ------------------------------------------------------------------------- */
static sz_type make_ID(const stack_type& v){
    stack_type::size_type ID = v.size();
    for(auto &i :v){
        ID ^= i + 0x9e3779b9 + (ID << 6) + (ID >> 2);
    }
    return ID;
}

/** ------------------------------------------------------------------------- *
 * Computes the estimated cost of a given stack_type.
 *
 * PARAMETERS
 * v            The stack_type
 * sortedStack  Same size as stack_type but sorted. No need to sort v each time.
 *
 * RETURN
 * estCost      The largest element not in its place compared to the sorted stack
 *
 * ------------------------------------------------------------------------- */
static sz_type compute_estCost(const stack_type& sortedStack, const stack_type& v){

    if(sortedStack.size() != v.size() || v.size() == 0)
        throw domain_error("Can't compute estCost, sizes are incorrect.");

    stack_type::value_type largestNotInPlace = 0;

    for(sz_type i = 0; i <= v.size() - 1 ; ++i ){

        if(v[i] == sortedStack[i])
            continue;
        largestNotInPlace = std::max(largestNotInPlace, v[i]);
    }
    return largestNotInPlace;
}

/** ------------------------------------------------------------------------- *
 * Performs a simple flip at a given index (sz_type)
 *
 * PARAMETERS
 * pancakes     The stack_type
 * flipIndex    sz_type index at which the flip is performed
 *
 * TRHOWS
 * domain_error (Good practice only)
 *
 * ------------------------------------------------------------------------- */
static void flip(stack_type& pancakes, const sz_type flipIndex){

    if(pancakes.size() == 0) // good practise
        throw std::domain_error("Can't flip an empty stack of pancakes");

    if(pancakes.begin() + flipIndex >= pancakes.end()){
        throw domain_error("Flip out of range");
    }

    //ex : [1,4,2,0,3] with flipIndex = 1
    if(flipIndex != 0){
        reverse(pancakes.begin(), pancakes.begin() + 1 + flipIndex);
    }
    return; //[4,1,2,0,3]
}

/** ------------------------------------------------------------------------- *
 * Finds in closedSet if a stack has been already picked once before. If there
 * is a match between IDs, we check if the vectors are equal (imperfect hash)
 *
 * PARAMETERS
 * closedSet    The container closedSet_type that stores already picked children
 * v            The stack_type to search in the closedSet
 *
 * RETURN
 * TRUE/FALSE if found or not
 *
 * ------------------------------------------------------------------------- */
bool is_in_closedSet(const closedSet_type& closedSet, const stack_type& v){

    pair<closedSet_type::const_iterator, closedSet_type::const_iterator> result = closedSet.equal_range(make_ID(v));
    for (closedSet_type::const_iterator it = result.first; it != result.second; ++it){
        if(it->second == v) // in of match, we check if stacks are really identical
            return true;
    }
    return false;
}

/** ------------------------------------------------------------------------- *
 * Builds the flip sequence from the informations stored in the pathRecorder
 *
 * PARAMETERS
 * flips        The flip_type container that will store the flip sequence
 * pathRecorder The container that eventually contains the most efficient previous step
 * currUID      The last picked child that has his stack_type == sortedStack
 *
 * RETURN
 * /
 *
 * ------------------------------------------------------------------------- */
 void build_flips(flip_type& flips, pathRecorder_type& pathRecorder, vector<sz_type>& currUID){

    flips.push_back(get_flipIndex(currUID));
    while(pathRecorder.find(currUID) != pathRecorder.end()){
        currUID = pathRecorder[currUID];
        flips.push_back(get_flipIndex(currUID));
    }
    reverse(flips.begin(), flips.end());
    flips.erase(flips.begin()); // first flip is always zero
    return ;
 }

/** ------------------------------------------------------------------------- *
 * From a given parent, generates all its children and put them in the openSet
 * if they haven't been picked once for exploration.
 *
 * PARAMETERS
 * parentStack      Stack_type of the parent
 * parentUID        UID of the parent
 * sortedPancakes   The target, the sorted stack_type
 * openSet          Container that stores all the children we want to visit
 * closedSet        "Garbage" container that stores already visited children
 *
 * RETURN
 * /
 *
 * ------------------------------------------------------------------------- */
static void generate_children(const stack_type& parentStack,
                              const vector<sz_type>& parentUID,
                              const stack_type& sortedPancakes,
                              pQ_type& openSet,
                              const unordered_multimap<sz_type, stack_type>& closedSet,
                              pathRecorder_type& pathRecorder ){

    stack_type::size_type flipIndex = 1;
    for(; flipIndex != parentStack.size(); ++flipIndex){

        if(flipIndex == get_flipIndex(parentUID))
            continue; // we rebuilt the parent of "parent": nothing to do

        stack_type childStack(parentStack);

        try{
            flip(childStack, flipIndex);

            if(is_in_closedSet(closedSet, childStack)){
                continue;
            }

            int rCostParent = get_rCost(parentUID);
            sz_type childTotCost = rCostParent + flipIndex + 1 + compute_estCost(sortedPancakes, childStack);
            vector<sz_type> childUID = make_UID(childTotCost, rCostParent + flipIndex + 1,
                                                 flipIndex);
            pQEl_type child(childStack, childUID);
            openSet.insert(child);
            // Best path until now -> record it !
            pathRecorder.insert(make_pair(childUID, parentUID));

        }catch(exception &e){cerr << "Error : " << e.what() <<endl;};
    }
    return;
}

/** ------------------------------------------------------------------------- *
 * Returns the best flip sequence that can be performed to sort the pancakes
 * (vector of integers) with use of the A* algorithm
 *
 * PARAMETERS
 * pancakes     The vector of integers (the stack of pancakes) to sort
 * flips        The sequence of flips that needs to be performed to achieve this goal
 *
 * RETURN
 * /
 *
 * NB : Actually, in this implementation, keywords "child" or "children" can 
 * also identy a neighbor or an ancestor because the algorithm can go backward
 * ------------------------------------------------------------------------- */
void astar_pancake_sort(const stack_type& pancakes, flip_type& flips){

    if(pancakes.size() < 2 || is_sorted(pancakes.begin(), pancakes.end()))
        return; // trivial case

    stack_type originalCopy(pancakes);

    // No need to check if pancakes are different, the algorithm will work

    stack_type sortedPancakes(pancakes);
    sort(sortedPancakes.begin(), sortedPancakes.end());

    /*
    * closedSet stores all the children that have been picked because of their lowest cost.
    * Unfortunately, because of the imperfect hash function, we can't use an unordered_set<sz_type>
    * wich would have been much faster ! Thus, we need to keep the stack_type in case of "collision".
    */
    unordered_multimap<sz_type, stack_type> closedSet;

    /*
    * openSet is our priority queue that stores the children in ascending order (% total cost)
    * compare_totCost is passed by reference so that std::multiset can compare correctly keys
    */
    pQ_type openSet(compare_totCost);
    try{
        vector<sz_type> originalCopyUID = make_UID(compute_estCost(sortedPancakes, originalCopy), 0, 0);
        openSet.insert(make_pair(originalCopy, originalCopyUID));
    }catch(exception& e){cerr << " Error while making the first id (root) :" << e.what() << endl; return;};

    // Store (eventually) the most efficient previous step. Don't work with unordered_map unfortunately.
    pathRecorder_type pathRecorder;

    while(!openSet.empty()){

        // Take the child with the lowest totCost
        pQ_type::iterator currParent = openSet.begin();

        vector<sz_type> currParentUID = currParent->second;
        stack_type currParentStack   = currParent->first;

        if(currParentStack == sortedPancakes){
            build_flips(flips, pathRecorder, currParentUID);
            return ;
        }

        openSet.erase(openSet.begin());
        const pair<sz_type, stack_type> tmp(make_ID(currParentStack), currParentStack);
        closedSet.insert(tmp); // Once a node has been picked, insert it in closedSet

        generate_children(currParentStack, currParentUID, sortedPancakes, openSet, closedSet, pathRecorder);
    }
    return; // error status (impossible to sort the stack of pancakes)
}
