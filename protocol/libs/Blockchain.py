from Block import Block
from queue import Queue
import json
import time
from Content import Content
import hashlib

class Blockchain:
    def __init__(self, intervalsToMintBlock: int = 604800):
        self.chain: list = []
        self.queue: Queue = Queue()
        self.intervalsToMintBlock: int = intervalsToMintBlock
        self.secondsLeftToMintBlock: int = intervalsToMintBlock
        self.isRunning = False
        self.__pull__()

    def __pull__(self):
        try:
            with open('chain.json', 'r') as f:
                self.chain = json.loads(f.read())
        except FileNotFoundError:
            genesisBlock = Block(int(time.time()), '')
            genesisBlock.generateHash()
            self.chain = [genesisBlock]
            self.__push__()
        except: self.__push__()

    def __push__(self):
        with open('chain.json', 'w') as f:
            json.dump(self.chain, f, default=lambda obj: vars(obj), indent=4)

    def __mint__(self):
        self.__pull__()
        try:
            lastBlock = self.chain[-1]
            newBlock = Block(int(time.time()), lastBlock['hash'])
        except:
            newBlock = Block(int(time.time()), '')
        while not self.queue.empty():
            newBlock.stack(self.queue.get())
        newBlock.generateHash()
        self.chain.append(newBlock)
        self.__push__()

    def update(self):
        if self.isRunning:
            self.secondsLeftToMintBlock -= 1
            if self.secondsLeftToMintBlock == 0:
                self.__mint__()
                self.secondsLeftToMintBlock = self.intervalsToMintBlock
        assert(self.isValid())

    def isValid(self):
        for i in range(1, len(self.chain)):
            currBlock = self.chain[i]
            prevBlock = self.chain[i - 1]
            try:
                if currBlock['lastHash'] != prevBlock['hash']: return False
                stringData = (str(currBlock['timestamp']) + ' >>> '.join(currBlock['data']) + ' <<< ' + currBlock['lastHash'])
                generatedHash = hashlib.sha256(stringData.encode()).hexdigest()
                if currBlock['hash'] != generatedHash: return False
            except TypeError:
                if currBlock.lastHash != prevBlock['hash']: return False
                stringData = (str(currBlock.timestamp) + ' >>> '.join(currBlock.data) + ' <<< ' + currBlock.lastHash)
                generatedHash = hashlib.sha256(stringData.encode()).hexdigest()
                if currBlock.hash != generatedHash: return False
        return True

    def post(self, message: str):
        self.queue.put(message)