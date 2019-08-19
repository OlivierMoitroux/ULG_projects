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
from sklearn.tree import DecisionTreeClassifier

# My imports:
import plot
from sklearn.metrics import accuracy_score
from sklearn import tree
from sklearn.model_selection import train_test_split


def plot_dec_bndaries(depths, seed):
    """
    :param depths: vector of the depths to test
    :param seed: seed for randomness
    :return: plots of the boundaries found by the different depths of trees
    """

    dataset = make_dataset2(1500, seed)

    # get label/target, ...
    X_train, X_test, y_train, y_test = train_test_split(dataset[0], dataset[1],
                                                        test_size=300,
                                                        random_state=seed)

    for depth in depths:
        dtc = DecisionTreeClassifier(max_depth=depth, random_state=seed)
        estimator = dtc.fit(X_train, y_train)

        # # Export decision tree to .dot file
        # tree.export_graphviz(dtc,
        #                      out_file='tree-depth-' + str(depth) + '.dot')
        # # The .dot can then be imported in
        # # http://sandbox.kidstrythisathome.com/erdos/ or
        # # http://www.webgraphviz.com/ to visualize the decision making.

        plot.plot_boundary("DT-Depth-" + str(depth), estimator, X_test,
                           y_test, title="DT-Depth-" + str(depth))


def get_accuracy_stat(depths, seed, nb_gen=5):
    """
    :param depths: vector of the depths to test
    :param seed: seed for randomness
    :param nb_gen: number of dataset generations to compute the average
    accuracy of the trees
    :return: the means and standard deviations of the results of the trees
             averaged on nb_gen run
    """

    accuracy_table = np.empty((nb_gen, len(depths)))
    score_table = np.empty((nb_gen, len(depths)))

    for gen_no in range(nb_gen):
        # Observed data and label/target
        dataset = make_dataset2(1500, seed+gen_no)
        X_train, X_test, y_train, y_test = \
            train_test_split(dataset[0], dataset[1], test_size=300,
                             random_state=seed + gen_no)

        for j, depth in enumerate(depths):

            dtc = DecisionTreeClassifier(max_depth=depth, random_state=seed)
            estimator = dtc.fit(X_train, y_train)

            # Score on training set
            score_table[gen_no][j] = estimator.score(X_train, y_train)

            y_predict = estimator.predict(X_test)
            accuracy_table[gen_no][j] = accuracy_score(y_test, y_predict)

    print("Scores: {}".format(np.mean(score_table, axis=0)))
    return np.mean(accuracy_table, axis=0), np.std(accuracy_table, axis=0)


def plot_stats(means, stds, depths):
    """
    :param means: mean results of the different trees on the test sample
    :param stds: standard deviations of previous results
    :param depths: the vector containing the different depths of the trees
    :return: plots the stats related to the results : means and st. deviations
    """

    n_depths = len(depths)
    # the x locations for the groups
    ind = np.arange(n_depths)
    # the width of the bars
    width = 0.35

    fig, ax = plt.subplots()
    rects1 = ax.bar(ind, means, width, color='royalBlue', yerr=stds)

    # add some text for labels, title and axes ticks
    ax.set_ylabel('Score')
    ax.set_title('Accuracy scores by depths')
    ax.set_xticks(ind + width / 2)
    ax.set_xticklabels(str(depths[i]) for i in range(len(depths)))
    ax.set_xlabel('Depth parameter')

    for i, rect in enumerate(rects1):
        height = rect.get_height()
        ax.text(rect.get_x() + rect.get_width() / 2., 1.04 * height,
                "{0:.3f}".format(height), ha='center', fontweight='bold')

    plt.savefig("statQ1.eps")

if __name__ == "__main__":
    pass

    seed = 3
    depths = [1, 2, 4, 8, None]

    plot_dec_bndaries(depths, seed)

    # Q1.2)
    means, stds = get_accuracy_stat(depths, seed + 1)
    print("Means:{}".format(means))
    print("Standard deviations:{}".format(stds))

    plot_stats(means, stds, depths)
