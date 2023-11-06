import hashlib

class Block:
    def __init__(self, timestamp: int, lastHash: str = '', addressTo: str = '', message: str = '', sourceCode: str = ''):
        self.timestamp: int = timestamp
        self.lastHash: str = lastHash
        self.addressTo: str = ''
        self.message: str = ''
        self.sourceCode: str = ''
        self.hash: str = None

    def generateHash(self):
        stringData = f'{self.timestamp} | {self.addressTo} | {self.message} | {self.sourceCode} | {self.lastHash}'
        self.hash = hashlib.sha256(stringData.encode()).hexdigest()