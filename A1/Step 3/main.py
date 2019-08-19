
import numbers
import numpy as np
import random
import matplotlib.pyplot as plt
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

def exploratoryPolicy(QList, currPos, MOVES, eps):
    dirs = ["up", "left", "right", "down"]

    if random.uniform(0, 1) < eps:
        dir = random.randint(0, 3)
        return MOVES[dirs[dir]]
    else:
        bestDir = None
        max = float("-inf")
        for actionNo, Q in enumerate(QList):
            if Q[currPos[0], currPos[1]] > max:
                max = Q[currPos[0], currPos[1]]
                bestDir = actionNo
        return MOVES[dirs[bestDir]]



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
        # Order is not preserver with python < 3.6 -> take care to always use
        # this list to retrieve the string of an action based on a (
        # random) integer index so that everything should be consistent.
        self.dirs = ["up", "left", "right", "down"]#list(MOVES.keys())
        self.nDir = len(MOVES)

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
        starting cell in the grid by applying a given policy. Q3

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
        timesteps. Q3
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
        Compute p(x'|x, u) = p(nextCell, currCell, action) for Q4, Q5
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
        Compute Q_N with MDP of the domain (Q4)
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
        Compute the estimation of Q with a MDP structure (Q5) thanks to a
        trajectory
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

    def buildRandTrajectory(self, startCell, T, deterministic=True,
                            beta=0.3, seed=None):
        """
        Build a plausible trajectory via a random policy
        :param startCell: the starting state x_0
        :param T: length of trajectory
        :param deterministic: True/False
        :param beta: parameter of dynamics in [0, 1]
        :param seed: a ranom seed to replicate results. /!\ Only applies to
        the action sequence, the noise w_t is let free !
        :return: h = [[x_0, u_0, r_0], ..., [x_t]]
        actions u_k are strings ("up", "down", ...)
        """
        hist = []
        currCell = startCell

        if seed is not None:
            random.seed(seed)

        # t = 0
        actionStr = self.dirs[random.randint(0, 3)]
        [nextX, nextY] = self._move(currCell, self.MOVES[actionStr],
                                    deterministic, beta, np.random.uniform())
        hist.append([currCell, actionStr, self.rewardGrid[nextX, nextY]])
        currCell = [nextX, nextY]

        for t in range(1, T):
            actionStr = self.dirs[random.randint(0, 3)]
            [nextX, nextY] = self._move(currCell, self.MOVES[actionStr],
                                        deterministic, beta,
                                        np.random.uniform())
            immediate_reward = self.rewardGrid[nextX, nextY]
            hist.append([currCell, actionStr, immediate_reward])
            currCell = [nextX, nextY]

        # List of list to ease coding in estTransition()
        hist.append([[nextX, nextY]])
        return hist


    def buildRandTrajectory2(self, startCell, T, deterministic=True,
                            beta=0.3, seed=None):
        """
        Build a plausible trajectory via a random policy
        :param startCell: the starting state x_0
        :param T: length of trajectory
        :param deterministic: True/False
        :param beta: parameter of dynamics in [0, 1]
        :param seed: a ranom seed to replicate results. /!\ Only applies to
        the action sequence, the noise w_t is let free !
        :return: h = [[x_0, u_0, r_0, x_1], ..., [x_t-1, u_t-1, r_t-1, x_t]]
        action u_k are actionNo used to dereference self.dirs
        """
        hist = []
        currCell = startCell

        if seed is not None:
            random.seed(seed)
        # t = 0
        actionNo = random.randint(0, 3)
        actionStr = self.dirs[actionNo]
        [nextX, nextY] = self._move(currCell, self.MOVES[actionStr],
                                    deterministic, beta, np.random.uniform())
        hist.append([currCell, actionNo, self.rewardGrid[nextX, nextY],
                     [nextX, nextY]])
        currCell = [nextX, nextY]

        for t in range(1, T):
            actionNo = random.randint(0, 3)
            actionStr = self.dirs[actionNo]
            [nextX, nextY] = self._move(currCell, self.MOVES[actionStr],
                                        deterministic, beta,
                                        np.random.uniform())
            immediate_reward = self.rewardGrid[nextX, nextY]
            hist.append([currCell, actionNo, immediate_reward, [nextX,
                                                                 nextY]])
            currCell = [nextX, nextY]
        return hist

    def buildRandTrajectories(self, nTraj, T, deterministic=True,
                              beta=0.3, startCell=None, seed=None):
        """
        Return a global unrealistic trajectory that is the result of the
        concatenation of several smaller ones, each of length T. Built with
        a random policy. Actions are encoded as strings
        :param nTraj: number of trajectories
        :param T: length of a trajectory
        :param deterministic: True/False
        :param beta: param. of dynamics in [0, 1]
        :return: a global trajectory
        """
        listHist = []

        randStart = True
        if startCell is not None:
            randStart = False

        for n in range(nTraj):
            if randStart is True:
                startCell = [random.randint(0, self.width - 1),
                             random.randint(0, self.height - 1)]
            hist = self.buildRandTrajectory(startCell, T,
                                            deterministic=deterministic,
                                            beta=beta,  seed=seed)[:-1]
            listHist = listHist + hist
        return listHist

    def buildRandTrajectories2(self, nTraj, T, deterministic=True,
                               beta=0.2, startCell=None, seed=None):
        """
        Return a global unrealistic trajectory that is the result of the
        concatenation of several smaller ones, each of length T. Built with
        a random policy. Action are encoded as numbers
        :param nTraj: number of trajectories
        :param T: length of a trajectory
        :param deterministic: True/False
        :param beta: param. of dynamics in [0, 1]
        :param startCell: a common startcell for the trajectories.
        Otherwise, random for each one.
        :return: a global trajectory
        """
        listHist = []
        randStart = True
        if startCell is not None:
            randStart = False
        seed = None
        for n in range(nTraj):
            if randStart is True:
                startCell = [random.randint(0, self.width - 1),
                             random.randint(0, self.height - 1)]
            hist = self.buildRandTrajectory2(startCell, T,
                                             deterministic=deterministic,
                                             beta=beta, seed=seed)
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
        Estimate p(nextCell|cell, action) thanks to the history hist. Q4, Q5
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

    def q_learning(self, globalTraj, expReplay, discntFact, alpha,
                   batchSize=None):
        """
        Return a list of length = number of direction, each element being an
        estimation Q(x) for its given index = u = direction
        :param globalTraj: a single trajectory (list of 4 tuples) or a set
        of trajectories concatenated.
        :param expReplay: True/False
        :param discntFact: gamma
        :param alpha: learning rate
        :return: list of lenght = number of direction containing estimations
        of Q
        """

        # Initialisation, t = 0
        # Init a list of Q(x) of length equal to the number of directions.
        estQList = [Grid(self.width, self.height, 0) for u in range(self.nDir)]
        k = 0
        t = len(globalTraj)

        if type(alpha) is not np.ndarray:
            tmp = np.empty(t)
            tmp.fill(alpha)
            alpha = tmp

        if (expReplay is True) and (batchSize is None):
            batchSize = 1
        elif expReplay is False:
            batchSize = 1

        while k != t:

            if expReplay is False:
                tuple = globalTraj[k]
            else:
                # Sample in the population of trajectories
                j = random.randint(0, t-1)
                tuple = globalTraj[j]
            [[x, y], actionNo, rew, [nextX, nextY]] = tuple
            currMax = float("-inf")
            # For each possible action
            for u in range(self.nDir):
                currMax = max(currMax, estQList[u][nextX, nextY])

            estQList[actionNo][x, y] = (1-alpha[k])*estQList[actionNo][x, y]\
                                     + alpha[k]*(rew+discntFact*currMax)

            k += batchSize
        return estQList

    def q_learning_dynamic(self, globalTraj, estQList, k, t_max,
                           expReplay, discntFact, alpha, batchSize=None):
        # Initialisation, t = 0, k= 0, estQList = [Grid(self.width, self.height, 0) for u in range(self.nDir)]
        if (expReplay is False) or (batchSize is None):
            batchSize = 1
        alreadyTook = []
        b = 0

        indexUpdated = []

        while b < batchSize and k < t_max:
            if expReplay is False:
                tuple = globalTraj[k]
            else:
                j = random.randint(0, t_max-1)
                while j in alreadyTook:
                    j = random.randint(0, t_max-1)
                alreadyTook.append(j)
                tuple = globalTraj[j]

            [[x, y], actionNo, rew, [nextX, nextY]] = tuple
            currMax = float("-inf")
            # For each possible action
            for u in range(self.nDir):
                currMax = max(currMax, estQList[u][nextX, nextY])

            estQList[actionNo][x, y] = (1 - alpha) * estQList[actionNo][x, y] \
                                       + alpha * (rew + discntFact * currMax)
            b += 1
            k += 1
            indexUpdated.append([[x, y], actionNo])
        return estQList, indexUpdated

# ------------------------- Question solver -------------------------------- #

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


def question4(simulator, T, discntFact, beta, silentStep=False):
    """Deterministic chosen by putting beta=0"""

    width, height = simulator.width, simulator.height
    # to store previous result for max(Q_N-1)
    prev = Grid(width, height, 0)
    optPolicy = PolicyGrid(width, height)

    listQ_N = [Grid(simulator.width, simulator.height, 0) for u in range(
        simulator.nDir)]

    for t in range(T + 1):
        for y in range(height):
            for x in range(width):
                maxV = float("-inf")
                bestDir = ""
                for actionNo, actionStr in enumerate(simulator.dirs):
                    Q = simulator.simumateQ([x, y], simulator.MOVES[
                        actionStr], t, prev, discntFact, beta=beta)
                    if Q > maxV:
                        maxV = Q
                        bestDir = actionStr
                    # Last step, store the Q(x, u)
                    if t == T:
                        listQ_N[actionNo][x, y] = Q
                prev[x, y] = maxV
                optPolicy[x, y] = bestDir
        if silentStep == False:
            print("t={}\nJ:\n{}\nu:\n{}\n\n".format(t, prev, optPolicy))
    # Even if flag silent is set to True, display the final result
    if silentStep is True:
        print("t={}\nJ:\n{}\nu:\n{}\n\n".format(T, prev, optPolicy))

    # return the [expected cum rew with optimal policy, optimal policy, Q(x,u)]
    return prev, optPolicy, listQ_N


def question5(simulator, T, discntFact, hist, silentStep=False):
    width, height = simulator.width, simulator.height
    # Store previous result (max(Q_N-1))
    prev = Grid(width, height, 0)
    optPolicy = PolicyGrid(width, height)
    for t in range(T + 1):
        for y in range(height):
            for x in range(width):
                maxV = float("-inf")
                bestDir = ""
                for action in simulator.MOVES:
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


def question6(simulator, startCell, nTraj, lengthTraj, expReplay, alpha,
              discntFact, deterministic, beta, batchSize=None, silent=False,
              silentListEstQ=True):

    listOfTraj = simulator.buildRandTrajectories2(nTraj, lengthTraj,
                                                  deterministic, beta=beta,
                                                  startCell=startCell)

    estQList = simulator.q_learning(listOfTraj, expReplay, discntFact, alpha,
                                   batchSize=batchSize)

    optPolicy = PolicyGrid(simulator.width, simulator.height)
    Ju_N = Grid(simulator.width, simulator.height, 0)

    # extract optimal policy and Ju_N
    for x in range(simulator.width):
        for y in range(simulator.height):
            currMaxRew = float("-inf")
            bestDirNo = 0
            for u in range(simulator.nDir):
                if estQList[u][x, y] > currMaxRew:
                    bestDirNo = u
                    currMaxRew = estQList[u][x, y]
            # Use same vector dirs to index strings as in q_learning() and
            # more specifically as buildRantrajectory2() when the later
            # associatesa random dirNo to a string. This function then used
            # MOVES[actionStr] with actionStr picked from dirs[
            # randActionNo]. Thus, it should stay consistent.
            optPolicy[x, y] = simulator.dirs[bestDirNo]
            Ju_N[x, y] = estQList[bestDirNo][x, y]

    if silent is False:
        print("Expected cumulative reward of optimal policy:")
        print(Ju_N)
        print("\nCorresponding optimal policy:")
        print(optPolicy)

    if silentListEstQ is False:
        printListEstQ(estQList)

    return Ju_N, optPolicy, estQList


def question6_batch(sim, nTraj, lengthTraj, expReplay, alpha,
              discntFact, deterministic, beta, batchSize=None, silent=False,
              silentListEstQ=True):
    detTraj = sim.buildRandTrajectories2(nTraj, lengthTraj,
                                         deterministic, beta=beta,
                                         startCell=[3, 3])
    nSamplesTot = lengthTraj*nTraj

    estQList = [Grid(sim.width, sim.height, 0) for i in range(4)]
    optPolicy = PolicyGrid(simulator.width, simulator.height)
    Ju_N = Grid(simulator.width, simulator.height, 0)
    for n in range(nSamplesTot):
        [estQList, _] = sim.q_learning_dynamic(detTraj, estQList, n,
                                               nSamplesTot, expReplay,
                                               discntFact, alpha,
                                               batchSize=batchSize)
    # extract optimal policy and Ju_N
    for x in range(simulator.width):
        for y in range(simulator.height):
            currMaxRew = float("-inf")
            bestDirNo = 0
            for u in range(simulator.nDir):
                if estQList[u][x, y] > currMaxRew:
                    bestDirNo = u
                    currMaxRew = estQList[u][x, y]
            optPolicy[x, y] = simulator.dirs[bestDirNo]
            Ju_N[x, y] = estQList[bestDirNo][x, y]
    if silent is False:
        print("Expected cumulative reward of optimal policy:")
        print(Ju_N)
        print("\nCorresponding optimal policy:")
        print(optPolicy)

    if silentListEstQ is False:
        printListEstQ(estQList)


def printListEstQ(listEstQ):
    for i in range(4):
        print(listEstQ[i])


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
    #
    #
    # '''Q3: Expected return of a policy'''
    # question3(simulator, discntFact, 1000)
    #
    # simulator.buildRandTrajectories(3, 10, True)
    #
    # """Q4: Optimal policy"""
    # print("Question 4: ")
    # print("Deterministic setting:")
    # question4(simulator, T, discntFact, 0, silentStep=True)
    # print("Stochastic setting:")
    # question4(simulator, T, discntFact, beta, silentStep=True)
    #
    # """Q5: system identification"""
    # print("\n--------------------\n")
    # print("Question 5:")
    # print("**********\n")
    # print("Deterministic setting:")
    # hist = simulator.buildRandTrajectory([width - 1, height - 1], 500,
    #                                      deterministic=True, seed=890)
    # question5(simulator, T, discntFact, hist, silentStep=True)
    #
    # print("Stochastic setting:")
    # hist = simulator.buildRandTrajectory([width - 1, height - 1], 500,
    #                                      deterministic=False, beta=beta,
    #                                      seed=890)
    # question5(simulator, T, discntFact, hist, silentStep=True)

    """Q6: Q-learning in batch setting"""
    print("\n--------------------\n")
    print("Q6: Q-learning in batch setting")
    print("\n*******************************\n")

    print("1) Simulation of q-learning algorithm, 100 episodes"
          " of length 1000, starting in [3, 3] by applying a random policy. "
          "No experience  replay/batch size.\n")

    print("1.a) alpha = 0.05\n----------------\n")
    # Deterministic case:
    print("1.a.i) Deterministic setting:")
    question6(simulator, [3, 3], 100, 1000, False, 0.05, discntFact, True,
              beta, batchSize=None, silent=False, silentListEstQ=True)


    # # Stochastic setting:
    print("\n1.a.ii) Stochastic setting:")
    question6(simulator, [3, 3], 100, 1000, False, 0.05, discntFact, False,
              beta, batchSize=None, silent=False, silentListEstQ=True)

    print("\n1.b) alpha = 0.2\n----------------\n")
    # Deterministic case:
    print("1.b.i) Deterministic setting:")
    question6(simulator, [3, 3], 100, 1000, False, 0.2, discntFact, True,
              beta, batchSize=None, silent=False, silentListEstQ=True)

    # Stochastic setting:
    print("\n1.b.ii) Stochastic setting:")
    question6(simulator, [3, 3], 100, 1000, False, 0.2, discntFact, False,
              beta, batchSize=None, silent=False, silentListEstQ=True)

    print("\n1.a) alpha = 0.5\n----------------\n")
    # Deterministic case:
    print("1.c.i) Deterministic setting:")
    question6(simulator, [3, 3], 100, 1000, False, 0.5, discntFact, True,
              beta, batchSize=None, silent=False, silentListEstQ=True)

    # Stochastic setting:
    print("\n1.c.ii) Stochastic setting:")
    question6(simulator, [3, 3], 100, 1000, False, 0.5, discntFact, False,
              beta, batchSize=None, silent=False, silentListEstQ=True)

    print("\n1.a) alpha decreasing linearly\n----------------\n")
    # Deterministic case:
    print("1.c.i) Deterministic setting:")
    alpha = np.linspace(0.5, 0, 100*1000)
    question6(simulator, [3, 3], 100, 1000, False, 0.5, discntFact, True,
              beta, batchSize=None, silent=False, silentListEstQ=False)

    # Stochastic setting:
    print("\n1.c.ii) Stochastic setting:")
    question6(simulator, [3, 3], 100, 1000, False, 0.5, discntFact, False,
              beta, batchSize=None, silent=False, silentListEstQ=True)

    print("Deterministic: Batch1")
    question6_batch(simulator, 100, 1000, True, 0.05, discntFact, True,
              beta, batchSize=1)

    print("Stochastic: Batch1")
    question6_batch(simulator, 100, 1000, True, 0.05, discntFact, False,
                    beta, batchSize=1)
    print("Deterministic: Batch10")
    question6_batch(simulator, 100, 1000, True, 0.05, discntFact, True,
                    beta, batchSize=10)
    print("Stochastic: Batch10")
    question6_batch(simulator, 100, 1000, True, 0.05, discntFact, False,
                    beta, batchSize=10)
    print("Deterministic: Batch100")
    question6_batch(simulator, 100, 1000, True, 0.05, discntFact, True,
                    beta, batchSize=50)
    print("Stochastic: Batch100")
    question6_batch(simulator, 100, 1000, True, 0.05, discntFact, False,
                    beta, batchSize=50)


