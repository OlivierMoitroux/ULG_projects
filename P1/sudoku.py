import numpy as np

def SudokuEntr(grid):

    totalEntr = 0
    # subGrids is a array of array, whose elements are the 3*3 subGrids of the
    # main sudoku game. subGrids[0,0] is therefore the upper left 3*3 subgrid
    subGrids = [[grid[0:3, 0:3], grid[0:3, 3:6], grid[0:3, 6:9]],
                [grid[3:6, 0:3], grid[3:6, 3:6], grid[3:6, 6:9]],
                [grid[6:9, 0:3], grid[6:9, 3:6], grid[6:9, 6:9]]]

    # going through the grid
    for i in range(9):
        for j in range(9):

            seen = []
            case = grid[i, j]

            # if the case is empty, we look into it
            if case == 0:

                # check for element on the line
                for element in grid[i,:]:
                    if element not in seen and element != 0:
                        seen.append(element)
                # check for element in the colon
                for element in grid[:,j]:
                    if element not in seen and element != 0:
                        seen.append(element)

                # check for elements in the subgrid the case is part of
                i2 = int(i/3)
                j2 = int(j/3)
                for vector in subGrids[i2][j2]:
                    for element in vector:
                        if element not in seen and element != 0:
                            seen.append(element)

                unseen = 9-len(seen)
                numbProba = 1/unseen
                caseEntropy = -numbProba*unseen*np.log2(numbProba)
                totalEntr += caseEntropy


    return totalEntr


if __name__ == '__main__':

    grid = np.load('sudoku.npy')
    print(grid)
    print("H = {} Shannon".format(SudokuEntr(grid)))

