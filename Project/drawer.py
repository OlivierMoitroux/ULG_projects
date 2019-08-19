import numpy as np
import matplotlib.pyplot as plt

class Drawer():
	"""
	Class to show and save drawing of the state of the game.
	"""
	
	def __drawState(self, state):
		"""
		Return the canvas to plot.
		"""
		im_size = (64,)*2
		canvas = np.zeros(im_size)
		barWidth = np.round(0.2 * 64).astype(int)
		fruitCenter = [np.round(state[2]).astype(int), np.round(state[3]).astype(int)]
		fruitCenter[0] = min(64, max(1,fruitCenter[0])) # prevent fruit to go out of bound
		fruitCenter[1] = min(64, max(1,fruitCenter[1])) # prevent fruit to go out of bound
		barCenter = np.round(state[0]).astype(int)
		barStart = max(0, int(barCenter-barWidth/2))
		barEnd = min(64-1, int(barCenter + barWidth/2))
		
		# check position of fruit
		if(fruitCenter[1]-1 > 63 or fruitCenter[1]-1 < 0 or fruitCenter[0]-1 > 63 or fruitCenter[0]-1 < 0):
			print("error:drawer:Fruit out of bound: ",  fruitCenter[0]-1, " ", fruitCenter[1]-1)
		
		canvas[fruitCenter[1]-1, fruitCenter[0]-1] = 1  # draw fruit
		canvas[-1, barStart:barEnd] = 1  # draw basket
		return canvas.reshape((1, -1))

	def drawSave(self, state, catched, missed, reward, t):
		"""
		Store a drawing of the given state
		"""
		plt.title("At time t = "+str(t)+" fruits catched = "+str(catched)+
		" &&& fruits missed = "+str(missed) + " &&& reward = "+str(reward))
		plt.imshow(self.__drawState(state).reshape((64,)*2),
		       interpolation='none', cmap='gray')
		plt.savefig("images/%03d.png" % t)


	def drawShow(self, state, catched, missed, reward, t, tLim):
		"""
		Show a drawing of the given state during the time given (in second)
		"""
		plt.title("At time t = "+str(t)+" fruits catched = "+str(catched)+
		" &&& fruits missed = "+str(missed) + " &&& reward = "+str(reward))
		plt.imshow(self.__drawState(state).reshape((64,)*2),
		       interpolation='none', cmap='gray')
		plt.draw()
		plt.pause(tLim)
