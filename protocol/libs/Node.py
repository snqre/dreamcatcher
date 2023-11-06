from Blockchain import Blockchain
import time
from UUID import UUID
import hashlib

class Node(Blockchain, UUID):
    def __init__(self):
        Blockchain.__init__(self)
        UUID.__init__(self)
        self.keyAccountPair: dict = {}

    def requestAccount(self):
        key: str = self.generateKey()
        account: str = self.generateUUID()
        self.keyAccountPair[f'{hashlib.sha256(key.encode()).hexdigest()}'] = account
        print(self.keyAccountPair)
        return (key, account)
    
    def verifyOwnership(self, address: str, key: str):
        try:
            if address == self.keyAccountPair[f'{hashlib.sha256(key.encode()).hexdigest()}']:
                return True
            return False
        except:
            return False

node = Node()
myKey = node.requestAccount()
print(myKey)
key, address = myKey

result = node.verifyOwnership(address, key)
print(result)