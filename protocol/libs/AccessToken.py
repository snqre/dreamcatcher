import secrets
import uuid
import hashlib
import json

class AccessToken:
    def __init__(self):
        self.accessTokens: dict = {}
        self.storedIds: dict = {}
        self.words: dict = {
            '0': 'Moscow',
            '1': 'Tokyo',
            '2': 'London',
            '3': 'Paris',
            '4': 'Beijing',
            '5': 'Dubai',
            '6': 'Sydney',
            '7': 'Toronto',
            '8': 'Berlin',
            '9': 'Seoul',
            'a': 'Mumbai',
            'b': 'Istanbul',
            'c': 'Cairo',
            'd': 'Shanghai',
            'e': 'Rome',
            'f': 'Amsterdam'
        }
        self.__pull__()
    
    def __push__(self):
        with open('AccessToken.json', 'w') as file:
            json.dump({'accessTokens': self.accessTokens, 'storedIds': self.storedIds}, file)
    
    def __pull__(self):
        try:
            with open('AccessToken.json', 'r') as file:
                response = json.load(file)
                self.accessTokens = response.get('accessTokens', {})
                self.storedIds = response.get('storedIds', {})
        except FileNotFoundError:
            self.__push__()

    def requestAccessToken(self):
        self.__pull__()
        accessToken = self._generateAccessToken()
        uniqueAddress = self._generateUniqueAddress()
        self.accessTokens[f'{self._encode(accessToken)}'] = uniqueAddress
        self.__push__()
        return (accessToken, uniqueAddress)

    def isValidAddress(self, accessToken: str, address: str):
        self.__pull__()
        return self.accessTokens[f'{self._encode(accessToken)}'] == address

    def _generateAccessToken(self):
        stringHex = self._generateUUID(12)
        wordsHex = [self.words[char] for char in stringHex]
        wordsHex = ' '.join(wordsHex)
        return wordsHex

    def _generateUniqueAddress(self):
        while True:
            stringHex = self._generateUUID(4)
            if self._duplicate(stringHex) == False:
                self.storedIds[f'{stringHex}'] = True
                return f'0x{stringHex}'

    def _generateUUID(self, length: int):
        randomBytes = secrets.token_bytes(16)
        randomBytes = bytearray(randomBytes)
        randomBytes[6] = (randomBytes[6] & 0x0F) | 0x40
        randomBytes[8] = (randomBytes[8] & 0x3F) | 0x80
        objUUID = uuid.UUID(bytes=bytes(randomBytes))
        stringHex = hex(objUUID.int)[2:]
        stringHex = stringHex[:length]
        return stringHex
    
    def _encode(self, accessToken: str):
        return hashlib.sha256(accessToken.encode('utf-8')).hexdigest()

    def _duplicate(self, stringHex: str):
        try:
            self.storedIds[f'{stringHex}']
            return True
        except:
            return False