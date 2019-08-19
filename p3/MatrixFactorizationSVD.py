# ! /usr/bin/env python
# -*- coding: utf-8 -*-

import os
import time
import datetime
from contextlib import contextmanager

import pandas as pd

from surprise import Dataset
from surprise import Reader
from surprise.prediction_algorithms.matrix_factorization import *
from surprise.prediction_algorithms.knns import *
from surprise.model_selection import GridSearchCV


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
                                        datetime.timedelta(
                                            seconds=end - start)))


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
            provided, a default one will be used. Also note that the file
            extension (.txt) will be appended to the file.
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
        for (user_id, movie_id), prediction in zip(user_movie_ids,
                                                   y_predict):

            if np.isnan(prediction):
                raise ValueError('The prediction cannot be NaN')
            line = '{:d}_{:d},{}\n'.format(user_id, movie_id, prediction)
            handle.write(line)
    return file_name


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
            y_pred[i] = 0.0
    return y_pred, nb_scale_required


def getBestTunedAlgo(rating_matrix_df):
    '''
    Return a tuned (unbiaised )algorithm for data training and prediction.
    Tuning is  done exhausitevely by cross-validation and by taking the
    minimum mean  squared error.
    :param rating_matrix_df: a dataframe with ['user_id', 'movie_id', 'rating']
    :return: a tuned algorithm with the dataframe containing all the
    optimization results.
    '''

    # Use a reader to load the trainset from the dataframe
    reader = Reader(rating_scale=(1.0, 5.0))
    full_train_set = Dataset.load_from_df(rating_matrix_df, reader)

    # Configuration:
    algo = SVDpp
    param_grid = {'n_factors': [30], 'n_epochs': [50],
                  'lr_all': [0.006], 'reg_all': [0.09]}
    # SVDpp is slightly better than SVD and used for the final leaderboard
    # submission but is much longer to compute. Parameter grid is normally
    # used with several parameters but we only write down the best one for
    # this code submission.

    # Side-note:
    # {'n_factors': [30], 'n_epochs': [50], 'lr_all': [0.0055, 0.006],
    # 'reg_all': [0.09, 0.08, 0.1]}
    # would take 1 hours and 20 minutes with SVDpp

    # Another parameter grid formalism is however used for top-k
    # collaborative filtering:
    # param_grid = {'k': [39, 40, 41, 42], 'sim_options': {'name': [
    #     'pearson_baseline'], 'user_based': [False]}}
    # algo = KNNBaseline

    # In all cases, the training is done on unbiaised rating to achieve best
    #  results

    # Tuning procedure
    gs = GridSearchCV(algo, param_grid, measures=['rmse', 'mae'], cv=5,
                      n_jobs=-1)
    # refit = True

    gs.fit(full_train_set)

    # Best RMSE score:
    print("Best RMSE score is \n{}".format(gs.best_score['rmse']))

    # Combination of parameters that gave the best RMSE score:
    print("Best combination of parameters is \n{}".format(gs.best_params[
              'rmse']))

    # All the information about the tuning procedure:
    all_results_tuning = pd.DataFrame.from_dict(gs.cv_results)

    return gs.best_estimator['rmse'], all_results_tuning


if __name__ == '__main__':
    PREFIX = 'data/'

    # ------------------------------- Learning ----------------------------- #

    # Load training data
    train_usr_movie_df = pd.read_csv(os.path.join(PREFIX, 'data_train.csv'),
                                     delimiter=",")
    train_usr_movie_v = train_usr_movie_df.values.squeeze()

    train_ratings_df = pd.read_csv(os.path.join(PREFIX, 'output_train.csv'),
                                   delimiter=",")
    train_ratings_v = train_ratings_df.values.squeeze()

    user_data_df = pd.read_csv(os.path.join(PREFIX, 'data_user.csv'),
                               delimiter=",")
    user_data_v = user_data_df.values.squeeze()

    movie_data_df = pd.read_csv(os.path.join(PREFIX, 'data_movie.csv'),
                                delimiter=",")
    movie_data_v = movie_data_df.values.squeeze()

    rating_matrix_df = pd.concat([train_usr_movie_df, train_ratings_df],
                                 axis=1)
    rating_matrix_df["user_id"] = pd.to_numeric(rating_matrix_df["user_id"],
                                                downcast='integer')
    rating_matrix_df["movie_id"] = pd.to_numeric(rating_matrix_df[
                                                     "movie_id"],
                                                 downcast='integer')

    # Tuning the parameters of the chosen algorithm
    print("Optimizing the training parameters ...")
    algo, debug = getBestTunedAlgo(rating_matrix_df)

    reader = Reader(rating_scale=(1.0, 5.0))
    full_train_set = Dataset.load_from_df(rating_matrix_df,
                                          reader).build_full_trainset()

    # Training on algorithm with tuned parameters:
    start = time.time()
    with measure_time('Training ...'):
        print("Training with right tuned algo ...")
        algo.fit(full_train_set)

    # ------------------------------ Prediction ---------------------------- #
    # Load test data
    test_usr_movie_df = pd.read_csv(
        os.path.join(PREFIX, 'data_test.csv'))

    print("Testing with right tuned algo ...")

    # Formating the testset according to the library formalism.
    my_test_set = [0]*len(test_usr_movie_df.values)
    for i, line in enumerate(test_usr_movie_df.values):
        my_test_set[i] = (str(line[0]), str(line[1]))

    # Prediction on the test set
    y_pred = [0]*len(test_usr_movie_df.values)
    for i, line in enumerate(test_usr_movie_df.values):
        y_pred[i] = algo.predict(line[0], line[1]).est

    y_pred_scaled_back, nb_scale_required = scale_back(y_pred)
    print("Scaling back to [0, 5] was required: {} ({:.2%})".format(
        nb_scale_required, nb_scale_required/len(y_pred)))

    # Making the submission file
    fname = make_submission(y_pred, test_usr_movie_df.values, 'SVDpp')
    print('Submission file "{}" successfully written'.format(fname))

    if nb_scale_required != 0:
        fname = make_submission(y_pred_scaled_back, test_usr_movie_df.values,
                                'SVDpp_scaled_back')
        print('Submission file "{}" successfully written'.format(fname))
