import os
import matplotlib.pyplot as plt
import random
import numpy as np
from tqdm import tqdm as ProgressBar
import pandas as pd
import catcher
import warnings
import drawer
import pickle
#from policy import FittedQPolicy_discrete
import tensorflow as tf
from keras.models import Sequential
from keras.optimizers import adam
from keras.layers.core import Dense
from keras.layers import Lambda
import keras.backend as K
from keras.optimizers import Adam

from dataset_utils import getStateFromTraj
from dataset_utils import getNextStateFromTraj
from dataset_utils import getActionsFromTraj
from dataset_utils import getRewardsFromTraj

from ActorNetwork import ActorNetwork
from CriticNetwork import CriticNetwork

from enum import Enum

class Axis(Enum):
    # column
    col = int(0)
    # Row
    row = int(1)


class DiscreteAction:
    """
    A class to handle discrete actions
    """
    def __init__(self):
        self.LEFT = -1
        self.RIGHT = 1
        self.STAY = 0

    def toStr(self, nb):
        if nb == -1:
            return 'left'
        elif nb == 1:
            return 'right'
        elif nb == 0:
            return 'stay'
        else:
            raise ValueError("[toStr of DicreteAction] Wrong call")


class Simulator:
    """A class to handle simulations in a domain"""

    def __init__(self, showDraw = False, saveDraw = False, discreteAction = True):
        """
        The domain is a ContinuousCatcher catcher.

        :param showDraw:	(bool) whether to show drawing of state at each time step
        :param saveDraw:	(bool) whether to draw state at each time step and store it in images folder
        :param discrete:	(bool) whether from the discrete (True) or continous (False)
        """
        self.model = None
        self.catcher = catcher.ContinuousCatcher()
        self.catcher.reset()

        self.discreteAction = discreteAction
        self.showDraw = showDraw
        self.saveDraw = saveDraw

        # action space : discrete
        discreteAction = DiscreteAction()
        self.LEFT = discreteAction.LEFT
        self.STAY = discreteAction.STAY
        self.RIGHT = discreteAction.RIGHT
        self.ACTIONS = [discreteAction.LEFT, discreteAction.STAY, discreteAction.RIGHT]
        self.ACTION_STR = {discreteAction.LEFT:"left",
                           discreteAction.STAY:"stay",
                           discreteAction.RIGHT:"right"}
        self.N_ACTIONS = len(self.ACTIONS)
        self.N_STATES = 4

        # action space : continuous
        self.MAX_LEFT = -0.021 * 64  # given by Sami
        self.MAX_RIGHT = 0.021 * 64  # given by Sami

    # -----------------------------------------------------------------------
    # 								Policies
    # 								========
    # ------------------------------------------------------------------------

    def takePolicyAction(self, state, verbose=False):
        """
        Using the state, it predicts which of the discrete action to take.
        Important : It will use self.model to predict, so make sure that it is updated.
        :return: (numpy array) containing the action to take
        """
        if self.model is None:
            raise ValueError('[predictDiscreteAction] forgot to set a model '
                             'in simulator')
        if self.discreteAction:
            """
            inputs = np.asarray([
            [bar_center_x, bar_velocity, fruit_center_x, fruit_center_y, LEFT]
            [bar_center_x, bar_velocity, fruit_center_x, fruit_center_y, STAY]
            [bar_center_x, bar_velocity, fruit_center_x, fruit_center_y, RIGHT]])
            """
            inputs = np.zeros((3, 5))
            inputs[:, [0, 1, 2, 3]] = [state, state,state]
            inputs[0, 4] = self.LEFT
            inputs[1, 4] = self.STAY
            inputs[2, 4] = self.RIGHT
            outputs = self.model.predict(inputs)

            bestActionNo = np.argmax(outputs)
            bestAction = self.ACTIONS[bestActionNo]
            if verbose:
                print("Left = ", outputs[0], "\t -- stay = ", outputs[1], " -- right = ", outputs[2])
                print(self.ACTION_STR[self.ACTIONS[bestActionNo]])
            return [bestAction]
        else:
            bestAction = self.model.predict(state.reshape(1, 4))
            if verbose:
                print("Best action = {}".format(bestAction[0]))
            return bestAction[0]

    def randAction(self):
        """Take an action defined in the domain at random"""
        if self.discreteAction:
            return [self.ACTIONS[random.randint(0, self.N_ACTIONS-1)]]
        else:
            coef = 1000
            return [random.randint(self.MAX_LEFT*coef, self.MAX_RIGHT*coef)/coef]

    # -----------------------------------------------------------------------
    # 								Generators
    # 								==========
    # ------------------------------------------------------------------------

    def buildEpisodes(self, n, policy=None):
        """
        Build n episodes starting from initState. By defaut, use a random
        policy.
        :param n: number of episodes
        :param policy: function ptr to a policy. If None, random policy
        :return: listEp (list of tuple [state, action, reward, nextState]) , stat (dictionnary with nTuple and
        nCatched and nMissed)
        """

        # clean images folder
        if self.saveDraw:
            self._cleanImgFolder()

        listEpisodes = []
        stat = {"nTuple": 0, "nCatched": 0, "nMissed": 0}
        for i in ProgressBar(range(n), desc="Building episodes"):
            ep, statEp = self.buildEpisode(policy=policy, cleanImages=False,
                                           saveDraw=False)
            stat["nTuple"] += statEp["epLen"]
            stat["nCatched"] += statEp["nCatched"]
            stat["nMissed"] += statEp["nMissed"]
            listEpisodes.append(ep)
        return listEpisodes, stat

    def buildTrainSet(self, N, policy=None):
        """
            Build a panda dataframe that contains relevant information to build a
            dataset
            :param N: Number of episodes
            :return: trainSet in panda data frame format and stat,
            a dictionnary with statistic about the dataset
        """
        trainSet = pd.DataFrame(
            columns=['t', 'barX', 'barV', 'fruitX', 'fruitY',
                     'action',
                     'nextBarX', 'nextBarV', 'nextFruitX',
                     'nextFruitY', 'rew', 'left', 'right', 'stay',
                     'bestAction'])

        stat = {"nTuple": 0, "nCatched": 0, "nMissed": 0}
        for t in ProgressBar(range(N), desc="Building episodes (trainSet)"):
            traj, statEp = self.buildEpisode(
                policy=policy, cleanImages=False, saveDraw=False)
            stat["nTuple"] += statEp["epLen"]
            stat["nCatched"] += statEp["nCatched"]
            stat["nMissed"] += statEp["nMissed"]

            states = getStateFromTraj(traj)
            actions = getActionsFromTraj(traj)
            rewards = getRewardsFromTraj(traj)
            nextStates = getNextStateFromTraj(traj)
            epLen = statEp["epLen"]
            rows = list(zip(list(range(epLen)), states[0], states[1],
                            states[2],
                                 states[3], actions,
                    nextStates[0], nextStates[1], nextStates[2], nextStates[
                        3], rewards, [self.LEFT] * epLen, [self.RIGHT]*epLen, [
                                self.STAY] * epLen, [0] * epLen))

            # Append to dataset the data stored in the trajectory
            trainSet = trainSet.append(
                [pd.Series(i, index=trainSet.columns) for i in
                 rows], ignore_index=True)

        # Index from 0 to the number of tuples
        trainSet = trainSet.assign(index=pd.Series([i for i in range(
            stat["nTuple"])]).values)
        # Sort by index and not by time
        return trainSet.set_index("index"), stat


    def buildTransitions(self, nTransitions, episodeTMax=100):
        """
        Build a dataset of ``nTransitions``. Each episode run is interrupted if it exceeds episodeTMax
        :param nTransitions: number of transitions desired
        :param episodeTMax: number of transistions maximum allowed for a
        generated episode
        :return: dataset in panda dataframe and a stat dictionary
        """
        print("Building dataset of {} transitions ...".format(nTransitions))
        trainSet = pd.DataFrame(
            columns=['t', 'barX', 'barV', 'fruitX', 'fruitY',
                     'action',
                     'nextBarX', 'nextBarV', 'nextFruitX',
                     'nextFruitY', 'rew', 'left', 'right', 'stay',
                     'bestAction', 'done'])
        stat = {"nTuple": 0, "nCatched": 0, "nMissed": 0}
        tuples2generate = nTransitions
        while tuples2generate > 0:

            if tuples2generate > episodeTMax:
                tMax = episodeTMax
            else:
                tMax = tuples2generate
            traj, statEp = self.buildEpisode(cleanImages=False,
                                             saveDraw=False, tMax=tMax)
            epLen = statEp["epLen"]
            stat["nTuple"] += statEp["epLen"]
            stat["nCatched"] += statEp["nCatched"]
            stat["nMissed"] += statEp["nMissed"]

            states = getStateFromTraj(traj)[:tMax]
            actions = getActionsFromTraj(traj)[:tMax]
            rewards = getRewardsFromTraj(traj)[:tMax]
            nextStates = getNextStateFromTraj(traj)[:tMax]

            if epLen < tMax:
                nTuple = epLen
                done = True
            else:
                nTuple = tMax
                done = False

            tuples2generate -= epLen

            rows = list(zip(list(range(nTuple)), states[0], states[1],
                            states[2],
                                 states[3], actions,
                    nextStates[0], nextStates[1], nextStates[2], nextStates[
                        3], rewards, [self.LEFT] * nTuple, [self.RIGHT]*nTuple, [
                                self.STAY] * nTuple, [0] * nTuple,
                            [False]*nTuple))
            # Append to dataset the data stored in the trajectory
            trainSet = trainSet.append(
                [pd.Series(i, index=trainSet.columns) for i in
                 rows], ignore_index=True)
            trainSet["done"].iloc[-1] = done

        trainSet = trainSet.assign(index=pd.Series([i for i in range(
            nTransitions)]).values)
        return trainSet.set_index("index"), stat


    def buildEpisode(self, policy=None, cleanImages = True, tMax = 10000,
                     saveDraw = False, showDraw=False, verbose=False):
        """
        Build a single episode and run until terminal state reached. Take
        care when using.
        :param policy: Fct taking a state in argument and returning array containing the action to take,
        if None, random policy applied
        :param cleanImages: (bool) whether to clean the images folder
        :param tMax: (int) maximal number of time step before game ends
        :return: episode (list of tuple [state, action, reward, nextState]), stat (dictionnary with epLen, nWin)
        """

        stat = {"epLen": 0, "nCatched": 0, "nMissed": 0}

        # clean images folder
        if cleanImages:
            self._cleanImgFolder()

        # Initial condition of an episode
        self.catcher.reset()

        initState = self.catcher.observe()

        figureData = [[initState, self.catcher.lives]]

        if policy is None:
            act = self.randAction()
        else:
            act = policy(initState, verbose)
        nextState, reward, done = self.catcher.step(act)

        figureData.append([nextState, self.catcher.lives])

        ep = [[initState, act[0], reward, nextState]]
        self._updateStat(stat, reward)

        t = 0
        while not done and t < tMax-1:
            state = nextState
            if policy is None:
                act = self.randAction()
            else:
                act = policy(state)

            nextState, reward, done = self.catcher.step(act)

            figureData.append([nextState, self.catcher.lives])

            # update the statistic given the reward
            self._updateStat(stat, reward)
            ep.append([state, act[0], reward, nextState])
            t += 1

            # show a drawing of the state
        if showDraw is True:
            self.catcher.generateAnimation(figureData)

        if saveDraw is True:
            self.catcher.saveAnimation(figureData)

        return ep, stat

    def _updateStat(self, stat, reward):
        """
        Return the stat given the reward obtained
        """
        stat["epLen"] += 1
        if reward == 1:
            pass
        elif reward < 0:
            stat["nMissed"] += 1
        else:
            stat["nCatched"] += 1
        return stat

    # -----------------------------------------------------------------------
    # 								Simulation
    # 								==========
    # ------------------------------------------------------------------------


    def fqi(self, model, modelType, trainSet, numIter, gamma):

        X_train = trainSet[["barX", "barV", "fruitX", "fruitY",
                            "action"]].values
        directRew = np.copy(trainSet["rew"])
        y_train = np.ravel(trainSet[["rew"]].values)  # reward as output


        lefts = trainSet[["nextBarX", "nextBarV", "nextFruitX",
                          "nextFruitY",
                          "left"]]
        rights = trainSet[["nextBarX", "nextBarV", "nextFruitX",
                           "nextFruitY",
                           "right"]]
        stays = trainSet[["nextBarX", "nextBarV", "nextFruitX",
                          "nextFruitY",
                          "stay"]]

        # learn model
        for K in ProgressBar(range(numIter), desc="FQI: Learning + "
                                                  + modelType):
            if modelType == "NN":
                model.fit(X_train, y_train, verbose=0, epochs=5)
            else:
                model.fit(X_train, y_train)

            # update TS
            if self.discreteAction:

                predRewLefts = model.predict(lefts)
                predRewStays = model.predict(stays)
                predRewRights = model.predict(rights)

                # update the reward
                bestActions = trainSet["bestAction"].values
                for k in range(trainSet.shape[0]):
                    predRewActions = [predRewLefts[k], predRewStays[k],
                                              predRewRights[k]]
                    bestActionNo = np.argmax(predRewActions)
                    maxQ = predRewActions[bestActionNo]
                    bestActions[k] = self.ACTIONS[bestActionNo]


                    y_train[k] = directRew[k] + gamma * maxQ

            else:
                print("TODO continuous action space")

            if modelType == "NN":
                if((K+1)%round(numIter/10) == 0):
                    model.save("fqi"+str(K+1)+".h5")
            else:
                if((K+1)%round(numIter/10) == 0):
                    pickle.dump(model, open("trained_" + modelType + "_fqi"+str(K+1)+".sav",
                                              'wb'))

        return model

    # -----------------------------------------------------------------------
    # 								   DDQN
    # 								==========
    # ------------------------------------------------------------------------


    def buildModel(self, name):
        """
        Build the network architecture used to evaluate Q or the maximizer
        optimizer for double Q learning
        :param name:
        :return: the network compiled
        """

        model = Sequential(name=name)

        model.add(Dense(40, input_dim=self.N_STATES+1, activation='relu',
                        kernel_initializer="random_uniform"))
        model.add(Dense(40, activation='relu'))
        model.add(Dense(1, activation='linear', kernel_initializer="random_uniform"))

        adam = Adam(lr=0.0001)
        model.compile(optimizer=adam, loss='mse')
        return model

    def updateTargetWeights(self, qNetwork, targetNetwork):
        """
        Copy weights of qNetwork in targetNetwork
        :param qNetwork:
        :param targetNetwork:
        :return:
        """
        targetNetwork.set_weights(qNetwork.get_weights().copy()) # copy to
        # be sure

    def dql_rb(self, gamma=0.95, nEpisodes=500, epsStart=1, epsStop=0.01,
               xplrSteps=None,
               replayBufferSize=800, batchSize=20, epTMax=250,
               randomPop=True, plotInterval=None):
        """
        Deep Q learning with replay buffer
        :param gamma: discount factor
        :param nEpisodes: a number of episodes to train on. Should be a
        multiple of 50 if plotInterval is not specified.
        :param epsStart: Start of epsilon for exploitation/exploration
        :param epsStop: end of epsilon
        :param xplrSteps: number of decremental step for epsilon
        :param batchSize: size of a batch
        :param epTMax: number of max time steps allowed per episode before cut
        :param replayBufferSize: size of the replay buffer
        :param randomPop: wether to discard random transition in buffer or
        just the oldest one
        :param plotInterval: interval to save model
        :return: the Q estimator trained
        """
        if xplrSteps is None:
            xplrSteps = nEpisodes*(int(epTMax/2))
            print("XplrStep for epsilons = {}".format(xplrSteps))

        if plotInterval is None:
            if nEpisodes%50 != 0:
                raise ValueError("Expect nEpisode to be %50 for intermediate storage if plotInterval not specified")
            plotInterval = int(nEpisodes/50)
            print(plotInterval)

        replayBuffer = Memory(self, replayBufferSize, randomPop=randomPop,
                              episodeTMax=epTMax, batchSize=batchSize)

        epsilons = np.linspace(epsStart, epsStop, xplrSteps)

        QNetwork = self.buildModel("QNetwork")

        statesActions = np.zeros((self.N_ACTIONS, self.N_STATES+1))
        y = np.zeros((batchSize, 1))
        epsNo = 0
        for epNo in ProgressBar(range(nEpisodes), desc="Training episodes "
                                                       "dql"):
            if epNo%plotInterval == 0:
                QNetwork.save("trained_models/dql"+str(epNo)+".h5")
            self.catcher.reset()
            initState = self.catcher.observe()
            state = initState

            for t in range(epTMax):

                if epsNo == xplrSteps-1:
                    print("Reached end of epsilon decrease after {}".format(
                        epNo))
                if random.random() < epsilons[int(min(xplrSteps-1, epsNo))]:
                    bestActionNo = random.randrange(0, 3)
                else:
                    statesActions = self.buildStatesActions(statesActions, state)
                    Q_pred = QNetwork.predict(statesActions)
                    # print(Q_pred)
                    bestActionNo = np.argmax(Q_pred)

                bestAction = self.ACTIONS[bestActionNo]
                newState, rew, done = self.catcher.step([bestAction])
                replayBuffer.append([t, state, bestAction, rew, newState, done])
                [bState, bRew, bNextState, bDone] = replayBuffer.getBatch()

                for j in range(batchSize):
                    if bDone[j]:
                        y[j] = bRew[j]
                    else:
                        input = self.buildStatesActions(statesActions,
                                                        bNextState[j])

                        y[j] = bRew[j] + gamma * np.max(QNetwork.predict(input))
                # QNetwork.fit(bState, y, verbose=0)
                # QNetwork.train_on_batch(bState, y)
                QNetwork.fit(bState, y, epochs=5, verbose=False)
                state = newState
                epsNo += 1
        return QNetwork



    def buildStatesActions(self, stateActions, state):
        """
        Create an input for the network given a state of the K discrete actions
        :param stateActions: a numpy array (N_actions, N_STATE+1) to fill
        :param state: the state
        :return: the numpy array filled with the K states and the
        different actions
        """
        stateActions[:, [0, 1, 2, 3]] = np.array([state for _ in
                                                  range(self.N_ACTIONS)])

        stateActions[:, 4] = np.array([self.LEFT, self.STAY,
                                       self.RIGHT])
        return stateActions


    def ddql_rb(self, gamma=0.95, nEpisodes=500, epsStart=1, epsStop=0.01,
               xplrSteps=None, plotInterval = None,
               replayBufferSize=800, batchSize=20, epTMax=250, randomPop=True):
        """
        Double deep Q learning with replay buffer
        :param gamma: discount factor
        :param nEpisodes: a number of episodes to train on. Should be a
        multiple of 50 if plotInterval is not specified.
        :param epsStart: Start of epsilon for exploitation/exploration
        :param epsStop: end of epsilon
        :param xplrSteps: number of decremental step for epsilon
        :param batchSize: size of a batch
        :param epTMax: number of max time steps allowed per episode before cut
        :param replayBufferSize: size of the replay buffer
        :param randomPop: wether to discard random transition in buffer or
        just the oldest one
        :param plotInterval: interval to save model
        :return: the Q estimator trained
        """
        if xplrSteps is None:
            xplrSteps = int(nEpisodes*(epTMax/2))
            print(xplrSteps)
        if plotInterval is None:
            if nEpisodes%50 != 0:
                raise ValueError("Expect nEpisode to be %50 for intermediate storage if plotInterval not specified")
            plotInterval = int(nEpisodes/50)

        replayBuffer = Memory(self, replayBufferSize, randomPop=randomPop,
                              episodeTMax=epTMax, batchSize=batchSize)

        epsilons = np.linspace(epsStart, epsStop, xplrSteps)

        QNetwork = self.buildModel("QNetwork")
        targetNetwork = self.buildModel("TNetwork")

        stateActions = np.zeros((self.N_ACTIONS, self.N_STATES+1))
        y = np.zeros((batchSize, 1))
        epsNo = 0
        for epNo in ProgressBar(range(nEpisodes), desc="Training episodes "
                                                       "dql"):

            self.catcher.reset()
            initState = self.catcher.observe()
            state = initState

            self.updateTargetWeights(QNetwork, targetNetwork)

            if epNo%plotInterval == 0:
                QNetwork.save("trained_models/ddql"+str(epNo)+".h5")

            for t in range(epTMax):

                if random.random() < epsilons[int(min(xplrSteps-1, epsNo))]:
                    bestActionNo = random.randrange(0, 3)
                else:
                    stateActions = self.buildStatesActions(stateActions, state)
                    Q_pred = QNetwork.predict(stateActions)
                    bestActionNo = np.argmax(Q_pred)

                bestAction = self.ACTIONS[bestActionNo]
                newState, rew, done = self.catcher.step([bestAction])
                replayBuffer.append([t, state, bestAction, rew, newState, done])
                [bState, bRew, bNextState, bDone] = replayBuffer.getBatch()

                for j in range(batchSize):
                    if bDone[j]:
                        y[j] = bRew[j]
                    else:
                        inputs = self.buildStatesActions(stateActions,
                                                        bNextState[j])
                        predRewTarget = targetNetwork.predict(inputs)
                        # pred = QNetwork.predict(inputs)
                        # input = inputs[np.argmax(predRew)]  # does not work
                        y[j] = bRew[j] + gamma * np.max(predRewTarget)
                QNetwork.fit(bState, y, epochs=5, verbose=False)
                # QNetwork.train_on_batch(bState, y)
                state = newState
                epsNo += 1
        return QNetwork

    # -----------------------------------------------------------------------
    #                Deep deterministic Policy gradients DDPG
    # 				 ========================================
    # ------------------------------------------------------------------------
    def ddpg(self, sizeRpb=1000, nEp = 100, batchSize=1000, tMax = 220,
             epsStart=1, epsStop=0.01, xplrSteps=None):
        """
        :param sizeRpb:	(int) size of replay buffer
        :param nEp:		(int) number of episodes
        :param batchSize:		(int) number of batch in minibatch
        :param tMax:		(int) number of time steps
        """
        mu, sigma = 0, 0.1 # mean and standard deviation of the random process N
        gamma = 0.95 # discounted reward
        tau = 0.1 # learning rate of target networks for soft tracking

        """Use session for sampled gradient policy"""
        sess = tf.Session()
        K.set_session(sess)

        if xplrSteps is None:
            xplrSteps = int(nEp*(tMax/2))

        epsilons = np.linspace(epsStart, epsStop, xplrSteps)

        """Definition of the actor networks"""
        actor = ActorNetwork(sess, 4, 1, batchSize, tau, 0.0005,
                             self.MAX_RIGHT)
        # value network
        # -------------
        # Use a special class for gradient (see reference)
        # init actor and actor target network
        # actor = self._ddpgBuildActor()  # mu
        # actor.compile(optimizer="adam", loss='mse')

        # Target network
        # --------------
        # actorT = self._ddpgBuildActor()
        # actorT.set_weights(actor.model.get_weights())
        # actorT.compile(optimizer="adam", loss='mse')

        """Definition of the critic networks"""
        critic = CriticNetwork(sess, 4, 1, batchSize, tau, 0.001)
        # value network
        # -------------
        # critic = self._ddpgBuildCritic()  # Q net
        # critic.compile(optimizer="adam", loss='mse')

        # Target network
        # --------------
        # criticT = self._ddpgBuildCritic()
        # criticT.set_weights(critic.model.get_weights())
        # criticT.compile(optimizer="adam", loss='mse')

        # init replay buffer
        # -------------------
        listEp, stat = self.buildEpisodes(int(sizeRpb/100))
        feat_state = 4 # feature state = bar_center_x, bar_velocity, fruit_center_x, fruit_center_y
        vecEp = np.zeros((stat["nTuple"], feat_state+1+1+feat_state)) # tuple = state, action, reward, new_state
        index = 0
        for ep in listEp: # from list of episode to numpy array
            for tup in ep:
                vecEp[index][0:4] = tup[0]
                vecEp[index][4] = tup[1]
                vecEp[index][5] = tup[2]
                vecEp[index][6:10] = tup[3]
                index += 1
        rpb = vecEp[0:sizeRpb] # replay buffer filled with random actions

        # init minibatch
        miniB = np.zeros((batchSize, 10))
        epsNo = 0
        for ep in ProgressBar(range(nEp), desc='Training DDPG'):
            # init random process N
            randProc = lambda x: (max(self.MAX_LEFT, min(self.MAX_RIGHT, x + np.random.normal(mu, sigma, 1)[0])))
            # In the original paper: Ornstein-Uhlenbeck process

            # init state
            self.catcher.reset()
            s = self.catcher.observe()
            done = False

            for t in range(tMax):
                if done:
                    # get new init state
                    self.catcher.reset()
                    s = self.catcher.observe()

                # select action
                eps = epsilons[int(min(xplrSteps-1, epsNo))]
                # or use randproc(actor.model.predict(np.array([s]))[0])
                # with a decrease variance
                a = self._epsGreedy(actor.model.predict(np.array([s]))[0], eps)

                # execute action
                sNew, rew, done = self.catcher.step([a])

                # store transition in replay buffer
                # -----------------------------------
                index = random.randint(0, rpb.shape[0]-1)
                rpb[index, 0:4] = s
                rpb[index, 4] = a
                rpb[index, 5] = rew
                rpb[index, 6:10] = sNew

                # get minibatch from rpb
                # -----------------------
                for sample in range(batchSize):
                    miniB[sample, :] = rpb[random.randint(0, rpb.shape[
                        0]-1), :]

                # update reward from mini batch
                # -----------------------------
                nextStatesBToPredict = miniB[:, 6:10] # sampled next states
                # [:, 0] flattens horizontally the prediction
                actionSelectedByCurrPolicy = actor.target_model.predict(nextStatesBToPredict[:, 0:4])[:, 0]  # computed with network mu'
                nextQ = critic.target_model.predict([nextStatesBToPredict,
                                                     actionSelectedByCurrPolicy])[:, 0]  # y_i ==
                # target Q value is computed with network Q'


                # Compute Q'
                y_t = miniB[:, 5] + gamma*nextQ

                # update critic network Q
                # -----------------------
                # # Q_val = critic.forward([states, actions])
                # # critic loss = mse_loss(Q_val, Qprime)
                # critic.fit(miniB[:, 0:5], miniB[:, 5], epochs=3, verbose=0)

                loss = 0
                loss += critic.model.train_on_batch([miniB[:, 0:4], miniB[:,
                 4]], y_t)


                # update actor by performing policy gradient
                # ------------------------------------------

                # states = miniB[:, 0:4]  # sampled sates
                # predActions = actor.model.predict(miniB[:, 0:4])
                #
                # # we still need to do the policy gradients, the following
                # # line should be used but we don't know how exactly.
                # # see : https://yanpanlau.github.io/2016/10/11/Torcs-Keras.html for more informations
                #
                # grad = tf.gradients(states, predActions)
                #
                # # tf.train.AdamOptimizer(LEARNING_RATE).apply_gradients(grads)
                #
                # # We need to apply the chain rule and average the prediction
                # #  over the batch before performing the backpropagation.
                # policyLoss = - critic.predict(miniB[:, 0:5], actor.predict(
                #     miniB[:, 0:5])).mean()
                #
                # # Performing the backpropagation with this loss on the actor is
                # # straightforward in PyTorch but we could not find a solution
                # # in Keras.


                act4Gradient = actor.model.predict(miniB[:, 0:4])
                grads = critic.gradients(miniB[:, 0:4], act4Gradient)
                actor.train(miniB[:, 0:4], grads)

                # update target critic and actor
                # ------------------------------

                self._ddpgUpdateTargetNet(critic, tau)
                self._ddpgUpdateTargetNet(actor, tau)

                # Decrease linearly exploration greedy prob.
                epsNo += 1


            # if (ep+1) % round(M/10) == 0:
            #     actor.target_model.save("ddpg"+str(ep+1)+".h5")

        return actor.target_model

    def _ddpgUpdateTargetNet(self, actorOrCriticNet, tau):
        # actorOrCriticNet.target_model.set_weights(tau * actorOrCriticNet.model.get_weights() + (
        #         1 - tau) * actorOrCriticNet.target_model.get_weights())
        # -> does not work ! Need to loop manually

        weights = actorOrCriticNet.model.get_weights()
        targetWeights = actorOrCriticNet.target_model.get_weights()
        for i in range(len(weights)):
            targetWeights[i] = tau * weights[i] + (1 - tau) * targetWeights[i]
        actorOrCriticNet.target_model.set_weights(targetWeights)

    def _epsGreedy(self, actionFloat, eps):
        # randProc = lambda x: (max(self.MAX_LEFT, min(self.MAX_RIGHT, x +
        #                                              np.random.normal(mu,
        #                                                               sigma,
        #                                                               1)[0])))
        if random.random() < eps:
            return random.uniform(self.MAX_LEFT, self.MAX_RIGHT)
        else:
            return actionFloat

    def _ddpgBuildCritic(self):
        # Side note: in the original paper, the network takes both the
        # states and the action as inputs.
        # However, the actions was not included until the 2nd hidden layer of
        # the Q-network (use of a merge layer).
        reg = Sequential()
        reg.add(Dense(20, input_dim=5, kernel_initializer="uniform",
                      activation="relu"))
        reg.add(Dense(20, activation="relu"))
        reg.add(Dense(1,  activation="linear"))
        return reg

    def _ddpgBuildActor(self):
        reg = Sequential()
        reg.add(Dense(20, input_dim=4, kernel_initializer="uniform",
                      activation="relu"))
        reg.add(Dense(20, activation="relu"))
        reg.add(Dense(1,  activation="tanh")) #output in -1 and 1
        reg.add(Lambda(lambda a : a*self.MAX_RIGHT)) # output in the action space
        return reg

    # -----------------------------------------------------------------------
    # 							Utility methods
    # 							===============
    # ------------------------------------------------------------------------

    def _cleanImgFolder(self):
        try:
            images = [img for img in os.listdir('images') if img.endswith(".png")]
            for img in images:
                os.remove('images/' + img)
        except FileNotFoundError as e:
            warnings.warn("Can't empty folder /images, folder does not "
                          "exists", )


# -----------------------------------------------------------------------
# 							Replay buffer manager
# 							======================
# ------------------------------------------------------------------------


class Memory:
    """
    A circular buffer with the option of random discard
    """

    def __init__(self, simulator, capacity, randomPop=True,
                 episodeTMax=100, batchSize=32):
        self.capacity = capacity
        self.sim = simulator
        # Fill buffer to capacity
        df, _ = self.sim.buildTransitions(capacity,
                                            episodeTMax=episodeTMax)
        # Store only numpy data for performance and reconstruct later data
        # frame if required
        self.data = df.values
        self.colName = list(df.columns.values)
        self.indice = {k: v for v, k in enumerate(self.colName)}
        self.randomPop = randomPop
        self.batchSize = batchSize


    def append_df(self, observations):
        """
        Append a dataframe row
        :param observations: row in df format
        """
        if self.randomPop:

            self.data[np.random.choice(self.data.shape[0],
                                       observations.shape[0],
                                  replace=False)] = observations.values
        else:
            self.data =self.data[observations.shape[0]:, :]
            self.data = np.vstack((self.data, observations.values))

    def append(self, observation):
        """
        Append a row to buffer
        :param observation: [t, state, action, rew, nextState, done]
        :return:
        """
        [t, state, action, rew, nextState, done] = observation
        row = np.array([t,state[0], state[1], state[2], state[3],
              action, nextState[0], nextState[1], nextState[2],
              nextState[3], rew, self.sim.LEFT, self.sim.RIGHT,
              self.sim.STAY, 0, done])
        if self.randomPop:

            self.data[np.random.choice(self.data.shape[0], 1,
                                  replace=False)] = row
        else:
            self.data =self.data[1:, :]
            self.data = np.vstack((self.data, row))

    def toDf(self):
        """
        :return: a dataframe
        """
        return pd.DataFrame(data=self.data, columns=self.colName)

    def getXTrain(self):
        barX = self.indice["barX"]
        barV = self.indice["barV"]
        fruitX = self.indice["fruitX"]
        fruitY = self.indice["fruitY"]
        act = self.indice["action"]
        return self.data[:, [barX, barV, fruitX, fruitY, act]]

    def getYTrain(self):
        return np.ravel(self.data[:, self.indice["rew"]])

    def getBatch(self):
        barX = self.indice["barX"]
        barV = self.indice["barV"]
        fruitX = self.indice["fruitX"]
        fruitY = self.indice["fruitY"]
        nextBarX = self.indice["nextBarX"]
        nextBarY = self.indice["nextBarV"]
        nextFruitX = self.indice["nextFruitX"]
        nextFruitY = self.indice["nextFruitY"]
        act = self.indice["action"]
        rew = self.indice["rew"]
        done = self.indice['done']
        batch = self.data[np.random.choice(self.data.shape[0],
                                           self.batchSize, replace=False)]
        states = batch[:,[barX, barV, fruitX, fruitY, act]]
        rews = batch[:, rew]
        nextStates = batch[:, [nextBarX, nextBarY, nextFruitX, nextFruitY]]
        dones = batch[:, done]
        return [states, rews, nextStates, dones]
