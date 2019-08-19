from toolbox import *


def Q2(sim, initState, policy, fPlotName, maxTimeStep=70, GAMMA=1.0):

    print("========\nQuestion 2\n========\n")
    cumRew, hist = sim.simulate(initState, policy, gamma=GAMMA,
                                histRet=True, t_stop=maxTimeStep)
    m = max(getPosFromHist(hist))
    print(fPlotName)
    print("Max position = {}m".format(m))
    pos = getPosFromHist(hist)
    speed = getSpeedFromHist(hist)
    timesteps = [t for t in range(len(hist))]
    plt.plot(timesteps, pos, timesteps, speed)
    plt.xlabel("Number of time steps")
    plt.rcParams["font.size"] = 15
    plt.legend(["position (m)", "speed (m/s)"])
    plt.savefig("illustrations/"+fPlotName)
    plt.show()

    print("Cumulative reward:")
    print(cumRew)


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

    eps = np.finfo(float).eps
    boundPos = [-1 + eps, 1 - eps]
    boundS = [-3 + eps, 3 - eps]
    xpctdRew = sim.monteCarlo(nSim, t_stop, policy, boundPos, boundS, gamma)

    print("xpctdRew (nSim={}, t_stop={}) = {}".format(nSim, t_stop, xpctdRew))


def Q4(sim, policy, fVideoName, maxTimeStep=70, GAMMA=1.0):
    print("========\nQuestion 4\n========\n")
    cumXpctdRew, hist = sim.simulate(initState, policy, gamma=GAMMA,
                                     histRet=True, t_stop=maxTimeStep)
    plot.makeVideo(hist, fVideoName)


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

    """Q2: result testing on a simple policy"""
    Q2(sim, initState, accPolicy, "alwaysAcc.eps", maxTimeStep=70)
    Q2(sim, initState, decPolicy, "alwaysDec.eps", maxTimeStep=70)
    Q2Rand(sim, initState, N_EPISODE)

    """Q3: expected cumulative reward"""
    nSim = 1000
    t_stop = 50
    Q3(sim, nSim, t_stop, accPolicy, GAMMA)

    """Q4: Video of the car"""
    Q4(sim, accPolicy, "alwaysAcc.avi")
