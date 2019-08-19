import main
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.pyplot import cm

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


if __name__ == '__main__':

    domainInstanceValues = [[-3, 1, -5, 0, 19],
                            [6, 3, 8, 9, 10],
                            [5, -8, 4, 1, -8],
                            [6, -9, 4, 19, -5],
                            [-20, -17, -4, -3, 9]
                            ]
    MOVES = {'right': (1, 0), 'left': (-1, 0), 'up': (0, 1), 'down': (0, -1)}
    DISCNTFACT = 0.99
    BETA = 0.5

    simulator = main.Simulator(5, 5, domainInstanceValues, MOVES)

    plotDetStochaOverN(simulator, BETA, DISCNTFACT)
    plotVarBeta(simulator)



