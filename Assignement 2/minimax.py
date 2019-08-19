from pacman_module.game import Agent
from pacman_module.pacman import Directions


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

    def _make_node_state(self, gameState):
        return hash((hash(gameState.getPacmanPosition()),
                     hash(gameState.getFood()),
                     hash(gameState.getGhostPosition(1))
                     ))

    def _terminal_test(self, gameState) -> bool:
        # end of game ?
        return gameState.isWin() or gameState.isLose()

    def _utilFct(self, gameState):
        return gameState.getScore()

    # ------------------------------------------------------------------------

    def _max_value(self, gameState) -> float:

        if self._terminal_test(gameState):
            return self._utilFct(gameState)

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
                score = self._min_value(succGameState)

            v = max(score, v)

        if v == float("-inf"):
            # All sates have already been visited -> sub-tree should be ignored
            return float("+inf")

        return v

    # ------------------------------------------------------------------------

    def _min_value(self, gameState) -> float:

        if self._terminal_test(gameState):
            return self._utilFct(gameState)

        v = float("+inf")
        for (succGameState, succAction) in \
                gameState.generateGhostSuccessors(1):

            score = self._max_value(succGameState)
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
                score = self._min_value(succGameState)
                v = max(v, score)
                bestMove = succAction if v == score else bestMove

            return bestMove

        except Exception as e:
            print(e)
