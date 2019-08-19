"""
File to test and plot the performance of the model.
"""
import argparse
import numpy as np
import pickle
import random
import sys
import os
import json
import matplotlib.pyplot as plt
from sklearn import ensemble
from simulator import Simulator
from keras.models import Sequential
from keras.optimizers import adam
from keras.layers.core import Dense
import warnings
from keras.models import model_from_json, load_model
from tqdm import tqdm as ProgressBar
from natsort import natsorted

def testAndPlot(directoryName, typeModel, numEp, xAxisName="Number of episodes", step=1, saveName="plot.png"):
	"""
	Test a model and plot its performance. The plot is saved on the current directory.
	
	The directory whose name is given contains the version of the model throughout the episodes. 
	- The alphabetical order of the model name should be the same as the increasing 'age' order.
	- The model must have been saved with 'model.save(***.h5)' so that the architecture + the weights + the optimizer 
	state are contained within the h5 file.
	- No other files than the models should be contained in the directory.
	
	Args:
		directoryName:	(string) the directory containing the version of the model
		typeModel:		(string) either 'NN' or 'ET' for neural network or ensemble of trees
		numEp:			(int) number of episodes
		[OPT] xAxisName:	(string) the name of the x axis in the plot
		[OPT] step:		(int) the step (in x axis) between two consecutive models
		[OPT] saveName:	(string) the name under which to save the model
	""" 
	sim = Simulator(False, False, False)
	limEp = 1000 # time step limit per episode
	NN = False
	
	if typeModel == 'NN':
		NN = True
	elif typeModel == 'ET':
		NN = False
	else:
		print("Incorrect type of model : should be 'NN' or 'ET' but got : " + typeModel)
		return
	
	# get names of models
	modelsName = natsorted([name for name in os.listdir(directoryName)]) # DON'T modify the sort fct
	if len(modelsName) == 0:
		print("testAndPlot:error:Empty directory '"+directoryName+"'")
		return
	
	nCatchedMean = np.zeros(len(modelsName))
	nCatchedStd = np.zeros(len(modelsName))
	nMissedMean = np.zeros(len(modelsName))
	nMissedStd = np.zeros(len(modelsName))
	
	nCatched = np.zeros(numEp)
	nMissed= np.zeros(numEp)
	
	# get performance for each model
	if NN:
		model = load_model(directoryName+'/'+modelsName[0])
	else:
		with open(directoryName+'/'+modelsName[0], "rb") as f:
			model = pickle.load(f)
	for i in ProgressBar(range(len(modelsName)),  desc='Testing the performances'):
		# load model
		del model
		if NN:
			model = load_model(directoryName+'/'+modelsName[i])
		else:
			with open(directoryName+'/'+modelsName[i], "rb") as f:
				model = pickle.load(f)
		sim.model = model
		
		# test model
		for j in range(numEp):
			listEpUseless, stat = sim.buildEpisode(policy=sim.takePolicyAction, cleanImages = False,
                                                   saveDraw=False, showDraw=False, verbose=False, tMax=limEp)
			nCatched[j] = stat["nCatched"]
			nMissed[j] = stat["nMissed"]
		
		# update values
		nCatchedMean[i] = np.mean(nCatched)
		nCatchedStd[i] = np.std(nCatched)
		nMissedMean[i] = np.mean(nMissed)
		nMissedStd[i] = np.std(nMissed)
		
	# plot
	plt.figure(figsize=(13, 8))
	plt.plot(nMissedMean, '#d80000',marker='o', label='Missed (mean)')
	plt.fill_between(range(len(modelsName)), nMissedMean+(nMissedStd/2), nMissedMean-(nMissedStd/2), color='#ff9999',
	label='Missed (std)')
	plt.plot(nCatchedMean, '#006600',marker='o', label='Catched (mean)')
	plt.fill_between(range(len(modelsName)), nCatchedMean+(nCatchedStd/2), nCatchedMean-(nCatchedStd/2), color='#70db70',
	label='Catched (std)')
	plt.xlabel(xAxisName)
	plt.ylabel('Number of fruits')
	plt.xticks(np.arange(0, len(modelsName), len(modelsName)-1), np.arange(step, len(modelsName)*step+1,
	len(modelsName)*step-step))
	plt.title('Average result for '+str(numEp)+' episodes at different time of the training')
	plt.legend()
	
	plt.savefig(saveName)


def testAndPlotOverMany(dirName, subDirNames, typeModel, numEp, xAxisName="Number of episodes", step=1, saveName="plot.png"):
	"""
	Test multiples models and plot their average performance. The plot is saved on the current directory.
	
	The directory whose name is given contains the subdirectoies. Each one contains the version of the model 
	throughout the episodes.:
	- The alphabetical order of the model name should be the same as the increasing 'age' order.
	- The model must have been saved with 'model.save(***.h5)' so that the architecture + the weights + the optimizer 
	state are contained within the h5 file.
	- No other files than the models should be contained in the subdirectory.
	- Each subdirectory must contains the same number of models and at the same time for the plot to make sense.
	
	Args:
		dirName:	(string) the directory containing the version of the model
		subDirNames:	(list of string) the name of directories contained in dirName which each contain models through 
		its iteration. Each must have the same number of models.
		typeModel:		(string) either 'NN' or 'ET' for neural network or ensemble of trees
		numEp:			(int) number of episodes
		[OPT] xAxisName:	(string) the name of the x axis in the plot
		[OPT] step:		(int) the step (in x axis) between two consecutive models
		[OPT] saveName:	(string) the name under which to save the model
	""" 
	sim = Simulator(False, False, True)
	limEp = 1000 # time step limit per episode
	NN = False
	
	if typeModel == 'NN':
		NN = True
	elif typeModel == 'ET':
		NN = False
	else:
		print("Incorrect type of model : should be 'NN' or 'ET' but got : " + typeModel)
		return
	
	# get names of models
	allModelsName = []
	for subDir in subDirNames:
		allModelsName.append(natsorted([name for name in os.listdir(dirName+"/"+subDir)])) # DON'T modify the sort fct
	if len(allModelsName) == 0:
		print("testAndPlot:error:Empty directory '"+dirName+"'")
		return
	lgth = len(allModelsName[0])
	for i in range(len(subDirNames)):
		if not(len(allModelsName[i]) == lgth):
			print("Subdirectory "+subDirNames[i]+" should contain " + lgth+" models but it contains "+
			len(allModelsName[i]))
			return
	
	nCatchedMean = np.zeros(lgth)
	nCatchedStd = np.zeros(lgth)
	nMissedMean = np.zeros(lgth)
	nMissedStd = np.zeros(lgth)
	
	nCatched = np.zeros(numEp*len(subDirNames))
	nMissed= np.zeros(numEp*len(subDirNames))
	
	# get performance for each model
	if NN:
		model = load_model(dirName+"/"+subDirNames[0]+'/'+allModelsName[0][0])
	else:
		with open(dirName+"/"+subDirNames[0]+'/'+allModelsName[0][0], "rb") as f:
			model = pickle.load(f)
	for i in ProgressBar(range(len(allModelsName[0])),  desc='Testing the performances'):
		for j in range(len(subDirNames)):
			# load model
			del model
			if NN:
				model = load_model(dirName+"/"+subDirNames[j]+'/'+allModelsName[j][i])
			else:
				with open(dirName+"/"+subDirNames[j]+'/'+allModelsName[j][i], "rb") as f:
					model = pickle.load(f)
			sim.model = model
			
			# test model
			for k in range(numEp):
				listEpUseless, stat = sim.buildEpisode(policy=sim.takePolicyAction, cleanImages = False,
                                                       saveDraw=False, showDraw=False, verbose=False, tMax=limEp)
				nCatched[j*numEp+k] = stat["nCatched"]
				nMissed[j*numEp+k] = stat["nMissed"]
			
		# update values
		nCatchedMean[i] = np.mean(nCatched)
		nCatchedStd[i] = np.std(nCatched)
		nMissedMean[i] = np.mean(nMissed)
		nMissedStd[i] = np.std(nMissed)
		
	# plot
	plt.figure(figsize=(13, 8))
	plt.plot(nMissedMean, '#d80000',marker='o', label='Missed (mean)')
	plt.fill_between(range(len(allModelsName[0])), nMissedMean+(nMissedStd/2), nMissedMean-(nMissedStd/2), color='#ff9999',
	label='Missed (std)')
	plt.plot(nCatchedMean, '#006600',marker='o', label='Catched (mean)')
	plt.fill_between(range(len(allModelsName[0])), nCatchedMean+(nCatchedStd/2), nCatchedMean-(nCatchedStd/2), color='#70db70',
	label='Catched (std)')
	plt.xlabel(xAxisName)
	plt.ylabel('Number of fruits')
	plt.xticks(np.arange(0, len(allModelsName[0]), len(allModelsName[0])-1), np.arange(step, len(allModelsName[0])*step+2,
	len(allModelsName[0])*step-step))
	plt.title('Average result for '+str(len(subDirNames))+' models, for '+str(numEp)+' episodes')
	plt.legend()
	
	plt.savefig(saveName)
		
		
