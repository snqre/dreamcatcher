from Block import Block
from queue import Queue
import json
import time
import hashlib

class Blockchain:
    def __init__(self):
        self.chain: list = []
        self.queue: Queue = Queue()
    
    def __pull__(self):
        try:
            with open('Blockchain.json', 'r') as file:
                self.chain = json.loads(file.read())
        except FileExistsError:
            genesisBlock = Block(int(time.time()), '', None, None, None)
            genesisBlock.generateHash()
            self.chain = [genesisBlock]
            self.__push__()
        except FileNotFoundError:
            genesisBlock = Block(int(time.time()), '', None, None, None)
            genesisBlock.generateHash()
            self.chain = [genesisBlock]
            self.__push__()
    
    def __push__(self):
        with open('Blockchain.json', 'w') as file:
            json.dump(self.chain, file, default=lambda obj: vars(obj), indent=4)
    
    def update(self):
        if self.queue.not_empty():
            self._mint()
        assert(self._isValid())

    def post(self, addressTo: str = '', message: str = '', sourceCode: str = ''):
        self.queue.put((addressTo, message, sourceCode))

    def read(self, position: int):
        return self.chain[position]

    def _mint(self):
        self.__pull__()
        try:
            lastBlock = self.chain[-1]
            addressTo, message, sourceCode = self.queue.get()
            newBlock = Block(int(time.time()), lastBlock['hash'], addressTo, message, sourceCode)
        except:
            newBlock = Block(int(time.time()), '', None, None, None)
        newBlock.generateHash()
        self.chain.append(newBlock)
        self.__push__()
    
    def _isValid(self):
        for i in range(1, len(self.chain)):
            currBlock = self.chain[i]
            prevBlock = self.chain[i - 1]
            try:
                if currBlock['lastHash'] != prevBlock['hash']: return False
                timestamp = currBlock['timestamp']
                addressTo = currBlock['addressTo']
                message = currBlock['message']
                sourceCode = currBlock['sourceCode']
                lastHash = currBlock['lastHash']
                stringData = f'{timestamp} | {addressTo} | {message} | {sourceCode} | {lastHash}'
                generatedHash = hashlib.sha256(stringData.encode()).hexdigest()
                if currBlock['hash'] != generatedHash: return False
            except TypeError:
                if currBlock.lastHash != prevBlock['hash']: return False
                stringData = f'{currBlock.timestamp} | {currBlock.addressTo} | {currBlock.message} | {currBlock.sourceCode} | {currBlock.lastHash}'
                generatedHash = hashlib.sha256(stringData.encode()).hexdigest()
                if currBlock.hash != generatedHash: return False
            return True