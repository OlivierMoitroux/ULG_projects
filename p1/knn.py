"""
University of Liege
ELEN0062 - Introduction to machine learning
Project 1 - Classification algorithms
"""
#! /usr/bin/env python
# -*- coding: utf-8 -*-

import numpy as np
from matplotlib import pyplot as plt

from data import make_dataset1, make_dataset2
from sklearn.neighbors import KNeighborsClassifier

# My imports:
import plot
from sklearn.metrics import accuracy_score
import numpy
from sklearn.model_selection import train_test_split


def plot_dec_bndary(neighbors, seed, train_set, testSet):
    """
    :param neighbors: a vector of the different number of neighbors to test
    :param seed: the seed for randomness
    :param train_set: part of the set used for training the algorithm
    :param testSet: part of the set used for testing the algorithm
    :return: plots the resulting boundaries
    """

    # Observed data and label/target
    X_train, y_train = train_set[0], train_set[1]
    X_test, y_test = testSet[0], testSet[1]

    for n_neighbors in neighbors:
        model = KNeighborsClassifier(n_neighbors=n_neighbors,
                                     algorithm="auto")
        model_fit = model.fit(X_train, y_train)

        y_predicted = model.predict(X_test)
        print("Accuracy score for {} neighbors : {}".format(n_neighbors,
              accuracy_score(y_test, y_predicted)))

        plot.plot_boundary("kNN-neighbors-" + str(n_neighbors), model_fit,
                           X_test, y_test, title="kNN-neighbors-" + str(
                            n_neighbors))


def k_cross_validation(dataset, neighbors, k):
    """
    :param dataset: all the data dots as a pair of vectors (x and y)
    :param neighbors: a vector of all the number of neighbors to try
    :param k: the dataset will be cut in k different subsets
    :return: a matrix (k X len(neighbors)) containing the scores of all the
    number of neighbors for every subset used as the test sample
    """

    # Split dataset in k
    X, y = numpy.split(dataset[0], k), numpy.split(dataset[1], k)

    X_train, y_train, X_test, y_test = [], [], [], []

    score = np.empty((k, len(neighbors)))

    for i in range(k):
        X_test.extend(X[i])
        y_test.extend(y[i])
        for j in range(k):
            # for each split but the one used for test
            if j != i:
                X_train.extend(X[j])
                y_train.extend(y[j])

        for ind, n_neighbors in enumerate(neighbors):
            model = KNeighborsClassifier(n_neighbors=n_neighbors,
                                         algorithm="auto")
            model.fit(X_train, y_train)
            y_predicted = model.predict(X_test)

            score[i][ind] = accuracy_score(y_test, y_predicted)

        # Clear datasets for next iteration
        X_train.clear()
        y_train.clear()
        X_test.clear()
        y_test.clear()
    return score


def max_mean_neighbor(score, neighbors):
    return neighbors[np.argmax(np.mean(score, axis=0))]


if __name__ == "__main__":

    seed = 3
    neighbors = [1, 5, 25, 125, 625, 1200]
    k = 10

    dataset = make_dataset2(1500, seed)
    X_train, X_test, y_train, y_test = train_test_split(dataset[0], dataset[1],
                                                        test_size=300,
                                                        random_state=seed)
    train_set = (X_train, y_train)
    test_set = (X_test, y_test)

    plot_dec_bndary(neighbors, seed, train_set, test_set)
    score = k_cross_validation(dataset, neighbors, k)
    print("Score = \n{}".format(score))

    # For the report:
    print("Mean of the accuracy score for each neighbor = \n{}".format(
        np.mean(score, axis=0)))

    print("=> the best neighbor is {}".format(max_mean_neighbor(score,
                                                                neighbors)))
