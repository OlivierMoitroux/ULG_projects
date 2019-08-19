
import numbers
import numpy as np
import main as main



class SimulateCellTester:
    def __init__(self, WIDTH, HEIGHT, domainInstanceValues, MOVES):
        self.width = WIDTH
        self.height = HEIGHT
        self.rewardGrid = domainInstanceValues
        self.MOVES = MOVES
        self.simulator = main.Simulator(WIDTH, HEIGHT, domainInstanceValues,
                                        MOVES)

    def test(self, initCell, DISCNTFACT, T, t_i=0, initReward=0):
        return self.simulator.simulateCell(initCell, T, main.upPolicy,
                                    DISCNTFACT, t_i=t_i,
                                           cumXpctedReward=initReward,
                                           deterministic=True, silent=False)


class SimulateAllTester:
    def __init__(self, WIDTH, HEIGHT, domainInstanceValues, MOVES):
        self.width = WIDTH
        self.height = HEIGHT
        self.rewardGrid = domainInstanceValues
        self.MOVES = MOVES
        self.simulator = main.Simulator(WIDTH, HEIGHT, domainInstanceValues,
                                     MOVES)

    def test(self, DISCNTFACT):
        print("Computed directly:")
        self.simulator.simulateAll(3, main.upPolicy, DISCNTFACT,
                                   deterministic=True, silent=False)
        print("---")
        print("Computed from initial time {}:".format(2))
        prev = simulator.simulateAll(2, main.upPolicy, DISCNTFACT,
                                     deterministic=True,silent=True)
        simulator.simulateAll(3, main.upPolicy, DISCNTFACT, t_start=3,
                              init=prev, deterministic=True, silent=False)


if __name__ == '__main__':

    # np.set_printoptions(precision=5)
    np.random.seed(seed=8080)

    '''State space parameter'''
    # Action space
    MOVES = {'right': (1, 0), 'left': (-1, 0), 'up': (0, 1), 'down': (0, -1)}

    # Number of time Steps
    T = 4

    # Discount factor (gamma)
    DISCNTFACT = 0.99

    BETA = 0.3

    '''Init. Instance of problem'''
    # Dimensions
    WIDTH = 5
    HEIGHT = 5
    domainInstanceValues = [[-3, 1, -5, 0, 19],
                            [6, 3, 8, 9, 10],
                            [5, -8, 4, 1, -8],
                            [6, -9, 4, 19, -5],
                            [-20, -17, -4, -3, 9]
                            ]

    print("Domain instance:\n{}".format(main.Grid(5,5, domainInstanceValues)))
    simulator = main.Simulator(WIDTH, HEIGHT, domainInstanceValues, MOVES)


    '''Test dynamic programming'''
    print("Test dynamic programming of Simulate all")
    dpt = SimulateAllTester( WIDTH, HEIGHT, domainInstanceValues, MOVES)
    dpt.test(DISCNTFACT)
    print("OK same results")

    print("----------------")

    '''Test simulate cell'''
    print("Evolution of expected cum reward for a given cell")
    sc = SimulateCellTester(WIDTH, HEIGHT, domainInstanceValues, MOVES)
    [initCell, initReward] = sc.test([0, 0], DISCNTFACT, 3)

    print("----------------")
    '''Test dynamic programming simulate cell'''
    print("Test dynamic programming for a given cell (start from t=3)")
    sc.test(initCell, DISCNTFACT, 4, t_i=3, initReward=initReward)
