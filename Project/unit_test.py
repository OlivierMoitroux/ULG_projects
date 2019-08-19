from simulator import *
import pickle
import random
import sys
import os
import json
import pandas as pd
from keras.models import Sequential
from keras.models import load_model
from keras.models import  model_from_json


def buildModel(name):
    N_ACTIONS = 4
    N_STATES = 4
    EPOCHS = 10
    BATCH_SIZE = 50

    model = Sequential(name=name)

    model.add(Dense(100, input_dim=N_STATES + 1, activation='relu',
                    kernel_initializer="random_normal"))
    model.add(Dense(50, activation='relu'))
    model.add(Dense(1, activation='relu'))
    return model
if __name__ == '__main__':
    sim = Simulator(showDraw=True, saveDraw=False, discreteAction=True)
    # Test memory
    # mem = Memory(sim, 36, randomPop=True,
    #              episodeTMax=100, batchSize=32)
    #
    # test, _ = sim.buildTransitions(5)
    # mem.append(test)
    # mem.append(test)
    # mem.append(test)
    # mem.append(test)
    # a = mem.getDf()
    # b = mem.getXTrain()
    # c = mem.getYTrain()
    # states, actions, rewards, nextStates = mem.getBatch()
    # print()

    # trainedModel = sim.dql_rb()
    # trainedModel.save_weights("trained_models/model_dql_weights.h5",
    #                           overwrite=True)
    # trainedModel.save("trained_models/model_dql.h5", overwrite=True)
    # with open("trained_models/model_architecture_dql.json", "w") as outfile:
    #     json.dump(trainedModel.to_json(), outfile)


    # json_file = open('../trained_models/model_architecture_dql.json', 'r')
    # loaded_model_json = json_file.read()
    # json_file.close()
    # loaded_model = model_from_json(loaded_model_json)

    # loaded_model = Sequential
    # loaded_model = load_model("../trained_models/model_dql.h5")

    # loaded_model = sim.buildModel("dql") # does not work, think it is a
    # function

    model = Sequential(name="ddql")

    model.add(Dense(100, input_dim=4 + 1, activation='relu',
                    kernel_initializer="random_normal"))
    model.add(Dense(50, activation='relu'))
    model.add(Dense(1, activation='relu'))
    model.compile(optimizer="adam", loss="mse")
    #
    #
    model.load_weights("trained_models/ddql/ddql1800.h5")
    sim.model = model

    # model.predict(np.array([25.5,  0. ,  3. , -5. , 1]).reshape((-1, 1)))

    sim.buildEpisode(sim.takePolicyAction, showDraw=True, verbose=True)
