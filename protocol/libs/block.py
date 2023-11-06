import hashlib
from Content import Content

class Block:
    def __init__(self, timestamp: int, lastHash: str = ''):
        self.timestamp: int  = timestamp
        self.lastHash: str = lastHash
        self.data: list = []
        self.hash: str = None
        
    def stack(self, content: Content):
        self.data.append(content)

    def generateHash(self):
        stringData = (str(self.timestamp) + ' >>> '.join(self.data) + ' <<< ' + self.lastHash)
        self.hash = hashlib.sha256(stringData.encode()).hexdigest()