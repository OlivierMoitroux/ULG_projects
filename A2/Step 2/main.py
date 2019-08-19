from toolbox import *
import matplotlib.pyplot as plt
import plot
from enum import Enum
from sklearn.ensemble import ExtraTreesRegressor
from sklearn.linear_model import LinearRegression
from sklearn.preprocessing import MinMaxScaler

from keras.models import Sequential
from keras.layers import Dense
from keras.models import load_model


class Axis(Enum):
    # column
    col = int(0)
    # Row
    row = int(1)


def Q2(sim, initState, policy, fPlotName, maxTimeStep=70, GAMMA=1.0):

    print("========\nQuestion 2\n========\n")
    cumRew, hist = sim.simulate(initState, policy, gamma=GAMMA,
                                histRet=True, t_stop=maxTimeStep)
    m = max(getPosFromHist(hist))
    print("{}\n---------".format(fPlotName))
    print("Max position = {}m".format(m))
    pos = getPosFromHist(hist)
    speed = getSpeedFromHist(hist)
    timesteps = [t for t in range(len(hist))]
    plot.plotPosSpeed(timesteps, pos, speed, fPlotName)

    print("Cumulative reward = {}".format(cumRew))


def Q2Rand(sim, initState, N_EPISODE):
    # Generating random episodes
    listEp, stat = sim.buildEpisodes(N_EPISODE, initState)
    # To get F, one needs to convert [[ep1][ep2], ..] in [ep1, ep2, ..]
    print("Simulation with F composed of {} 4-tuples.".format(stat["nTuple"]))
    print("{} reward(s) = 1 has been observed.\n".format(stat["nWin"]))
    print("Here are the cumXpctRew of these episodes:")
    randXpctdRewWin = []
    for ep in listEp:
        # Get the last immediate reward of each episode in list of episodes
        if ep[-1][2] > 0:
            randXpctdRewWin.append(getCumReward(ep, 0.95))
    print(randXpctdRewWin)
    print("mean = {}, var = {}".format(np.mean(randXpctdRewWin),
                                       np.var(randXpctdRewWin)))


def Q3(sim, nSim, t_stop, policy, gamma):
    print("========\nQuestion 3\n========\n")

    # Get epsilon machine
    eps = np.finfo(float).eps
    boundPos = [-1 + eps, 1 - eps]
    boundS = [-3 + eps, 3 - eps]
    xpctdRew = sim.monteCarlo(nSim, t_stop, policy, boundPos, boundS, gamma)
    print("xpctdRew (nSim={}, t_stop={}) = {}".format(nSim, t_stop, xpctdRew))

def Q3Debug(sim, nSim, t_stop, policy, gamma):
    print("========\nQuestion 3\n========\n")

    eps = np.finfo(float).eps
    boundPos = [-1 + eps, 1 - eps]
    boundS = [-3 + eps, 3 - eps]
    arrayCumRew = np.array(sim.monteCarloDebug(nSim, t_stop, policy, boundPos,
                                         boundS, gamma))
    m = np.mean(arrayCumRew, axis=Axis.col.value)
    v = np.var(arrayCumRew, axis=Axis.col.value)
    print("Mean cum rew = {}".format(m))
    print("Var cum rew = {}".format(v))
    t = [i for i in range(len(m))]
    plot.plotMeanVar(t, m, v, "cumulative reward", "CumRewMonteCarlo.eps")
    print(m[-1])
    # print("xpctdRew (nSim={}, t_stop={}) = {}".format(nSim, t_stop, xpctdRew))


def Q4(sim, policy, fVideoName, maxTimeStep=70, GAMMA=1.0):
    print("========\nQuestion 4\n========\n")
    cumXpctdRew, hist = sim.simulate(initState, policy, gamma=GAMMA,
                                     histRet=True, t_stop=maxTimeStep)
    plot.makeVideo(hist, fVideoName)


def Q5_train(sim, nTraj, initState, gamma, fittedQIterLR, fittedQIterET,
             fittedQIterNN, intermediates2Store):
    """
    Train the 3 estimators
    :param sim: simulator instance
    :param nTraj: number of trajectories to build the dataset
    :param initState: [p_0, s_O]
    :param gamma: discount factor
    :param fittedQIterLR: n
    :param fittedQIterET: n
    :param fittedQIterNN: n
    :param intermediates2Store: list of intermediate models to store
    :return: / but save models on disk
    """
    # Build sequence of episodes
    trajectories, stat = sim.buildEpisodes(nTraj, initState)

    pickle.dump(trajectories, open("trajectories.sav", 'wb'))
    pickle.dump(stat, open("stat.sav", 'wb'))

    # trajectories = pickle.load(open("trajectories.sav", 'rb'))
    # stat = pickle.load(open("stat.sav", 'rb'))

    ProgressBar.write("Number of one-step transistions in dataset = {}".format(
        stat["nTuple"]))
    ProgressBar.write("\nAmong which, {} lead to a win".format(stat["nWin"]))

    # Train with extremely randomized trees
    ProgressBar.write("Training extremely randomized trees")
    model = ExtraTreesRegressor(n_estimators=100, verbose=False, n_jobs=-1)
    estQModel, statModel = sim.fittedQ(model, trajectories, gamma, fittedQIterET,
                                  saveIntermediate=intermediates2Store,
                                  modelType="et")

    # Save trained model to disk
    pickle.dump(estQModel, open("trained_et.sav", 'wb'))
    pickle.dump(statModel, open("trained_et_stat.sav", 'wb'))

    # Train with linear regression
    ProgressBar.write("Training linear regression")
    model = LinearRegression(n_jobs=-1)
    estQModel, statModel = sim.fittedQ(model, trajectories, gamma, fittedQIterLR,
                                  saveIntermediate=intermediates2Store,
                                  modelType="lr")
    pickle.dump(estQModel, open("trained_lr.sav", 'wb'))
    pickle.dump(statModel, open("trained_lr_stat.sav", 'wb'))

    # Train with NN
    ProgressBar.write("Training neural network")
    dataset = trajectories2DataSet(trajectories)
    X_train = dataset[['pos', 'speed', 'action']].values
    y_train = np.ravel(dataset[['rew']].values)

    scalarX, scalarY = MinMaxScaler(), MinMaxScaler()
    scalarX.fit(X_train)
    scalarY.fit(y_train.reshape(stat["nTuple"], 1))
    X = scalarX.transform(X_train)
    y = scalarY.transform(y_train.reshape(stat["nTuple"], 1))
    # define and fit the final model
    model = Sequential()
    model.add(Dense(100, input_dim=3, activation='relu'))
    model.add(Dense(100, activation='relu'))
    model.add(Dense(1, activation='linear'))
    model.compile(loss='mse', optimizer='adam')

    estQModel,statModel = sim.fittedQ(model, trajectories, gamma, fittedQIterNN,
                                 saveIntermediate=intermediates2Store,
                                 modelType="nn")
    estQModel.save('trained_nn.h5')
    pickle.dump(statModel, open("trained_nn_stat.sav", 'wb'))

def Q5_dispDistQ(sim, gamma, fittedQIterLR, fittedQIterET, fittedQIterNN):
    """
    Display the distance between Q_N and Q_N-1
    """
    trainedEtStat = pickle.load(open("trained_et_stat.sav", 'rb'))
    trainedLrStat = pickle.load(open("trained_lr_stat.sav", 'rb'))
    trainedNnStat = pickle.load(open("trained_nn_stat.sav", 'rb'))

    plot.plotDistanceQ(fittedQIterET, trainedEtStat["distQ"],
                       "extremely rand trees", "distQET.eps")

    plot.plotDistanceQ(fittedQIterLR, trainedLrStat["distQ"],
                       "linear regression", "distQLR.eps")
    plot.plotDistanceQ(fittedQIterNN, trainedNnStat["distQ"],
                       "neural network", "distQNN.eps")


def Q5_video(sim, initState, trainedModel, gamma, fVideoName, modelType):
    """
    Generate the video from a trained model
    """
    cumRew, histRet = sim.simulateFittedQPolicy(initState, trainedModel,
                                                gamma, modelType,
                                                t_stop=100, histRet=True)

    plot.makeVideo(histRet, fVideoName)


def Q5_plotIntermediatePoliciesHeatMaps(modelType, savedIntermediate):
    """
    Plot estimated optimal policies and cumulative reward for intermediate
    modesl.
    :param modelType: nn, rf or lr
    :param savedIntermediate: list of intermediate models
    :return: plot
    """
    if modelType == "nn":
        trainedModelList = [
            load_model("trained_" + modelType + str(i) + ".h5")
            for i in savedIntermediate]
    else:
        trainedModelList = [pickle.load(open("trained_"+modelType+str(i)+".sav",
                                             'rb'))
                         for i in savedIntermediate]

    for i, model in enumerate(trainedModelList):
        plot.plotPolicy(model, "policy_"+modelType+str(savedIntermediate[
            i])+".eps", display=True)
        plot.plotHeatMap(model, modelType+str(savedIntermediate[i]))

    if modelType == "nn":
        trainedModel = load_model("trained_" + modelType + ".h5")
    else:
        trainedModel = pickle.load(open("trained_" + modelType + ".sav", 'rb'))

    plot.plotPolicy(trainedModel, "policy_"+modelType+".eps", display=True)


def Q5_plotHeatMaps():
    """
    Plot heat maps corresponding to the expected cumulative reward of each
    of the 3 estimators when they are fully trained.
    :return:
    """
    trainedET = pickle.load(open("trained_et.sav", 'rb'))
    trainedLR = pickle.load(open("trained_lr.sav", "rb"))
    trainedNN = load_model('trained_nn.h5')
    plot.plotHeatMap(trainedET, "et")
    plot.plotHeatMap(trainedLR, "lr")
    plot.plotHeatMap(trainedNN, "nn")

def Q5_trajectory(trainedModel, initState, gamma, modelType):
    """
    Plot the optimal trajectory
    """
    cumRew, histRet = sim.simulateFittedQPolicy(initState, trainedModel,
                                                gamma, modelType,
                                                t_stop=100, histRet=True)
    print("Final cumulative reward = {}".format(cumRew))
    plot.plotTrajectory(histRet, "trajectory"+modelType+".eps")

if __name__ == '__main__':

    np.set_printoptions(formatter={'float': lambda x: "{0:0.4f}".format(x)})


    '''State space parameter'''

    # Discount factor
    GAMMA = 0.95

    N_EPISODE = 1000

    domainInstance = Domain()
    sim = Simulator(domainInstance)
    p_0 = -0.5
    s_0 = 0
    initState = [p_0, s_0]

    # """Q2: result testing on a simple policy"""
    # Q2(sim, initState, accPolicy, "alwaysAcc.eps", maxTimeStep=70)
    # Q2(sim, initState, decPolicy, "alwaysDec.eps", maxTimeStep=70)
    # Q2Rand(sim, initState, N_EPISODE)
    #
    # """Q3: expected cumulative reward"""
    # nSim = 1500
    # t_stop = 50
    # Q3(sim, nSim, t_stop, accPolicy, GAMMA)
    # Q3Debug(sim, nSim, t_stop, accPolicy, GAMMA)
    #
    # """Q4: Video of the car"""
    # Q4(sim, accPolicy, "alwaysAcc.avi")

    """Q5: Estimation of Q_N with fitted Q-Algorithm"""
    nTraj = 1000
    fittedQIterET = 100
    fittedQIterLR = 150
    fittedQIterNN = 70
    intermediates2Store = (1, 5, 10, 20, 50)
    # This next line can be runned once then commented
    Q5_train(sim, nTraj, initState, GAMMA, fittedQIterLR, fittedQIterET,
             fittedQIterNN, intermediates2Store)

    Q5_dispDistQ(sim, GAMMA, fittedQIterLR, fittedQIterET, fittedQIterNN)

    # Load trained model from disk
    trainedET = pickle.load(open("trained_et.sav", 'rb'))
    trainedLR = pickle.load(open("trained_lr.sav", "rb"))
    trainedNN = load_model('trained_nn.h5')

    # Generate videos
    Q5_video(sim, initState, trainedLR, GAMMA, "fittedQ_lr.avi", "lr")
    Q5_video(sim, initState, trainedET, GAMMA, "fittedQ_et.avi", "nn")

    # Plot intermediate plots
    Q5_plotIntermediatePoliciesHeatMaps("et", intermediates2Store)
    Q5_plotIntermediatePoliciesHeatMaps("lr", intermediates2Store)
    Q5_plotIntermediatePoliciesHeatMaps("nn", intermediates2Store)

    # Plot the finale expected cumulative rewards for each estimator
    Q5_plotHeatMaps()

    # Plot the optimal trajectory
    Q5_trajectory(trainedET, initState, GAMMA, "rf")
    Q5_trajectory(trainedNN, initState, GAMMA, 'nn')

    # stat = pickle.load(open("stat.sav", 'rb'))
    # print(stat['nTuple'])
