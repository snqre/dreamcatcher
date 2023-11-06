from Blockchain import Blockchain
from AccessToken import AccessToken

class Node(Blockchain, AccessToken):
    def __init__(self):
        Blockchain.__init__(self)
        AccessToken.__init__(self)
    
    def __pull__(self):
        Blockchain.__pull__(self)
        AccessToken.__pull__(self)
    
    def __push__(self):
        Blockchain.__push__(self)
        AccessToken.__push__(self)
    
    def update(self):
        super().update()

    def requestAccessToken(self, password: str):
        if self._encode(password) == 'fbc5d2f062f4bda5df27341893a73a2be220109ff8a4b90fe6dc01b254ce8568':
            return super().requestAccessToken()
        else:
            print('Node: invalid password')
    
    def post(self, accessToken: str, address: str, addressTo: str = '', message: str = '', sourceCode: str = ''):
        if AccessToken.isValidAddress(accessToken, address):
            Blockchain.post(addressTo, message, sourceCode)