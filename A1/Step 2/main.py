
import numbers
import numpy as np
import random

# ----------------------------- TOOLBOX ------------------------------------ #


class Grid:
    """
    A simple grid that has its element [0,0] in the bottom left.
    """

    def __init__(self, width, height, initObject):
        self.m = height

        self.n = width
        if type(initObject) is list:
            self.data = np.array(initObject)[::-1]

        elif isinstance(initObject, numbers.Number):
            self.data = np.zeros([width, height])[::-1]
        elif type(initObject) is np.ndarray:
            self.data = initObject
        else:
            raise ValueError('Bad argument, cfr. doc of the class.')

    def __str__(self):
        return str(self.data[::-1])+"\n"

    def __getitem__(self, key):
        return self.data[key[1], key[0]]

    def __setitem__(self, key, score):
        self.data[key[1], key[0]] = score

    def __eq__(self, other):
        if other is None:
            return False
        return self.data == other.data

    def __add__(self, other):
        ret = Grid(self.n, self.m, 0)
        for x in range(self.n):
            for y in range(self.m):
                ret[x, y] = self.data[x, y]+other[x, y]
        return ret


class PolicyGrid:
    def __init__(self, width, height):
        self.n = width
        self.m = height
        # '<U4' to be able to store the largest name of possible actions (down)
        self.data = np.zeros((width, height), dtype='<U4')

    def __str__(self):
        return str(self.data[::-1])

    def __getitem__(self, key):
        return self.data[key[1], key[0]]

    def __setitem__(self, key, dir):
        self.data[key[1], key[0]] = dir

    def __eq__(self, other):
        if other is None:
            return False
        return self.data == other.data

# ----------------------------- POLICIES ----------------------------------- #


def upPolicy(currPos, MOVES):
    """
    A simple stationary policy that always go up
    :param currPos: the current position (not used right now)
    :param MOVES: the action space
    :return: a tuple (dx, dy)
    """
    return MOVES["up"]


# Seeding as no effect
def randPolicy(currPos, MOVES):
    _, move = random.choice(list(MOVES.items()))
    return move


# Seed fix the random sequence for reproducibility
def fRandPolicy(currPos, MOVES):
    dirs = ["up", "left", "right", "down"]
    dir = random.randint(0, 3)
    return MOVES[dirs[dir]]

# ----------------------------- Simulator ---------------------------------- #


class Simulator:
    """
    A class to handle the simulation of a policy on a given grid.
    """
    def __init__(self, width, height, domainInstanceValues, MOVES):
        self.width = width
        self.height = height
        self.rewardGrid = Grid(width, height, domainInstanceValues)
        self.MOVES = MOVES

    def _move(self, currPos, action, deterministic, beta, w_t):
        """
        Perform a move according to the system dynamics.
        :param currPos: [x ,y]
        :param action: (dx, dy)
        :param deterministic: True/False
        :param beta: [0, 1], parameter of the dynamic
        :param w_t: the r.v. drawn in [0, 1] uniformly
        :return: [nextX, nextY]
        """
        (x_t, y_t) = currPos
        (i, j) = action
        (n, m) = self.width, self.height
        if deterministic is True:
            return [min(max(x_t+i, 0), n-1), min(max(y_t+j, 0), m-1)]
        elif deterministic is False and beta is not None:
            if w_t <= 1 - beta:
                return [min(max(x_t+i, 0), n-1), min(max(y_t+j, 0), m-1)]
            else:
                return [0, 0]

    def simulateCell(self, startCell, T, policy, discntFact, t_i=0,
                     cumXpctedReward=0, deterministic=True, beta=0.5,
                     silent=True):
        """
        Return the final position and the cumExpectedReward of a given
        starting cell in the grid by applying a given policy.

        :param startCell: cell of which we want to compute the cum xpct rew.
        :param T: number of time step
        :param policy: a stationary policy (function pointer)
        :param discntFact: gamma/decay factor in [0, 1]
        :param t_i: initial time of simulation
        :param cumXpctedReward: initial expected cum. reward
        :param deterministic: True/False
        :param beta: parameter of the dynamic in [0, 1]
        :param silent: True/False to display (intermediate) results or not
        :return: [position after T, cum. xpct. reward of startCell]
        """
        currCell = startCell
        if t_i == 0:
            action = policy(currCell, self.MOVES)
            [nextX, nextY] = self._move(currCell, action, deterministic,
                                        beta, np.random.uniform())
            cumXpctedReward = self.rewardGrid[nextX, nextY]
            currCell = [nextX, nextY]
            if silent is False:
                print("J at step {}: {}".format(1, cumXpctedReward))
                print("Position after {} time step: ({},{})\n".format(1, nextX,
                                                                      nextY))
            t = 1
        else:
            t = t_i
        while t < T:
            action = policy(currCell, self.MOVES)
            [nextX, nextY] = self._move(currCell, action, deterministic,
                                        beta, np.random.uniform())
            immediate_reward = self.rewardGrid[nextX, nextY]
            cumXpctedReward += immediate_reward * (discntFact ** t)
            if silent is False:
                print("J at step {}: {}".format(t+1, cumXpctedReward))
                print("Position after {} time step: ({},{})\n".format(t+1,
                                                                      nextX,
                                                                      nextY))
            t += 1
            currCell = [nextX, nextY]

        return [currCell, cumXpctedReward]

    def simulateAll(self, t_stop, policy, discntFact, init=None, t_start=0,
                    deterministic=True, beta=0.5, silent=True):
        """
        Return the cumulative expected reward of the entire grid after T
        timesteps.
        :param t_stop: Number of time steps
        :param policy: a stationary policy (function pointer)
        :param discntFact: gamma/decay factor in [0, 1]
        :param init: an initial reward value
        :param t_start: an initial time
        :param deterministic: True/False
        :param beta: parameter of dynamic of the system
        :param silent: True/False to display (intermediate) results or not
        :return: A grid which values are the cumulative expected reward
        after T time steps
        """

        if t_start > t_stop:
            raise ValueError('Start time should be before stop time')

        if t_stop == 0:
            cumXpctdReward = Grid(self.width, self.height, 0)
            if silent is False:
                print("t = {}\n{}".format(t_stop, cumXpctdReward))
            return cumXpctdReward

        elif t_start == 1 or t_start == 0:
            pastCumReward = Grid(self.width, self.height, 0)

        elif t_start > 1 and init is not None:
            pastCumReward = init
        else:
            raise ValueError('Bad argument, cfr. doc of the class.')

        currXpctdReward = Grid(self.width, self.height, 0)

        for t in range(t_start, t_stop + 1):
            w_t = np.random.uniform()
            for y in range(self.height):
                for x in range(self.width):
                    currCell = [x, y]
                    action = policy(currCell, self.MOVES)

                    [nextX, nextY] = self._move(currCell, action,
                                                deterministic, beta, w_t)
                    # Immediate reward
                    immediate_reward = self.rewardGrid[nextX, nextY]

                    if t == 0:
                        rewardSignal = 0

                    elif t == 1:
                        rewardSignal = immediate_reward
                    else:
                        r_past = pastCumReward[nextX, nextY]
                        rewardSignal = immediate_reward + discntFact * r_past

                    currXpctdReward[x, y] = rewardSignal

            pastCumReward = currXpctdReward
            if silent is False:
                print("t = {}:".format(t))
                print(currXpctdReward, "\n")
        return currXpctdReward

    def _notReachable(self, nextCell, currCell, action):
        return self._move(currCell, action, True, 0, 0) != nextCell

    def transitionProb(self, nextCell, currCell, action, beta=0.0):
        """
        Compute p(x'|x, u) = p(nextCell, currCell, action)
        :param nextCell: x'
        :param currCell: x
        :param action: u in format [dx, dy]
        :param beta: param of dynamics in [0, 1]
        :return: the transition probability
        """

        if self._notReachable(nextCell, currCell, action):
            if nextCell == [0, 0]:
                p = beta
            else:
                p = 0
        else:
            if nextCell == [0, 0]:
                p = 1
            else:
                p = 1-beta
        return p

    def rewardFun(self, currCell, action, beta=0.0):
        """
        Compute r(x, u)
        :param currCell: x
        :param action: u in format [dx, dy]
        :param beta: param of dynamics in [0, 1]
        :return: r
        """
        [nextX, nextY] = self._move(currCell, action, True, 0, 0)
        return (1-beta)*self.rewardGrid[nextX, nextY] + (
            beta)*self.rewardGrid[0, 0]

    def simumateQ(self, cell, action, t_i, maxQ_past,
                  discntFact, beta=0.0):
        """
        Compute Q_N
        :param cell: x
        :param action: u in format [dx, dy]
        :param t_i: init time
        :param maxQ_past: prev value for d.p.
        :param discntFact: gamma
        :param beta: param of dynamics in [0, 1]
        :return: Q_N
        """
        if t_i == 0:
            return 0
        elif t_i == 1:
            Q = self.rewardFun(cell, action, beta=beta)
            return Q

        sum = 0
        r = self.rewardFun(cell, action, beta=beta)
        for nextX in range(self.width):
            for nextY in range(self.height):
                p = self.transitionProb([nextX, nextY], cell, action,
                                        beta=beta)
                q = maxQ_past[nextX, nextY]
                sum += p * q
        return r + discntFact*sum

    def simumateEstQ(self, cell, action, t_i, maxQ_past, hist, discntFact):
        """
        Compute the estimation of Q
        :param cell: x
        :param action: u in format [dx, dy]
        :param t_i: init time
        :param maxQ_past: previous result (d.p.)
        :param discntFact: gamma
        :param beta: param dynamic in [0, 1]
        :return: max Q_N over u
        """
        if t_i == 0:
            return 0
        elif t_i == 1:
            Q = self.estReward(cell, action, hist)
            return Q

        sum = 0
        r = self.estReward(cell, action, hist)
        for nextX in range(self.width):
            for nextY in range(self.height):
                p = self.estTransitionProb([nextX, nextY], cell, action, hist)
                q = maxQ_past[nextX, nextY]
                sum += p * q
        return r + discntFact*sum

    def buildRandTrajectory(self, startCell, T, MOVES, deterministic=True,
                            beta=0.3, seed=8080):
        """
        Build a plausible trajectory via a random policy
        :param startCell: the starting state x_0
        :param T: length of trajectory
        :param MOVES: dictionnary of allowed moves
        :param deterministic: True/False
        :param beta: parameter of dynamics in [0, 1]
        :param seed: a ranom seed to replicate results
        :return: h = [[x_0, u_0, r_0], ..., [x_t]]
        """
        hist = []
        currCell = startCell
        dirs = ["up", "left", "right", "down"]
        random.seed(seed)

        # t = 0
        actionStr = dirs[random.randint(0, 3)]
        [nextX, nextY] = self._move(currCell, MOVES[actionStr], deterministic,
                                    beta, np.random.uniform())
        hist.append([currCell, actionStr, self.rewardGrid[nextX, nextY]])
        currCell = [nextX, nextY]

        for t in range(1, T):
            actionStr = dirs[random.randint(0, 3)]
            [nextX, nextY] = self._move(currCell, MOVES[actionStr],
                                        deterministic, beta,
                                        np.random.uniform())
            immediate_reward = self.rewardGrid[nextX, nextY]
            hist.append([currCell, actionStr, immediate_reward])
            currCell = [nextX, nextY]

        # List of list to ease coding in estTransition()
        hist.append([[nextX, nextY]])
        return hist

    def buildRandTrajectories(self, N_traj, T, MOVES, deterministic=True,
                              beta=0.3):
        """
        Return a global unrealistic trajectory that is the result of the
        concatenation of several smaller ones, each of length T.
        :param N_traj: number of trajectories
        :param T: length of a trajectory
        :param MOVES: Set of allowed actions
        :param deterministic: True/False
        :param beta: param. of dynamics in [0, 1]
        :return: a global trajectory
        """
        listHist = []
        for n in range(N_traj):
            startCell = [random.randint(0, self.width - 1),
                         random.randint(0, self.height - 1)]
            hist = self.buildRandTrajectory(startCell, T, MOVES,
                                            deterministic, beta, n)[:-1]
            listHist = listHist + hist
        return listHist

    def estReward(self, cell, action, hist):
        """
        Estimate the reward r(x, u) = r(cell, action) thanks to history hist
        :param cell: x
        :param action: u
        :param hist: h
        :return: estimation of reward
        """

        rew = 0
        cnt = 0
        # [:-1] to avoid last element (x_t) that is a shorter tuple
        for t, tuple in enumerate(hist[:-1]):
            cell_t = tuple[0]
            action_t = tuple[1]
            reward_t = tuple[2]
            if cell_t == cell and action_t == action:
                rew += reward_t
                cnt += 1
        if cnt == 0:
            return 0
        else:
            return rew/cnt

    def estTransitionProb(self, nextCell, cell, action, hist):
        """
        Estimate p(nextCell|cell, action) thanks to the history hist
        :param nextCell: x'
        :param cell: x
        :param action: u
        :param hist: h
        :return: estimation of transition probability in [0, 1]
        """

        succesfullTransition = 0
        interestingTransition = 0

        # [:-1] to avoid last element (x_t) that is a shorter tuple
        for t, tuple in enumerate(hist[:-1]):
            cell_t = tuple[0]
            action_t = tuple[1]
            nextCell_t = hist[t+1][0]
            if cell_t == cell and action_t == action:
                interestingTransition += 1
                if nextCell_t == nextCell:
                    succesfullTransition += 1
        if interestingTransition == 0:
            return 0
        else:
            return succesfullTransition/interestingTransition


def question2(discntFact, deterministic):
    print("-----")
    print("Q2: Simulation of upPolicy starting in [0, 0]")
    simulator.simulateCell([0, 0], T, upPolicy, discntFact,
                           deterministic=deterministic, silent=False)
    print("-----\n")


def question3(simulator, discntFact, n_sim):

    width = simulator.width
    height = simulator.height

    print("Q3: Evolution of J for the entire grid")
    print("a) Deterministic setting:")
    simulator.simulateAll(T, upPolicy, discntFact,
                          deterministic=True, silent=False)

    print("b) Stochastic setting:")
    prevExpJ = Grid(width, height, 0)
    for t in range(1, T):
        print("t={}".format(t))
        sum = np.zeros([width, height])
        for n_test in range(n_sim):
            J = simulator.simulateAll(t, upPolicy, discntFact, t_start=t,
                                      init=prevExpJ, deterministic=False,
                                      silent=True)
            sum += J.data
        mean = sum / n_sim
        prevExpJ = Grid(width, height, mean)
        print(prevExpJ)


def question4(simulator, T, MOVES, discntFact, beta, silentStep=False):
    width, height = simulator.width, simulator.height
    # to store previous result for max(Q_N-1)
    prev = Grid(width, height, 0)
    optPolicy = PolicyGrid(width, height)
    for t in range(T + 1):
        for y in range(height):
            for x in range(width):
                maxV = float("-inf")
                bestDir = ""
                for action in MOVES:
                    Q = simulator.simumateQ([x, y], MOVES[action], t, prev,
                                            discntFact, beta=beta)
                    if Q > maxV:
                        maxV = Q
                        bestDir = action
                prev[x, y] = maxV
                optPolicy[x, y] = bestDir
        if silentStep == False:
            print("t={}\nJ:\n{}\nu:\n{}\n\n".format(t, prev, optPolicy))
    # Even if flag silent is set to True, display the final result
    if silentStep is True:
        print("t={}\nJ:\n{}\nu:\n{}\n\n".format(T, prev, optPolicy))
    return prev, optPolicy


def question5(simulator, T, MOVES, discntFact, hist, silentStep=False):
    width, height = simulator.width, simulator.height
    # Store previous result (max(Q_N-1))
    prev = Grid(width, height, 0)
    optPolicy = PolicyGrid(width, height)
    for t in range(T + 1):
        for y in range(height):
            for x in range(width):
                maxV = float("-inf")
                bestDir = ""
                for action in MOVES:
                    Q = simulator.simumateEstQ([x, y], action, t, prev,
                                               hist, discntFact)
                    if Q > maxV:
                        # Found a new best action
                        maxV = Q
                        bestDir = action
                prev[x, y] = maxV
                optPolicy[x, y] = bestDir
        if silentStep is False:
            print("t={}\nJ:\n{}\nu:\n{}\n\n".format(t, prev, optPolicy))
    # Even if flag silent is set to True, display the final result
    if silentStep is True:
        print("t={}\nJ:\n{}\nu:\n{}\n\n".format(T, prev, optPolicy))
    return prev, optPolicy


if __name__ == '__main__':

    np.set_printoptions(formatter={'float': lambda x: "{0:0.4f}".format(x)})

    '''State space parameter'''
    # Action space
    MOVES = {'right': (1, 0), 'left': (-1, 0), 'up': (0, 1), 'down': (0, -1)}

    # Number of time Steps
    T = 500

    # Discount factor (gamma)
    discntFact = 0.99

    beta = 0.2

    '''Init. Instance of problem'''
    # Dimensions
    width = 5
    height = 5
    domainInstanceValues = [[-3, 1, -5, 0, 19],
                            [6, 3, 8, 9, 10],
                            [5, -8, 4, 1, -8],
                            [6, -9, 4, 19, -5],
                            [-20, -17, -4, -3, 9]
                            ]

    print("Domain instance:\n{}".format(Grid(5, 5, domainInstanceValues)))
    simulator = Simulator(width, height, domainInstanceValues, MOVES)

    # '''Q2: Unit test'''
    # print("Deterministic setting:")
    # question2(discntFact, True)
    # print("Stochastic setting:")
    # question2(discntFact, False)


    # '''Q3: Expected return of a policy'''
    # question3(simulator, discntFact, 1000)

    simulator.buildRandTrajectories(3, 10, MOVES, True)

    """Q4: Optimal policy"""
    print("Question 4: ")
    print("Deterministic setting:")
    question4(simulator, T, MOVES, discntFact, 0, silentStep=True)
    print("Stochastic setting:")
    question4(simulator, T, MOVES, discntFact, beta, silentStep=True)

    """Q5: system identification"""
    print("\n--------------------\n")
    print("Question 5:")
    print("Deterministic setting:")
    hist = simulator.buildRandTrajectory([width - 1, height - 1], 500, MOVES,
                                         deterministic=True, seed=890)
    question5(simulator, T, MOVES, discntFact, hist, silentStep=True)

    print("Stochastic setting:")
    hist = simulator.buildRandTrajectory([width - 1, height - 1], 500, MOVES,
                                         deterministic=False, beta=beta, seed=890)
    question5(simulator, T, MOVES, discntFact, hist, silentStep=True)

    # Unit tests for Q5
    # ------------------

    # random.seed(8080)
    # dirs = ["up", "left", "right", "down"]
    # for i in range(5):
    #     print(fRandPolicy(0, MOVES))

    # histStocha = simulator.buildRandHistory([0, 0], 900, MOVES, seed=890,
    #                                   deterministic=False, beta=0.3)
    # hist = simulator.buildRandHistory([0, 0], 900, MOVES, seed=890)
    # print(hist)
    # print(simulator.estReward([1, 1], "up", histStocha))
    # print(simulator.estTransitionProb([1, 1], [0, 1], "right", histStocha))
