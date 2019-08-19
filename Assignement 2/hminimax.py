from pacman_module.game import Agent
from pacman_module.pacman import Directions
# from pacman_module import util
from leeAlgo import LeeAlgo


class PacmanAgent(Agent):

    def __init__(self, args):
        """
        Arguments:
        ----------
        - `args`: Namespace of arguments from command-line prompt.
        """
        self.args = args

        # Stores the already explored nodes.
        # Set because hash functions are faster to retrieve an element (O(1))
        self._visited = set()
        # The associated score, coupled with _visited, is necessary to
        # determine wether or not a new state has interests to be visited. This
        # is true because we use a class variable set for visited. See
        # report for another viable solution.
        self._associatedScore = {}
        self._depth = 0

        # /!\ Small_adv: MAXDEPTH should be = 3 /!\
        # /!\ Medium_adv or large_adv: MAXDEPTH should be = 1 /!\
        # -> See report for explanation
        self._MAXDEPTH = 3

    def _make_node_state(self, gameState):
        return hash((hash(gameState.getPacmanPosition()),
                     hash(gameState.getFood()),
                     hash(gameState.getGhostPosition(1))
                     ))

    def _cutoff_test(self, gameState, depth) -> bool:
        # cut-off or end of game ?
        return gameState.isWin() or gameState.isLose() or depth == 0

    def _evalFct(self, gameState) -> int:
        pacPos = gameState.getPacmanPosition()
        foodList = gameState.getFood().asList()
        score = gameState.getScore()

        if len(foodList) == 0:
            return score

        # Get the minimum real distance to a food
        dist = LeeAlgo(gameState).minMazeDistance(pacPos, foodList)
        return score - dist

    def _evalFct2(self, gameState) -> float:
        algo = LeeAlgo(gameState)
        pacPos = gameState.getPacmanPosition()
        # ghostPos = gameState.getGhostPosition(1)
        foodList = gameState.getFood().asList()
        score = gameState.getScore()
        offset = 2000

        # a) win factor
        if gameState.isWin():
            return score + 100 + offset

        # b) lose factor:
        # elif gameState.isLose():
        #     return score - 100 + offset

        # c) distance to food factor
        minFoodDist = algo.minMazeDistance(pacPos, foodList)
        score -= minFoodDist * 1.5

        # d) number food left factor:
        if len(foodList) > 0:
            score += ((1 / len(foodList)) * 100)

        # e) distance to ghost factor:
        # if util.manhattanDistance(pacPos, ghostPos) < 2:
        #     # runaway:
        #     score -= 20
        return score + offset

    # ------------------------------------------------------------------------

    def _max_value(self, gameState, depth) -> float:

        if self._cutoff_test(gameState, depth):
            return self._evalFct2(gameState)

        v = float("-inf")

        for (succGameState, succAction) in \
                gameState.generatePacmanSuccessors():

            succNodeState = self._make_node_state(succGameState)

            if succNodeState in self._visited and self._associatedScore[
                    succNodeState] >= succGameState.getScore():
                # state already visited and has a less interesting score
                # then the one encountered during the past -> skip the new one
                score = float("-inf")

            else:
                self._visited.add(succNodeState)
                self._associatedScore[succNodeState] = succGameState.getScore()
                score = self._min_value(succGameState, depth)

            v = max(v, score)

        if v == float("-inf"):
            # All sates have already been visited -> sub-tree should be ignored
            return float("+inf")
        return v

    # ------------------------------------------------------------------------

    def _min_value(self, gameState, depth) -> float:

        if self._cutoff_test(gameState, depth):
            return self._evalFct2(gameState)

        v = float("+inf")

        for (succGameState, succAction) in \
                gameState.generateGhostSuccessors(1):

            score = self._max_value(succGameState, depth - 1)
            v = min(v, score)

        if v == float("+inf"):
            # All sates have already been visited -> sub-tree should be ignored
            return float("-inf")
        return v

    # ------------------------------------------------------------------------

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
        depth = self._MAXDEPTH

        try:
            if state.getNumAgents() - 1 != 1:
                raise Exception("One ghost is expected: not more not "
                                "less !")

            v = float("-inf")
            bestMove = Directions.STOP

            for (succGameState, succAction) in \
                    state.generatePacmanSuccessors():
                # At root, clear the history for each branch
                self._visited.clear()
                self._associatedScore.clear()

                # Record the new state
                succNodeState = self._make_node_state(succGameState)
                self._visited.add(succNodeState)
                self._associatedScore[succNodeState] = succGameState.getScore()

                # Choose a direction with highest score
                score = self._min_value(succGameState, depth)
                v = max(v, score)
                bestMove = succAction if v == score else bestMove

            return bestMove

        except Exception as e:
            print(e)

