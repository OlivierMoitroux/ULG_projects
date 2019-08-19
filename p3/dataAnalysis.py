import pandas as pd
import os
import matplotlib.pyplot as plt
import numpy as np


PREFIX = "data/"


def analyze_age(df):

    print("------------\nAge of user analysis:\n------------\n")
    print("Plotting age distribution:\n")
    # Histogram of age
    fig = plt.figure(figsize=(17, 10))
    df.age.plot.hist(bins=30)
    plt.rcParams.update({'font.size': 15})

    # trip_data.hist(column="Trip_distance")
    plt.title("Histogram of users' ages")
    plt.ylabel('count of users')
    plt.xlabel('age')
    plt.rc('xtick', labelsize=15)
    plt.rc('ytick', labelsize=10)
    plt.show()

    # Age groups
    print("\nAge categories:\n")
    labels = ['0-9', '10-19', '20-29', '30-39', '40-49', '50-59', '60-69',
              '70-79']
    df['age_categories'] = pd.cut(df.age, range(0, 81, 10), right=False,
                                  labels=labels)
    df[['age', 'age_categories']].drop_duplicates()[:10]
    print(df.groupby('age_categories').agg({'rating': [np.size, np.mean]}))


def analyze_ratings(ratings):
    print("------------\nRating analysis:\n------------\n")
    print(ratings.describe())


def analyze_movie(df):
    print("------------\nMovie analysis:\n------------\n")

    print("Most watched movies:\n")
    most_watched_movies = df.groupby('movie_title').agg({'rating': [np.size,
                                                                    np.mean]})
    # We notice that the most watched film have quite good notes
    with pd.option_context('display.max_rows', 20):
        print(most_watched_movies.sort_values([('rating', 'size')],
                                              ascending=False))

    print("\nLess watched movies:\n")
    less_watched_movies = df.groupby('movie_title').size(
    ).sort_values(ascending=True)[:20]
    print(less_watched_movies)

    print("\nBest rated movies:\n")
    best_rated_movies = df.groupby('movie_title').agg({'rating': [np.size,
                                                                  np.mean]})
    with pd.option_context('display.max_rows', 20):
        print(best_rated_movies.sort_values([('rating', 'mean')],
                                            ascending=False))

    print("\n")

    most50 = best_rated_movies['rating']['size'] >= 50
    print(best_rated_movies[most50].sort_values([('rating', 'mean')],
                                                ascending=False)[:20])


def analyze_gender(df):
    print("------------\nGender analysis:\n------------\n")

    most_50 = df.groupby('movie_id').size().sort_values(ascending=False)[:50]

    print("Movie delta for gender:\n")
    pivoted = df.pivot_table(index=['movie_id', 'movie_title'],
                             columns=['gender'],
                             values='rating',
                             fill_value=0)
    pivoted['diff'] = pivoted.M - pivoted.F
    print(pivoted.head())

    print("Plot movie delta for gender:\n")
    pivoted.reset_index('movie_id', inplace=True)
    disagreements = pivoted[pivoted.movie_id.isin(most_50.index)]['diff']
    disagreements.sort_values().plot(kind='barh', figsize=[9, 15])
    # plt.rcParams.update({'font.size': 15})

    plt.title(
        'Male vs. Female Avg. Ratings\n(Difference > 0 = Favored by Men)')
    plt.ylabel('Title')
    plt.xlabel('Average Rating Difference')
    # plt.rc('xtick', labelsize=10)
    # plt.rc('ytick', labelsize=10)
    plt.show()


def analyze_type_film_age(df):
    # [!] Some kind of proba of a person in a given age category to watch a
    # certain kind of movie is not possible because some films are
    #  in several categories so probabilities can't some to one ...
    # #df[['age', 'age_categories']].drop_duplicates()[:10]
    # list_of_fc = [lambda L: np.count_nonzero(L) / np.size(L)] *  len(
    # col_title)

    df[['age', 'age_categories']].drop_duplicates()[:10]
    dict = {}
    col_title = list(df.columns)[5:23]
    list_of_fc = [np.count_nonzero] * len(col_title)
    keys_values = zip(col_title, list_of_fc)
    for c, v in keys_values:
        dict[c] = v

    pd.set_option('display.max_columns', None)  # with does not work here
    print(df.groupby('age_categories').agg(dict))
    pd.set_option('display.max_columns', 0)  # reset to default


def make_data_analysis():
    data_user = pd.read_csv(os.path.join(PREFIX, 'data_user.csv'),
                            delimiter=",")
    data_movie = pd.read_csv(os.path.join(PREFIX, 'data_movie.csv'),
                             delimiter=",")

    ratings = pd.read_csv(os.path.join(PREFIX, 'output_train.csv'),
                          delimiter=",")

    data_train = pd.read_csv(os.path.join(PREFIX, 'data_train.csv'),
                             delimiter=",")

    user_rating = pd.concat([data_train, ratings], axis=1)
    movie_rating = pd.merge(data_movie, user_rating)

    df = pd.merge(movie_rating, data_user)

    analyze_age(df)
    analyze_ratings(ratings)
    analyze_movie(df)
    analyze_gender(df)
    analyze_type_film_age(df)

    return df


if __name__ == '__main__':
    df = make_data_analysis()
