import matplotlib.pyplot as plt
import numpy as np
import scipy as sy
#--------------------------------------------
#
#           Question 2b
#
#--------------------------------------------


class LS:

    def __init__(self, mu, sigma, size):
        self._mu = mu
        self._sigma = sigma
        self._SAMPLE_SIZE = size
        self._noise = np.random.normal(mu, sigma, size)

        # self.xValues = np.random.uniform(-4, 4, size) # --> distribution aléatoire mais équiprobable
        self._xValues = np.linspace(-4, 4, size) #--> donne une distribution uniforme de [-4,4]
        self._xValues.sort()

        # from the xValues and the formulas we generate the noisy yValues
        self._yValues =[]
        for i, x in enumerate(self._xValues):
            e = self._noise[i]
            y = np.sin(x) + (0.5*np.sin(3*x)) + e
            self._yValues.append(y)

        # creation of a linear model and the associated y values matching the
        # xValues
        self._polCoefficients = np.polyfit(self._xValues, self._yValues, 1)
        self._linearModel = np.poly1d(self._polCoefficients)
        self._linearModelValues = []

        for x in self._xValues:
            self._linearModelValues.append(self._linearModel(x))

        # creation of a non linear model and the associated y values matching
        # the xValues
        # !!!!! THIS IS A LINEAR MODEL !!!! TO CHANGE FOR KNN REGRESSION
        self._polCoefficients = np.polyfit(self._xValues, self._yValues, 11)
        self._nonLinearModel = np.poly1d(self._polCoefficients)
        self._nonLinearModelValues = []

        for x in self._xValues:
            self._nonLinearModelValues.append(self._nonLinearModel(x))

    def GetXValues(self):
        return self._xValues

    def GetYValues(self):
        return self._yValues

    # returns a linear polynom approximating the function
    # Can be used as follow : y = linearModel(x)
    def GetLinearModel(self):
        return self._linearModel

    def GetLinearModelValues(self):
        return self._linearModelValues

    # returns a 11 degree polynom approximating the function
    # can be used as fol
    def GetNonLinearModel(self):
        return self._nonLinearModel

    def GetNonLinearModelValues(self):
        return self._nonLinearModelValues


class BayesModel:
    def __init__(self, mu, sigma, size):
        self._mu = mu
        self._sigma = sigma
        self._SAMPLE_SIZE = size
        #self.xValues = np.random.uniform(-4, 4, size)
        self.xValues = np.linspace(-4, 4, size) #--> donne une distribution uniforme de[-4, 4]

        self.xValues.sort()

        self.yValues =[]

        for i, x in enumerate(self.xValues):
            y = np.sin(x) + (0.5*np.sin(3*x))
            self.yValues.append(y)

class LSCollection:
    def __init__(self, nbLS, sizeOfLS, mu, sigma):
        self._NB_LS = nbLS
        self._SIZE_LS = sizeOfLS
        self._mu = mu
        self._sigma = sigma
        # self.xValues = np.random.uniform(-4, 4, size) # --> distribution aléatoire mais équiprobable
        self._xValues = np.linspace(-4, 4,sizeOfLS)  # --> donne une distribution uniforme de [-4,4]
        self._xValues.sort()

        self.listOfLS =[]

        # we create a list of nbLS LS
        self._i = 0
        while  self._i < nbLS:
            self.listOfLS.append(LS(mu, sigma, sizeOfLS))
            self._i += 1

        # we create the average linear model by adding the y of every linear
        # model from the LS and dividing the resulting sum by nbLS
        self.averageLinearModelY =[0]*sizeOfLS

        for ls in self.listOfLS:
            for i,y in enumerate(ls.GetLinearModelValues()):
                self.averageLinearModelY[i] += y

        for i,y in enumerate(self.averageLinearModelY):
            self.averageLinearModelY[i] = y/nbLS

        # we create the average non linear model by adding the y of every non
        # linear model from the LS and dividing the resulting sum by nbLS
        self.averageNonLinearModelY = [0] * sizeOfLS

        for ls in self.listOfLS:
            for i, y in enumerate(ls.GetNonLinearModelValues()):
                self.averageNonLinearModelY[i] += y

        for i, y in enumerate(self.averageNonLinearModelY):
            self.averageNonLinearModelY[i] = y / nbLS

    def GetAvLinearModelVal(self,x):
        if x not in self._xValues:
            print("x was not found")
        else :
           i = self._xValues.index(x)
           return self.averageLinearModelY[i]

    def GetAvNonLinearModelVal(self,x):
        if x not in self._xValues:
            print("x was not found")
        else :
           i = self._xValues.index(x)
           return self.averageNonLinearModelY[i]


def YFct(x, e):
    y = np.sin(x) + (0.5*np.sin(3*x)) + e
    return y

def CreateYValues(mu, sigma, xValues):

    noise = CreateNoise(mu, sigma, SAMPLE_SIZE)
    xValues.sort()
    yValues = []

    for i, x in enumerate(xValues):
        e = noise[i]
        yValues.append(YFct(x, e))

    return yValues

def CreateXValues(size): # !!! the x values are not sorted and should be !!
    return np.random.uniform(-4, 4, size)

def CreateNoise(mu, sigma, size):
     return  np.random.normal(mu, sigma, size)



SAMPLE_SIZE = 700
mu = 0
sigma = np.sqrt(0.01)

#ls = LS(mu, sigma, SAMPLE_SIZE)
collec = LSCollection(50, SAMPLE_SIZE, mu, sigma)
ls = collec.listOfLS[40]

bm = BayesModel(mu, sigma, SAMPLE_SIZE)

plt.plot(ls._xValues, ls._yValues, '.', bm.xValues, bm.yValues, '.', ls._xValues, \
         ls._linearModelValues, '.', ls._xValues, ls._nonLinearModelValues, '.')
plt.show()
plt.plot(ls._xValues, ls._yValues, '.', bm.xValues, bm.yValues, '.', collec._xValues, \
         collec.averageLinearModelY, '.', collec._xValues, collec.averageNonLinearModelY, '.')
plt.show()
# plt.plot(bm.xValues, bm.yValues, '.')
# plt.show()
# plt.plot(ls.xValues, ls.linearModelValues, '.')
# plt.show()

