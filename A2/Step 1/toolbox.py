
import numbers
import numpy as np
import random
import matplotlib.pyplot as plt
import math
import plot
import unit_test
import question_solver

import os
from pathlib import Path

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
        for i in range(n):
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

        for i in range(n_iter):
            p_i = random.uniform(boundPos[0], boundPos[1])
            s_i = random.uniform(boundS[0], boundS[1])
            cumRewTot += self.simulate([p_i, s_i], policy, gamma,
                                       histRet=False, t_stop=t_stop)
        if n_iter != 0:
            return cumRewTot/n_iter
        else:
            return 0

    def simulate(self, initState, policy, gamma=1.0, histRet=False,
                 t_stop=None):
        """
        Simulate and build an episode
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


def getPosFromHist(hist):
    # TODO: convert to map
    return [item[0][0] for i, item in enumerate(hist)]


def getSpeedFromHist(hist):
    return [item[0][1] for i, item in enumerate(hist)]


def getRewardsFromHist(hist):
    return [item[2] for i, item in enumerate(hist)]


def getCumReward(hist, gamma):
    """Extract the final cumulative reward from an history"""
    immediateRewards = getRewardsFromHist(hist)
    cumReward = 0.0

    for t, r in enumerate(immediateRewards):
        cumReward += (gamma**t) * r
    return cumReward
