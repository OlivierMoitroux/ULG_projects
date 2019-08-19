from pacman_module import util

class Node:
    def __init__(self, x, y, dist2Root):
        self.x = x
        self.y = y
        self.distToRoot = dist2Root


class LeeAlgo:
    def __init__(self, gameState):
        self._fringe = util.Queue()
        self._maze = gameState.getWalls()
        self._M, self._N = self._maze.height, self._maze.width
        # Store the explored position in the maze
        self._visited = [[False for y in range(
            self._N)] for x in range(self._M)]
        # Store the set the distance to the root for each food
        self._minDist = {}
        # To explore in the 4 directions
        self._row, self._col = (-1, 0, 0, 1), (0, -1, 1, 0)

    def _isValid(self, i, j, x, y) -> bool:
        # In the maze, not a wall and not yet visited ?
        return (i > 0) and (i < self._M) and (j > 0) and (j < self._N) and (
                self._maze[x][y] is False) and (self._visited[i][j] is False)

    def _reset(self) -> None:
        self._visited = [[False for y in range(
            self._N)] for x in range(self._M)]
        self._fringe = util.Queue()
        self._minDist.clear()

    def _yToi(self, y) -> int:
        # Conversion of position notation to matrix notation (not same axis)
        return self._M - 1 - y

    def _xToj(self, x) -> int:
        # Conversion of position notation to matrix notation (not same axis)
        return x

    def minMazeDistance(self, pacman, food) -> int:
        # Return the minimum distance from pacman (root) to a food
        food2DiscoverInit = len(food)
        food2Discover = len(food)

        node = Node(pacman[0], pacman[1], 0)
        self._fringe.push(node)

        for foodPos in food:
            self._minDist[foodPos] = float("inf")

        while not self._fringe.isEmpty():
            # Basic cut-off for speeding up: useless to explore all the food
            #  in state space
            if food2Discover < food2DiscoverInit/1.5:
                break
            node = self._fringe.pop()
            pos = (node.x, node.y)
            dist = node.distToRoot

            # If a food is discovered:
            if pos in food:
                self._minDist[pos] = dist
                food2Discover -= 1
                # All food discovered ? (not used anymore if cut-off)
                if food2Discover == 0:
                    break
            # Expand in all 4 directions:
            for mov in range(4):
                i = self._yToi(node.y)
                j = self._xToj(node.x)

                newX = node.x + self._row[mov]
                newY = node.y + self._col[mov]

                if self._isValid(self._yToi(newY), self._xToj(newX), newX,
                                 newY):
                    self._visited[i][j] = True
                    self._fringe.push(Node(newX, newY, dist + 1))

        minDist = float("inf")
        for f in food:
            minDist = min(minDist, self._minDist[f])
        self._reset()
        return minDist