# ------------------------------------------------------------------
#                           A* Search
#                           *********
# This pacman agent uses the A* algorithm in order to
#  determine a sequence of move to eat all the capsules.
#
# @Author Pierre Hockers, Olivier Moitroux
# @Credits: Berkeley pacman project and ULiège
# ------------------------------------------------------------------

from pacman_module.game import Agent
from pacman_module.pacman import Directions
from pacman_module import util
from math import sqrt


class PacmanAgent(Agent):

    def __init__(self, args):
        """
        Arguments:
        ----------
        - `args`: Namespace of arguments from command-line prompt.
        """

        self.args = args

        # Priority queue items are paths. The last element of the path is the
        # state of a node
        self._ucsPriorQueue = util.PriorityQueue()

        # Stores the sequence of moves to perform
        self._moveSeq = None

        # Stores the already explored nodes. Set because hash functions are way
        # faster to retrieve an element (O(1))
        self._visited = set()

    def _buildMoveSeq(self, state) -> None:

        # Put initial state in path (list of <gameState, direction>).
        # The direction is stored to retrieve easily the sequence of move
        # that leads to this state afterwards.
        path = [(state, Directions.STOP)]

        # The queue stores a series of paths with associated priority
        self._ucsPriorQueue.push(path, 0)

        while not self._ucsPriorQueue.isEmpty():

            # Priority is the current node (of the tree) cost
            (currPathCost, path) = self._ucsPriorQueue.pop()

            # Retrieve the state (of the node != gameState) which is at the
            # last position of the path
            currNode = path[len(path) - 1]  # tuple <gameState, direction>
            currGameState = currNode[0]

            # Check the goal: every capsule eaten
            if currGameState.getNumFood() == 0:
                # Use the path (node of the search tree) to build the sequence
                # of moves
                for node in path:
                    # append direction
                    self._moveSeq.append(node[1])

                # Remove the useless initial move
                self._moveSeq.remove(Directions.STOP)
                return  # <=> Won

            # We define a state by being a pair <position, matrixOfFood>
            currState = (
            currGameState.getPacmanPosition(), currGameState.getFood())
            if currState not in self._visited:
                self._visited.add(currState)

                for successor in currGameState.generatePacmanSuccessors():
                    # State of the successor never met
                    if (successor[0].getPacmanPosition(),
                        successor[0].getFood()) not in self._visited:
                        successorPath = path.copy()

                        # Computation of the costs (priority) of the successor
                        succCost = self._computeSuccCost2(currPathCost,
                                                          successor[0])
                        heuristic = self._getDistHeuristic(successor[0])
                        totalPrior = succCost + heuristic

                        successorPath.append((successor[0], successor[1]))
                        self._ucsPriorQueue.push(successorPath, totalPrior)
        raise Exception("Prior. Queue empty: no solution found")

    # Simple, just count the number of food remaining in order to try to reduce
    #  it
    def _getSimpleHeurisitic(self, currGameState):
        return currGameState.getNumFood()

    # Based on the distance from the food dots to pacman
    def _getDistHeuristic(self, currGameState):
        foodMap = currGameState.getFood()
        pacman = currGameState.getPacmanPosition()
        totalOfDist = 0
        for x, row in enumerate(foodMap):
            for y, isFood in enumerate(row):
                if isFood is True:
                    dist = self._manhattanDistance(x, y, pacman[0], pacman[1])
                    totalOfDist += dist
        return sqrt(totalOfDist)

    # Computes the euclidian distance between two points
    def _euclidianDistance(self, x, y, x2, y2):
        tmp = abs(x - x2) * abs(x - x2) + abs(y - y2) * abs(y - y2)
        dist = sqrt(tmp)
        return dist

    # Computes the manhattan distance between two points
    def _manhattanDistance(self, x, y, x2, y2):
        return abs(util.manhattanDistance((x, y), (x2, y2)))

    # Adds the inverse of the successor'scost to the cost of the path (simple
    # but not that good and slow)
    def _computeSuccCost(self, currPathCost, succState):
        succScore = succState.getScore()
        if succScore == 0:
            return currPathCost
        else:
            return currPathCost - 1 / succState.getScore()

    # Uses the opposite of the score (simple and effective)
    def _computeSuccCost2(self, currPathCost, succState):
        return currPathCost - succState.getScore()

    # Manually attribute points to certain situations (slow)
    def _computeSuccCost3(self, currPathCost, succState):
        # Earns 10 points but make one move
        foodBonus = -9

        # Looses one move
        noFoodBonus = 1

        pos = succState.getPacmanPosition()

        if succState.hasFood(pos[0], pos[1]):
            return currPathCost + foodBonus
        else:
            return currPathCost + noFoodBonus

    # Adds one to the cost (same as bfs, optimal but very slow)
    def _computeSuccCost4(self, currPathCost, succState):
        return currPathCost + 1

    def get_action(self, state):
        """
        Given a pacman game state, returns a legal move.

        Arguments:
        ----------
        - `state`: the current game state. See FAQ and class
                   `pacman.GameState`.

        Return:
        -------
        - A legal move as defined in `game.Directions`.
        """
        try:
            # First call to get_action
            if self._moveSeq is None:
                self._moveSeq = []
                self._buildMoveSeq(state)
                # In order to just pop() the next dir. at each future call
                # (not much impact on perf. anyway)
                self._moveSeq.reverse()
        except Exception as e:
            print(e)

        if len(self._moveSeq) == 0:
            print(
                "ERROR: the move sequence is empty while game not won nor lost")
            return Directions.STOP

        return self._moveSeq.pop()
