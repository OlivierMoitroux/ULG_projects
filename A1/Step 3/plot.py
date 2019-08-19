import main
import numpy as np
import matplotlib.pyplot as plt
import random
import os

def updateSquareErrorQ(Q1, Q2, Q_err, indexUpdated):
    for index in indexUpdated:
        [x, y] = index[0]
        u = index[1]
        Q_err[u][x, y] = (Q2[u][x, y]-Q1[u][x, y])**2
    return Q_err

def computeSumErr(Q_err):
    sum = 0.0
    for u in range(4):
        for x in range(5):
            for y in range(5):
                sum += Q_err[u][x, y]
    return sum


def plotVarBeta(simulator):
    print("Generating evolution of variance over beta ...")
    betas = np.linspace(0, 1, 50)
    list = np.zeros([50, 1000])
    for i, beta in enumerate(betas):
        for n_sim in range(1000):
            J = simulator.simulateAll(1, main.upPolicy, DISCNTFACT,
                                      deterministic=False,
                                      beta=beta)
            list[i, n_sim] = J[3, 3]

    plt.plot(betas, np.var(list, axis=1))
    factor = 0.1
    axes = plt.gca()
    ylim = axes.get_ylim()
    new_ylim = (ylim[0] + ylim[1]) / 2 + np.array((-0.5, 0.5)) * (
            ylim[1] - ylim[0]) * (1 + factor)
    axes.set_ylim(ylim[0], new_ylim[1])
    plt.xlabel(r'$\beta$')
    plt.ylabel('$V\{J_{1}(3,3)\}$', rotation=0)
    plt.title('Variance of cumulative expected reward (stochastic)')
    plt.rcParams["font.size"] = 15

    plt.savefig("beta.eps")
    plt.show()

def plotDetStochaOverN(simulator, beta, discntFact):
    print("Generating J over N for deterministic and stochastic settings ...")
    # plt.figure(figsize=(20, 8))
    WIDTH = simulator.width
    HEIGHT = simulator.height

    T_PLOT = 700
    prevCumJDet = np.zeros([WIDTH, HEIGHT])
    prevCumJSto = np.zeros([WIDTH, HEIGHT])
    historyDet = []
    historySto = []
    for t in range(1, T_PLOT):
        prevCumJDet = simulator.simulateAll(t, main.upPolicy, discntFact,
                                            t_start=t,
                                            init=prevCumJDet,
                                            deterministic=True)
        sum = np.zeros([WIDTH, HEIGHT])
        for n_sim in range(200):
            J = simulator.simulateAll(t, main.upPolicy, discntFact, t_start=t,
                                      init=prevCumJDet,
                                      deterministic=False, beta=beta)
            sum += J.data
        mean = sum / 200
        prevCumJSto = main.Grid(WIDTH, HEIGHT, mean)
        historyDet.append(prevCumJDet)
        historySto.append(prevCumJSto)

    clrs = ('r', 'g', 'b', 'c', 'y')
    time = [i for i in range(1, T_PLOT)]

    # Plot det
    for x in range(WIDTH):
        for y in range(HEIGHT):
            lineDet = []
            for t in range(T_PLOT - 1):
                lineDet.append(historyDet[t][x, y])
            plt.plot(time, lineDet, clrs[x])
    plt.xlabel('N')
    plt.ylabel('$J_N$', rotation=0)
    plt.title('Deterministic')
    plt.rcParams["font.size"] = 15
    plt.savefig("det.eps")
    plt.show()

    # Plot stocha
    plt.clf()
    plt.cla()
    plt.close()

    for x in range(WIDTH):
        for y in range(HEIGHT):
            lineSto = []
            for t in range(T_PLOT - 1):
                lineSto.append(historySto[t][x, y])
            plt.plot(time, lineSto, clrs[x])
    plt.xlabel('N')
    plt.ylabel('$J_N$', rotation=0)
    plt.title(r'Stochastic ($\beta = '+str(BETA)+'$)')
    plt.rcParams["font.size"] = 15
    plt.savefig("stocha.eps")
    plt.show()


def plotConvergenceP(sim, maxLenHistory, beta, MOVES):

    print("Plotting convergence of P(x'|x, u) ...")
    width = sim.width
    height = sim.height
    N = maxLenHistory
    dirs = ["up", "left", "right", "down"]
    linePDet = []
    linePSto = []
    t = []

    startCell = [random.randint(0, width - 1), random.randint(0, height - 1)]
    histDet = sim.buildRandTrajectory(startCell, maxLenHistory, MOVES, deterministic=True,
                                      seed=8080)
    histSto = sim.buildRandTrajectory(startCell, maxLenHistory, MOVES,
                                      deterministic=False, beta=beta, seed=8080)


    for n in range(2, N+1):
        errPDet = 0.0
        errPSto = 0.0

        for nextX in range(width):
            for nextY in range(height):
                for x in range(width):
                    for y in range(height):
                        for dir in dirs:
                            action = MOVES[dir]

                            nextCell = [nextX, nextY]
                            currCell = [x, y]

                            # a) Deterministic setting
                            truePDet = sim.transitionProb(nextCell, currCell,
                                                         action, beta=0.0)

                            estPDet = sim.estTransitionProb(nextCell, currCell,
                                                            dir, histDet[:n])
                            # squared error of transition probability
                            errPDet += (truePDet - estPDet)**2

                            # b) Stochastic setting
                            truePSto = sim.transitionProb(nextCell, currCell,
                                                          action, beta=beta)
                            estPSto = sim.estTransitionProb(nextCell, currCell,
                                                            dir, histSto[:n])
                            # squared error on transition probability
                            errPSto += (truePSto - estPSto)**2

        linePDet.append(errPDet)
        linePSto.append(errPSto)
        t.append(n)
    plt.plot(t, linePDet, '-r', t, linePSto, '-b')
    plt.legend(["Deterministic", "Stochastic"])
    plt.title("Transition probability")
    plt.savefig("convergenceP.eps")
    plt.show()


def plotConvergencePTest(sim, nTraj, lengthTraj, beta, MOVES):

    print("Plotting convergence of P(x'|x, u) ...")
    width = sim.width
    height = sim.height
    N = nTraj * lengthTraj
    dirs = ["up", "left", "right", "down"]
    linePDet = []
    linePSto = []
    t = []

    histDet = sim.buildRandTrajectories(nTraj, lengthTraj, MOVES,
                                        deterministic=True)
    histSto = sim.buildRandTrajectories(nTraj, lengthTraj, MOVES,
                                        deterministic=False,
                                        beta=beta)
    for n in range(2, N+1):
        errPDet = 0.0
        errPSto = 0.0

        for nextX in range(width):
            for nextY in range(height):
                for x in range(width):
                    for y in range(height):
                        for dir in dirs:
                            action = MOVES[dir]

                            nextCell = [nextX, nextY]
                            currCell = [x, y]

                            # a) Deterministic setting
                            truePDet = sim.transitionProb(nextCell, currCell,
                                                         action, beta=0.0)

                            estPDet = sim.estTransitionProb(nextCell, currCell,
                                                            dir, histDet[:n])
                            # squared error of transition probability
                            errPDet += (truePDet - estPDet)**2

                            # b) Stochastic setting
                            truePSto = sim.transitionProb(nextCell, currCell,
                                                          action, beta=beta)
                            estPSto = sim.estTransitionProb(nextCell, currCell,
                                                            dir, histSto[:n])
                            # squared error on transition probability
                            errPSto += (truePSto - estPSto)**2

        linePDet.append(errPDet)
        linePSto.append(errPSto)
        t.append(n)
    plt.plot(t, linePDet, '-r', t, linePSto, '-b')
    plt.legend(["Deterministic", "Stochastic"])
    plt.title("Transition probability")
    plt.savefig("convergenceP.eps")
    plt.show()


def plotConvergenceR(sim, maxLenHistory, beta, MOVES):
    print("Plotting convergence of r(x, u) ...")
    width = sim.width
    height = sim.height
    N = maxLenHistory
    dirs = ["up", "left", "right", "down"]
    lineRDet = []
    lineRSto = []
    t = []

    startCell = [random.randint(0, width - 1), random.randint(0, height - 1)]
    histDet = sim.buildRandTrajectory(startCell, maxLenHistory, MOVES,
                                      deterministic=True,
                                      seed=8080)
    histSto = sim.buildRandTrajectory(startCell, maxLenHistory, MOVES,
                                      deterministic=False, beta=beta, seed=8080)

    for n in range(2, N + 1):
        errRDet = 0.0
        errRSto = 0.0

        for x in range(width):
            for y in range(height):
                for dir in dirs:
                    action = MOVES[dir]

                    currCell = [x, y]

                    # a) Deterministic setting
                    truePDet = sim.rewardFun(currCell, action, beta=0.0)

                    estPDet = sim.estReward(currCell, dir, histDet[:n])
                    errRDet += (truePDet - estPDet) ** 2

                    # b) Stochastic setting
                    truePSto = sim.rewardFun(currCell, action, beta=beta)
                    estPSto = sim.estReward(currCell, dir, histSto[:n])
                    errRSto += (truePSto - estPSto) ** 2

        lineRDet.append(errRDet)
        lineRSto.append(errRSto)
        t.append(n)
    plt.plot(t, lineRDet, '-r', t, lineRSto, '-b')
    plt.legend(["Deterministic", "Stochastic"])
    plt.title("Reward")
    plt.savefig("convergenceR.eps")
    plt.show()

def plotConvergenceRTest(sim, nTraj, lengthTraj, beta, MOVES):
    print("Plotting convergence of r(x, u) ...")
    width = sim.width
    height = sim.height
    N = nTraj*lengthTraj
    dirs = ["up", "left", "right", "down"]
    lineRDet = []
    lineRSto = []
    t = []

    histDet = sim.buildRandTrajectories(nTraj, lengthTraj, MOVES,
                                        deterministic=True)
    histSto = sim.buildRandTrajectories(nTraj, lengthTraj, MOVES,
                                        deterministic=False,
                                        beta=beta)

    for n in range(2, N + 1):
        errRDet = 0.0
        errRSto = 0.0

        for x in range(width):
            for y in range(height):
                for dir in dirs:
                    action = MOVES[dir]

                    currCell = [x, y]

                    # a) Deterministic setting
                    truePDet = sim.rewardFun(currCell, action, beta=0.0)

                    estPDet = sim.estReward(currCell, dir, histDet[:n])
                    errRDet += (truePDet - estPDet) ** 2

                    # b) Stochastic setting
                    truePSto = sim.rewardFun(currCell, action, beta=beta)
                    estPSto = sim.estReward(currCell, dir, histSto[:n])
                    errRSto += (truePSto - estPSto) ** 2

        lineRDet.append(errRDet)
        lineRSto.append(errRSto)
        t.append(n)
    plt.plot(t, lineRDet, '-r', t, lineRSto, '-b')
    plt.legend(["Deterministic", "Stochastic"])
    plt.title("Reward")
    plt.savefig("convergenceR.eps")
    plt.show()


def plotConvergenceQ(sim, nSamplesTot, beta, listQ_NDet, listQ_NSto, discntFact,
                     alpha):

    detErr = []
    stoErr = []

    detTraj = sim.buildRandTrajectories2(1, nSamplesTot, deterministic=True,
                                         beta=beta)

    stoTraj = sim.buildRandTrajectories2(1, nSamplesTot, deterministic=False,
                                         beta=beta)

    estQListDet = [main.Grid(sim.width, sim.height, 0) for u in range(4)]
    estQListSto = [main.Grid(sim.width, sim.height, 0) for u in range(4)]

    estQListErrDet = [main.Grid(sim.width, sim.height, 0) for u in range(4)]
    estQListErrSto = [main.Grid(sim.width, sim.height, 0) for u in range(4)]

    for n in range(nSamplesTot):
        [estQListDet, indexUpdatedDet ]= sim.q_learning_dynamic(detTraj,
                                                                estQListDet, n,
                                                                nSamplesTot,
                                                                True, discntFact, alpha)
        [estQListSto, indexUpdatedSto] = sim.q_learning_dynamic(stoTraj,
                                                                estQListSto, n,
                                                                nSamplesTot, True, discntFact, alpha)


        updateSquareErrorQ(estQListDet, listQ_NDet, estQListErrDet, indexUpdatedDet)
        updateSquareErrorQ(estQListSto, listQ_NSto, estQListErrSto,
                           indexUpdatedSto)

        detErr.append(computeSumErr(estQListErrDet))
        stoErr.append(computeSumErr(estQListErrSto))

    t = [i for i in range(nSamplesTot)]
    plt.plot(t, detErr, "-r", t, stoErr, "-b")
    plt.xlabel('N')
    plt.ylabel('Square error')
    plt.title('Convergence of Q')
    plt.rcParams["font.size"] = 15
    plt.legend(["Deterministic", "Stochastic"])
    plt.savefig("convQ.eps")
    plt.show()


if __name__ == '__main__':

    domainInstanceValues = [[-3, 1, -5, 0, 19],
                            [6, 3, 8, 9, 10],
                            [5, -8, 4, 1, -8],
                            [6, -9, 4, 19, -5],
                            [-20, -17, -4, -3, 9]
                            ]
    MOVES = {'right': (1, 0), 'left': (-1, 0), 'up': (0, 1), 'down': (0, -1)}
    DISCNTFACT = 0.99
    BETA = 0.2

    simulator = main.Simulator(5, 5, domainInstanceValues, MOVES)

    # plotDetStochaOverN(simulator, BETA, DISCNTFACT)
    # plotVarBeta(simulator)

    # # Plot the evolution of the convergence over N
    # plotConvergenceP(simulator, 550, BETA, MOVES)
    # plotConvergenceR(simulator, 550, BETA, MOVES)
    #
    # # Plot the evolution of the convergence over N. N being the length of a
    # # global unrealistic trajectory that is the result of the concatenation
    # # of several smaller ones.
    # plotConvergenceRTest(simulator, 100, 5, BETA, MOVES)
    # plotConvergencePTest(simulator, 100, 5, BETA, MOVES)

    # """Q4: Q_N"""
    [JDet, optPolicyDet, listQ_NDet] = main.question4(simulator, 500,
                                                     DISCNTFACT, 0,
                                                      silentStep=True)
    [JSto, optPolicySto, listQ_NSto] = main.question4(simulator, 500,
                                                  DISCNTFACT, BETA,
                                                      silentStep=True)

    plotConvergenceQ(simulator, 600000, BETA, listQ_NDet, listQ_NSto,
                     DISCNTFACT, 0.05)






