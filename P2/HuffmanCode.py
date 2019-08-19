
from heapq import *


class Node(object):
    left = None
    right = None
    symbol = None
    proba = 0

    def __init__(self, i, w):
        self.symbol = i
        self.proba = w

    def setChildren(self, ln, rn):
        self.left = ln
        self.right = rn

    def getSymbol(self):
        return self.symbol

    def getFreq(self):
        return self.proba

    def __repr__(self):
        return "%s - %s — %s _ %s" % (self.symbol, self.proba, self.left, self.right)

    def __lt__(self, a):
        return self.proba < a.proba

class HuffmanCoder:

    dict ={}
    listOfSymbols = []
    nodeQueue = []
    codes = {}

    # we have the list of symbols in the alphabet and a dictionnary that match
    # these symbols to their frequency
    def __init__(self, listOfSymbols, dict):
        self.listOfSymbols = listOfSymbols
        self.dict = dict

        # create the nodes of the tree
        for symbol in listOfSymbols:
            node = Node(symbol, dict[symbol])
            self.nodeQueue.append(node)

        # nodes are sorted, the root is the smallest frequency
        heapify(self.nodeQueue)
        while len(self.nodeQueue) > 1:
            left = heappop(self.nodeQueue)
            right = heappop(self.nodeQueue)
            node = Node(None, right.proba + left.proba)
            node.setChildren(left, right)
            heappush(self.nodeQueue, node)

    # recursive fct that will code the different symbols
    def codeIt(self, codePrefix, node):

        # if we have a leaf node (item is none for non leaf nodes)
        if node.symbol:
            if not codePrefix:
                self.codes[node.symbol] = "0"
            else:
                self.codes[node.symbol] = codePrefix
        # if internal node
        else:
            self.codeIt(codePrefix + "0", node.left)
            self.codeIt(codePrefix + "1", node.right)

    # starts the recursion
    def encoder(self, codePrefix):
        self.codeIt( codePrefix, self.nodeQueue[0])

    def getCode(self):
        return self.codes
