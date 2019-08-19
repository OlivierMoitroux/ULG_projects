from main import *

import cv2
import glob
from display_caronthehill import *
import os
import matplotlib.pyplot as plt
from pathlib import Path

from matplotlib import cm as CM
from matplotlib import mlab as ML
import numpy as NP

def cleanContentDir(directory):
    filelist = glob.glob(directory)
    for f in filelist:
        os.remove(f)
def makeGridDataset():
    nDot = 50
    X_Acc = []
    X_Dec = []
    for i, p in enumerate(np.linspace(-1.0, 1.0, nDot)):
        for j, s in enumerate(np.linspace(-3.0, 3.0, nDot)):
            X_Acc.append([p, s, 4])
            X_Dec.append([p, s, -4])
    X_Acc = np.array(X_Acc)
    X_Dec = np.array(X_Dec)
    return X_Acc, X_Dec
def makeVideo(hist, videoName):
    """
    Build the video from the sequence of images in /videos/images
    :param hist: history
    :param videoName: [name_video][.file_format]
    :return: [name_video][.file_format] in /videos
    """
    imageDirectory = os.path.join(os.getcwd(), "videos", "images", "*.jpeg")
    videoDirectory = os.path.join(os.getcwd(), "videos", videoName)

    cleanContentDir(imageDirectory)
    make_images(hist)

    img_array = []
    size = None

    fileList = glob.glob(imageDirectory)
    fileList.sort(key=lambda x: os.path.getmtime(x))
    for filename in fileList:
        img = cv2.imread(filename)
        height, width, layers = img.shape
        size = (width, height)
        img_array.append(img)

    out = cv2.VideoWriter(videoDirectory, cv2.VideoWriter_fourcc(*'DIVX'), 15, size)

    for i in range(len(img_array)):
        out.write(img_array[i])
    out.release()


def make_images(hist):
    """
    Build sequence of images from an history
    :param hist: history
    :return: Store the files in /videos/images
    """

    for i, tuple in enumerate(hist):
        state = tuple[0]
        save_caronthehill_image(state[0], state[1], str(Path().absolute())+"/videos/images/out"
                                + str(i) + ".jpeg")
    return


def plotPosSpeed(time, pos, speed, filename):
    """
    Plot position and speed along with time
    :param time: t
    :param pos: p
    :param speed: s
    :param filename: "[name].[file_type]"
    :return: show plot and save it in /illustrations
    """
    plt.plot(time, pos, time, speed)
    # plt.title("Unit test of euler integration")
    plt.xlabel("Timesteps")
    plt.ylabel("Position and speed")
    plt.legend(["Position (m)", "Position (m/s)"])
    plt.rcParams["font.size"] = 15
    plt.savefig("illustrations/"+filename)
    plt.show()

def plotMeanVar(t, m, v, yTitle, filename):
    plt.plot(t, m, t, v)
    plt.xlabel("Timesteps")
    plt.legend(["Mean " + yTitle, "Var " + yTitle])
    plt.savefig("illustrations/"+filename)
    plt.show()

def plotDistanceQ(nFittedQIter, dist, modelType, fPlotName):
    plt.plot([i for i in range(nFittedQIter)], dist)
    plt.title("D(Q_N, Q_N-1) with "+modelType)
    plt.savefig("illustrations/"+fPlotName)
    plt.show()

def plotPolicy(trainedModel, filename, display=True):

    X_Acc, X_Dec = makeGridDataset()

    Qacc = trainedModel.predict(X_Acc)
    Qdec = trainedModel.predict(X_Dec)

    posAcc, speedAcc = [], []
    posDec, speedDec = [], []
    posStay, speedStay = [], []

    for i, state in enumerate(X_Acc):
        if Qacc[i] > Qdec[i]:
            posAcc.append(state[0])
            speedAcc.append(state[1])
        elif Qacc[i] < Qdec[i]:
            posDec.append(state[0])
            speedDec.append(state[1])
        else:
            posStay.append(state[0])
            speedStay.append(state[1])

    g1 = (np.array(posAcc), np.array(speedAcc))
    g2 = (np.array(posDec), np.array(speedDec))
    g3 = (np.array(posStay), np.array(speedStay))

    data = (g1, g2, g3)
    colors = ("green", "red", "blue")
    groups = ("Accelerate", "Decelerate", "Never mind")

    # Create plot
    fig = plt.figure()
    ax = fig.add_subplot(1, 1, 1, axisbg="1.0")

    for data, color, group in zip(data, colors, groups):
        x, y = data
        ax.scatter(x, y, alpha=0.8, c=color, edgecolors='none', s=30, label=group)

    plt.xlabel("Position (m)")
    plt.ylabel("Speed (m/s)")
    plt.legend(["Position (m)", "Position (m/s)"])
    plt.rcParams["font.size"] = 15
    plt.legend(loc=2)
    plt.xlim([-1.1, 1.1])
    plt.ylim([-3.3, 3.3])
    plt.savefig("illustrations/" + filename)
    if display is True:
        plt.show()


def plotHeatMap(trainedModel, modelTypeNo):
    nDot = 50
    pos = np.linspace(-1.0, 1.0, 50)
    speed = np.linspace(-3.0, 3.0, 50)

    X_Acc, X_Dec = makeGridDataset()

    Qacc = trainedModel.predict(X_Acc)
    Qdec = trainedModel.predict(X_Dec)

    X, Y = np.meshgrid(pos, speed)
    x = X.ravel()
    y = Y.ravel()
    z = Qacc.ravel()
    gridsize = 30
    plt.subplot(111)

    # if 'bins=None', then color of each hexagon corresponds directly to its count
    # 'C' is optional--it maps values to x-y coordinates; if 'C' is None (default) then
    # the result is a pure 2D histogram

    plt.hexbin(x, y, C=z, gridsize=gridsize, cmap=CM.jet, bins=None)
    plt.axis([x.min(), x.max(), y.min(), y.max()])
    plt.rcParams["font.size"] = 15

    cb = plt.colorbar()
    cb.set_label(r'$\hatQ_N$')
    plt.savefig("illustrations/heatmap_" + modelTypeNo + "acc.eps")
    plt.show()

    z = Qdec.ravel()
    plt.subplot(111)

    # if 'bins=None', then color of each hexagon corresponds directly to its count
    # 'C' is optional--it maps values to x-y coordinates; if 'C' is None (default) then
    # the result is a pure 2D histogram

    plt.hexbin(x, y, C=z, gridsize=gridsize, cmap=CM.jet, bins=None)
    plt.axis([x.min(), x.max(), y.min(), y.max()])
    plt.rcParams["font.size"] = 15

    cb = plt.colorbar()
    cb.set_label(r'$\hatQ_N$')
    plt.xlabel("Position (m)")
    plt.ylabel("Speed (m/S)")
    plt.savefig("illustrations/heatmap_" + modelTypeNo + "dec.eps")
    plt.show()

def plotTrajectory(histRet, fPlotName):
    pos = getPosFromHist(histRet)
    speed = getSpeedFromHist(histRet)
    plt.scatter(pos, speed)
    plt.rcParams["font.size"] = 15
    plt.xlabel("Position (m)")
    plt.ylabel("Speed (m/S)")
    plt.savefig("illustrations/"+fPlotName)
    plt.show()
if __name__ == '__main__':
    print()


