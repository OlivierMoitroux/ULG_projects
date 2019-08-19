import pandas as pd
from tqdm import tqdm as ProgressBar
#from simulator import DiscreteAction
import simulator

def listEpisodes2DataSet(listEpisodes):
    """
    Build a panda dataframe that contains relevant information to build a
    dataset
    :param listEpisodes: Set of trajectories used to build the dataset
    :return: panda data frame
    """
    dataset = pd.DataFrame(columns=['t', 'barX', 'barV', 'fruitX','fruitY',
                                    'action',
                                    'nextBarX', 'nextBarV','nextFruitX',
                                    'nextFruitY', 'rew','left', 'right', 'stay',
                                    'bestAction'])
    act = simulator.DiscreteAction()
    T = 0
    for trajectory in ProgressBar(listEpisodes, desc="Building dataset"):
        t = len(trajectory)
        T += t
        [barX, barV, fruitX, fruitY] = getStateFromTraj(trajectory)
        rewards = getRewardsFromTraj(trajectory)
        actions = getActionsFromTraj(trajectory)
        [nextBarX, nextBarV, nextFruitX, nextFruitY] = getNextStateFromTraj(
            trajectory)

        rows = list(zip(list(range(t)), barX, barV, fruitX, fruitY,
                        actions, nextBarX, nextBarV, nextFruitX,
                        nextFruitY, rewards,
                        [act.LEFT]*T,
                        [act.RIGHT]*T,
                        [act.STAY]*T,
                        [0]*T))
        # Append to dataset the data stored in the trajectory
        dataset = dataset.append([pd.Series(i, index=dataset.columns) for i in
                                  rows], ignore_index=True)
    # # Sort by time steps
    # # dataset.sort_values(by="t", inplace=True)
    # # Use time as index and drop the column time
    # # dataset.set_index("t")
    #
    # # Add index column and use it as indexing in dataframe
    dataset = dataset.assign(index=pd.Series([i for i in range(T)]).values)
    # # print("Number of one-step transistions in dataset = {}".format(T))
    return dataset.set_index("index")



def getBarXFromTraj(traj):
    return [item[0][0] for item in traj]

def getBarVFromTraj(traj):
    return [item[0][1] for item in traj]

def getFruitXFromTraj(traj):
    return [item[0][2] for item in traj]

def getFruitYFromTraj(traj):
    return [item[0][3] for item in traj]


def getStateFromTraj(traj):
    # return [item[0] for item in hist]
    return [getBarXFromTraj(traj), getBarVFromTraj(traj), getFruitXFromTraj(
        traj), getFruitYFromTraj(traj)]

def getActionsFromTraj(traj):
    return [item[1] for item in traj]

def getRewardsFromTraj(traj):
    return [item[2] for item in traj]

def getNextBarXFromTraj(traj):
    return [item[3][0] for item in traj]

def getNextBarVFromTraj(traj):
    return [item[3][1] for item in traj]

def getNextFruitXFromTraj(traj):
    return [item[3][2] for item in traj]

def getNextFruitYFromTraj(traj):
    return [item[3][3] for item in traj]

def getNextStateFromTraj(traj):
    return [getNextBarXFromTraj(traj), getNextBarVFromTraj(traj),
            getNextFruitXFromTraj(
        traj), getNextFruitYFromTraj(traj)]


def getCumRewardFromTraj(traj, gamma):
    """Extract the final cumulative reward from an history"""
    immediateRewards = getRewardsFromTraj(traj)
    cumReward = 0.0

    for t, r in enumerate(immediateRewards):
        cumReward += (gamma**t) * r
    return cumReward