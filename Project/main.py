import argparse
import numpy as np
import pickle
import random
import sys
import os
import json
import matplotlib.pyplot as plt
from sklearn import ensemble
from simulator import Simulator
from keras.models import Sequential, load_model
from keras.optimizers import adam
from keras.layers.core import Dense
import warnings
from keras.models import model_from_json
from tester import testAndPlot, testAndPlotOverMany
from keras.models import load_model

def trainET_fqi(trainSet, NUM_TREES, NUM_ITER, GAMMA):
    """
    Train an extra tree estimator for Q
    """
    extraTreesModel = ensemble.ExtraTreesRegressor(NUM_TREES, n_jobs=-1)
    modelType = "extra_trees"
    trainedExtraTrees = sim.fqi(extraTreesModel, modelType, trainSet,
                                NUM_ITER, GAMMA)
    return trainedExtraTrees, modelType

def buildNN_fqi():
    reg = Sequential()
    reg.add(Dense(20, input_dim=5, kernel_initializer="random_uniform",
                  activation="relu"))
    #reg.add(Dense(64, activation="relu"))
    reg.add(Dense(20, activation="relu"))
    reg.add(Dense(1,  activation="linear", kernel_initializer="random_uniform"))
        # reg.compile(optimizer="adam", loss='mse')
    return reg

def buildNN_dql():
    model = Sequential(name="ddql")

    model.add(Dense(40, input_dim=4 + 1, activation='relu',
                    kernel_initializer="random_uniform"))
    model.add(Dense(40, activation='relu'))
    model.add(Dense(1, activation='relu'))
    return model

def trainNN_fqi(trainSet, NUM_ITER, GAMMA):
    """
    Train an NN estimator for Q
    """
    with warnings.catch_warnings():
        warnings.simplefilter("ignore")
        reg = buildNN_fqi()
        reg.compile(optimizer="adam", loss='mse')

        modelType = "NN"
        trainedNN = sim.fqi(reg, modelType, trainSet, NUM_ITER, GAMMA)
    return trainedNN, modelType


if __name__ == '__main__':
    string = '''Arguments to launch the different parts of the assignment.'''
    parser = argparse.ArgumentParser(description=string)
    parser.add_argument("-random",  action="store_true",
                        help=('''Simple test using a random policy.'''))
    parser.add_argument("-FQI",  action="store_true",
                        help=('''FQI with ensemble of trees.'''))
    parser.add_argument("-saveDraw",  action="store_true",
                        help=('''Draw state for each time step and store it in images folder.'''),
                        default=False)
    parser.add_argument("-showDraw",  action="store_true",
                        help=('''Show drawing of state for each time step.'''),
                        default=False)
    parser.add_argument("-discreteAction", action="store_true",
                        help=('''Whether to use discrete or continuous action space.'''),
                        default=True)

    parser.add_argument("-load", action="store_true", help=('''Name of the 
    model to load.'''))

    parser.add_argument("-NN", action="store_true",
                        help=(
                            '''Use a NN for training fqi'''),
                        default=False)

    parser.add_argument("-ET", action="store_true",
                        help=(
                            '''Use a extra trees for training fqi'''),
                        default=False)

    parser.add_argument("-plot", type=str,
                        help=(
                            '''Plot and save the performance of the models in the directory given'''))

    parser.add_argument("-plot_many", type=str, nargs='+',
                        help=(
                            '''Plot and save the performance of the models in the directory given. Expect to have 
                            multiple arguments: the first is the path to the main directory. Then the following ones
                            are the subdirectories containing the models to use. Each should contain the same number
                            of models.'''))

    parser.add_argument("-DQN", action="store_true",
                        help=('''Deep q learning with replay buffer'''),
                        default=False)

    parser.add_argument("-DDQN", action="store_true",
                        help=('''Double deep q learning wit replay buffer'''),
                        default=False)

    parser.add_argument("-DDPG", action="store_true",
                        help=('''Deep Deterministic Policy Gradient for 
                        continuous action space'''),
                        default=False)


    args = parser.parse_args()
    saveDraw = args.saveDraw
    showDraw = args.showDraw
    discreteAction = args.discreteAction

    sim = Simulator(showDraw, saveDraw, discreteAction)

    # Simple test using a random policy
    # =================================
    if args.random:
        print("\nSimple test using a random policy")
        print("=================================")
        ep, stat = sim.buildEpisode(showDraw=showDraw)
        print(("\rEnding at time t = {}\t\tfruits catched = {} &&& "+
            "fruits missed = {}").format(stat["epLen"], stat["nCatched"],
                                         stat["nMissed"]))

    # FQI with ensemble of trees
    # ==========================
    if args.FQI and not args.load:
        print("\nTraining with FQI ")
        print("====================")

        NUM_EP = 10  # number of episodes (observations)
        NUM_TRANSITIONS = 80000
        NUM_ITER = 40  # number of iterations
        NUM_TREES = 50  # number of trees in ensemble of trees
        GAMMA = 0.95  # discount factor

        # build episodes
        #listEp, stat = sim.buildEpisodes(NUM_EP)
        #trainSet = dataset_utils.listEpisodes2DataSet(listEp)
        #trainSet, stat = sim.buildTrainSet(NUM_EP)
        trainSet, stat = sim.buildTransitions(NUM_TRANSITIONS, episodeTMax=100)

        print("\nIn the ", NUM_EP, " random episodes, there was :\n\tnumber of tuples : ", stat["nTuple"],
        ",\n\tfruits catched : ", stat["nCatched"], ",\n\ttfruits missed : ", stat["nMissed"], " .")

        if args.ET:
            trainedModel, modelType = trainET_fqi(trainSet, NUM_TREES, NUM_ITER, GAMMA)
        else:
            trainedModel, modelType = trainNN_fqi(trainSet, NUM_ITER, GAMMA)


    if args.FQI:
        if args.load:
            if args.NN is True:
                sim.model = load_model(args.load)
            else:
                sim.model = pickle.load(open(args.load, 'rb'))

        else:
            sim.model = trainedModel # update model

        print("\nTesting the model:")
        ep, stat = sim.buildEpisode(policy=sim.takePolicyAction,
                                    cleanImages=True, saveDraw=saveDraw,
                                    showDraw=showDraw, verbose=False, tMax=10000)
        print("\nIn the episode played by the model, there was :\n\tnumber of tuples (time step) : ",
        stat["epLen"], ",\n\tfruits catched : ",stat["nCatched"], ",\n\tfruits missed : ", stat["nMissed"],
        " .")

    if args.plot:
        xAxisStr = input("\nWhat should be the x axis name? [str] : ")

        stepStr = input("\nWhat is the step between each models in term of '"+xAxisStr+"'? [int] : ")
        step = int(stepStr)

        typeModel = input("\nThe models are ensemble of trees or neural network? ['ET', 'NN'] : ")

        numEpStr = input("\nHow many episode to do the average on? [int] : ")
        numEp = int(numEpStr)

        testAndPlot(args.plot, typeModel, numEp, step=step, xAxisName=xAxisStr)
        print("The figure has been saved.")

    if args.plot_many:
        xAxisStr = input("\nWhat should be the x axis name? [str] : ")

        stepStr = input("\nWhat is the step between each models in term of '"+xAxisStr+"'? [int] : ")
        step = int(stepStr)

        typeModel = input("\nThe models are ensemble of trees or neural network? ['ET', 'NN'] : ")

        numEpStr = input("\nHow many episode to do the average on? [int] : ")
        numEp = int(numEpStr)

        testAndPlotOverMany(args.plot_many[0], args.plot_many[1:len(args.plot_many)], typeModel, numEp, step=step,
        xAxisName=xAxisStr)
        print("The figure has been saved.")

    if args.DQN:
        if args.load:
            net = buildNN_dql()
            net.load_weights("trained_models/dql/dql480.h5")
        else:
            net = sim.dql_rb(nEpisodes=500, batchSize=20)
        sim.model = net
        ep, stat = sim.buildEpisode(policy=sim.takePolicyAction,
                                    cleanImages=True, saveDraw=saveDraw,
                                    showDraw=showDraw, verbose=False,
                                    tMax=10000)
        print("\nTesting the model:")
        print("\nIn the episode played by the model, there was :\n\tnumber of tuples (time step) : ",
        stat["epLen"], ",\n\tfruits catched : ",stat["nCatched"], ",\n\tfruits missed : ", stat["nMissed"],
        " .")

    if args.DDQN:
        if args.load:
            net = buildNN_dql()
            net.load_weights("trained_models/ddql/ddql400.h5")
        else:
            net = sim.ddql_rb(nEpisodes=500, batchSize=20)
        sim.model = net
        ep, stat = sim.buildEpisode(policy=sim.takePolicyAction,
                                    cleanImages=True, saveDraw=saveDraw,
                                    showDraw=showDraw, verbose=False,
                                    tMax=10000)
        print("\nTesting the model:")
        print("\nIn the episode played by the model, there was :\n\tnumber of tuples (time step) : ",
        stat["epLen"], ",\n\tfruits catched : ",stat["nCatched"], ",\n\tfruits missed : ", stat["nMissed"],
        " .")

    if args.DDPG:
        sim.discreteAction = False
        if args.load:
            net = load_model("trained_models/ddpg/ddpg400.h5")
        else:
            net = sim.ddpg(sizeRpb=2000, nEp=1000, batchSize=100, tMax=200)
        sim.model = net
        ep, stat = sim.buildEpisode(policy=sim.takePolicyAction,
                                    cleanImages=True, saveDraw=saveDraw,
                                    showDraw=showDraw, verbose=False,
                                    tMax=10000)
        print("\nTesting the model:")
        print("\nIn the episode played by the model, there was :\n\tnumber of tuples (time step) : ",
        stat["epLen"], ",\n\tfruits catched : ",stat["nCatched"], ",\n\tfruits missed : ", stat["nMissed"],
        " .")
