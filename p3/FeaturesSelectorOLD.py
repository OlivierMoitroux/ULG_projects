
import numpy as np
import os
from sklearn.feature_selection import SelectKBest
from sklearn.feature_selection import chi2
from sklearn.svm import LinearSVC
import pandas as pd
from sklearn.ensemble import ExtraTreesClassifier
from sklearn.feature_selection import SelectFromModel
from sklearn.pipeline import Pipeline
from sklearn.ensemble import RandomForestClassifier
import matplotlib.pyplot as plt
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.feature_selection import f_classif, f_regression


class FeaturesSelector:
    def __init__(self, df):

        self._data_tuples = df.values
        self.N = len(self._data_tuples)

        self._x_age = self.age_classification(df['age'].values).reshape(-1,1)

        self._x_gender = self.gender_classification(df['gender'].values).reshape(-1,1)
        self._x_occupation = self.profession_converter(df['occupation'].values).reshape(-1, 1)

        self._x_release = self.extract_date(df['video_release'].values,
                                            df['movie_title'].values).reshape(-1,1)
        self._x_genre = df.loc[:, 'unknown':'Western']

        self.features_name = ["age", "gender", "occupation", "release"]
        self.features_name = self.features_name + (list(df.loc[:,
                                                      'unknown':'Western']))
        # self.feature_index = ([df.columns.get_loc(c) for c in
        #                       self.features_name])

        df = df.astype({"rating":int})
        self._ratings = df['rating'].values.reshape(-1, 1)

        # self._weigthed_ratings = self.weight(df['rating'].values)

        self.Y = self._ratings

        # concatenation of the 4 features
        self.X = np.hstack((self._x_age, self._x_gender, self._x_occupation,
                            self._x_release,self._x_genre))

        # ['age', 'gender', 'release', 'genre']
        #                   ....

    def convert_name(self,names):
        vectorizer = CountVectorizer()
        X = vectorizer.fit_transform(names)
        Y = vectorizer.get_feature_names()
        print(Y)
        return X.toarray()


    def select_kbest_features(self, n):
        eval_fct = ["chi2", "f_classif", "f_regression"]
        features, selector = None, None
        for i, score_fct in enumerate([chi2, f_classif, f_regression]):
            selector = SelectKBest(score_func=score_fct, k=n)
            # chi2, f_classif, f_regression
            # or f_regression, ...
            # fit = test.fit_transform(self.X, self.Y)
            features = selector.fit_transform(self.X, self.Y)
            scores = selector.scores_
            self.plot_histogram_features("Kbest "+eval_fct[i], scores)

        # Get the name of the features selected by kbest
        mask = selector.get_support()
        new_features = []  # The list of your K best features

        for bool, feature in zip(mask, self.features_name):
            if bool:
                new_features.append(feature)
        print("KBest selected the features:")
        print(new_features)
        return (mask, features)


    def select_l1_features(self, n):

        lsvc = LinearSVC(C=0.01, penalty="l1", dual=False).fit(self.X,
                                                                 self.Y)
        model = SelectFromModel(lsvc, prefit=True, threshold=-np.inf,
                                max_features=n)
        X_new = model.transform(self.X)

        mask = model.get_support()

        return (mask, X_new)

    def select_treeForest_features(self, n):
        # Feature Importance with Extra Trees Classifier

        model = ExtraTreesClassifier() # a forest
        clf = model.fit(self.X, self.Y)
        scores = model.feature_importances_

        std = np.std(
            [tree.feature_importances_ for tree in model.estimators_],
            axis=0)
        self.plot_histogram_features("random forest",scores, std)

        model = SelectFromModel(clf, prefit=True, threshold=-np.inf,
                                max_features=n)
        X_new = model.transform(self.X)
        mask = model.get_support()
        return mask, X_new

    def plot_histogram_features(self, selector_type, scores, std=None):
        indices = np.argsort(scores)[::-1]
        # Print the feature ranking
        print("Feature ranking: "+selector_type)

        for f in range(self.X.shape[1]):
            print("%d. feature ({}) %d (%f)".format(self.features_name[
                                                        indices[f]]) % (
                f + 1, indices[f], scores[indices[f]]))

        # Plot the feature importances of the forest
        plt.figure()
        plt.title("Feature importances: "+selector_type)
        if std is not None:
            plt.bar(range(self.X.shape[1]), scores[indices],
                    color="r", yerr=std[indices], align="center")
        else:
            plt.bar(range(self.X.shape[1]), scores[indices],
                    color="r", align="center")

        plt.xticks(range(self.X.shape[1]), indices)
        plt.xlim([-1, self.X.shape[1]])
        plt.show()

    # (Not used)
    def pipeline(self):
        clf = Pipeline([
            ('feature_selection', SelectFromModel(LinearSVC(penalty="l1"))),
            ('classification', RandomForestClassifier())
        ])
        ret = clf.fit(self.X, self.Y)
        return ret

    def age_classification(self, ages):
        ret = np.empty(self.N, dtype=int)
        for i, age in enumerate(ages):
            if age < 16:
                ret[i] = 0
            elif age <= 25:
                ret[i] = 1
            elif age <= 40:
                ret[i] = 2
            elif age <= 55:
                ret[i] = 3
            else:
                ret[i] = 4
        return ret

    def gender_classification(self, genders):
        ret = np.empty(self.N, dtype=bool)
        for i, gender in enumerate(genders):
            if gender == 'F':
                ret[i] = 0
            if gender == 'M':
                ret[i] = 1
        return ret

    def extract_date(self, video_releases, movie_titles):
        ret = np.empty(self.N, dtype=int)
        for i, release_date in enumerate(video_releases):
            if movie_titles[i] == 'unknown':
                ret[i] = 0
                continue
            try:
                ret[i] = int(release_date.split("-")[2])
            except Exception as e:
                print(e)
                print("->{}".format(movie_titles[i]))
            # ret[i] = int(title[title.find("(")+1:title.find(")")])
        return ret

    # (Not used)
    def weight(self, ratings, m=50):
        # ret = np.empty(self.N, dtype=float)
        # #C = np.mean(ratings)
        # wr = (v/(v+m))*R + ((m/(v+m))*C)
        # v = nb of votes for the movie
        # m = minimum votes required to be listed in the chart
        # -> m = metadata['vote_count'].quantile(0.90)
        # R = avg rating of the movie
        # C = mean vote across all report

        # Define a new feature 'score' and calculate its value with
        # `weighted_rating()` q_movies['score'] = q_movies.apply(
        # weighted_rating, axis=1)
        return 0

    def user_feature_converter(self, user_data):
        user_id = []
        age = []
        gender = []
        for i in range(len(user_data)):
            user_id.append([user_data[i][0]])
            age.append([self.age_classification(user_data[i][1])])
            gender.append([self.gender_classification(user_data[i][2])])
        user_features = np.hstack((user_id, age, gender))
        return user_features

    def convert_title(self, s):
        if (type(s) == float):
            print(s)
            return s
        max = len(s)
        min = max - 4
        converted = s[min:max]
        return converted

    def movie_feature_converter(self, movie_data):
        movie_id = np.zeros(len(movie_data))
        release_date = np.zeros(len(movie_data))
        movie_type = np.zeros((len(movie_data), 19))
        for i in range(len(movie_data)):
            movie_id[i] = movie_data[i][0]
            converted = self.convert_title(movie_data[i][2])

            release_date[i] = converted
            movie_genre = movie_data[i][5:]
            for j in range(19):
                movie_type[i][j] = movie_genre[j]
        print(movie_type)

        movie_features = np.hstack((movie_id.reshape((-1, 1)),
                                    release_date.reshape((-1, 1)),
                                    movie_type))
        return movie_features

    def profession_converter(self,professions):
        X = np.empty(self.N, dtype=int)
        for i in range(len(professions)):
            if professions[i]in ['artist','entertainment','homemaker',
                                 'librarian','writer']:
                X[i]=0
            elif professions[i] in ['engineer','programmer','scientist',
                                    'technician']:
                X[i]=1
            elif professions[i] in ['administrator','executive','marketing',
                                    'salesman']:
                X[i] = 2
            elif professions[i] in ['doctor', 'healthcare']:
                X[i] = 3
            elif professions[i] in ['student']:
                X[i] = 4
            elif professions[i] in ['none','retired']:
                X[i] = 5
            elif professions[i] in ['other']:
                X[i] = 6
            elif professions[i]in ['lawyer']:
                X[i] = 7
            elif professions[i] in ['educator']:
                X[i] = 8

        return X


def load_from_csv(path, delimiter=','):
    return pd.read_csv(path, delimiter=delimiter).values.squeeze()


def create_featureful_matrix(userID_movieID_pairs,
                             user_data, movie_data, rating=None):
    '''
    # [UserID1 FeatureUser MovieID FeatureMovie Rating]
    :param userID_movieID_pairs:
    :param rating:
    :return:
    '''

    corresponding_user = []
    corresponding_movie = []

    for i in range(len(userID_movieID_pairs)):
        corresponding_user.append(
            user_data[userID_movieID_pairs[i][0]-1, 1:]
        )
        corresponding_movie.append(
            movie_data[userID_movieID_pairs[i][1] - 1][:])
    featureful_matrix = np.hstack((userID_movieID_pairs[:, 0].reshape((-1, 1)),
                                   corresponding_user, corresponding_movie))
    c_labels = ['user_id', 'age', 'gender', 'occupation', 'zip_code',
                'movie_id', 'movie_title', 'video_release', 'nan', 'URL',
                'unknown', 'Action', 'Adventure', 'Animation', 'Children',
                'Comedy', 'Crime', 'Documentary', 'Drama', 'Fantasy',
                'Film-Noir', 'Horror', 'Musical', 'Mystery', 'Romance',
                'Sci-Fi', 'Thriller', 'War', 'Western']
    if rating is not None:
        featureful_matrix = np.hstack((featureful_matrix, rating.reshape((-1, 1))))
        c_labels.append('rating')

    df = pd.DataFrame(featureful_matrix, columns=c_labels)

    return df

if __name__ == '__main__':
    PREFIX = "data/"
    userID_movieID_pairs = load_from_csv(os.path.join(PREFIX,
                                                      'data_train.csv'))
    # [User id, movie id]

    training_rating = load_from_csv(os.path.join(PREFIX, 'output_train.csv'))

    user_data = load_from_csv(os.path.join(PREFIX, 'data_user.csv'))
    movie_data = load_from_csv(os.path.join(PREFIX, 'data_movie.csv'))

    featureful_train_matrix = create_featureful_matrix(userID_movieID_pairs,
                                                       user_data,
                                                       movie_data,
                                                       training_rating)

    fs = FeaturesSelector(featureful_train_matrix)
    mask1, X1 = fs.select_kbest_features(3)

    # [...]
    # (depreciated code and not useful to clean it anyway for the
    # submission). Mask is a vector that was used to select only the right
    # columns of the matrix with all the features.
