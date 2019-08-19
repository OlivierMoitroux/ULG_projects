import numpy as np
from enum import Enum

class Axis(Enum):
    # column
    col = 0
    # Row
    row = 1

def prior(jointProb, axis):
    return np.sum(jointProb, axis=axis.value)


def entropy(priors):
    return np.sum(-p * np.log2(p) for p in priors)


def joint_entropy(jointProb):
    """
    H(A,B)
    :param jointProb: P(A, B)
    :return: H(A,B)
    """
    return np.sum(-p * np.log2(p) for (x, y), p in np.ndenumerate(jointProb) if p > 0)


def condional_entropy(jointProb, priors):
    """
    H(A|B) = H(A, B) - H(B)
    :param jointProb: P(A,B)
    :param priors: P(B)
    :return: H(A|B)
    """
    return joint_entropy(jointProb) - entropy(priors)


def mutual_information(jointProb):
    """
    Implement the raw definition
    :param jointProb: P(A, B)
    :return: I(A, B)
    """
    p_x, p_y = prior(jointProb, Axis.col), prior(jointProb, Axis.row)
    return np.sum(p * np.log2(p/(p_x[j]*p_y[i])) for (i, j),
                p in np.ndenumerate(jointProb) if p > 0 and p_x[j] > 0 and
                p_y[i] > 0)

def toJoint(jointProbXY, mask):
    """
    :param jointProbXY: P(A, B)
    :param mask: W [or Z]
    :return: P(A, W [or Z])
    """
    nRow, nCol = jointProbXY.shape
    jointProb = np.zeros([2, nCol])

    for col in range(nCol):
        for row in range(nRow):
            if mask[row, col] == 1:
                jointProb[0, col] += jointProbXY[row, col]
            else:
                jointProb[1, col] += jointProbXY[row, col]
    return jointProb

def cond_joint_entropy(jointProb, priors):
    """
    H(A, B| C) = H(A, B, C) - H(C)
    :param jointProb: [1] P(W, X) or [2] P(X, Y)
    :param priors: P(C)
    :return: [1] H(W, Z |X) or [2] H(X, Y|W)
    e.g.
    H(X, Y|W) = cond_joint_entropy(P(X, Y), P(W))
    H(W, Z|X) = cond_joint_entropy(P(W, X), P(X))
    """
    # H(A, B, C)
    H_ABC = joint_entropy(jointProb)
    return H_ABC - entropy(priors)


def cond_mutual_information(jointProbAC, jointProb, priors):
    """
    I(A, B| C) = 2H(A|C)-H(A, B|C)
    :param jointProbAC: P(A, C)
    :param jointProb: [1] P(X, Y) or [2] P(W, X)
    :param priors: [1] P(W) or [2]P(X)
    :return: [1] I(X, Y|W) or [2]I(W, Z|X)
    Example:
    -------
    H(X, Y|W) = cond_joint_entropy(P(X, W), P(X, Y), P(W))
    H(W, Z|X) = cond_joint_entropy(P(W, X), P(W, X), P(X))
    """
    priors_C = prior(jointProbAC, Axis.row)
    # H(A|C)
    H_A_if_C = condional_entropy(jointProbAC, priors_C)

    H_AB_if_C = cond_joint_entropy(jointProb, priors)
    # 2*H(A|C) - H(A,B|C)
    return 2*H_A_if_C - H_AB_if_C

if __name__ == '__main__':
    W = np.array([[1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]])
    Z = 1 - W

    jointProbXY = np.array([[1 / 8, 1 / 16, 1 / 16, 1 / 4], [1 / 16, 1 / 8, 1 / 16, 0],
                            [1/32, 1/32, 1/16, 0], [1/32, 1/32, 1/16, 0]])

    jointProbXW = toJoint(jointProbXY, W)
    jointProbYW = toJoint(jointProbXY.transpose(), W)
    jointProbXZ = toJoint(jointProbXY, Z)
    jointProbYZ = toJoint(jointProbXY.transpose(), Z)
    jointProbWZ = np.array([[0, 11/16], [5/16, 0]])

    jointProbWX = jointProbXW.transpose()

    p_x = prior(jointProbXY, Axis.col)
    p_y = prior(jointProbXY, Axis.row)
    p_w = prior(jointProbXW, Axis.row)
    p_z = prior(jointProbXZ, Axis.row)

    print("Q1)")
    print("H(x) = {}".format(entropy(p_x)))
    print("H(y) = {}".format(entropy(p_y)))
    print("H(W) = {}".format(entropy(p_w)))
    print("H(Z) = {}".format(entropy(p_z)))

    print("\nQ2)")
    print("H(x, y) = {}".format(joint_entropy(jointProbXY)))
    print("H(x, w) = {}".format(joint_entropy(jointProbXW)))
    print("H(y, w) = {}".format(joint_entropy(jointProbYW)))
    print("H(w, z) = {}".format(joint_entropy(jointProbWZ)))

    print("\nQ3)")
    print("H(x|y) = {}".format(condional_entropy(jointProbXY, p_y)))
    print("H(w|x) = {}".format(condional_entropy(jointProbXW, p_x)))

    print("H(z|w) = {}".format(condional_entropy(jointProbWZ, p_w)))
    print("H(w|z) = {}".format(condional_entropy(jointProbWZ, p_z)))

    print("\nQ4")
    print("H(x, y|w) = {}".format(cond_joint_entropy(
        jointProbXY, p_w)))
    print("H(w, z|x) = {}".format(cond_joint_entropy(
        jointProbWX, p_x)))
    print("\nQ5)")

    print("I(x, y) = {}".format(mutual_information(jointProbXY)))
    print("I(x, w) = {}".format(mutual_information(jointProbXW)))
    print("I(y, z) = {}".format(mutual_information(jointProbYZ)))
    print("I(w, z) = {}".format(mutual_information(jointProbWZ)))

    print("\nQ6)")
    print("I(x, y|w) = {}".format(cond_mutual_information(
        jointProbXW, jointProbXY, p_w)))
    print("I(w, z|x) = {}".format(cond_mutual_information(
        jointProbWX, jointProbWX, p_x)))
