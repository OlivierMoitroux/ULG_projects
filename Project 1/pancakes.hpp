
/* ========================================================================= *
 * Sorting by prefix reversal interface
 * ========================================================================= */

#ifndef _PANCAKES_HPP_
#define _PANCAKES_HPP_

#include <vector>

typedef std::vector<int> stack_type;
typedef std::vector<stack_type::size_type> flip_type;

void simple_pancake_sort(const stack_type& pancakes, flip_type& flips);

void astar_pancake_sort(const stack_type& pancakes, flip_type& flips);

#endif // _PANCAKES_HPP_
