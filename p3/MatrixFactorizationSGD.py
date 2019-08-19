# ! /usr/bin/env python
# -*- coding: utf-8 -*-

import os
import time
import datetime
from contextlib import contextmanager

import pandas as pd
import numpy as np


def SGD(n_users, n_movies, triplets):
    '''Learn the vectors p_u and q_i with SGD for all u=user and i=item=movie.
       ------------------------------------------
       Inspired by Nicolas Hug Machine Learning PhD, software engineer
       for further information see http://nicolas-hug.com/blog/matrix_facto_1
    '''

    n_factors = 10  # number of factors
    alpha = .01  # learning rate
    n_epochs = 10  # number of iteration of the SGD procedure

    # The user and item factors are randomly initialized
    p = np.random.rand(n_users,
                       n_factors)
    q = np.random.rand(n_movies,
                       n_factors)

    # Optimization procedure
    for _ in range(n_epochs):
        for u, i, r_ui in triplets:
            err = r_ui - np.dot(p[u-1],
                                q[i-1])
            # Update vectors p_u and q_i
            p[u-1] += alpha * err * q[i-1]
            q[i-1] += alpha * err * p[u-1]
    return p, q


def estimate(u, i, p, q):
    '''Estimate rating of user u for item i'''
    return np.dot(p[u-1], q[i-1])


def scale_back(y_pred):
    '''Analyse the prediction vector and scale out of range values back in
    [1.0, 5.0]
    '''
    nb_scale_required = 0
    for i in range(len(y_pred)):
        if y_pred[i] > 5:
            nb_scale_required += 1
            y_pred[i] = 5.0
        if y_pred[i] < 0:
            nb_scale_required += 1
            y_pred[i] = 1.0
    return y_pred, nb_scale_required


@contextmanager
def measure_time(label):
    """
        Context manager to measure time of computation.
        >>> with measure_time('Heavy computation'):
        >>>     do_heavy_computation()
        'Duration of [Heavy computation]: 0:04:07.765971'

        Parameters
        ----------
        label: str
            The label by which the computation will be referred
        """
    start = time.time()
    yield
    end = time.time()
    print('Duration of [{}]: {}'.format(label,
                                        datetime.timedelta(seconds=end-start)))


def load_from_csv(path, delimiter=','):
    """
        Load csv file and return a NumPy array of its data

        Parameters
        ----------
        path: str
            The path to the csv file to load
        delimiter: str (default: ',')
            The csv field delimiter

        Return
        ------
        D: array
            The NumPy array of the data contained in the file
        """
    return pd.read_csv(path, delimiter=delimiter).values.squeeze()


def make_submission(y_predict, user_movie_ids, file_name='submission',
                    date=True):
    """
        Write a submission file for the Kaggle platform

        Parameters
        ----------
        y_predict: array [n_predictions]
            The predictions to write in the file. `y_predict[i]` refer to the
            user `user_ids[i]` and movie `movie_ids[i]`
        user_movie_ids: array [n_predictions, 2]
            if `u, m = user_movie_ids[i]` then `y_predict[i]` is the prediction
            for user `u` and movie `m`
        file_name: str or None (default: 'submission')
            The path to the submission file to create (or override). If none is
            provided, a default one will be used. Also note that
            the file extension (.txt) will be appended to the file.
        date: boolean (default: True)
            Whether to append the date in the file name

        Return
        ------
        file_name: path
            The final path to the submission file
        """

    # Naming the file
    if date:
        file_name = '{}_{}'.format(file_name, time.strftime('%d-%m-%Y_%Hh%M'))

    file_name = '{}.txt'.format(file_name)

    # Writing into the file
    with open(file_name, 'w') as handle:
        handle.write('"USER_ID_MOVIE_ID","PREDICTED_RATING"\n')
        for (user_id, movie_id), prediction in zip(user_movie_ids, y_predict):

            if np.isnan(prediction):
                raise ValueError('The prediction cannot be NaN')
            line = '{:d}_{:d},{}\n'.format(user_id, movie_id, prediction)
            handle.write(line)
    return file_name


if __name__ == '__main__':
    prefix = 'data/'

    # ------------------------------- Learning ----------------------------- #
    # Load training data
    training_user_movie_pairs = load_from_csv(os.path.join(prefix,
                                                           'data_train.csv'))
    training_labels = load_from_csv(os.path.join(prefix, 'output_train.csv'))

    user_data = load_from_csv(os.path.join(prefix, 'data_user.csv'))
    movie_data = load_from_csv(os.path.join(prefix, 'data_movie.csv'))
    user_movie_rating_triplets = np.hstack((training_user_movie_pairs,
                                            training_labels.reshape((-1, 1))))
    start = time.time()
    with measure_time('Training ...'):
        p, q = SGD(len(user_data), len(movie_data), user_movie_rating_triplets)

    # ------------------------------ Prediction ---------------------------- #

    # Load test data
    test_user_movie_pairs = load_from_csv(os.path.join(prefix,
                                                       'data_test.csv'))

    # Build the prediction matrix
    y_pred = []
    for i, j in test_user_movie_pairs:
        y_pred.append(estimate(i, j, p, q))

    y_pred_scaled_back, nb_scale_required = scale_back(y_pred)
    print("Scaling back to [0, 5] was required: {} ({:.2%})".format(
        nb_scale_required, nb_scale_required / len(y_pred)))

    # Making the submission file
    fname = make_submission(y_pred, test_user_movie_pairs, 'SGD_biaised')
    print('Submission file "{}" successfully written'.format(fname))

    fname = make_submission(y_pred_scaled_back, test_user_movie_pairs,
                            'SGD_biaised_scaled_back')
    print('Submission file "{}" successfully written'.format(fname))
