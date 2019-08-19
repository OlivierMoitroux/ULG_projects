"""
University of Liege
ELEN0062 - Introduction to machine learning
Project 1 - Classification algorithms
"""
#! /usr/bin/env python
# -*- coding: utf-8 -*-

import numpy as np

from sklearn.base import BaseEstimator, ClassifierMixin


class LinearDiscriminantAnalysis(BaseEstimator, ClassifierMixin):

    def __init__(self):

        self._priors = None
        self._n_classes = None
        self._classes = None
        self._means = []
        self._class_proba = []
        self._cov_X = None

    def __check_input(self, X, y):
        """
        :param X:  array-like, shape = [n_samples, n_features]
                   The training input samples.
        :param y:  array-like, shape = [n_samples]
                   The target values.
        :return: ValueError if the inputs are not what was expected
        """
        # Check that the inputs X and y are valid
        X = np.asarray(X, dtype=np.float)
        if X.ndim != 2:
            raise ValueError("X must be 2 dimensional")

        y = np.asarray(y)
        if y.shape[0] != X.shape[0]:
            raise ValueError("The number of samples differs between X and y")

    def fit(self, X, y):
        """Fit a linear discriminant analysis model using the training set
        (X, y).

        Parameters
        ----------
        X : array-like, shape = [n_samples, n_features]
            The training input samples.

        y : array-like, shape = [n_samples]
            The target values.

        Returns
        -------
        self : object
            Returns self.
        """

        # Input validation
        self.__check_input(X, y)

        # Get the classes and their occurrence
        self._classes, occ_classes = np.unique(y, return_counts=True)
        self._n_classes = len(self._classes)

        # Step 1: compute mean of each feature and prior probabilities
        n_samples = float(len(y))

        for k, cla in enumerate(self._classes):
            self._means.append(np.mean(X[y == cla], axis=0))
            self._class_proba.append(occ_classes[k] / n_samples)
        # means=
        # [[feat_1_c1, feat_2_c1, ..., feat_n_c1]
        #  [...]
        #  [feat_1_cn, ..., feat_n_cn]]

        # Step 2: calculate the covariance matrix for X
        self._cov_X = np.cov(X, rowvar=False)

        return self

    def predict(self, X):
        """Predict class for X.

        Parameters
        ----------
        X : array-like of shape = [n_samples, n_features]
            The input samples.

        Returns
        -------
        y : array of shape = [n_samples]
            The predicted classes, or the predict values.
        """

        proba = self.predict_proba(X)
        n_samples = X.shape[0]
        y = np.zeros(n_samples)

        for sample in range(n_samples):
            y[sample] = self._classes[np.argmax(proba[sample][:])]
            # y[sample] = np.max(proba[sample][:])
        return y

    def predict_proba(self, X):
        """Return probability estimates for the test data X.

        Parameters
        ----------
        X : array-like of shape = [n_samples, n_features]
            The input samples.

        Returns
        -------
        p : array of shape = [n_samples, n_classes]
            The class probabilities of the input samples. Classes are ordered
            by lexicographic order.
        """

        if self._classes is None:
            raise ValueError("fit() must first be called")

        n_samples = X.shape[0]
        proba = np.zeros((n_samples, self._n_classes))



        # for each object
        for sample in range(n_samples):

            # compute denominator for now
            den = 0
            for l in range(len(self._classes)):
                mean_l = self._means[l]
                pi_l = self._class_proba[l]
                f_l = multivariate_normal.pdf(X[sample][:], mean_l,
                                              self._cov_X)
                den = den + f_l * pi_l

            # for each class
            for k in range(self._n_classes):
                mean_k = self._means[k]
                pi_k = self._class_proba[k]
                f_k = multivariate_normal.pdf(X[sample][:], mean_k,
                                              self._cov_X)

                proba[sample][k] = f_k * pi_k / den

        # Get indices corresponding to the (lexi.) sorted array of classes
        sorted_indices = np.argsort(self._classes)
        return proba[:, sorted_indices]


class Assignement:

    def __init__(self, seed, n_datasets=2):
        self._seed = seed
        self._n_datasets = n_datasets

    def get_accuracy_stat(self, n_gen=5):
        """
        Compute mean and standard deviation of accuracy score using LDA
        :param n_gen: number of generation used to average the result
        :return: means - [mean score dataset1, mean score dataset_2]
        :return: stds - [std score dataset1, std score dataset_2]
        """

        accuracy_table = np.empty((n_gen, 2))

        for gen_no in range(n_gen):
            # Observed data and label/target
            for j in range(2):
                if j == 0:
                    X, y = make_dataset1(1500, self._seed + gen_no)
                else:
                    X, y = make_dataset2(1500, self._seed + gen_no)

                X_train, X_test, y_train, y_test = \
                    train_test_split(X, y, test_size=300,
                                     random_state=self._seed + gen_no)

                estimator = LinearDiscriminantAnalysis().fit(X_train, y_train)
                y_predict = estimator.predict(X_test)
                accuracy_table[gen_no][j] = accuracy_score(y_test, y_predict)

        return np.mean(accuracy_table, axis=0), np.std(accuracy_table, axis=0)

    def plot_dec_bndaries(self):
        """
        Plot the decision boundary of the n_datasets computed with LDA
        :return: plot the decision boundary for the two make_dataset() methods
        """

        for j in range(2):
            if j == 0:
                dataset = make_dataset1(1500, self._seed)
            else:
                dataset = make_dataset2(1500, self._seed)

            X_train, X_test, y_train, y_test = \
                train_test_split(dataset[0], dataset[1], test_size=300,
                                 random_state=self._seed)

            estimator = LinearDiscriminantAnalysis().fit(X_train, y_train)
            plot_boundary("lda-dataset-{}".format(j+1), estimator, X_test,
                          y_test, title="L.D.A. on dataset {}".format(j+1))

    def plot_stats(self, means, stds):
        """
        Bar plot the mean and std of score
        :param means: [mean score dataset_1, ..., mean score dataset_n]
        :param stds: [std score dataset_1, ..., mean score dataset_n]
        :return: /
        """

        ind = np.arange(self._n_datasets)  # the x locations for the groups
        width = 0.35  # the width of the bars

        fig, ax = plt.subplots()
        rects1 = ax.bar(ind, means, width, color='royalBlue', yerr=stds)

        # add some text for labels, title and axes ticks
        ax.set_ylabel('Score')
        ax.set_title('Accuracy scores for two different datasets')
        ax.set_xticks(ind + width / 2)
        ax.set_xticklabels(str(i+1) for i in range(self._n_datasets))
        ax.set_xlabel('Dataset')

        for i, rect in enumerate(rects1):
            height = rect.get_height()
            ax.text(rect.get_x() + rect.get_width() / 2., 1.04 * height,
                    "{0:.3f}".format(height), ha='center', fontweight='bold')

        plt.savefig("statQ3.eps")

if __name__ == "__main__":

    from data import make_dataset1, make_dataset2
    from plot import plot_boundary
    from sklearn.model_selection import train_test_split
    from scipy.stats import multivariate_normal
    from sklearn.metrics import accuracy_score
    from matplotlib import pyplot as plt

    seed = 3

    Q3 = Assignement(seed)
    Q3.plot_dec_bndaries()
    meanAcc, stdAcc = Q3.get_accuracy_stat()
    Q3. plot_stats(meanAcc, stdAcc)
    print("Mean accuracy = {}".format(meanAcc))
    print("Standard deviation accuracy = {}".format(stdAcc))
