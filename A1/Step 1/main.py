
import numbers
import numpy as np

# ----------------------------- TOOLBOX ------------------------------------ #


class Grid:
    """
    A simple grid that has its element [0,0] in the bottom left.
    """

    def __init__(self, width, height, initObject):
        self.n = width
        self.m = height

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

# ----------------------------- POLICIES ----------------------------------- #


def upPolicy(currPos, MOVES):
    """
    A simple stationary policy that always go up
    :param currPos: the current position (not used right now)
    :param MOVES: the action space
    :return: a tuple (dx, dy)
    """
    return MOVES["up"]

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

    def _rewardFun(self, grid, nextPos):
        return grid[nextPos[0], nextPos[1]]

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


if __name__ == '__main__':

    '''State space parameter'''
    # Action space
    MOVES = {'right': (1, 0), 'left': (-1, 0), 'up': (0, 1), 'down': (0, -1)}

    # Number of time Steps
    T = 4

    # Discount factor (gamma)
    DISCNTFACT = 0.99

    BETA = 0.8

    '''Init. Instance of problem'''
    # Dimensions
    WIDTH = 5
    HEIGHT = 5
    domainInstanceValues = [[-3, 1, -5, 0, 19],
                            [6, 3, 8, 9, 10],
                            [5, -8, 4, 1, -8],
                            [6, -9, 4, 19, -5],
                            [-20, -17, -4, -3, 9]
                            ]

    print("Domain instance:\n{}".format(Grid(5, 5, domainInstanceValues)))
    simulator = Simulator(WIDTH, HEIGHT, domainInstanceValues, MOVES)

    '''Q2: Unit test'''
    # @see test.py
    print("-----")
    print("Q2: Simulation of upPolicy starting in [0, 0]")
    simulator.simulateCell([0, 0], T, upPolicy, DISCNTFACT,
                           deterministic=True, silent=False)
    print("-----\n")

    '''Q3: Expected return of a policy'''
    print("Q3: Evolution of J for the entire grid")
    print("a) Deterministic setting:")
    simulator.simulateAll(T, upPolicy, DISCNTFACT,
                          deterministic=True, silent=False)

    print("b) Stochastic setting:")
    prevExpJ = Grid(WIDTH, HEIGHT, 0)
    N_SIM = 1000
    for t in range(1, T):
        print("t={}".format(t))
        sum = np.zeros([WIDTH, HEIGHT])
        for n_test in range(N_SIM):
            J = simulator.simulateAll(t, upPolicy, DISCNTFACT, t_start=t,
                                      init=prevExpJ, deterministic=False,
                                      silent=True)
            sum += J.data
        mean = sum / N_SIM
        prevExpJ = Grid(WIDTH, HEIGHT, mean)
        print(prevExpJ)
