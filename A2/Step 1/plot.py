from main import *

import cv2
import glob
from display_caronthehill import *
import os
from pathlib import Path


def makeVideo(hist, videoName):
    """
    Build the video from the sequence of images in /videos/images
    :param hist: history
    :param videoName: [name_video][.file_format]
    :return: [name_video][.file_format] in /videos
    """
    imageDirectory = os.path.join(os.getcwd(), "videos", "images", "*.jpeg")
    videoDirectory = os.path.join(os.getcwd(), "videos", videoName)
    make_images(hist)

    img_array = []
    size = None
    for filename in glob.glob(imageDirectory):
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
    plt.title("Unit test of euler integration")
    plt.xlabel("t")
    plt.ylabel("Position and speed")
    plt.legend(["Position (m)", "Position (m/s)"])
    plt.rcParams["font.size"] = 15
    plt.savefig("illustrations/"+filename)
    plt.show()


if __name__ == '__main__':
    print()