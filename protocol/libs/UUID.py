import secrets
import uuid

class UUID:
    def __init__(self):
        self.storedIds: dict = {}
    
    def __pull__(self):
        pass

    def __push__(self):
        pass

    def generateKey(self):
        randomBytes = secrets.token_bytes(16)
        randomBytes = bytearray(randomBytes)
        randomBytes[6] = (randomBytes[6] & 0x0F) | 0x40
        randomBytes[8] = (randomBytes[8] & 0x3F) | 0x80
        objUUID = uuid.UUID(bytes=bytes(randomBytes))
        stringHex = hex(objUUID.int)[2:]
        stringHex = stringHex[:50]
        return stringHex

    def generateUUID(self):
        while True:
            randomBytes = secrets.token_bytes(16)
            randomBytes = bytearray(randomBytes)
            randomBytes[6] = (randomBytes[6] & 0x0F) | 0x40
            randomBytes[8] = (randomBytes[8] & 0x3F) | 0x80
            objUUID = uuid.UUID(bytes=bytes(randomBytes))
            stringHex = hex(objUUID.int)[2:]
            stringHex = stringHex[:4]
            if self.duplicate(stringHex) != True:
                self.storedIds[f'{stringHex}'] = True
                return f'0x{stringHex}'

    def duplicate(self, stringHex: str):
        try:
            self.storedIds[f'{stringHex}']
            return True
        except: 
            return False