import numpy as np
import random
import math
import pandas as pd
import pickle

from tqdm import tqdm as ProgressBar


# ----------------------------- TOOLBOX ------------------------------------ #


class Domain:
    """The car on the hill problem"""

    def __init__(self):
        self.UBP = 1
        self.LBP = -1
        self.UBS = 3
        self.LBS = -3

        self.g = 9.81
        self.m = 1
        self.discretizeTime = 0.1
        self.intTimeStep = 0.001

        self.actions = [4, -4]
        self.actionsDict = {"acc": 4, "dec": -4}
        self.actionsStr = ["acc", "dec"]

        self.acc = lambda p, s, u: self._ds(p, s, u)

    def isTerminal(self, p, s):
        """
        Check wether we are in a terminal state or not
        :param p: position
        :param s: speed
        :return: True/False
        """
        return abs(p) > 1 or abs(s) > 3

    def reward(self, nextState):
        """Reward function"""
        nextP, nextS = nextState[0], nextState[1]
        if nextP < -1 or abs(nextS) > 3:
            return -1
        elif nextP > 1 and abs(nextS) <= 3:
            return 1
        else:
            return 0

    def dynamics(self, p_0, s_0, u, t_i):
        """
        Describe the dynamics of the domain
        :param p_0: initial position
        :param s_0: initial speed
        :param u: action (acceleration value)
        :param t_i: initial time
        :return: nextP, nextS, nextT
        """

        nextP, nextS = self.euler(self.acc, p_0, s_0, u)

        return nextP, nextS, t_i + self.discretizeTime

    def euler(self, acc, p_0, s_0, u):
        """
        Perform integration with simple euler method
        :param acc: acceleration formula
        :param p_0: initial position
        :param s_0: initial speed
        :param u: acceleration value during two timesteps
        :return: (postion, speed) after a timestep elapsed
        """
        p_dot_0 = s_0
        n = int(self.discretizeTime/self.intTimeStep) + 1

        p = p_0
        p_dot = p_dot_0

        for i in range(n):
            p_dot += self.intTimeStep * acc(p, p_dot, u)
            p += self.intTimeStep * p_dot
        return p, p_dot

    def eulerVec(self, acc, p_0, s_0, u, t_i, t_f):
        """
        Perform integration with simple euler method
        :param acc: acceleration formula
        :param p_0: initial position
        :param s_0: initial speed
        :param u: acceleration value during two timesteps
        :param t_i: initial time of integration
        :param t_f: end time of integration
        :return: (postion, speed) for each integration timesteps
        """
        n = int((t_f - t_i) / self.intTimeStep) + 1
        # n = int(self.discretizeTime/self.intTimeStep)+1
        t = np.linspace(t_i, t_f, n)
        p = np.zeros(n)
        p_dot = np.zeros(n)

        p[0] = p_0
        p_dot[0] = s_0
        t[0] = t_i

        for i in range(1, n):
            p_dot[i] = p_dot[i-1] + self.intTimeStep * acc(p[i-1],
                                                           p_dot[i-1], u)
            p[i] = p[i-1] + self.intTimeStep * p_dot[i]
            t[i] = t[i-1] + self.intTimeStep
        return p, p_dot, t

    def _ds(self, p, s, u):
        '''Ret: acceleration of the car'''
        return u/(1+(self._dhill(p)**2)) - \
               (self.g*self._dhill(p))/(1+(self._dhill(p))**2) - \
               ((s**2)*self._dhill(p)*self._ddhill(p))/(1+(self._dhill(p)**2))

    def _dp(self, s):
        """return speed of car"""
        return s

    def _hill(self, p):
        """Define hill shape"""
        if p < 0:
            return p+p**2

        return p/(math.sqrt(1+5*(p**2)))

    def _dhill(self, p):
        """Define slope of hill"""
        if p < 0:
            return 2*p + 1
        return 1/((5*(p**2)+1)**(3/2))

    def _ddhill(self, p):
        """Define derivative of slope of hill"""
        if p < 0:
            return 2
        return (-15*p)/((5*(p**2)+1)**(5/2))


# ----------------------------- POLICIES ----------------------------------- #


def accPolicy():
    """Always accelerate"""
    return "acc", 4


def decPolicy():
    """Always decelerate"""
    return "dec", -4


class FittedQPolicy:
    """
    A class to make a one-shot prediction with a policy trained by fitted q
    algorithm
    """
    def __init__(self, model):
        self.model = model

    def take_action(self, pos, speed, modelType):
        if modelType == "nn":
            r_acc = self.model.predict(np.array([pos, speed, 4]).reshape((1, 3)))
            r_dec = self.model.predict(np.array([pos, speed, -4]).reshape((1, 3)))
        else:
            r_acc = self.model.predict([[pos, speed, 4]])
            r_dec = self.model.predict([[pos, speed, -4]])
        return ("acc", 4) if r_acc > r_dec else ("dec", -4)


# ----------------------------- Simulator ---------------------------------- #


class Simulator:
    """A class to handle simulations in a domain"""
    def __init__(self, domain):
        self.dom = domain

    def _randAction(self):
        """Take an action defined in the domain at random"""
        randActNo = random.randint(0, 1)
        actionStr = self.dom.actionsStr[randActNo]
        u = self.dom.actions[randActNo]
        return actionStr, u

    def buildEpisodes(self, n, initState, policy=None):
        """
        Build n episodes starting from initState. By defaut, use a random
        policy.
        :param n: number of episodes
        :param initState: initial state [p_0, s_0]
        :param policy: function ptr to a policy. If None, random policy
        :return: listEp, stat (dictionnary with nTuple and nWin)
        """
        listEpisodes = []
        stat = {"nTuple": 0, "nWin": 0}
        for i in ProgressBar(range(n), desc="Building episodes"):
            ep, statEp = self.buildEpisode(initState, policy)
            stat["nTuple"] += statEp["epLen"]
            stat["nWin"] += statEp["nWin"]
            listEpisodes.append(ep)
        return listEpisodes, stat

    def buildEpisode(self, initState, policy=None):
        """
        Build a single episode and run until terminal state reached. Take
        care when using.
        :param initState: [p_0, s_0]
        :param policy: If None, random policy applied
        :return: episode, stat (dictionnary with epLen, nWin)
        """

        stat = {"epLen": 0, "nWin": 0}

        # Initial condition of an episode
        p_0, s_0 = initState[0], initState[1]
        if policy is None:
            actionStr, u = self._randAction()
        else:
            actionStr, u = policy()

        nextP, nextS, nextT = self.dom.dynamics(p_0, s_0, u, 0)
        nextState = [nextP, nextS]

        rew = self.dom.reward(nextState)
        ep = [[initState, actionStr, rew, nextState]]
        stat["epLen"] = 1

        while not self.dom.isTerminal(nextP, nextS):
            state = nextState[0], nextState[1]
            p, s = state[0], state[1]
            t = nextT

            if policy is None:
                actionStr, u = self._randAction()
            else:
                actionStr, u = policy()

            nextP, nextS, nextT = self.dom.dynamics(p, s, u, t)
            nextState = nextP, nextS
            rew = self.dom.reward(nextState)

            if rew == 1:
                stat["nWin"] += 1

            ep.append([state, actionStr, rew, nextState])
            stat["epLen"] += 1

        return ep, stat

    def monteCarlo(self, n_iter, t_stop, policy, boundPos, boundS, gamma):
        """
        Estimate the expected cumulative result of a policy with Monte Carlo
        principle
        :param n_iter: Number of iteration for the simulation
        :param t_stop: Max nb of timesteps allowed per episode
        :param policy: If None, random policy
        :param boundPos: [minP, maxP]
        :param boundS: [minS, maxS]
        :param gamma: discount factor
        :return: expected cumulative result
        """

        cumRewTot = 0.0

        for i in ProgressBar(range(n_iter), desc="Monte Carlo sim"):
            p_i = random.uniform(boundPos[0], boundPos[1])
            s_i = random.uniform(boundS[0], boundS[1])
            cumRewTot += self.simulate([p_i, s_i], policy, gamma=gamma,
                                       histRet=False, t_stop=t_stop)
        if n_iter != 0:
            return cumRewTot/n_iter
        else:
            return 0
    def monteCarloDebug(self, n_iter, t_stop, policy, boundPos, boundS, gamma):
        """
        Estimate the expected cumulative result of a policy with Monte Carlo
        principle
        :param n_iter: Number of iteration for the simulation
        :param t_stop: Max nb of timesteps allowed per episode
        :param policy: If None, random policy
        :param boundPos: [minP, maxP]
        :param boundS: [minS, maxS]
        :param gamma: discount factor
        :return: list of cumulative reward of each histories generated
        """

        listHistories = []

        for i in ProgressBar(range(n_iter), desc="Monte Carlo sim"):
            p_i = random.uniform(boundPos[0], boundPos[1])
            s_i = random.uniform(boundS[0], boundS[1])
            listHistories.append(self.simulateDebug([p_i, s_i], policy,
                                            t_stop, gamma=gamma,
                                       histRet=True))
        return [getRewardsFromHist(listHistories[i]) for i in range(len(listHistories))]

    def simulate(self, initState, policy, gamma=1.0, histRet=False,
                 t_stop=None):
        """
        Simulate a policy
        :param initState: [p_0, s_0]
        :param policy: if None, random policy
        :param gamma: discount facotr
        :param histRet: Wether we want the full history or not
        :param t_stop: max timesteps allowed for simulation
        :return: cumRew, [hist] if histRet set to True.
        """
        p_0, s_0 = initState[0], initState[1]
        actionStr, u = policy()

        nextP, nextS, nextT = self.dom.dynamics(p_0, s_0, u, 0)
        nextState = [nextP, nextS]

        rew = self.dom.reward(nextState)
        cumRew = rew
        hist, histLen = None, 1
        tstep = 1
        if histRet is True:
            hist = [[initState, actionStr, rew, nextState]]

        while not self.dom.isTerminal(nextP, nextS) \
                and not histLen == t_stop:
            state = nextState[0], nextState[1]
            p, s = state[0], state[1]
            t = nextT

            actionStr, u = policy()

            nextP, nextS, nextT = self.dom.dynamics(p, s, u, t)
            nextState = nextP, nextS
            rew = self.dom.reward(nextState)
            cumRew += rew * (gamma ** tstep)

            if histRet is True:
                hist.append([state, actionStr, rew, nextState])

            histLen += 1
            tstep += 1

        if histRet is True:
            return cumRew, hist
        else:
            return cumRew

    def simulateDebug(self, initState, policy, t_stop, gamma=1.0,
                      histRet=False):
        """
        Simulate a policy
        :param initState: [p_0, s_0]
        :param policy: if None, random policy
        :param gamma: discount facotr
        :param histRet: Wether we want the full history or not
        :param t_stop: max timesteps allowed for simulation
        :return: cumRew, [hist] if histRet set to True.
        """
        p_0, s_0 = initState[0], initState[1]
        actionStr, u = policy()

        nextP, nextS, nextT = self.dom.dynamics(p_0, s_0, u, 0)
        nextState = [nextP, nextS]

        rew = self.dom.reward(nextState)
        cumRew = rew
        hist, histLen = None, 1
        tstep = 1
        if histRet is True:
            hist = [[initState, actionStr, cumRew, nextState]]
        if self.dom.isTerminal(nextP, nextS):

            for i in range(t_stop - tstep + 1):
                if histRet is True:
                    hist.append([initState, actionStr, cumRew, nextState])
            return hist

        while tstep <= t_stop:
            state = nextState[0], nextState[1]
            p, s = state[0], state[1]
            t = nextT

            actionStr, u = policy()

            nextP, nextS, nextT = self.dom.dynamics(p, s, u, t)
            nextState = nextP, nextS
            rew = self.dom.reward(nextState)
            cumRew += rew * (gamma ** tstep+1)

            if histRet is True:
                hist.append([state, actionStr, cumRew, nextState])

            histLen += 1
            tstep += 1

            if self.dom.isTerminal(nextP, nextS):
                for i in range(t_stop-tstep + 1):
                    if histRet is True:
                        hist.append([state, actionStr, cumRew, nextState])
                break

        if histRet is True:
            return hist
        else:
            return cumRew

    def fittedQ(self, model, trajectories, gamma, fittedQIter,
                saveIntermediate=(), modelType=None):
        """
        Computes Q hat by running the fitted Q algorithm
        :param model: an estimator to train
        :param trajectories: Set of trajectories (to build dataset)
        :param gamma: discount factor
        :param fittedQIter: number of fitted q iteration to perform
        :param saveIntermediate: list of intermediate models to store on disk
        :param modelType: nn, lr or rf
        :return: the trained estimator
        """

        N = fittedQIter
        stat = {"distQ":[]}
        # print([len(trajectories[i]) for i in range(len(trajectories))])
        # T = max(len(trajectories[i]) for i in range(len(trajectories)))

        dataset = trajectories2DataSet(trajectories)
        # trainingset = dataset[['pos', 'speed', 'rew']].copy()
        X_train = dataset[['pos', 'speed', 'action']].values
        # Scikit-learn wants 1D ouput
        y_train = np.ravel(dataset[['rew']].values)

        model.fit(X_train, y_train)

        estQPrev = dataset['rew'].values

        for i in ProgressBar(range(1, N+1), desc="Fitted Q iterations"):
            distanceEstQFromOneIter2Another = 0

            X_test = dataset[['nextPos', 'nextSpeed', 'acc']].values
            y_testAcc = model.predict(X_test)

            X_test = dataset[['nextPos', 'nextSpeed', 'dec']].values
            y_testDec = model.predict(X_test)

            directRew = dataset['rew'].values
            bestActions = dataset['bestAction'].values
            for k in range(dataset.shape[0]):
                if y_testDec[k] > y_testAcc[k]:
                    bestActions[k] = -4
                    maxQ = y_testDec[k]
                elif y_testDec[k] < y_testAcc[k]:
                    bestActions[k] = 4
                    maxQ = y_testAcc[k]
                else:
                    bestActions[k] = 0
                    maxQ = y_testAcc[k]
                y_train[k] = directRew[k] + gamma * maxQ
                distanceEstQFromOneIter2Another += (estQPrev[k] - y_train[
                    k])**2

            model.fit(X_train, y_train)
            stat["distQ"].append(distanceEstQFromOneIter2Another/dataset.shape[0])

            if i in saveIntermediate:
                if modelType == "nn":
                    model.save("trained_"+modelType+str(i)+".h5")
                else:
                    pickle.dump(model, open("trained_"+modelType+str(i)+".sav", 'wb'))
        return model, stat

    def simulateFittedQPolicy(self, initState, model, gamma,
                              modelType, t_stop=200, histRet=False):
        """
        Simulate a policy trained by fitted q algorithm
        :param initState: [p_0, sh_0]
        :param model: an estimator to fit
        :param gamma: discount facotr
        :param modelType: rf, lr or nn as string
        :param t_stop: max length of an episode
        :param histRet: Wether to return the all history along with cum rew
        or not
        :return: cumRew, [hist]
        """
        p_0, s_0 = initState[0], initState[1]
        policy = FittedQPolicy(model)
        actionStr, u = policy.take_action(p_0, s_0, modelType)

        nextP, nextS, nextT = self.dom.dynamics(p_0, s_0, u, 0)
        nextState = [nextP, nextS]

        rew = self.dom.reward(nextState)
        cumRew = rew
        hist, histLen = None, 1
        tstep = 1

        if histRet is True:
            hist = [[initState, actionStr, rew, nextState]]
        while(not self.dom.isTerminal(nextP, nextS) and tstep < t_stop):
            state = nextState[0], nextState[1]
            p, s = state[0], state[1]
            t = nextT

            actionStr, u = policy.take_action(p, s, modelType)

            nextP, nextS, nextT = self.dom.dynamics(p, s, u, t)
            nextState = nextP, nextS
            rew = self.dom.reward(nextState)
            cumRew += rew * (gamma ** tstep)

            if histRet is True:
                hist.append([state, actionStr, rew, nextState])

            histLen += 1
            tstep += 1

        if histRet is True:
            return cumRew, hist
        else:
            return cumRew


def getPosFromHist(hist):
    return [item[0][0] for i, item in enumerate(hist)]


def getSpeedFromHist(hist):
    return [item[0][1] for i, item in enumerate(hist)]


def getNextPosFromHist(hist):
    return [item[3][0] for i, item in enumerate(hist)]


def getNextSpeedFromHist(hist):
    return [item[3][1] for i, item in enumerate(hist)]


def getRewardsFromHist(hist):
    return [item[2] for i, item in enumerate(hist)]


def getActionFromHist(hist):
    actions = [item[1] for i, item in enumerate(hist)]
    return [4 if i[0] == 'a' else -4 for i in actions]


def getCumReward(hist, gamma):
    """Extract the final cumulative reward from an history"""
    immediateRewards = getRewardsFromHist(hist)
    cumReward = 0.0

    for t, r in enumerate(immediateRewards):
        cumReward += (gamma**t) * r
    return cumReward

def trajectories2DataSet(trajectories):
    """
    Build a panda dataframe that contains relevant information to build a
    dataset
    :param trajectories: Set of trajectories used to build the dataset
    :return: panda data frame
    """
    dataset = pd.DataFrame(columns=['t', 'pos', 'speed', 'action',
                                    'nextPos', 'nextSpeed','rew', 'acc',
                                    'dec', 'bestAction'])
    T = 0
    for trajectory in ProgressBar(trajectories, desc="Building dataset"):
        t = len(trajectory)
        T += t
        rewards = getRewardsFromHist(trajectory)
        pos = getPosFromHist(trajectory)
        speed = getSpeedFromHist(trajectory)
        action = getActionFromHist(trajectory)
        nextPos = getNextPosFromHist(trajectory)
        nextSpeed = getNextSpeedFromHist(trajectory)
        rows = list(zip(list(range(t)), pos, speed, action, nextPos,
                        nextSpeed, rewards, [4]*T, [-4]*T, [0]*T))
        # Append to dataset the data stored in the trajectory
        dataset = dataset.append([pd.Series(i, index=dataset.columns) for i in
                                  rows], ignore_index=True)
    # Sort by time steps
    # dataset.sort_values(by="t", inplace=True)
    # Use time as index and drop the column time
    # dataset.set_index("t")

    # Add index column and use it as indexing in dataframe
    dataset = dataset.assign(index=pd.Series([i for i in range(T)]).values)
    # print("Number of one-step transistions in dataset = {}".format(T))
    return dataset.set_index("index")
